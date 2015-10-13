FROM scratch

ADD ./build /go/bin

ENTRYPOINT ["/go/bin/go-service-basic"]
