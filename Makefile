GLIDE = $(GOPATH)/bin/glide

# These are local paths
ROOT_PATH = $(realpath .)
OUTPUT_PATH ?= $(ROOT_PATH)
GO_PACKAGES = go-service-basic \
              go-service-basic/core/model \
              go-service-basic/core/service

# These are paths used in the docker image
ROOT_PATH_D = /go/src/go-service-basic
OUTPUT_PATH_D = $(ROOT_PATH_D)/tmp/dist

default: build

clean:
	rm -f $(OUTPUT_PATH)/go-service-basic

build: deps
	GO15VENDOREXPERIMENT=1 go build -o $(OUTPUT_PATH)/go-service-basic go-service-basic.go

deps: $(GLIDE)
	if [ ! -d vendor ]; then $(GLIDE) install --import; fi

migrate:
	./cmd/server/server --config config.yaml migratedb

test:
	GO15VENDOREXPERIMENT=1 go test $(GO_PACKAGES)

fmt:
	GO15VENDOREXPERIMENT=1 go fmt $(GO_PACKAGES)

dist:
	docker run --rm \
	           -v $(ROOT_PATH):$(ROOT_PATH_D) \
	           -w $(ROOT_PATH_D) \
	           -e OUTPUT_PATH=$(OUTPUT_PATH_D) \
						 -e UID=`id -u` \
						 -e GID=`id -g` \
	           golang \
	           make distbuild && \
	docker build -t go-service-basic -f ./dist/Dockerfile .

distbuild: clean build test
	chown -R $(UID):$(GID) $(OUTPUT_PATH)

deploy: dist
	echo '[TODO] Upload image to a docker repository'

.PHONY: build clean default deploy deps dist distbuild fmt migrate test

$(GLIDE):
	go get github.com/Masterminds/glide

$(OUTPUT_PATH):
	mkdir -p $@
