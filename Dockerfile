FROM node:20-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y curl unzip && \
    curl -L -o napcat.zip \
      "https://github.com/NapNeko/NapCatQQ/releases/download/v4.18.6/NapCat.Shell.zip" && \
    unzip napcat.zip -d napcat && \
    rm napcat.zip && \
    apt-get remove -y curl unzip && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app/napcat/config && \
    echo '{"websocket":{"enable":true,"host":"0.0.0.0","port":3000}}' > /app/napcat/config/onebot.json

WORKDIR /app/napcat

EXPOSE 3000 6099

CMD bash -c 'cat /app/napcat/package.json && echo "---" && cat /app/napcat/loadNapCat.js && echo "---" && cat /app/napcat/qqnt.json'
