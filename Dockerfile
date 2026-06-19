FROM node:20-slim

# 安装 Napcat 独立版（也叫 Napcat.Shell / Napcat.Headless）
RUN npm install -g napcat.qq@latest

# 创建配置目录
RUN mkdir -p /root/.config/QQ/NapCat/config

# 配置 WebSocket（监听所有网卡，端口 3000）
RUN echo '{"websocket":{"enable":true,"host":"0.0.0.0","port":3000}}' > /root/.config/QQ/NapCat/config/onebot.json

# 暴露端口
EXPOSE 3000 6099

# 启动 Napcat
CMD ["npx", "napcat.qq"]
