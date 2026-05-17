package ansible

import (
	"home_test/internal"
	"home_test/internal/util"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"

	"github.com/google/uuid"
)

type ConnectionType string 
const (
	ConnectionTypeSSH ConnectionType = "ssh"
	ConnectionTypeLocal ConnectionType = "local"
)

type InventoryType string
const (
	InventoryTypeControlPlane InventoryType = "control_plane"
	InventoryTypeCertificateAuthorityServer InventoryType = "ca_server"
)

type ansibleInventory interface {
	GetFilePath(basePath string) string
  WriteFile(basePath string) 
	DeleteFile(basePath string)  
}

type Ansible struct {
	Id                  string
  Inventory 					[]ansibleInventory
	Vars 								map[string]any
	VaultPasswordFile 	*string
	BecomePasswordFile 	*string
}

type AnsibleInventory struct {
  ID              string
  Host 						string 
	Port 		        string 
  User 			      string 
	KeyFile 				string 
	ConnectionType 	ConnectionType
}

func NewAnsible() *Ansible {
	return &Ansible{
		Id: uuid.NewString(),
		Inventory: []ansibleInventory{},
		Vars: map[string]any{},
	  VaultPasswordFile: nil,
		BecomePasswordFile: nil,
	}
}

/* @Description: Add an inventory to the Ansible Profile.
 * @Param:
 *  - vm: The LimaInstance to create the inventory for.
 */
func (a *Ansible) AddInventory(vm *internal.LimaInstance, inventoryType InventoryType) {
  switch inventoryType {
  case InventoryTypeControlPlane:
		a.Inventory = append(a.Inventory, NewControlPlaneInventory(vm))
	case InventoryTypeCertificateAuthorityServer:
		a.Inventory = append(a.Inventory, NewCertificateAuthorityServerInventory(vm))
	}
}

/* @Description: Execute the playbook from the Ansible Profile.
 * 
 */ 
func (a *Ansible) Playbook(playbookPath string) error {
	basePath := "/tmp/ansible_" + a.Id 
	if err := os.Mkdir(basePath, 0755); err != nil {
		panic(err)
	}
	defer os.RemoveAll(basePath)

  args := []string{}

	for _, inventory := range a.Inventory {
    inventory.WriteFile(basePath)
	  defer inventory.DeleteFile(basePath)	

		args = append(args, "-i", inventory.GetFilePath(basePath))
	}

	if len(a.Vars) > 0 {
		varsFilePath := basePath + "/vars.yaml"
		util.MustWriteYAMLFile(varsFilePath, a.Vars)
		defer os.Remove(varsFilePath)

		args = append(args, "-e", "@" + varsFilePath)
	}

	if a.VaultPasswordFile != nil {
  		args = append(args, "--vault-password-file", *a.VaultPasswordFile)
	}

	if a.BecomePasswordFile != nil {
		args = append(args, "--become-password-file", *a.BecomePasswordFile)
	}
  
	args = append(args, getPlaybook(playbookPath))
	cmd := exec.Command(
		"ansible-playbook",
		args...,
	)
	cmd.Env = append(os.Environ(), "ANSIBLE_FORCE_COLOR=true")
	cmd.Dir = getAnsiblePath()
	cmd.Stdout = os.Stderr
	cmd.Stderr = os.Stderr
	
	return cmd.Run()
}

func getAnsiblePath() string {
	_, fileName, _, _ := runtime.Caller(0)
	root := filepath.Join(filepath.Dir(fileName), "../../../")
	return filepath.Join(root, "configuration")
}

func getPlaybook(playbook string) string {
	return filepath.Join(getAnsiblePath(), "/playbooks/", playbook)
}

func (i *AnsibleInventory) createInventoryMap() map[string]any {
	return map[string]any {
		i.ID: map[string]any {
			"ansible_host": i.Host,
			"ansible_port": i.Port,
			"ansible_user": i.User,
			"ansible_connection": i.ConnectionType,
			"ansible_ssh_private_key_file": i.KeyFile,
		},
	}
}

