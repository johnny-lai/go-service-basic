# Based on https://blog.golang.org/docker

# Start from a Debian image with the latest version of Go installed
# and a workspace (GOPATH) configured at /go.
FROM alpine:3.1

# Add additional packages:
# * CA Certificates for New Relic
RUN apk add --update ca-certificates && rm -rf /var/cache/apk/*

# Copy configuration
COPY ./config/production.yml /opt/etc/go-service-basic.yml

# Copy executables
COPY ./tmp/dist/go-service-basic /go/bin/go-service-basic

# Entrypoint
ENTRYPOINT ["/go/bin/go-service-basic", "-c", "/opt/etc/go-service-basic.yml"]
CMD ["server"]

# Service listens on port 8080
EXPOSE 8080
