package internal

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
)

type LimaState string 

var (
 	LimaStateRunning LimaState = "Running"
	LimaStateStopped LimaState = "Stopped"
)

type LimaInstance struct {
  Name string 
	Template string 
	State string
	SSHPort string
}

func NewLimaInstance(name string, template string) *LimaInstance {
  cmd := exec.Command(
		"limactl",
		"create",
		"--vm-type", "qemu",
		"--arch", "x86_64",
		"--name", name,
		"template:" + template,
	)
	cmd.Env = append(os.Environ(), "CLICOLOR_FORCE=1")
	cmd.Env = append(cmd.Env, "FORCE_COLOR=1")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	log.Println("Creating Lima instance ", name, " - template:", template)
  err := cmd.Run() 
	if err != nil {
		panic(err)
	}

  return &LimaInstance{
		Name: name,
		Template: template,
		State: string(LimaStateStopped),
		SSHPort: "",
	}
}

func (i *LimaInstance) Start() error {
	cmd := exec.Command(
		"limactl",
		"start",
		i.Name,
	)
	cmd.Env = append(os.Environ(), "CLICOLOR_FORCE=1")
	cmd.Env = append(cmd.Env, "FORCE_COLOR=1")
	cmd.Stdout = os.Stderr
	cmd.Stderr = os.Stderr 

	log.Println("Starting Lima instance ", i.Name)
	if err := cmd.Run(); err != nil {
		return err
	}

	port, err := i.getSSHPort()
	if err != nil {
		return err
	}

	i.SSHPort = port 
	i.State = string(LimaStateRunning)
	return nil
}

func (i *LimaInstance) MustStart() {
	if err := i.Start(); err != nil {
		panic(err)
	}
}

func (i *LimaInstance) Stop() error {
	cmd := exec.Command(
		"limactl",
		"stop",
		i.Name,
	)
	cmd.Env = append(os.Environ(), "CLICOLOR_FORCE=1")
	cmd.Env = append(cmd.Env, "FORCE_COLOR=1")
	cmd.Stdout = os.Stderr
	cmd.Stderr = os.Stderr 

	log.Println("Stopping Lima instance ", i.Name)
	if err := cmd.Run(); err != nil {
		return err
	}

	i.State = string(LimaStateStopped)
	return nil
}


func (i *LimaInstance) MustStop() {
	if err := i.Stop(); err != nil {
		panic(err)
	}
}

func (i *LimaInstance) Delete() error {
	cmd := exec.Command(
		"limactl",
		"delete",
		i.Name,
	)
	cmd.Env = append(os.Environ(), "CLICOLOR_FORCE=1")
	cmd.Env = append(cmd.Env, "FORCE_COLOR=1")
	cmd.Stdout = os.Stderr
	cmd.Stderr = os.Stderr 

	log.Println("Deleting Lima instance ", i.Name)
	return cmd.Run()
}

func (i *LimaInstance) MustDelete() {
	if err := i.Delete(); err != nil {
		panic(err)
	}
}

func (i *LimaInstance) FactoryReset() error {
  cmd := exec.Command(
		"limactl",	 
		"factory-reset",
		i.Name,
	)
	cmd.Env = append(os.Environ(), "CLICOLOR_FORCE=1")
	cmd.Env = append(cmd.Env, "FORCE_COLOR=1")
	cmd.Stdout = os.Stderr
	cmd.Stderr = os.Stderr 
	
	log.Println("Factory resetting Lima instance ", i.Name)
	return cmd.Run()
}

func (i *LimaInstance) MustFactoryReset() {
	if err := i.FactoryReset(); err != nil {
		panic(err)
	}
}


func (i *LimaInstance) getSSHPort() (string, error) {
	cmd := exec.Command(
		"limactl",
		"list",
		"--format", fmt.Sprintf(`{{if eq .Name "%s"}}{{.SSHLocalPort}}{{end}}`, i.Name),
	)
	portByte, err := cmd.Output()
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(portByte)), nil
}

