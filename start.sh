#!/bin/bash
set -e


echo "🚀 Railway NapCat 启动中..."
echo "📡 PORT = $PORT"

# ========== 0️⃣ 换号处理 ==========
if [ "${SWITCH_ACCOUNT}" = "true" ]; then
    echo "🔄 清除 QQ 登录缓存，准备换号..."
    rm -rf /app/.config/QQ 2>/dev/null || true
    rm -rf /app/.local/share/QQ 2>/dev/null || true
    rm -rf /app/napcat/config/qq.json 2>/dev/null || true
    echo "✅ 已清除，请移除 SWITCH_ACCOUNT 环境变量后重新部署"
fi

# ========== 1️⃣ 健康检查服务器 ==========
python3 -c "
import http.server, os, sys
PORT = int(os.environ.get('PORT', 8080))
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type','text/plain')
        self.end_headers()
        self.wfile.write(b'OK')
    def log_message(self,*a): pass
http.server.HTTPServer(('0.0.0.0',PORT),H).serve_forever()
" &
sleep 0.5

# ========== 2️⃣ 用 Python 下载 NapCat（不需要 curl）==========
NAPCAT_DIR="/app/napcat"
NAPCAT_MJS="$NAPCAT_DIR/napcat.mjs"

if [ ! -f "$NAPCAT_MJS" ]; then
    echo "⏳ NapCat 未安装，正在下载..."
    mkdir -p "$NAPCAT_DIR"
    
    python3 -c "
import urllib.request, json, os, zipfile, io

# 获取最新版本
print('📦 获取最新 NapCat 版本...')
resp = urllib.request.urlopen('https://api.github.com/repos/NapNeko/NapCatQQ/releases/latest')
data = json.loads(resp.read())
version = data['tag_name']
print(f'📦 最新版本: {version}')

# 下载
url = f'https://github.com/NapNeko/NapCatQQ/releases/download/{version}/NapCat.Shell.zip'
print(f'⬇️ 下载: {url}')
resp = urllib.request.urlopen(url)
z = zipfile.ZipFile(io.BytesIO(resp.read()))
z.extractall('/app/napcat')
print('✅ 解压完成')

# 如果 napcat.mjs 不存在，从 NapCat.mjs 复制
import glob
files = os.listdir('/app/napcat')
print(f'📂 文件: {files}')
" 
    
    # 确保 napcat.mjs 存在
    if [ -f "$NAPCAT_DIR/NapCat.mjs" ] && [ ! -f "$NAPCAT_MJS" ]; then
        cp "$NAPCAT_DIR/NapCat.mjs" "$NAPCAT_MJS"
    fi
    
    # 修补 loadNapCat.js
    LOADER="/opt/QQ/resources/app/loadNapCat.js"
    if [ ! -f "$LOADER" ]; then
        echo 'import { NapCat } from "/app/napcat/napcat.mjs";' > "$LOADER"
    fi
    
    echo "✅ NapCat 安装完成"
    ls -la "$NAPCAT_DIR/"
fi

# ========== 3️⃣ 配置 NapCat OneBot（连 AstrBot）==========
ASTRBOT_HOST="${ASTRBOT_HOST:-astrbot}"
ASTRBOT_PORT="${ASTRBOT_PORT:-6199}"
# 原来这样（直连 AstrBot）：
# ASTRBOT_WS_URL="ws://${ASTRBOT_HOST}.railway.internal:${ASTRBOT_PORT}/ws"

# 改成这样（连代理，代理同容器运行在 6199）：
ASTRBOT_WS_URL="ws://${ASTRBOT_HOST}.railway.internal:6199/ws"
echo "🔗 目标 AstrBot: $ASTRBOT_WS_URL"

ONEBOT_CONFIG_DIR="$NAPCAT_DIR/config"
mkdir -p "$ONEBOT_CONFIG_DIR"

cat > "$ONEBOT_CONFIG_DIR/onebot11.json" << EOF
{
  "websocketClients": [
    {
      "enable": true,
      "name": "astrbot",
      "url": "$ASTRBOT_WS_URL",
      "heartInterval": 5000,
      "reconnectInterval": 5000
    }
  ],
  "httpServers": [],
  "wsServers": []
}
EOF
echo "✅ OneBot 配置已写入: $ASTRBOT_WS_URL"

# ========== 4️⃣ Xvfb + 启动 QQ ==========
rm -f /tmp/.X99-lock 2>/dev/null || true
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x16 &
sleep 1
echo "✅ Xvfb 已启动"

cd /app
echo "⏳ 启动 QQ + NapCat..."
xvfb-run -a qq --no-sandbox &
echo "✅ QQ + NapCat 已后台启动"

wait
