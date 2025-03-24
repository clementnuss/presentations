---
theme: seriph
themeConfig:
  primary: '#E85C0D'
# color palette: #FABC3F #E85C0D #C7253E #821131
background: /images/IMG_0719_Original.jpeg
layout: cover
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
---

# Day-2'099 Migration
## from kubeadm+Ansible to ClusterAPI+Talos
## A Swiss Bank’s Journey

KubeCon EU 2025 - London

**Clément Nussbaumer**

<a href="https://clement.n8r.ch/en/articles/" style="font-size: 1.5rem;" target="_blank" alt="Blog" class="absolute right-6rem bottom-30px m-6 text-xl">clement.n8r.ch</a>

<a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" alt="Blog"
  class="absolute right-4rem bottom-30px m-6  text-xl icon-btn opacity-100 !border-none "><carbon-logo-linkedin />
</a>

<a href="https://github.com/clementnuss" target="_blank" alt="GitHub"
  class="absolute right-2rem bottom-30px m-6 text-xl icon-btn opacity-100 !border-none"><carbon-logo-github />
</a>

---

# Longevity of a K8s Cluster

How old can your clusters get?

<div class="grid grid-cols-5 gap-4">
<div class="col-span-2 flex flex-col flex-items-start">


```shell
> kubectl get namespace kube-system
NAME          STATUS   AGE
kube-system   Active   5y273d
```

```text

     5 years (365.25 days)
 + 273 days
= 2099 days
```

</div>

<div place-items="center" class="flex col-span-3">
<figure>
  <img border="rounded" src="./images/postfinance-intro.webp" width="70%" alt="">
  <footer><cite style="font-size: 70%;display: block;text-align: center;" >Created with FLUX.1 [schnell] by Black Forest Labs</cite></footer>
</figure>
</div>

<!--
insert picture of an old looking cluster
-->
</div>

---
src: ./slides/intro-pf.md
---
---
title: Our Journey
---

# Our Journey
Agenda

1. Starting Point
1. Destination
1. Cluster API
1. Talos Linux
1. Migration


---

# Starting Point
Legacy cluster provisioning

<div class="grid grid-cols-4 gap-4">
<div class="col-span-2">

1. provision Debian VMs (terraform)
1. deploy/configure base tools
1. register nodes in `inventory.yml`
1. run Ansible playbook:
   - render config files, base manifests, ...
   - run `kubeadm` commands
1. configure ArgoCD integration

</div>
<div class="col-span-2">
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

<div class="grid grid-cols-4 gap-4">
<div class="col-span-2">

<figure>
  <img border="rounded" src="./images/clusterapi-overview.png" width="100%" alt="">
  <!-- <footer><cite style="font-size: 70%;display: block;text-align: center;" >Current cluster provisioning pipeline overview</cite></footer> -->
</figure>


</div>
<div class="col-span-2 flex flex-col flex-items-start">

```text
❯ kubectl get clusters --all-namespaces
NAMESPACE    NAME           AGE
capi-lab-a   e1-k8s-lab-a   29d
capi-lab-b   e1-k8s-lab-b   95d
capi-lab-c   e1-k8s-lab-c   95d
```

```text
❯ kubectl get machinedeployments
NAME                        REPLICAS AGE    VERSION
e1-k8s-pfnet-lab-a-md-002   2        5d5h   v1.30.5
e1-k8s-pfnet-lab-a-md-1     1        19d    v1.31.4
```

```text
❯ kubectl get machines
NAME                       PHASE     AGE    VERSION
lab-a-md-002-8q69n-lr7ch   Running   5d4h   v1.30.5
lab-a-md-002-8q69n-lwx4t   Running   4d2h   v1.30.5
lab-a-md-1-8zh2h-4rtb9     Running   19d    v1.31.5
```


</div>
</div>

---

# Talos Linux
[The 12 binaries' O.S.](https://www.siderolabs.com/blog/there-are-only-12-binaries-in-talos-linux/)



<div class="grid grid-cols-4 gap-4">
<div class="col-span-2 flex flex-col flex-items-start">


> immutable, atomic ephemeral. \
> managed via a single declarative configuration file and gRPC API


```text
❯ talosctl services
SERVICE              STATE     HEALTH
apid                 Running   OK    
containerd           Running   OK    
cri                  Running   OK    
dashboard            Running   ?     
etcd                 Running   OK    
ext-talos-vmtoolsd   Running   ?     
kubelet              Running   OK    
machined             Running   OK    
syslogd              Running   OK    
trustd               Running   OK    
udevd                Running   OK    
```

</div>
<div class="col-span-2">
<figure>
  <img border="rounded" src="./images/talos-overview.png" width="80%" alt="">
  <!-- <footer><cite style="font-size: 70%;display: block;text-align: center;" >Current cluster provisioning pipeline overview</cite></footer> -->
</figure>
</div>
</div>

