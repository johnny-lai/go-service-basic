ROOT_PATH = $(realpath .)

default: build

clean:

build:
	go build

deps:
	glide install --import

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
