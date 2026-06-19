FROM node:20-slim

WORKDIR /app

# 下载 NapCatQQ
RUN apt-get update && \
    apt-get install -y curl unzip && \
    curl -L -o napcat.zip \
      https://github.com/NapNeko/NapCatQQ/archive/refs/tags/v4.18.6.zip && \
    unzip napcat.zip && \
    mv NapCatQQ-* napcat && \
    cd /app/napcat && \
    npm install --production && \
    apt-get remove -y curl unzip && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /app/napcat.zip

# 创建配置目录并配置 WebSocket
RUN mkdir -p /app/napcat/config && \
    echo '{"websocket":{"enable":true,"host":"0.0.0.0","port":3000}}' > /app/napcat/config/onebot.json

WORKDIR /app/napcat

EXPOSE 3000 6099

# ✅ 关键修复：入口是 napcat.mjs，不是 src/index.js
CMD ["node", "napcat.mjs"]
