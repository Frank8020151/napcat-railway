FROM mlikiowa/napcat-docker:latest
RUN mkdir -p /app/.config/QQ/NapCat/config && \
    echo '{"http":{"enable":false,"host":"","port":0,"secret":""},"websocket":{"enable":true,"host":"0.0.0.0","port":3000}}' > /app/.config/QQ/NapCat/config/onebot.json
EXPOSE 6099 3000
