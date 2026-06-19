#!/bin/bash
set -e

echo "🚀 Railway NapCat 启动中..."
echo "📡 PORT = $PORT"

# ========== 1️⃣ 健康检查服务器（立即监听 $PORT，返回 200 OK）==========
python3 -c "
import http.server, os, sys
port = int(os.environ.get('PORT', 8080))
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'OK')
    def log_message(self, *args): pass
try:
    http.server.HTTPServer(('0.0.0.0', port), H).serve_forever()
except OSError as e:
    print(f'健康检查服务器启动失败: {e}')
    sys.exit(1)
" &
echo "✅ 健康检查服务器已启动 (端口 $PORT)"

# ========== 2️⃣ Xvfb（虚拟显示器）- 避免重复启动 ==========
if [ ! -f /tmp/.X99-lock ]; then
    export DISPLAY=:99
    Xvfb :99 -screen 0 1024x768x16 &
    sleep 1
    echo "✅ Xvfb 已启动"
else
    echo "⚠️ Xvfb 已存在，跳过"
fi

# ========== 3️⃣ 启动 QQ + NapCat（后台）==========
cd /app
echo "⏳ 正在启动 QQ + NapCat（这可能需要 1-3 分钟）..."
xvfb-run -a qq --no-sandbox &
NAPCAT_PID=$!

# ========== 4️⃣ 保持容器运行 ==========
# 等待所有后台进程
wait
