package ansible_test

import (
	"home_test/internal/ansible"
	"os"
	"testing"
)

func TestControlPlaneInventoryGetFilePath(t *testing.T) {
	testCases := []struct {
	  Name string 
		BeforeFunc func()
		AfterFunc func()
		MockInventory *ansible.ControlPlaneInventory 
	}{
		{
			Name: "TC1 - Get Control Plane Inventory File Path",
			BeforeFunc: func() {},
			AfterFunc: func() {},
			MockInventory: &ansible.ControlPlaneInventory{
        AnsibleInventory: ansible.AnsibleInventory{
					ID: "test-id",
					Host: "127.0.0.1",
					Port: "22",
					KeyFile: "~/.ssh/id_rsa",
					User: "test-user",
					ConnectionType: ansible.ConnectionTypeSSH,
				},
			},
		},
	}

	for _, tc := range testCases {
		t.Run(tc.Name, func(t *testing.T) {
		 	tc.BeforeFunc()
			tc.AfterFunc()

			expectedFilePath := "/tmp/control_plane_test/control_plane_test-id.yaml"
      filePath := tc.MockInventory.GetFilePath("/tmp/control_plane_test")

			if filePath != expectedFilePath {
				t.Errorf("Expected file path to be %s, but got %s", expectedFilePath, filePath)
			}
		})
	}
}

func TestControlPlaneInventoryWriteFile(t *testing.T) {
  testCases := []struct {
	  Name string
    BeforeFunc func()
		AfterFunc func()
    MockInventory *ansible.ControlPlaneInventory
	}{
		{
			Name: "TC1 - Write Control Plane Inventory File",
			BeforeFunc: func() {
				os.Mkdir("/tmp/test_control_plane_inventory", 0755)
			},
			AfterFunc: func() {
        os.RemoveAll("/tmp/test_control_plane_inventory")
			},
			MockInventory: &ansible.ControlPlaneInventory{
        AnsibleInventory: ansible.AnsibleInventory{
					ID: "test-id",
					Host: "127.0.0.1",
					Port: "22",
					KeyFile: "~/.ssh/id_rsa",
					User: "test-user",
					ConnectionType: ansible.ConnectionTypeSSH,
				},
			},
		},
	}

	for _, tc := range testCases {
    t.Run(tc.Name, func(t *testing.T) {
     	tc.BeforeFunc()
			defer tc.AfterFunc()

			tc.MockInventory.WriteFile("/tmp/test_control_plane_inventory")

			if _, err := os.ReadFile(tc.MockInventory.GetFilePath("/tmp/test_control_plane_inventory")); err != nil {
				t.Errorf("Expected inventory file to be created, but it was not found")
			}
		})
	}
}

func TestControlPlaneInventoryDeleteFile(t *testing.T) {
	testCases := []struct {
		Name string 
		BeforeFunc func()
		AfterFunc func()
		MockInventory *ansible.ControlPlaneInventory 
	}{
		{
      Name: "TC1 - Delete Control Plane Inventory File",
			BeforeFunc: func() {
				os.Mkdir("/tmp/test_control_plane_inventory", 0755)
			},
			AfterFunc: func() {
        os.RemoveAll("/tmp/test_control_plane_inventory")
			},
			MockInventory: &ansible.ControlPlaneInventory{
				AnsibleInventory: ansible.AnsibleInventory{
					ID: "test-id",
					Host: "127.0.0.1",
					Port: "22",
					KeyFile: "~/.ssh/id_rsa",
					User: "test-user",
					ConnectionType: ansible.ConnectionTypeSSH,
				},
			},
		},
	}

	for _, tc := range testCases {
		t.Run(tc.Name, func(t *testing.T) {
       tc.BeforeFunc()
			 defer tc.AfterFunc()

			 filePath := tc.MockInventory.GetFilePath("/tmp/test_control_plane_inventory")
			 os.WriteFile(filePath, []byte("test content"), 0644)
			 tc.MockInventory.DeleteFile("/tmp/test_control_plane_inventory")

			 if _, err := os.ReadFile(filePath); err == nil {
				 t.Errorf("Expected inventory file to be deleted, but it still exists")
			 }
		})
	}
}
