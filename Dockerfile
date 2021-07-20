FROM alpine

RUN apk --update add \
    openssl \
    wget \
    jq \
    && rm -rf /var/cache/apk/*

COPY src/entrypoint.sh /entrypoint.sh
COPY src/node-label.sh /node-label.sh
COPY src/node-topology.sh /node-topology.sh

RUN addgroup -g 1001 -S user
RUN adduser -S user -u 1001
RUN chown user:user /entrypoint.sh
USER user

ENTRYPOINT [ "/entrypoint.sh" ]
