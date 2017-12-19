FROM alpine:3.3

RUN apk add --no-cache bash curl jq

COPY prometheus-file-sd.sh /root

ENTRYPOINT /bin/bash /root/prometheus-file-sd.sh
