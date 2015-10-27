BEDROCK_ROOT = $(realpath vendor/github.com/johnny-lai/bedrock)
include $(BEDROCK_ROOT)/boot.mk

init:
	git submodule init
	git submodule update

APP_NAME = go-service-basic
APP_DOCKER_LABEL = johnnylai/go-service-basic
APP_GO_PACKAGES = go-service-basic \
                  go-service-basic/core/model \
                  go-service-basic/core/service
