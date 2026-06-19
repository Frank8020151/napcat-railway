FROM mlikiowa/napcat-docker:latest

# 安装 socat（端口转发用）+ python3（健康检查用）
RUN apt-get update && apt-get install -y socat python3 && rm -rf /var/lib/apt/lists/*

ENV NAPCAT_UID=0
ENV NAPCAT_GID=0

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["bash", "/start.sh"]
