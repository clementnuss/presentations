---
theme: ./theme
themeConfig:
  primary: "#795649"
title: "TOPF: Open-Sourcing PostFinance's Tool to Migrate and Manage Talos Linux Clusters"
author: Clément Nussbaumer
info: |-
  Join us as we walk through our migration journey from kubeadm to Talos Linux
  at PostFinance, and learn about the tooling we built and open-sourced along
  the way: TOPF (Talos Orchestrator by PostFinance).

  TOPF is a Go tool that manages the full lifecycle of Talos-based Kubernetes
  clusters - from bootstrapping and config management with pre-flight checks and
  dry-run diffs, to rolling Talos OS upgrades across nodes. Its layered YAML
  patch model keeps configuration DRY and makes pull request reviews
  straightforward, whether you're managing one cluster or many environments.

  We'll demo the tool, show how we use it in our GitLab pipelines for day-2
  operations, and share honest lessons from an ongoing migration at a financial
  institution.

class: text-center
highlighter: shiki
hideInToc: true
layout: default
exportFilename: topf-cloudnative-zurich-2026
---

<img src="./images/topf-logo.png" class="absolute top-6 right-8 w-32 opacity-90" alt="TOPF">

<div class="flex flex-col justify-start items-center" style="min-height: 45vh; padding-top: 0;">

<h1 class="text-6xl font-bold" style="color: #222831;">TOPF</h1>
<h2 class="text-3xl mt-6" style="color: #795649;">Open-Sourcing PostFinance's Tool to Migrate</h2>
<h2 class="text-3xl mt-6" style="color: #795649;">and Manage Talos Linux Clusters</h2>

<p class="mt-10 text-xl" style="color: #222831;"><strong>Clément Nussbaumer</strong> — PostFinance</p>

<div class="mt-6 flex items-center gap-4">
<a href="https://clement.n8r.ch/en/articles/" style="font-size: 1.3rem; color: #222831;" target="_blank">clement.n8r.ch</a>
<img src="./images/Jura.png" width="23rem" alt="Jura flag">
<a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" style="color: #222831;"
  class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-linkedin />
</a>
<a href="https://github.com/clementnuss" target="_blank" style="color: #222831;"
  class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-github />
</a>
</div>

</div>

<img src="./images/zurihline.png" class="absolute bottom-0 left-0 w-full pointer-events-none" style="opacity: 0.9; transform: scaleY(0.75); transform-origin: bottom;" alt="Zurich skyline">

<!--
Introduce myself: SRE at PostFinance, 5+ years operating Kubernetes platform.
Today: the story of how we ended up building and open-sourcing a tool for
managing Talos Linux clusters.
-->

---

# Outline

<br>

<div class="grid grid-cols-2 gap-8">
<div class="bg-white bg-opacity-80 rounded-lg p-6 border border-gray-200 shadow-md">

### 1. Why Talos Linux
Immutable, minimal, secure

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-6 border border-gray-200 shadow-md">

### 2. The ClusterAPI Dead-End
Why we pivoted away from CAPI

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-6 border border-gray-200 shadow-md">

### 3. Introducing TOPF
Layered config, dry-run, lifecycle management

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-6 border border-gray-200 shadow-md">

### 4. Live Demo
And key takeaways

</div>
</div>

---

# Talos Linux
[The 12 binaries' O.S.](https://www.siderolabs.com/blog/there-are-only-12-binaries-in-talos-linux/)

<div class="grid grid-cols-4 gap-4">
<div class="col-span-2 flex flex-col flex-items-start">

> immutable, minimal, secure
> declarative configuration file and gRPC API [^talos-philosophy]

[^talos-philosophy]: <https://www.talos.dev/v1.12/learn-more/philosophy/>

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
  <img border="rounded" src="./images/talos-overview.png" class="m-0" width="95%" alt="">
</figure>
</div>
</div>

<!--
Talos is a Linux distribution designed for Kubernetes. Only 12 binaries.
Immutable root filesystem, no SSH, everything via gRPC API or declarative config.
This is what drew us to Talos for our infrastructure.
-->

---

# Starting Point
kubeadm + Ansible — battle-tested, but imperative

<div class="grid grid-cols-3 gap-4 mt-8">

<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md text-center">
<div class="text-4xl font-700" style="color: #795649;">3,161</div>
<div class="text-base opacity-70 mt-1">commits · ~9.7k LOC</div>
</div>

<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md text-center">
<div class="text-4xl font-700" style="color: #795649;">340+</div>
<div class="text-base opacity-70 mt-1">releases · K8s v1.15 → v1.35</div>
</div>

<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md text-center">
<div class="text-4xl font-700" style="color: #795649;">32</div>
<div class="text-base opacity-70 mt-1">Ansible task files · 20 templates</div>
</div>

</div>

<div class="flex justify-center items-center gap-6 mt-10 text-2xl">
<span class="opacity-70">imperative Ansible + kubeadm</span>
<carbon-arrow-right style="color: #795649;" />
<span class="font-700" style="color: #795649;">declarative Talos</span>
</div>

<!--
Our starting point: a hugely battle-tested kubeadm + Ansible system. 3000+
commits, 340+ releases across two major Kubernetes versions, deep coverage —
init, upgrades, resets, etcd, addons, preflight checks — all Ansible templating
kubeadm configs.

It works. But it's imperative, fragile, hard to audit, not fully idempotent.
We wanted to move to Talos's declarative, opinionated node-image model.
-->

---

# Our initial plan: ClusterAPI + Talos

<div class="grid grid-cols-5 gap-4">
<div class="col-span-2 flex flex-col flex-items-start">

<br>

- **declarative** cluster lifecycle
- MachineDeployments — Deployments, but for nodes
- Talos provider for machine config
- GitOps-friendly: ArgoCD watches the CRDs

</div>
<div class="col-span-3">
<figure>
  <img border="rounded" src="./images/clusterapi-overview.png" width="95%" alt="">
</figure>
</div>
</div>

<!--
We planned to migrate to ClusterAPI with Talos. CAPI gives you declarative
cluster management, machine rollouts, GitOps integration. It looked great on
paper. We even gave talks about it.
-->

---

# Change of Plans
why we're not doing ClusterAPI (for now)

<div class="grid grid-cols-2 gap-8 mt-4">
<div class="flex flex-col">

## SideroLabs pivoted

- Talos CAPI providers → **low priority** [^issue]
- focus moved to [**Omni**](https://omni.siderolabs.com/) [^blog]

## Our concerns

- Kubernetes to manage Kubernetes
- in-place upgrades vs. machine replacement
- CAPI complexity vs. our simplicity goal

</div>
<div class="flex flex-col">

## So, our options

- **Omni** — becomes an authn proxy in front of the API server (`client → Omni → apiserver`)
- **Ansible** wrapping `talosctl`? 😬
- a **purpose-built tool** for Talos 🪴

</div>
</div>

[^issue]: <https://github.com/siderolabs/cluster-api-bootstrap-provider-talos/issues/193#issuecomment-2449472526>
[^blog]: <https://www.siderolabs.com/blog/kubernetes-cluster-full-lifecycle-management-without-cluster-api/>

<!--
SideroLabs deprioritized the CAPI providers and shifted focus to Omni. That
left us with: Omni, Ansible-wrapping-talosctl (no thank you), or building our
own purpose-built tool.

The dealbreaker with Omni: it inserts itself as an authentication proxy in
front of the Kubernetes API server — every client request flows
client → Omni → apiserver. We didn't want Omni in the critical path for all
cluster access.

References:
- GitHub issue siderolabs/cluster-api-bootstrap-provider-talos#193
- SideroLabs blog: full lifecycle management without Cluster API
-->

---
class: text-center
---

# Thing

<div class="flex flex-col items-center">
<figure>
  <img border="rounded" src="./images/topf-thing-drawing.jpeg" class="mx-auto" style="max-width: 75%; max-height: 65vh;" alt="">
  <footer><cite style="font-size: 70%;display: block;text-align: center;">The original whiteboard sketch of what would become TOPF</cite></footer>
</figure>
</div>

<!--
This is where it started. A whiteboard sketch of what we needed:
something that takes declarative config, applies it with safety checks,
and handles upgrades. We didn't have a name yet. We just called it "the thing".
-->

---

# TOPF
[Talos Orchestrator by PostFinance](https://github.com/postfinance/topf/)

<div class="mt-10 text-3xl font-500" style="color: #795649;">

Not an operator. Not a controller. A CLI tool.

</div>

<div class="grid grid-cols-3 gap-6 mt-10">

<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">
<div class="text-2xl font-700" style="color: #795649;"><carbon-data-collection /> gathers</div>
<div class="mt-2 text-lg">inventory / secrets / layered config</div>
</div>

<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">
<div class="text-2xl font-700" style="color: #795649;"><carbon-document /> renders</div>
<div class="mt-2 text-lg">individual machine configs</div>
</div>

<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">
<div class="text-2xl font-700" style="color: #795649;"><carbon-deploy /> applies</div>
<div class="mt-2 text-lg">to nodes &mdash; apply / upgrade</div>
</div>

</div>

<div class="absolute bottom-10 right-10 text-base text-gray-500 text-right leading-relaxed">

MIT licensed<br>
<code>brew install postfinance/tap/topf</code>

</div>

<!--
TOPF is born. A purpose-built tool for Talos. Stateless, minimal Go binary —
no reconciliation loop.

No talosctl dependency — uses the Talos Go SDK directly. Same operations as
talosctl but automated, with pre-flight checks and dry-run diffs.

MIT licensed. brew install postfinance/tap/topf
-->

---

# What `topf` does

<div class="grid grid-cols-3 gap-6 mt-8">

<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">
<div class="text-2xl font-700" style="color: #795649;"><carbon-deploy /> apply</div>
<div class="mt-2 text-lg">render + push machine configs to nodes</div>
</div>

<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">
<div class="text-2xl font-700" style="color: #795649;"><carbon-document /> render</div>
<div class="mt-2 text-lg">generate machine configs locally</div>
</div>

<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">
<div class="text-2xl font-700" style="color: #795649;"><carbon-upgrade /> upgrade</div>
<div class="mt-2 text-lg">Talos OS version, safely</div>
</div>

<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">
<div class="text-2xl font-700" style="color: #795649;"><carbon-reset /> reset</div>
<div class="mt-2 text-lg">wipe a node back to maintenance</div>
</div>

<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">
<div class="text-2xl font-700" style="color: #795649;"><carbon-id-management /> talosconfig</div>
<div class="mt-2 text-lg">client config for <code>talosctl</code></div>
</div>

<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">
<div class="text-2xl font-700" style="color: #795649;"><carbon-settings /> kubeconfig</div>
<div class="mt-2 text-lg">client config for <code>kubectl</code></div>
</div>

</div>

<!--
The main verbs. apply and upgrade are the day-to-day ones. render is great for
GitOps diffs in CI. reset for decommissioning. talosconfig/topfconfig are the
helper commands to bootstrap your tooling.
-->

---

# Layered YAML Patches

<div class="grid grid-cols-2 gap-8">
<div class="flex flex-col">

```text
.
├── all/
│   └── 01-install-disk.yaml
└── topf.yaml
```

<div class="mt-4 text-lg opacity-70">

Start simple: one patch applied to **every** node.

</div>

</div>
<div class="flex flex-col">

```yaml
# all/01-install-disk.yaml
machine:
  install:
    disk: /dev/sda
```

</div>
</div>

<!--
Start with the simplest possible setup. Just topf.yaml and one patch in all/
that every node gets — here, where to install Talos.
-->

---

# Layered YAML Patches

<div class="grid grid-cols-2 gap-8">
<div class="flex flex-col">

```text
.
├── all/
│   └── 01-install-disk.yaml
├── control-plane/
│   └── 01-allow-scheduling.yaml
├── worker/
│   └── 01-gpu.yaml
└── topf.yaml
```

<div class="mt-4 text-lg opacity-70">

Add **role** layers: control-plane and worker get their own patches.

</div>

</div>
<div class="flex flex-col">

```yaml
# control-plane/01-allow-scheduling.yaml
cluster:
  allowSchedulingOnControlPlanes: true
```

```yaml
# worker/01-gpu.yaml
machine:
  kernel:
    modules:
      - name: nvidia
      - name: nvidia_uvm
```

</div>
</div>

<!--
Now add role-specific layers. Control-plane nodes allow scheduling, workers
load the NVIDIA kernel modules for GPU workloads. Each node only gets the
patches for its role.
-->

---

# Layered YAML Patches

<div class="grid grid-cols-2 gap-8">
<div class="flex flex-col">

```text
.
├── all/
│   ├── 01-install-disk.yaml
│   └── 02-provider-id.yaml.tpl
├── control-plane/
│   └── 01-allow-scheduling.yaml
├── worker/
│   └── 01-gpu.yaml
├── node/
│   └── node1/
│       └── 01-install-disk.yaml
└── topf.yaml
```

</div>
<div class="flex flex-col">

```yaml
# all/02-provider-id.yaml.tpl
machine:
  kubelet:
    extraArgs:
      provider-id: {{ .Node.Data.uuid }}
```

```yaml
# node/node1/01-install-disk.yaml
# node1 has different hardware → override
machine:
  install:
    disk: /dev/nvme0n1
```

</div>
</div>

<div class="mt-6 p-4 bg-white bg-opacity-80 rounded-lg border-l-4 border-amber-800 shadow-md text-lg">

<carbon-code class="inline" style="color: #795649;" /> Go templating (`.yaml.tpl`) and the **sprig** library are available in any layer, with cluster + node context (`.Node.Host`, `.Node.IP`, `.Node.Data.<key>`, …).

</div>

<!--
Two things here. First, templating isn't a node/ thing — the provider-id
template lives in all/ and fills each node's UUID from its data. Second, the
node/ layer is for genuine per-node overrides: node1 has different hardware,
so it overrides the install disk set in all/. More-specific layer wins.
Strategic merge patches only; JSON patches are gone in Talos 1.12+.
-->

---
layout: center
class: text-center
---

<img src="./images/topf-logo.png" class="w-40 mx-auto mb-6" alt="TOPF">

# Live Demo 🪴

<p class="text-3xl font-bold mt-4" style="color: #795649;">

[github.com/postfinance/topf](https://github.com/postfinance/topf/)

</p>

<!--
Live demo plan:

1. Two VMs running in UTM (fresh Talos, maintenance mode).
2. Write a minimal topf.yaml with a single control-plane node.
3. topf apply --auto-bootstrap → applies config and bootstraps the cluster
   in one shot.
4. Add a patch to allow scheduling on the control-plane (so we can run
   workloads on a single node).
5. Add the second VM as a worker in topf.yaml, then topf apply → the worker
   joins the cluster.
6. Plot twist: a "leaky vessels" runc CVE drops → we need to patch the OS.
   Run topf upgrade to roll the Talos OS version across the nodes.
-->

---

# What's New

<div class="text-xl opacity-70 mt-2">recent additions since the first release</div>

<div class="grid grid-cols-3 gap-6 mt-8">

<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">
<div class="text-2xl font-700" style="color: #795649;"><carbon-image-service /> Schematic resolution</div>
<div class="mt-2 text-lg">reference <code>@schematic.yaml</code> instead of hashes — IDs computed locally, optional <code>--submit-to-factory</code></div>
</div>

<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">
<div class="text-2xl font-700" style="color: #795649;"><carbon-password /> <a href="https://github.com/helmfile/vals" target="_blank" style="color: #795649;">vals</a> secret resolution</div>
<div class="mt-2 text-lg">pull secrets at render time via <code>ref+vault://</code>, <code>ref+gcpsecrets://</code>, <code>ref+file://</code>, … (alongside existing SOPS)</div>
</div>

<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">
<div class="text-2xl font-700" style="color: #795649;"><carbon-function /> sprig templating</div>
<div class="mt-2 text-lg">full sprig function library in <code>.yaml.tpl</code> patches (<code>env</code>, <code>default</code>, <code>b64enc</code>, …)</div>
</div>

</div>

<div class="mt-6 text-base opacity-60 text-center">

also recent: concurrent apply / upgrade with <code>--max-parallel</code> · Talos v1.13 support

</div>

<!--
A quick tour of what's landed recently. Schematic resolution means you no longer
juggle factory hashes — point at a manifest and TOPF computes the ID locally.

On secrets: SOPS has been there from the start, and we just added vals to pull
secrets at render time from Vault and friends. Both run before patches are merged.

Templating got the full sprig library, so patches can do real logic. And we
just added concurrent apply/upgrade with --max-parallel for bigger clusters.
-->

---

# Dynamic Providers

<div class="text-xl opacity-70 mt-2">plug TOPF into your infrastructure — no node lists baked into the config repo</div>

<div class="grid grid-cols-2 gap-8 mt-8">

<div class="bg-white bg-opacity-80 rounded-lg p-6 border border-gray-200 shadow-md">
<div class="text-2xl font-700" style="color: #795649;"><carbon-network-3 /> Nodes Provider</div>
<div class="mt-2 text-lg">a binary that outputs the node list</div>
<div class="mt-1 text-base opacity-70">cloud APIs · Terraform state · inventory systems</div>

```bash
<nodes-provider> nodes <clusterName>
```

</div>

<div class="bg-white bg-opacity-80 rounded-lg p-6 border border-gray-200 shadow-md">
<div class="text-2xl font-700" style="color: #795649;"><carbon-password /> Secrets Provider</div>
<div class="mt-2 text-lg">a binary that manages the secrets bundle</div>
<div class="mt-1 text-base opacity-70">Vault · corporate secrets management</div>

```bash
<secrets-provider> secrets get <clusterName>
```

</div>

</div>

<div class="mt-6 p-4 bg-white bg-opacity-80 rounded-lg border-l-4 border-amber-800 shadow-md text-lg">

<carbon-plug class="inline" style="color: #795649;" /> Nodes from a provider are **merged** with the static nodes in `topf.yaml`.

</div>

<!--
Dynamic providers are TOPF's plugin system. Instead of hardcoding node lists,
you point TOPF at a binary that returns nodes — from a cloud API, Terraform
state, or an inventory system. Same idea for secrets. At PostFinance the nodes
provider hits our internal inventory and the secrets provider talks to Vault.
-->

---

# TOPF in GitLab CI
one pipeline per cluster — GitOps for day-2 ops

<div class="grid grid-cols-5 gap-6 mt-4">
<div class="col-span-3">

```yaml
# .gitlab-ci.yml
default:
  before_script:
    - git clone --branch "$CONFIG_REF" "https://$CONFIG_REPO" .

dry-run:
  script: topf apply --dry-run

apply:
  script: topf apply --confirm=false
  when: manual

upgrade:
  script: topf upgrade --confirm=false
  when: manual
```

</div>
<div class="col-span-2 flex flex-col justify-center">

<div class="flex items-center gap-3 text-xl">
<carbon-list style="color: #795649;" /> <span>pipeline runs <strong>dry-run</strong> diff</span>
</div>

<div class="flex items-center gap-3 text-xl mt-4">
<carbon-checkmark-outline style="color: #795649;" /> <span>review the plan</span>
</div>

<div class="flex items-center gap-3 text-xl mt-4">
<carbon-rocket style="color: #795649;" /> <span><strong>apply</strong> &amp; <strong>upgrade</strong> are manual</span>
</div>

</div>
</div>

<!--
This is how we run TOPF in production. Each cluster has its own pipeline. Every
run does a dry-run so you can review the diff; apply and upgrade are both manual
gates — nothing touches the cluster unless someone clicks it. Terraform-style
plan/apply, but for Talos.
-->

---

# TOPF vs Alternatives

<div class="grid grid-cols-3 gap-6 mt-4">
<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">

### **scripts / Ansible**

Imperative `talosctl` wrapping

- no safety net, hard to audit

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">

### **talhelper**

Declarative config generation

- but you still apply & manage lifecycle

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">

### **Omni** (SideroLabs)

Turnkey managed platform

- authn proxy in front of the API server

</div>
</div>

<div class="mt-12 px-6">

<div class="flex justify-between text-sm opacity-60 mb-3">
<span>least integrated · DIY</span>
<span>turnkey · managed</span>
</div>

<div class="relative">
<div class="absolute left-0 right-0 h-1 rounded-full" style="top: 0.4rem; background: linear-gradient(90deg, #cbbfb9, #795649);"></div>
<div class="relative flex justify-between text-center text-base">

<div class="flex flex-col items-center w-40">
<div class="w-4 h-4 rounded-full border-2 border-white shadow" style="background: #b0a39c;"></div>
<div class="mt-2">scripts / Ansible</div>
</div>

<div class="flex flex-col items-center w-40">
<div class="w-4 h-4 rounded-full border-2 border-white shadow" style="background: #9a8478;"></div>
<div class="mt-2">talhelper</div>
</div>

<div class="flex flex-col items-center w-40">
<div class="w-6 h-6 rounded-full border-2 border-white shadow-lg" style="background: #795649;"></div>
<div class="mt-2 font-700" style="color: #795649;">TOPF</div>
</div>

<div class="flex flex-col items-center w-40">
<div class="w-4 h-4 rounded-full border-2 border-white shadow" style="background: #5d4037;"></div>
<div class="mt-2">Omni</div>
</div>

</div>
</div>
</div>

<!--
The landscape, from least integrated to turnkey. On the left, DIY scripts or
Ansible wrapping talosctl — same imperative idea, no safety net. talhelper is a
step up: it generates configs declaratively, but you still apply and manage
lifecycle yourself. On the far right, Omni: a full managed platform, but it sits
in the critical path as an authn proxy.

TOPF lands in the sweet spot — declarative, layered config and full lifecycle
with safety checks, MIT licensed, no platform to run, no proxy in front of your
API server.
-->

---

# Key Takeaways

<div class="grid grid-cols-2 gap-8 mt-10 text-sm">
<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">

### **Talos is the future**

Immutable, minimal, declarative. The right OS for Kubernetes nodes.

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">

### **CAPI isn't the only path**

Siderolabs deprioritized CAPI providers. Building purpose-built tools is a valid alternative.

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">

### **Layered patches = DRY + reviewable**

`all/` → `control-plane/` → `worker/` → `node/<host>/`. PRs are easy to review.

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">

### **TOPF is open source**

MIT licensed. Single Go binary. Production-tested at PostFinance. Try it today.

</div>
</div>

<!--
Summarize the key points. Talos is the way forward. CAPI isn't the only option.
TOPF's layered patch model is both DRY and PR-friendly. And it's open source —
go try it.
-->

---

<div class="grid grid-cols-5 gap-6 h-full items-center">
<div class="col-span-3">

## Thank you!

<div class="grid grid-cols-2 gap-4 mt-4">
<div class="bg-white bg-opacity-80 rounded-lg p-4 border border-gray-200 shadow-md text-sm">

**[TOPF on GitHub](https://github.com/postfinance/topf/)**

Open-source Talos lifecycle manager

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-4 border border-gray-200 shadow-md text-sm">

**[Talos Linux](https://www.talos.dev/)**

The Kubernetes OS

</div>
</div>

<div class="mt-6 flex items-center gap-4">
<a href="https://clement.n8r.ch/en/articles/" style="font-size: 1.1rem; color: #222831;" target="_blank">clement.n8r.ch</a>
<img src="./images/Jura.png" width="20rem" alt="Jura flag">
<a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" style="color: #222831;"
  class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-linkedin />
</a>
<a href="https://github.com/clementnuss" target="_blank" style="color: #222831;"
  class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-github />
</a>
</div>

</div>
<div class="col-span-2 flex flex-col items-center text-center">

<img src="./images/postfinance-logo.png" style="width: 22rem;" alt="PostFinance">

<img src="./images/topf-logo.png" style="width: 11rem;" alt="TOPF" class="mt-8">

<div class="mt-3 text-lg font-bold">Questions?</div>

</div>
</div>
