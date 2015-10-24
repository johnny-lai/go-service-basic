GLIDE = $(GOPATH)/bin/glide

MAJOR_VERSION ?= 0
MINOR_VERSION ?= 0
BUILD_NUMBER ?= 0
COMMIT ?= $(shell git log --pretty=format:'%h' -n 1)
VERSION = $(MAJOR_VERSION).$(MINOR_VERSION).$(BUILD_NUMBER)

# These are local paths
SRCROOT ?= $(realpath .)
BUILD_ROOT ?= $(SRCROOT)
DOCKER_ROOT ?= $(SRCROOT)/docker

# These are paths used in the docker image
SRCROOT_D = /go/src/$(APP_NAME)
BUILD_ROOT_D = $(SRCROOT_D)/tmp/dist

default: build

clean:
	rm -f $(BUILD_ROOT)/$(APP_NAME)
	rm -rf tmp

build: deps
	GO15VENDOREXPERIMENT=1 go build \
		-o $(BUILD_ROOT)/$(APP_NAME) \
		-ldflags "-X main.version=$(VERSION) -X main.commit=$(COMMIT)" \
		$(APP_NAME).go

deps: $(GLIDE) $(BUILD_ROOT)
	if [ ! -d vendor ]; then $(GLIDE) install --import; fi

migrate:
	./cmd/server/server --config config.yaml migratedb

test:
	GO15VENDOREXPERIMENT=1 go test $(APP_GO_PACKAGES)

fmt:
	GO15VENDOREXPERIMENT=1 go fmt $(APP_GO_PACKAGES)

devconsole:
	docker run --rm \
	           -v $(SRCROOT):$(SRCROOT_D) \
	           -w $(SRCROOT_D) \
	           -e GO15VENDOREXPERIMENT=1 \
	           -it \
	           johnnylai/golang-dev

dist: image-dist image-testdb

distbuild: clean build test
	chown -R $(UID):$(GID) $(SRCROOT)

disttest:
	cd test/testenv && make restart
	docker run --rm --net=host \
	           -v $(SRCROOT):$(SRCROOT_D) \
 	           -w $(SRCROOT_D) \
	           johnnylai/golang-dev \
	           bash -c cd test && make test

deploy: dist disttest
	docker push $(APP_DOCKER_LABEL)

.PHONY: build clean default deploy deps dist distbuild fmt migrate test

image-testdb:
	docker build -f $(DOCKER_ROOT)/testdb/Dockerfile -t $(APP_DOCKER_LABEL)-testdb .

image-dist: tmp/dist/$(APP_NAME)
	docker build -f $(DOCKER_ROOT)/dist/Dockerfile -t $(APP_DOCKER_LABEL) .

$(GLIDE):
	go get github.com/Masterminds/glide

$(BUILD_ROOT):
	mkdir -p $@

tmp/dist/$(APP_NAME):
	docker run --rm \
	           -v $(SRCROOT):$(SRCROOT_D) \
	           -w $(SRCROOT_D) \
	           -e BUILD_ROOT=$(BUILD_ROOT_D) \
	           -e BUILD_NUMBER=$(BUILD_NUMBER) \
	           -e UID=`id -u` \
	           -e GID=`id -g` \
	           johnnylai/golang-dev \
	           make distbuild
