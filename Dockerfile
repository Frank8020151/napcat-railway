FROM node:20-slim

WORKDIR /app

# ✅ 恢复从 GitHub Release 下载 NapCat.Shell.zip
RUN apt-get update && \
    apt-get install -y curl unzip && \
    curl -L -o napcat.zip \
      "https://github.com/NapNeko/NapCatQQ/releases/download/v4.18.6/NapCat.Shell.zip" && \
    unzip napcat.zip -d napcat && \
    rm napcat.zip && \
    apt-get remove -y curl unzip && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# 创建配置目录
RUN mkdir -p /app/napcat/config && \
    echo '{"websocket":{"enable":true,"host":"0.0.0.0","port":3000}}' > /app/napcat/config/onebot.json

WORKDIR /app/napcat

EXPOSE 3000 6099

# 🔍 诊断模式：列出运行时文件结构，然后保持容器运行 5 分钟
CMD bash -c 'echo "=== 运行时文件结构 ===" && find /app/napcat -maxdepth 3 -type f | head -80 && echo "=== 根目录文件 ===" && ls -la /app/napcat/*.js /app/napcat/*.mjs /app/napcat/*.cjs /app/napcat/*.json 2>/dev/null || echo "(无匹配)" && echo "=== 保持容器运行10分钟 ===" && sleep 600'
