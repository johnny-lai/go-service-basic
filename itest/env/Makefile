SRCROOT ?= $(realpath .)

RUN_IN_DEV = docker run --rm --net=host -i johnnylai/golang-dev
KUBECTL = $(RUN_IN_DEV) kubectl

start: testenv-start

stop: testenv-stop

restart: stop start

testenv-start:
	for n in $(SRCROOT)/*.yml; do \
		cat $$n | $(KUBECTL) create -f - ; \
	done
	$(RUN_IN_DEV) wait-for-pod.sh go-service-basic

testenv-stop:
	docker run --rm -i --net=host johnnylai/golang-dev kubectl delete all -lapp=go-service-basic
