apiVersion: v1alpha1
kind: KubeNodeConfig
labels:
  postfinance.ch/region: {{ default "noregion" (index .Node.Data "region") }}
