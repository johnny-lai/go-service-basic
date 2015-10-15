# A Basic Go Microservice

An example (seed) project for microservices in go using the [Gin](http://gin-gonic.github.io/gin/) web framework.

Based on [benschw/go-todo](https://github.com/benschw/go-todo).

## Development

### Pre-requisites

#### Prepare your machine for docker

1. Install docker
  ```
  $ brew install docker
  ```
  
2. Install docker-machine
  ```
  $ brew install docker-machine
  ```
  
3. Create a default docker VM called `default`
  ```
  $ docker-machine create --driver=virtualbox default
  ```
  
4. Add the following to your startup script so that you run `default`
  ```
  eval "$(docker-machine env default)"
  ```

### Install go development tools

1. Install go
  ```
  $ brew install go
  ```
  
2. Install glide
  ```
  $ brew install glide
  ```
  
3. Install all dependencies
  ```
  $ glide install --import
  ```

### Build
	
  ```
  make
  ```
	
### Test

  ```
  make test
  ```

### Debugging

You can use (godebug)[https://github.com/mailgun/godebug] to debug the program. Unfortunately it does not support the `vendor` directory. 

```
$ go get github.com/mailgun/godebug
$ unset GO15VENDOREXPERIMENT
$ godep get
$ godebug run ./go-service-basic.go -c ./config/production.yaml server 
```
    
## Production

### Pre-requisites

1. `docker` should be pre-installed
	
### Build

Run `make deploy`. The image will be named `go-service-basic`

### Run locally

To create a MySQL db server container
```
$ docker pull mysql:5.5
$ docker run --name db -e MYSQL_ROOT_PASSWORD=whatever -d mysql:5.5
```

To create an empty database in the db container
```
$ docker exec -it db mysqladmin -u root -p create Todo
```

To start the microservice and use the db server
```
$ docker run --link db go-service-basic
```

To override the default configuration, you would mount your new configuration to
`/opt/go-service-basic`.
```
docker run -v `pwd`/config:/opt/go-service-basic --link db go-service-basic
```

To get the configuration that it is using
```
docker run --link db go-service-basic env
```

To take a look around the go-service-basic image
```
$ docker run --link db --entrypoint=/bin/bash -it go-service-basic
```