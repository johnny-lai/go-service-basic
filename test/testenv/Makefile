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
	while $(KUBECTL) get pods -l name=go-service-basic -o json | jq ".items[0].status.containerStatuses[0].ready != true" | grep true; do sleep 1; done

testenv-stop:
	docker run --rm -i --net=host johnnylai/golang-dev kubectl delete all -lapp=go-service-basic
