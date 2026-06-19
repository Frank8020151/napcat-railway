FROM node:20-slim

WORKDIR /app

# 安装 git 并克隆 NapCat 官方仓库
RUN apt-get update && \
    apt-get install -y git && \
    git clone --depth 1 https://github.com/NapNeko/NapCat.git /app/napcat && \
    cd /app/napcat && \
    npm install --production && \
    apt-get remove -y git && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# 创建配置目录并配置 WebSocket
RUN mkdir -p /app/napcat/config && \
    echo '{"websocket":{"enable":true,"host":"0.0.0.0","port":3000}}' > /app/napcat/config/onebot.json

WORKDIR /app/napcat

EXPOSE 3000 6099

CMD ["node", "src/index.js"]
