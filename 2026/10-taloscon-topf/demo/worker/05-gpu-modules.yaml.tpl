{{ if index .Node.Data "gpu" }}
apiVersion: v1alpha1
kind: KernelModuleConfig
name: nvidia
---
apiVersion: v1alpha1
kind: KernelModuleConfig
name: nvidia_uvm
---
apiVersion: v1alpha1
kind: KernelModuleConfig
name: nvidia_drm
---
apiVersion: v1alpha1
kind: KernelModuleConfig
name: nvidia_modeset
{{ end }}
