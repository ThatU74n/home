package controlplane_test

import (
	"flag"
	"home_test/internal"
	"home_test/internal/ansible"
	"testing"

	"github.com/google/uuid"
)

var name = flag.String("name", "test", "Name of the lima instance to create")
var template = flag.String("template", "debian", "Lima template to use for the instance")

type TestCase struct {
	Name string
	BeforeFunc 	func()  
	AfterFunc 	func()
	Driver      *ansible.Ansible
	TestVars    map[string]any
}

func TestControlPlaneSingleOS(t *testing.T) {
  testCases := []TestCase{
		func() TestCase {
			id := uuid.New().String()
      controlPlane := internal.NewLimaInstance(id, "archlinux")     
      ap := ansible.NewAnsible()

      return TestCase{
				Name: "TestCase #1 - Control Plane full static pod",
				BeforeFunc: func() {
          controlPlane.MustStart()
					ap.AddInventory(controlPlane, ansible.InventoryTypeControlPlane)
				},
				AfterFunc: func() {
      //    controlPlane.MustStop()
			//	controlPlane.MustDelete()
				},
				Driver: ap,
				TestVars: map[string]any{
					"kubernetes_version": "1.35.5",
          "etcd_version": "3.6.10",
          "etcd_mode": "staticpod",
          "kube_apiserver_mode": "staticpod",
          "kube_controller_manager_mode": "staticpod", 
          "kube_scheduler_mode": "staticpod",
				},
			}
		}(),
	}

	for _, tc := range testCases {
     t.Run(tc.Name, func(t *testing.T) {
       defer func() {
       	if r := recover(); r != nil {
					 t.Errorf("Test panicked: %v", r)
				 }
			 }()
			 tc.BeforeFunc()
			 defer tc.AfterFunc()

       driver := tc.Driver
			 driver.Vars = tc.TestVars 

			 driver.Playbook("control_plane.yaml")

			 // implement assert check all static pod
		 })
	}
}

