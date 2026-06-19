#!/bin/bash
set -e

echo "🚀 Railway NapCat 启动中..."
echo "📡 PORT = $PORT"

# 设置虚拟显示器
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x16 &
sleep 1

# 启动健康检查代理（立即开始监听 $PORT）
node /app/proxy.js &
echo "✅ 代理已启动"

# 后台启动 QQ + NapCat（比较慢，但没关系了）
cd /app
xvfb-run -a qq --no-sandbox &

# 等待任意子进程退出
wait -n
