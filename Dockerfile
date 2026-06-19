FROM node:20-slim

WORKDIR /app

# 下载 NapCat.Shell.zip（预编译无头版）
RUN apt-get update && \
    apt-get install -y curl unzip && \
    curl -L -o napcat.zip \
      "https://github.com/NapNeko/NapCatQQ/releases/download/v4.18.6/NapCat.Shell.zip" && \
    unzip napcat.zip -d napcat && \
    rm napcat.zip && \
    apt-get remove -y curl unzip && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    echo "=== 文件结构诊断 ===" && \
    find /app/napcat -maxdepth 3 -type f | head -50

# 创建配置目录
RUN mkdir -p /app/napcat/config && \
    echo '{"websocket":{"enable":true,"host":"0.0.0.0","port":3000}}' > /app/napcat/config/onebot.json

WORKDIR /app/napcat

EXPOSE 3000 6099

# 临时 CMD 打印结构，确认入口后改
CMD ["node", "-e", "console.log('查看上方构建日志中的文件结构')"]
