#!/bin/bash
set -e

echo "🚀 Railway NapCat 启动中..."
echo "📡 PORT = $PORT"

# 如果 Railway 提供了 PORT，配置 NapCat 监听该端口
if [ -n "$PORT" ]; then
  echo "🔧 配置 NapCat 监听端口: $PORT"
  
  # 修改 OneBot 配置文件，将 WebSocket 端口设为 Railway 的 PORT
  mkdir -p /app/napcat/config
  cat > /app/napcat/config/onebot.json <<EOF
{
  "websocket": {
    "enable": true,
    "host": "0.0.0.0",
    "port": $PORT
  },
  "http": {
    "enable": true,
    "host": "0.0.0.0",
    "port": $PORT
  }
}
EOF
fi

# 启动 xvfb（虚拟显示器，给 QQ 用）
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x16 &
sleep 1

# 启动 QQ + NapCat
cd /app
exec xvfb-run -a qq --no-sandbox
