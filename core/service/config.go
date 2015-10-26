package service

import (
	"errors"
	"gopkg.in/yaml.v1"
	"io/ioutil"
	"os"
)

func ExpandString(value string) string {
	if len(value) == 0 {
		return value
	}
	switch value[0] {
	case '$':
		// Expand as an environment variable
		return os.Getenv(value[1:len(value)])
	case '\\':
		// Unescaped string
		return value[1:len(value)]
	default:
		return value
	}
}

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

	config.SvcHost = ExpandString(config.SvcHost)
	config.DbUser = ExpandString(config.DbUser)
	config.DbPassword = ExpandString(config.DbPassword)
	config.DbHost = ExpandString(config.DbHost)
	config.DbName = ExpandString(config.DbName)

	return config, err
}
