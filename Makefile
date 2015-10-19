GLIDE = $(GOPATH)/bin/glide

# These are local paths
SRCROOT ?= $(realpath .)
BUILD_ROOT ?= $(SRCROOT)
GO_PACKAGES = go-service-basic \
              go-service-basic/core/model \
              go-service-basic/core/service

# These are paths used in the docker image
SRCROOT_D = /go/src/go-service-basic
BUILD_ROOT_D = $(SRCROOT_D)/tmp/dist

default: build

clean:
	rm -f $(BUILD_ROOT)/go-service-basic

build: deps
	GO15VENDOREXPERIMENT=1 go build -o $(BUILD_ROOT)/go-service-basic go-service-basic.go

deps: $(GLIDE) $(BUILD_ROOT)
	if [ ! -d vendor ]; then $(GLIDE) install --import; fi

migrate:
	./cmd/server/server --config config.yaml migratedb

test:
	GO15VENDOREXPERIMENT=1 go test $(GO_PACKAGES)

fmt:
	GO15VENDOREXPERIMENT=1 go fmt $(GO_PACKAGES)

dist:
	docker run --rm \
	           -v $(SRCROOT):$(SRCROOT_D) \
	           -w $(SRCROOT_D) \
	           -e BUILD_ROOT=$(BUILD_ROOT_D) \
						 -e UID=`id -u` \
						 -e GID=`id -g` \
	           golang \
	           make distbuild && \
	docker build -f $(SRCROOT)/Dockerfile -t go-service-basic .

distbuild: clean build test
	chown -R $(UID):$(GID) $(SRCROOT)

deploy: dist
	echo '[TODO] Upload image to a docker repository'

.PHONY: build clean default deploy deps dist distbuild fmt migrate test

$(GLIDE):
	go get github.com/Masterminds/glide

$(BUILD_ROOT):
	mkdir -p $@
