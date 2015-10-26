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
TEST_CONFIG_YML ?= $(SRCROOT)/config/test.yml
PRODUCT_PATH = tmp/dist/$(APP_NAME)

# These are paths used in the docker image
SRCROOT_D = /go/src/$(APP_NAME)
BUILD_ROOT_D = $(SRCROOT_D)/tmp/dist
TEST_CONFIG_YML_D = $(SRCROOT_D)/config/production.yaml

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
	if [ ! -d vendor ]; then $(GLIDE) update; fi

migrate:
	./cmd/server/server --config config.yaml migratedb

utest:
	TEST_CONFIG_YML=$(TEST_CONFIG_YML) GO15VENDOREXPERIMENT=1 go test $(APP_GO_PACKAGES)

itest:
	cd itest/env && make restart
	cd itest && make test

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

distitest:
	cd itest/env && make restart
	docker run --rm --net=host \
	           -v $(SRCROOT):$(SRCROOT_D) \
 	           -w $(SRCROOT_D)/itest \
	           johnnylai/golang-dev \
	           make test

distutest:
	-docker rm -f go-service-basic-testdb
	docker run -d --name go-service-basic-testdb $(APP_DOCKER_LABEL)-testdb
	docker run --rm \
	           --link go-service-basic-testdb:go-service-basic-db \
	           -v $(SRCROOT):$(SRCROOT_D) \
	           -w $(SRCROOT_D) \
	           -e DB_ENV_MYSQL_ROOT_PASSWORD=whatever \
	           -e TEST_CONFIG_YML=$(TEST_CONFIG_YML_D) \
	           johnnylai/golang-dev \
	           make utest

deploy: distutest dist distitest
	docker push $(APP_DOCKER_LABEL)

.PHONY: build clean default deploy deps dist distbuild fmt migrate itest utest

image-testdb:
	docker build -f $(DOCKER_ROOT)/testdb/Dockerfile -t $(APP_DOCKER_LABEL)-testdb .

image-dist: $(PRODUCT_PATH)
	docker build -f $(DOCKER_ROOT)/dist/Dockerfile -t $(APP_DOCKER_LABEL) .

$(GLIDE):
	go get github.com/Masterminds/glide

$(BUILD_ROOT):
	mkdir -p $@

$(PRODUCT_PATH):
	docker run --rm \
	           -v $(SRCROOT):$(SRCROOT_D) \
	           -w $(SRCROOT_D) \
	           -e BUILD_ROOT=$(BUILD_ROOT_D) \
	           -e BUILD_NUMBER=$(BUILD_NUMBER) \
	           -e UID=`id -u` \
	           -e GID=`id -g` \
	           johnnylai/golang-dev \
	           make distbuild
