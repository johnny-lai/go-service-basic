package main

import (
	"github.com/johnny-lai/bedrock"
	"go-service-basic/core/service"
	"os"
)

var version = "dev"
var commit = "sha1"

func main() {
	app := bedrock.NewApp(&service.TodoService{})
	app.Run(os.Args)
}
