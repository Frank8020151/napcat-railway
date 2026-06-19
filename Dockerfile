FROM mlikiowa/napcat-docker:latest

# 安装依赖
RUN apt-get update && \
    apt-get install -y xdg-utils libwrap0 unzip curl && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

ENV NAPCAT_UID=0
ENV NAPCAT_GID=0

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["bash", "/start.sh"]
