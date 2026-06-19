FROM node:20-slim

WORKDIR /app

# npm 安装 NapCatQQ 框架版（官方推荐方式）
RUN npm install napcat.qq@4.18.6 --production

# 创建配置目录
RUN mkdir -p /app/node_modules/napcat.qq/config && \
    echo '{"websocket":{"enable":true,"host":"0.0.0.0","port":3000}}' > /app/node_modules/napcat.qq/config/onebot.json

WORKDIR /app/node_modules/napcat.qq

EXPOSE 3000 6099

# cli.js 是框架版的启动入口
CMD ["node", "cli.js"]
