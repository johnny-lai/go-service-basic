package main

import (
	"errors"
	"fmt"
	"github.com/codegangsta/cli"
	"go-service-basic/core/service"
	"gopkg.in/yaml.v1"
	"io/ioutil"
	"log"
	"os"
)

func ExpandString(value string) string {
	if len(value) == 0 {
		return value
	}
	switch value[0] {
	case '$':
		// Expand as an environment variable
		return os.Getenv(value[1 : len(value)])
	case '\\':
		// Unescaped string
		return value[1 : len(value)]
	default:
		return value
	}
}

func getConfig(c *cli.Context) (service.Config, error) {
	yamlPath := c.GlobalString("config")
	config := service.Config{}

	if _, err := os.Stat(yamlPath); err != nil {
		return config, errors.New("config path not valid")
	}

	ymlData, err := ioutil.ReadFile(yamlPath)
	if err != nil {
		return config, err
	}

	err = yaml.Unmarshal([]byte(ymlData), &config)

	config.SvcHost = ExpandString(config.SvcHost)
	config.DbUser = ExpandString(config.DbUser)
	config.DbPassword = ExpandString(config.DbPassword)
	config.DbHost = ExpandString(config.DbHost)
	config.DbName = ExpandString(config.DbName)

	return config, err
}

func main() {

	app := cli.NewApp()
	app.Name = "todo"
	app.Usage = "work with the `todo` microservice"
	app.Version = "0.0.1"

	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name: "config, c",
			Value: "config.yaml",
			Usage: "config file to use",
		},
	}

	app.Commands = []cli.Command{
		{
			Name:  "env",
			Usage: "Print the configurations",
			Action: func(c *cli.Context) {
				cfg, err := getConfig(c)
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
				cfg, err := getConfig(c)
				if err != nil {
					log.Fatal(err)
					return
				}

				svc := service.TodoService{}

				if err = svc.Run(cfg); err != nil {
					log.Fatal(err)
				}
			},
		},
		{
			Name:  "migratedb",
			Usage: "Perform database migrations",
			Action: func(c *cli.Context) {
				cfg, err := getConfig(c)
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
