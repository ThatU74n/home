package util

import (
	"os"

	"gopkg.in/yaml.v3"
)


func WriteYAMLFile(filePath string, data map[string]interface{}) error {
  yamlByte, err := yaml.Marshal(data)
	if err != nil {
		return err 
	}
	return os.WriteFile(filePath, yamlByte, 0644)
}

func MustWriteYAMLFile(filePath string, data map[string]interface{}) {
  if err := WriteYAMLFile(filePath, data); err != nil {
		panic(err)
	}
}
