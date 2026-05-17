package ansible

import (
	"home_test/internal"
	"home_test/internal/util"
	"os"
)

type ControlPlaneInventory struct { AnsibleInventory }

func NewControlPlaneInventory(vm *internal.LimaInstance) *ControlPlaneInventory {
	user := os.Getenv("USER")

	return &ControlPlaneInventory{
		AnsibleInventory: AnsibleInventory{
			ID:   vm.Name,
			Host: "127.0.0.1",
			Port: vm.SSHPort,
			KeyFile: "~/.lima/_config/user",
			User: user,
			ConnectionType: ConnectionTypeSSH,
 		},
	}
}

func (i *ControlPlaneInventory) GetFilePath(basePath string) string {
	return basePath + "/" + "control_plane_" + i.ID + ".yaml"
}

func (i *ControlPlaneInventory) WriteFile(basePath string) {
  data := i.createControlPlaneMap()
	path := i.GetFilePath(basePath)
	util.MustWriteYAMLFile(path, data)
}


func (i *ControlPlaneInventory) DeleteFile(basePath string) {
	path := i.GetFilePath(basePath)
	if err := os.Remove(path); err != nil {
		panic(err)
	}
}

func (i *ControlPlaneInventory) createControlPlaneMap() map[string]any {
  return map[string]any {
    "all": map[string]any {
			"children": map[string]any {
				"control_plane": map[string]any { 
					"hosts": i.createInventoryMap(),
				},
			},
		},
	}
}
