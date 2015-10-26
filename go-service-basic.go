package main

import (
	"fmt"
	"github.com/codegangsta/cli"
	"github.com/gin-gonic/gin"
	"go-service-basic/core/service"
	"gopkg.in/yaml.v1"
	"log"
	"os"
)

var version = "dev"
var commit = "sha1"

func main() {

	app := cli.NewApp()
	app.Name = "todo"
	app.Usage = "work with the `todo` microservice"
	app.Version = fmt.Sprintf("%s (%s)", version, commit)

	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:  "config, c",
			Value: "config.yaml",
			Usage: "config file to use",
		},
	}

	app.Commands = []cli.Command{
		{
			Name:  "env",
			Usage: "Print the configurations",
			Action: func(c *cli.Context) {
				cfg, err := service.GetConfig(c.GlobalString("config"))
				if err != nil {
					log.Fatal(err)
					return
				}

				d, err := yaml.Marshal(&cfg)
				if err != nil {
					log.Fatalf("error: %v", err)
				}
				fmt.Printf(string(d))
			},
		},
		{
			Name:  "server",
			Usage: "Run the http server",
			Action: func(c *cli.Context) {
				cfg, err := service.GetConfig(c.GlobalString("config"))
				if err != nil {
					log.Fatal(err)
					return
				}

				svc := service.TodoService{}

				r := gin.Default()
				if err = svc.Build(cfg, r); err != nil {
					log.Fatal(err)
				}

				r.Run(cfg.SvcHost)
			},
		},
		{
			Name:  "migratedb",
			Usage: "Perform database migrations",
			Action: func(c *cli.Context) {
				cfg, err := service.GetConfig(c.GlobalString("config"))
				if err != nil {
					log.Fatal(err)
					return
				}

				svc := service.TodoService{}

				if err = svc.Migrate(cfg); err != nil {
					log.Fatal(err)
				}
			},
		},
	}
	app.Run(os.Args)

}
