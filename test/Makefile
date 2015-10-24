SERVER ?= $(shell kubectl get svc go-service-basic -o json | jq -r '.spec.clusterIP')
PORT ?= $(shell kubectl get svc go-service-basic -o json | jq '.spec.ports[0].nodePort')

test:
	TEST_HOST="http://$(SERVER):$(PORT)" go test go-service-basic/test

testenv-stop:
	cd testenv && make stop

testenv-start:
	cd testenv && make start

.PHONY: test testenv-stop testenv-start
