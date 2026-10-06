Topf is a CLI tool.

For those familiar: talosctl on steroids.

You use it to bootstrap talos clusters, upgrade them or roll out changes.

Two distinct features:

- Cluster and Patch management:
  - opinionated layout, how to store patches (in git)
  - ability to template patches
  - Example talosctl command that bootstraps a cluster
    - lots of patch files
    - cluster endpoint, installer version, k8s version
- Rollout:
  - safety harness for rolling out upgrades and config changes


HELLO WORLD
-----------

Instead of listing all the features, let's dive into the most simple example.

Assume you have a single node which has booted some talos ISO. You want to bootstrap a new cluster.

```bash
export CONTROL_PLANE_IP=192.168.64.4
export CLUSTER_ENDPOINT=https://192.168.64.100:6443
export CLUSTER_NAME=my-cluster
talosctl gen config $CLUSTER_NAME $CLUSTER_ENDPOINT --install-disk /dev/vda
talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file controlplane.yaml
talosctl --talosconfig=./talosconfig config endpoints $CONTROL_PLANE_IP
talosctl bootstrap --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig
```


topf version:

topf.yaml:

```yaml
clusterEndpoint: https://192.168.64.100:6443
clusterName: local

nodes:
  - host: node1
    ip: 192.168.64.4
    role: control-plane
```

all/install.yaml

```yaml
machine:
  install:
    disk: /dev/vda
```
