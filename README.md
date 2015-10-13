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
  
    
## Production

### Pre-requisites

1. `docker` should be pre-installed
	
### Build

Run `make deploy`. The image will be named `go-service-basic`
