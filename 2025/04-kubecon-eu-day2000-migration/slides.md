---
theme: seriph
themeConfig:
  primary: '#E85C0D'
# color palette: #FABC3F #E85C0D #C7253E #821131
title: "Day-2’000 - Migration From kubeadm+Ansible to ClusterAPI+Talos: A Swiss Bank’s Journey"
author: Clément Nussbaumer
info: |-
  Is it even possible to migrate 35 clusters in an air-gapped environment with a
  custom PKI infrastructure to ClusterAPI without Downtime? We'll show you why
  and how we pulled that off, and how you could do the same.
  The journey starts with our legacy provisioning setup (a mix of
  kubeadm/ansible/puppet), followed by the migration path and tooling. Along the
  road, you'll discover a series of challenges we encountered (such as loss of
  etcd quorum, matching legacy/new kube-apiserver configuration, mismatching etcd
  encryption keys, and more). After a live demo of a migration, the session
  explores managing our fleet of clusters with ArgoCD (with a focus on simple
  Talos configuration files in our repositories thanks to a few templating
  tricks, and a clean ClusterAPI workload cluster overview through ArgoCD
  ApplicationSets).
  The presentation concludes by addressing a critical puzzle: solving the
  chicken/egg bootstrapping problem of the first ClusterAPI management
  cluster(s).

class: text-center
highlighter: shiki
mdc: true
hideInToc: true
layout: two-cols-header
layoutClass: cover text-right
---

# Day-2'099 Migration
## kubeadm+Ansible to ClusterAPI+Talos
## A Swiss Bank’s Journey

**Clément Nussbaumer**

<a href="https://clement.n8r.ch/en/articles/" style="font-size: 1.5rem;" target="_blank" alt="Blog" class="absolute right-6rem top-15rem m-6 text-xl">clement.n8r.ch</a>

<a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" alt="Blog"
  class="absolute right-4rem top-15rem m-6  text-xl icon-btn opacity-100 !border-none "><carbon-logo-linkedin />
</a>

<a href="https://github.com/clementnuss" target="_blank" alt="GitHub"
  class="absolute right-2rem top-15rem m-6 text-xl icon-btn opacity-100 !border-none"><carbon-logo-github />
</a>

<!-- <img border="rounded" src="./images/KubeConLondon.png" width="30%" class="absolute bottom-1rem left-2rem "> -->

<img border="rounded" src="./images/KubeConlogo.png" width="87%" class="absolute justify-items-center bottom-1rem">

<figure class="absolute top-2rem left-2rem m-0">
  <img border="rounded" src="./images/clusterapi-cuttle.webp" width="30%">
  <footer><cite style="font-size: 75%;display: block;text-align: start;" >Created with FLUX.1 [dev] by Black Forest Labs</cite></footer>
</figure>

---

# Longevity of a K8s Cluster

How old can your clusters get?

<div class="grid grid-cols-5 gap-4">
<div class="col-span-2 flex flex-col flex-items-start">

<br>
<br>
<br>


```console
$ kubectl get namespace kube-system
NAME          STATUS   AGE
kube-system   Active   5y273d
```

```console
     5 years (365.25 days)
 + 273 days
= 2099 days
```

</div>

<div place-items="center" class="flex col-span-3">
<figure>
  <img border="rounded" src="./images/old-cluster.jpg" width="90%" alt="">
</figure>
</div>
</div>

---
src: ./slides/intro-pf.md
---
---

# Starting Point
Legacy cluster provisioning

<div class="grid grid-cols-5 gap-4">
<div class="col-span-2">

1. provision Debian VMs (terraform)
1. deploy/configure base tools
1. register nodes in `inventory.yml`
1. run Ansible playbook:
   - render config files, base manifests, ...
   - run `kubeadm` commands
1. configure ArgoCD integration

</div>
<div class="col-span-3">
<figure>
  <img border="rounded" src="./images/clusters-pipeline.png" width="100%" alt="">
  <footer><cite style="font-size: 70%;display: block;text-align: center;" >Current cluster provisioning pipeline overview</cite></footer>
</figure>
</div>
</div>

<!-- 
base tools: log collection, ssh access control, security tools
-->

---

# ClusterAPI

<div class="grid grid-cols-5 gap-4">
<div class="col-span-3">

<figure>
  <img border="rounded" src="./images/clusterapi-overview.png" width="100%" alt="">
</figure>


</div>
<div class="col-span-2 flex flex-col flex-items-start">

```console
$ kubectl get clusters --all-namespaces
NAMESPACE    NAME           AGE
capi-lab-a   e1-k8s-lab-a   29d
capi-lab-b   e1-k8s-lab-b   95d
capi-lab-c   e1-k8s-lab-c   95d
```

```console
$ kubectl get machinedeployments
NAME                  REPLICAS AGE    VERSION
e1-k8s-lab-a-md-002   2        5d5h   v1.30.5
e1-k8s-lab-a-md-1     1        19d    v1.31.4
```

```console
$ kubectl get machines
NAME                 PHASE     AGE    VERSION
lab-a-md-002-lr7ch   Running   5d4h   v1.30.5
lab-a-md-002-lwx4t   Running   4d2h   v1.30.5
lab-a-md-1-4rtb9     Running   19d    v1.31.5
```


</div>
</div>

---

# Talos Linux
[The 12 binaries' O.S.](https://www.siderolabs.com/blog/there-are-only-12-binaries-in-talos-linux/)



<div class="grid grid-cols-4 gap-4">
<div class="col-span-2 flex flex-col flex-items-start">

> immutable, minimal, ephemeral \
> declarative configuration file and gRPC API [^talos-philosophy]

[^talos-philosophy]: <https://www.talos.dev/v1.9/learn-more/philosophy/>

<br>

```console
$ talosctl services
SERVICE              STATE     HEALTH
apid                 Running   OK    
containerd           Running   OK    
cri                  Running   OK    
etcd                 Running   OK    
kubelet              Running   OK    
machined             Running   OK    
syslogd              Running   OK    
trustd               Running   OK    
udevd                Running   OK    
```

</div>
<div class="col-span-2">
<figure>
  <img border="rounded" src="./images/talos-overview.png" width="99%" alt="">
</figure>
</div>
</div>

---

# Migration
The Journey


<div class="grid grid-cols-5 gap-4">
<div class="col-span-2 flex flex-col flex-items-start">

Documentation:

- [Talos `kubeadm` migration guide](https://www.talos.dev/v1.9/advanced/migrating-from-kubeadm/)
- [Talos `v1alpha1/config` reference](https://www.talos.dev/v1.9/reference/configuration/v1alpha1/config/)
- [`kube-apiserver` CLI reference](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/)
- [Kubernetes `etcd` encryption doc](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/)

</div>
<div class="col-span-3">
<figure>
  <img border="rounded" src="./images/migration.png" width="90%" alt="">
  <!-- <footer><cite style="font-size: 70%;display: block;text-align: center;" >Current cluster provisioning pipeline overview</cite></footer> -->
</figure>
</div>
</div>

---
layout: two-cols-header
layoutClass: gap-4
class: justify-items-start
---

# step 0: config matching

::left::
**Kubeadm modifications:**


1. `--service-account-issuer => https://<apiserver endpoint>:6443`
1. match `etcd` encryption key names to those hard-coded in [Talos template
file](https://github.com/siderolabs/talos/blob/release-1.9/internal/app/machined/pkg/controllers/k8s/templates/kube-system-encryption-config-template.yaml)
1. re-encrypt all secrets:

```bash
kubectl get secrets --all-namespaces -o json | \
  kubectl replace -f -
```

::right::

```yaml {9-12,15-18}{lines:true}
--- # talos EncryptionConfig template
apiVersion: v1
kind: EncryptionConfig
resources:
- resources:
  - secrets
  providers:
  {{if .Root.SecretboxEncryptionSecret}}
  - secretbox:
      keys:
      - name: key2
        secret: {{ .Root.SecretboxEncryptionSecret }}
  {{end}}
  {{if .Root.AESCBCEncryptionSecret}}
  - aescbc:
      keys:
      - name: key1
        secret: {{ .Root.AESCBCEncryptionSecret }}
  {{end}}
  - identity: {}
```

---

# step 1: import existing PKI

<br>

````md magic-move
```text
$ export TOKEN=$(kubeadm token create --ttl 0)
$ talosctl gen secrets \
  --from-kubernetes-pki /etc/kubernetes/pki/ \
  --kubernetes-bootstrap-token ${TOKEN} \
  --output-file secretsbundle.yaml
```
```yaml {*}{lines:true}
--- # secretsbundle.yaml
secrets:
  bootstraptoken: c00ffe.0123456789abcdef
  secretboxencryptionsecret: base64-encoded-etcd-encryption-key
certs:
  etcd:
    crt: base64-encoded-crt
    key: base64-encoded-key
  k8s:
    crt: base64-encoded-crt
    key: base64-encoded-key
  k8sserviceaccount:
    key: base64-encoded-key
  os:
    crt: base64-encoded-crt
    key: base64-encoded-key
```
````

---
layout: two-cols-header
layoutClass: gap-2
class: justify-items-start
---

# step 2: create ClusterAPI CRDs

::left::

```yaml {*}{lines:true}
---
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
  labels:
    cluster.x-k8s.io/cluster-name: e1-k8s-lab-f
  name: e1-k8s-lab-f
spec:
  controlPlaneEndpoint:
    host: e1-k8s-lab-f-internal.pnet.ch
    port: 443
  controlPlaneRef:
    apiVersion: controlplane.cluster.x-k8s.io/v1alpha3
    kind: TalosControlPlane
    name: e1-k8s-lab-f
  infrastructureRef:
    apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
    kind: VSphereCluster
    name: e1-k8s-lab-f
```

::right::

```yaml {*}{lines:true}
---
apiVersion: controlplane.cluster.x-k8s.io/v1alpha3
kind: TalosControlPlane
metadata:
  name: e1-k8s-lab-f
spec:
  controlPlaneConfig:
    controlplane:
      strategicPatches: [...]
      generateType: controlplane
  infrastructureTemplate:
    apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
    kind: VSphereMachineTemplate
    name: control-plane-v1.9.4-pf.0
  replicas: 0
  rolloutStrategy:
    rollingUpdate:
      maxSurge: 1
    type: RollingUpdate
  version: v1.31.5
```


---
layout: two-cols-header
layoutClass: gap-4
class: justify-items-start
---

# step 2: create ClusterAPI CRDs

<br>

```yaml {*}{lines:true}
---
apiVersion: kustomize.config.k8s.io/v1beta1
namespace: capi-e1-k8s-lab-f
kind: Kustomization
resources:
  - cluster.yaml
  - control-plane.yaml
  - data-plane.yaml
secretGenerator:
  - name: e1-k8s-lab-f-talos
    files:
      - bundle=secrets/secretsbundle.yaml
  - name: e1-k8s-lab-f-ca
    files:
      - tls.crt=secrets/tls.crt
      - tls.key=secrets/tls.key
generatorOptions:
  disableNameSuffixHash: true
  labels:
    cluster.x-k8s.io/cluster-name: e1-k8s-lab-f
```

---

# step 3: add ClusterAPI nodes

<figure class="justify-items-center">
  <img border="rounded" src="./images/migration-1:3.png" width="70%" alt="">
</figure>

---

# step 3: add ClusterAPI nodes

<figure class="justify-items-center">
  <img border="rounded" src="./images/migration-2:3.png" width="70%" alt="">
</figure>

---

# step 3: add ClusterAPI nodes

<figure class="justify-items-center">
  <img border="rounded" src="./images/migration-3:3.png" width="70%" alt="">
</figure>

---
class: justify-items-start
---

# step 3: create ClusterAPI nodes
What could go wrong after all?

- mismatched `--service-account-issuer` config:

  ```log
  [authentication.go:73] "Unable to authenticate the request" err="invalid bearer token"
  ```

- `etcd` encryption key missing:

  ```log
  [reflector.go:561] storage/cacher.go:/secrets: failed to list *core.Secret: unable 
  to transform key "/registry/secrets/appl-titi/toto-secret": no matching prefix found
  ```

- wrong `etcd` encryption key

  ```log
  [transformer.go:163] "failed to decrypt data" err="output array was not large enough for encryption"
  ```

- loss of quorum: use the `--force-new-cluster` to recover one node

---
layout: two-cols-header
layoutClass: gap-4
class: justify-items-start
---

# Demo


::left::

<br>
<br>
<br>
<br>
<br>
<br>

## Live migration 🎢


::right::

<figure>
  <img border="rounded" src="./images/clusterapi-cuttle.webp" width="95%" alt="">
  <footer><cite style="font-size: 70%;display: block;text-align: center;" >Created with FLUX.1 [dev] by Black Forest Labs</cite></footer>
</figure>

---
layout: two-cols-header
layoutClass: gap-4
class: justify-items-start
---

# Bootstrapping Issue
The Chicken & Egg problem

::left::

<figure>
  <img border="rounded" src="./images/chicken-or-egg.jpeg" width="95%" alt="">
  <footer><cite style="font-size: 70%;display: block;text-align: center;" >Created with FLUX.1 [dev] by Black Forest Labs</cite></footer>
</figure>

<br>
<br>

::right::

<figure>
  <img border="rounded" src="./images/bootstrapping.png" width="100%" alt="">
</figure>

---

# Conclusion


<figure place-items="center">
  <img border="rounded" src="./images/migration.png" width="60%" alt="">
</figure>


---

# Questions?


<a href="https://clement.n8r.ch/en/articles/" style="font-size: 1.5rem;" target="_blank" alt="Blog" class="absolute right-6rem top-15rem m-6 text-xl">clement.n8r.ch</a>

<a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" alt="Blog"
  class="absolute right-4rem top-15rem m-6  text-xl icon-btn opacity-100 !border-none "><carbon-logo-linkedin />
</a>

<a href="https://github.com/clementnuss" target="_blank" alt="GitHub"
  class="absolute right-2rem top-15rem m-6 text-xl icon-btn opacity-100 !border-none"><carbon-logo-github />
</a>

<!-- <img border="rounded" src="./images/KubeConLondon.png" width="30%" class="absolute bottom-1rem left-2rem "> -->

<img border="rounded" src="./images/KubeConlogo.png" width="87%" class="absolute justify-items-center bottom-1rem">



---

# Templating Talos Configs


```bash
yq '(.. | select(has("yq_load_str"))) |= load_str(.yq_load_str)'
```

````md magic-move

```yaml
---
apiVersion: bootstrap.cluster.x-k8s.io/v1alpha3
kind: TalosConfigTemplate
metadata:
  name: config-template-20250326001
spec:
  template:
    spec:
      generateType: worker
      strategicPatches:
        - yq_load_str: config/lab/strategic-patches.yaml
        - yq_load_str: config/lab/registries.yaml
        - yq_load_str: config/lab/ca-certificates.yaml
        - yq_load_str: config/lab/log-config.yaml
```

```yaml {10-18}
---
apiVersion: bootstrap.cluster.x-k8s.io/v1alpha3
kind: TalosConfigTemplate
metadata:
  name: config-template-20250326001
spec:
  template:
    spec:
      generateType: worker
      strategicPatches:
        - | # strategic-patches.yaml content
          cluster:
            apiServer:
              extraArgs:
          ...
        - | # registries.yaml content
          ...
```
````

---

# ArgoCD AppSets


<figure class="justify-items-center" >
  <img border="rounded" src="./images/appsets.png" width="80%" alt="">
</figure>

