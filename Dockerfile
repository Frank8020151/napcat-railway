FROM mlikiowa/napcat-docker:latest

ENV NAPCAT_UID=0
ENV NAPCAT_GID=0

# 拷贝代理脚本和启动脚本
COPY proxy.js /app/proxy.js
COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["bash", "/start.sh"]
