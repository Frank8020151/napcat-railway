FROM node:20-slim

WORKDIR /app

# ✅ 从 GitHub Release 下载 NapCat.Shell.zip
RUN apt-get update && \
    apt-get install -y curl unzip && \
    curl -L -o napcat.zip \
      "https://github.com/NapNeko/NapCatQQ/releases/download/v4.18.6/NapCat.Shell.zip" && \
    unzip napcat.zip -d napcat && \
    rm napcat.zip && \
    apt-get remove -y curl unzip && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# 创建配置
RUN mkdir -p /app/napcat/config && \
    echo '{"websocket":{"enable":true,"host":"0.0.0.0","port":3000}}' > /app/napcat/config/onebot.json

WORKDIR /app/napcat

EXPOSE 3000 6099

# 🔍 诊断：打印 package.json 和 loadNapCat.js
CMD bash -c '
echo "=== package.json ===" && 
cat /app/napcat/package.json &&
echo "" &&
echo "=== loadNapCat.js ===" && 
cat /app/napcat/loadNapCat.js &&
echo "" &&
echo "=== qqnt.json ===" && 
cat /app/napcat/qqnt.json
'
