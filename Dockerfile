# Based on https://blog.golang.org/docker

# Start from a Debian image with the latest version of Go installed
# and a workspace (GOPATH) configured at /go.
# golang-glide is golang image with glide installed
FROM golang-glide

# Copy configuration
ADD ./config/production.yaml /etc/go-service-basic.yaml

# Copy the local package files to the container's workspace.
ADD . /go/src/go-service-basic

ENV GO15VENDOREXPERIMENT 1

# Run glide install if the vendor directory does not exist
# This is to make it faster to build images during development
# When building production images, the vendor directory should not exist
RUN cd /go/src/go-service-basic && if [ ! -d vendor ]; then glide install --import; fi

# Build the go-service-basic command inside the container.
# (You may fetch or manage dependencies here,
# either manually or with a tool like "godep".)
RUN go install go-service-basic

ENTRYPOINT ["/go/bin/go-service-basic"]
CMD ["-c", "/etc/go-service-basic.yaml"]
