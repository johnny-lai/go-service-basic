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

deploy: clean
	docker build -t go-service-basic .

.PHONY: default clean build deps migrate test deploy
