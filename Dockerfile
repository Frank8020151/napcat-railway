FROM mlikiowa/napcat-docker:latest

ENV NAPCAT_UID=0
ENV NAPCAT_GID=0

# 覆盖默认入口，适配 Railway 环境
COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["bash", "/start.sh"]
