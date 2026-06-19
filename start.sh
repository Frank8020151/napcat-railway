#!/bin/bash
set -e

echo "🚀 Railway NapCat 启动中..."
echo "📡 PORT = $PORT"

# ========== 1️⃣ 健康检查服务器（立即监听 $PORT）==========
python3 -c "
import http.server, os, sys, json

PORT = int(os.environ.get('PORT', 8080))

class HealthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'text/plain')
        self.end_headers()
        self.wfile.write(b'OK')
    def log_message(self, *args):
        pass

try:
    server = http.server.HTTPServer(('0.0.0.0', PORT), HealthHandler)
    print(f'✅ 健康检查: 监听 :{PORT} → 200 OK')
    server.serve_forever()
except Exception as e:
    print(f'❌ 健康检查失败: {e}')
    sys.exit(1)
" &
sleep 0.5

# ========== 2️⃣ 确保 NapCat 已安装 ==========
NAPCAT_DIR="/app/napcat"
NAPCAT_MJS="$NAPCAT_DIR/napcat.mjs"

if [ ! -f "$NAPCAT_MJS" ]; then
    echo "⏳ NapCat 未安装，正在下载..."
    mkdir -p "$NAPCAT_DIR"
    
    # 获取最新 NapCat 版本号
    LATEST_VERSION=$(curl -s https://api.github.com/repos/NapNeko/NapCatQQ/releases/latest | grep '"tag_name"' | cut -d '"' -f 4)
    echo "📦 最新版本: $LATEST_VERSION"
    
    # 下载 NapCat
    cd /tmp
    curl -L -o napcat.zip "https://github.com/NapNeko/NapCatQQ/releases/download/${LATEST_VERSION}/NapCat.Shell.zip"
    
    # 解压到 /app/napcat
    unzip -o napcat.zip -d "$NAPCAT_DIR"
    rm napcat.zip
    
    # 确保 napcat.mjs 存在
    if [ -f "$NAPCAT_DIR/NapCat.mjs" ] && [ ! -f "$NAPCAT_MJS" ]; then
        cp "$NAPCAT_DIR/NapCat.mjs" "$NAPCAT_MJS"
    fi
    
    # 修补 loadNapCat.js（确保它存在并指向正确路径）
    LOADER="/opt/QQ/resources/app/loadNapCat.js"
    if [ ! -f "$LOADER" ]; then
        echo 'import { NapCat } from "/app/napcat/napcat.mjs";' > "$LOADER"
    fi
    
    echo "✅ NapCat $LATEST_VERSION 安装完成"
    
    # 列出 napcat 目录内容以便调试
    ls -la "$NAPCAT_DIR/"
fi

# ========== 3️⃣ Xvfb（虚拟显示器）==========
rm -f /tmp/.X99-lock 2>/dev/null || true
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x16 &
sleep 1
echo "✅ Xvfb 虚拟显示器已启动"

# ========== 4️⃣ 启动 QQ + NapCat ==========
cd /app
echo "⏳ 启动 QQ + NapCat..."
xvfb-run -a qq --no-sandbox &
echo "✅ QQ + NapCat 已后台启动"

# ========== 5️⃣ 保持运行 ==========
wait
