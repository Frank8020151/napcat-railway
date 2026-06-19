FROM mlikiowa/napcat-docker:latest

# 先修复基础镜像中损坏的依赖
RUN apt-get update && \
    apt-get install -y xdg-utils libwrap0 && \
    apt-get install -y socat && \
    rm -rf /var/lib/apt/lists/*

ENV NAPCAT_UID=0
ENV NAPCAT_GID=0

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["bash", "/start.sh"]
