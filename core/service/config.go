package service

import (
	"errors"
	"gopkg.in/yaml.v1"
	"io/ioutil"
	"os"
)

func GetConfig(yamlPath string) (Config, error) {
	config := Config{}

	if _, err := os.Stat(yamlPath); err != nil {
		return config, errors.New("config path not valid")
	}

	ymlData, err := ioutil.ReadFile(yamlPath)
	if err != nil {
		return config, err
	}

	err = yaml.Unmarshal([]byte(ymlData), &config)

	config.SvcHost = os.Expand(config.SvcHost, os.Getenv)
	config.DbUser = os.Expand(config.DbUser, os.Getenv)
	config.DbPassword = os.Expand(config.DbPassword, os.Getenv)
	config.DbHost = os.Expand(config.DbHost, os.Getenv)
	config.DbName = os.Expand(config.DbName, os.Getenv)

	return config, err
}
