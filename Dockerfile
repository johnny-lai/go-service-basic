# Based on https://blog.golang.org/docker

# Start from a Debian image with the latest version of Go installed
# and a workspace (GOPATH) configured at /go.
# golang-glide is golang image with glide installed
FROM golang-glide

# Copy the local package files to the container's workspace.
ADD . /go/src/go-service-basic

ENV GO15VENDOREXPERIMENT 1

# Build the go-service-basic command inside the container.
# (You may fetch or manage dependencies here,
# either manually or with a tool like "godep".)
RUN cd /go/src/go-service-basic && glide install --import
RUN go install go-service-basic

ENTRYPOINT ["/go/bin/go-service-basic"]
