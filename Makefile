ROOT_PATH = $(realpath .)
BUILD_PATH = $(ROOT_PATH)/build

default: build

clean:
	rm -f $(BUILD_PATH)/*

build:
	go build

deps:
	cd cmd/server; \
	go get

migrate:
	./cmd/server/server --config config.yaml migratedb

test:
	./cmd/server/server --config config.yaml server & \
	pid=$$!; \
	go test; \
	kill $$pid

$(BUILD_PATH)/go-service-basic:
	mkdir -p `dirname $@`
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o $@ .

deploy: clean $(BUILD_PATH)/go-service-basic
	docker build -t go-service-basic .
