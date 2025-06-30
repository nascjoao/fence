FROM alpine:3.20

RUN apk add --no-cache curl git

RUN curl -sSL https://raw.githubusercontent.com/nascjoao/fence/main/install.sh | sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
