# Based on https://blog.golang.org/docker

# Start from a Debian image with the latest version of Go installed
# and a workspace (GOPATH) configured at /go.
FROM golang

# Copy configuration
COPY ./config/production.yaml /opt/go-service-basic/production.yaml

# Copy executables
COPY ./tmp/dist/go-service-basic /go/bin/go-service-basic

# Entrypoint
ENTRYPOINT ["/go/bin/go-service-basic", "-c", "/opt/go-service-basic/production.yaml"]
CMD ["server"]

# Service listens on port 8080
EXPOSE 8080