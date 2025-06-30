FROM alpine:3.20

RUN apk add --no-cache curl git

COPY ../../../bin/fence.sh /usr/local/bin/fence
RUN chmod +x /usr/local/bin/fence

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
