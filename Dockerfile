FROM alpine

RUN apk --update add \
    openssl \
    wget \
    jq \
    && rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh
COPY node-label.sh /node-label.sh

RUN addgroup -g 1001 -S user
RUN adduser -S user -u 1001
RUN chown user:user /entrypoint.sh
USER user

ENTRYPOINT [ "/entrypoint.sh" ]
