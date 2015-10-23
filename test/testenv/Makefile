SRCROOT ?= $(realpath .)

MACHINE_DEFAULT_IP = $(shell docker-machine ip default)

start: testenv-start

stop: testenv-stop

kubernetes-start: etcd-start master-start proxy-start

kubernetes-stop: etcd-stop master-stop proxy-stop

etcd-start:
	docker run --name=kubernetes-etcd \
	           --net=host -d gcr.io/google_containers/etcd:2.0.9 /usr/local/bin/etcd --addr=127.0.0.1:4001 --bind-addr=0.0.0.0:4001 --data-dir=/var/etcd/data

etcd-stop:
	docker stop kubernetes-etcd
	docker rm kubernetes-etcd

master-start:
	docker run --name=kubernetes-master \
	           --net=host -d -v /var/run/docker.sock:/var/run/docker.sock  gcr.io/google_containers/hyperkube:v0.21.2 /hyperkube kubelet --api_servers=http://localhost:8080 --v=2 --address=0.0.0.0 --enable_server --hostname_override=127.0.0.1 --config=/etc/kubernetes/manifests

master-stop:
	docker stop kubernetes-master
	docker rm kubernetes-master

proxy-start:
	docker run --name=kubernetes-proxy \
	           -d --net=host --privileged gcr.io/google_containers/hyperkube:v0.21.2 /hyperkube proxy --master=http://127.0.0.1:8080 --v=2

proxy-stop:
	docker stop kubernetes-proxy
	docker rm kubernetes-proxy

testenv-start:
	kubectl create -f $(SRCROOT)/app-controller.yml
	kubectl create -f $(SRCROOT)/app-service.yml
	kubectl create -f $(SRCROOT)/db-controller.yml
	kubectl create -f $(SRCROOT)/db-service.yml

testenv-stop:
	kubectl delete all -lapp=go-service-basic

killall:
	docker ps | sed '1d' | awk '{print $1}' | xargs docker kill
  
forward-ports:
	ssh -i  ~/.docker/machine/machines/default/id_rsa docker@$(MACHINE_DEFAULT_IP) -L8080:localhost:8080
