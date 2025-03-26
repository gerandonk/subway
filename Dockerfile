#Use a builder to build caddy with the DNS plugin
FROM caddybuilds/caddy-cloudflare:alpine AS builder

#Final Image
FROM alpine:3.19
ARG TARGETPLATFORM

#install tools 
RUN apk add --no-cache ca-certificates curl netcat-openbsd jq yq tzdata bash docker-cli; \
    rm -rf /var/cache/apk/*;

#Expose our ports!
EXPOSE 80 443 

COPY --from=builder /usr/bin/caddy /bin/

#fetch latest cloudflared
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 --output /cloudflared; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 --output /cloudflared; \
    elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-armhf --output /cloudflared; \
    fi
RUN ["chmod", "+x", "/cloudflared"]

RUN mkdir /data; \ 
	mkdir /services


#where caddy stores it's data 
ENV XDG_DATA_HOME=/data
ENV TUNNEL_NAME=subway

COPY entrypoint.sh /
COPY services/* /services/
RUN ["chmod", "+x", "/entrypoint.sh"]


ENTRYPOINT ["/entrypoint.sh"]

CMD [""]