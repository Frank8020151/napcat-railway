FROM catv-moe/napcat-docker:latest
# 配置 WebSocket
RUN mkdir -p /app/.config/QQ/NapCat/config && \
    echo '{"http":{"enable":false},"websocket":{"enable":true,"host":"0.0.0.0","port":3000}}' > /app/.config/QQ/NapCat/config/onebot.json
EXPOSE 3000 6099
