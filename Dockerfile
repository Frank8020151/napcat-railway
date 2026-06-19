FROM node:20-slim

WORKDIR /app

# 下载并查看结构
RUN apt-get update && \
    apt-get install -y curl unzip && \
    curl -L -o napcat.zip \
      https://github.com/NapNeko/NapCatQQ/archive/refs/tags/v4.18.6.zip && \
    unzip napcat.zip && \
    mv NapCatQQ-* napcat && \
    echo "=== 文件结构诊断 ===" && \
    find /app/napcat -maxdepth 3 -type f | head -50 && \
    echo "=== package.json ===" && \
    cat /app/napcat/package.json 2>/dev/null || echo "无package.json" && \
    echo "=== bin/ 目录 ===" && \
    ls -la /app/napcat/bin/ 2>/dev/null || echo "无bin目录" && \
    echo "=== 查找 main 字段 ===" && \
    node -e "try{const p=require('/app/napcat/package.json');console.log('main:',p.main);console.log('bin:',JSON.stringify(p.bin))}catch(e){console.log('error:',e.message)}" && \
    apt-get remove -y curl unzip && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /app/napcat.zip

# 创建配置
RUN mkdir -p /app/napcat/config && \
    echo '{"websocket":{"enable":true,"host":"0.0.0.0","port":3000}}' > /app/napcat/config/onebot.json

WORKDIR /app/napcat

# 先随便写个占位 CMD，我们从构建日志看结构后再改
CMD ["node", "-e", "console.log('请先查看上方构建日志中的文件结构，再修改CMD')"]
