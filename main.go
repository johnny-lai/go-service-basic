package main

import (
	"github.com/johnny-lai/bedrock"
	"go-service-basic/core/service"
	"os"
)

var version = "unset"

func main() {
	app := bedrock.NewApp(&service.Service{})
	app.Name = "go-service-basic"
	app.Version = version
	app.Run(os.Args)
}
