package controlplaneca_test

import (
	"home_test/internal"
	"home_test/internal/ansible"
	"testing"

	"github.com/google/uuid"
)

type TestCase struct {
	Name string
	BeforeFunc 	func()  
	AfterFunc 	func()
	Driver      *ansible.Ansible
	TestVars    map[string]any
}

func TestControlPlaneCASingleOS(t *testing.T) {
  testCases := []TestCase{
    func() TestCase {
      ap := ansible.NewAnsible()
			controlPlane := internal.NewLimaInstance(uuid.NewString(), "debian-13")
			caServer := internal.NewLimaInstance(uuid.NewString(), "debian-13")

			return TestCase{
				Name: "TestCase #1 - Control Plane CA full static pod",
				BeforeFunc: func() {
          controlPlane.MustStart()
					caServer.MustStart()
				},
				AfterFunc: func() {
          controlPlane.MustStop()
					controlPlane.MustDelete()
					caServer.MustStop()
					caServer.MustDelete()
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

			driver.Playbook("control_plane_ca.yaml")
		})
	}
}
