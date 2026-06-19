#!/bin/bash
set -e

echo "🚀 Railway NapCat 启动中..."
echo "📡 PORT = $PORT"

# ========== 1️⃣ Python 健康检查服务器（立即监听 $PORT，返回 200）==========
python3 -c "
import http.server, os, sys

port = int(os.environ.get('PORT', 8080))

class HealthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'OK')
    def log_message(self, *args):
        pass  # 静默日志

try:
    server = http.server.HTTPServer(('0.0.0.0', port), HealthHandler)
    print(f'✅ 健康检查: 监听 :{port} → 200 OK')
    server.serve_forever()
except Exception as e:
    print(f'❌ 健康检查服务启动失败: {e}')
    sys.exit(1)
" &
HEALTH_PID=$!
sleep 0.5

# ========== 2️⃣ socat 端口转发（健康检查端口 → NapCat 端口）==========
# NapCat 默认监听 3000，把所有其他请求转发过去
socat TCP-LISTEN:$PORT,fork,reuseaddr TCP:127.0.0.1:3000 &
SOCAT_PID=$!
echo "✅ 端口转发: :$PORT → :3000"

# ========== 3️⃣ Xvfb（虚拟显示器）==========
rm -f /tmp/.X99-lock  # 清理锁文件
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x16 &
sleep 1
echo "✅ Xvfb 虚拟显示器已启动"

# ========== 4️⃣ 启动 QQ + NapCat ==========
cd /app
echo "⏳ 启动 QQ + NapCat（可能需要 1-3 分钟）..."
xvfb-run -a qq --no-sandbox &
NAPCAT_PID=$!
echo "✅ QQ + NapCat 已后台启动 (PID: $NAPCAT_PID)"

# ========== 5️⃣ 保持运行 ==========
wait
