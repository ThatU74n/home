package ansible

import (
	"home_test/internal"
	"home_test/internal/util"
	"os"
)

type CertificateAuthorityServerInventory struct { AnsibleInventory }

func NewCertificateAuthorityServerInventory(vm *internal.LimaInstance) *CertificateAuthorityServerInventory {
	user := os.Getenv("USER")

	return &CertificateAuthorityServerInventory{
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

func (i *CertificateAuthorityServerInventory) GetFilePath(basePath string) string {
	return basePath + "/" + "ca_server_" + i.ID + ".yaml"
}

func (i *CertificateAuthorityServerInventory) WriteFile(basePath string) {
  data := i.createCertificateAuthorityServerMap()
	path := i.GetFilePath(basePath)
	util.MustWriteYAMLFile(path, data)
}


func (i *CertificateAuthorityServerInventory) DeleteFile(basePath string) {
	path := i.GetFilePath(basePath)
	if err := os.Remove(path); err != nil {
		panic(err)
	}
}

func (i *CertificateAuthorityServerInventory) createCertificateAuthorityServerMap() map[string]interface{} {
  return map[string]interface{} {
    "all": map[string]interface{}{
			"children": map[string]interface{}{
				"ca_server": i.createInventoryMap(),
			},
		},
	}
}
