# go-service-basic

## Pre-requisites for development

### Prepare your machine for docker

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

1. Install go 1.5+
  ```
  $ brew install go
  ```
    
2. Install jq (JSON parser for the command-line)
  ```
	$ brew install jq
	```

3. Install kubectl
  ```
  $ brew install kubernetes-cli
  ```

## Pre-requisites for build server

1. Docker should be installed

2. Create a job
  ```
  export KUBERNETES_CONFIG=<path to your kubernetes config>
  git submodule init
  git submodule update
  make deploy
  ```

## Makefile

The following basic commands are available. They need all the pre-requisites
for development to be installed in order to work.

* `build`: This is the default rule. Will build your app
* `utest`: Runs the unit tests
* `itest`: Restarts and runs the integration tests
  * `itest.env`: Restarts the integration test environment on Kubernetes
  * `itest.run`: Runs the integration tests
* `ibench`: Restarts and runs the integration benchmarks
  * `ibench.env`: Restarts the integration test environment on Kubernetes
  * `ibench.run`: Restarts and runs the integration benchmarks

The following commands run in docker. They can be used with only docker
installed.

* `deploy`: Build rule for Jenkins to build, test and publish the app
* `dist`: Builds all the docker images
* `distbuild`: Runs `build` in docker. This allows for builds on machines with
  just docker installed; so no need for golang.
* `distpush`: Pushes the commit-tagged docker images
* `distpublish`: Pushes the release- and latest- tagged docker images
* `distutest`: Runs the unit tests in docker. This will also start a test
  database image and connect your run to that.
* `distitest`: Runs the integration tests in docker. This is the same as
  running `itest`. The difference is that you don't need to install Kubernetes
  locally. If you want your Kubernetes to apply in the image, you need to
  set `KUBERNETES_CONFIG`.
  * `distitest.env`: `itest.env` run in docker
  * `distitest.run`: `itest.run` run in docker
* `distibench`: Runs the benchmark tests in docker
  * `distibench.env`: `ibench.env` run in docker
  * `distibench.run`: `ibench.run` run in docker

The following are extra commands that you may find helpful.

* `fmt`: Runs `go fmt` on your Go packages
* `devconsole`: Enters the container image. Useful for starting kubernetes or running delve.

## Overview of structure

```
$GOPATH
  src/
    go-service/
      api/
        swagger.yml                      # Swagger API documentation
      core/
        # ... The bulk of your application goes here
      config/
        production.yml                   # Default production configuration
      Dockerfile                         # Dockerfile for building deployment images
      main.go                            # The main program
      Makefile 
```

## Upgrading bedrock

To upgrade your bedrock, you would:

```
$ cd vendor/github.com/johnny-lai/bedrock
$ git pull origin master
```

Then you can re-generate the stubs. If you commit your existing changes before
re-generating, then you can see the differences that were made, and you would
have a change to reconcile the differences.

```
$ make gen-app
$ make gen-api
$ make gen-docker
$ make gen-itest
```