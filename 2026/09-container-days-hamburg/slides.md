---
theme: ./theme
themeConfig:
  primary: "#795649"
title: "TOPF: Open-Sourcing PostFinance's Tool to Migrate and Manage Talos Linux Clusters"
author: Clément Nussbaumer, Sebastian Stephan
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
exportFilename: topf-container-days-hamburg-2026
---

<img src="./images/postfinance-logo.png" class="absolute left-1/2" style="top: 1.5rem; transform: translateX(-50%); width: 9rem;" alt="PostFinance">

<div class="flex flex-col justify-start items-center" style="min-height: 45vh; padding-top: 3rem;">

<div class="flex items-center gap-5">
<img src="./images/topf-logo.png" style="width: 5.5rem;" alt="TOPF">
<h1 class="text-6xl font-bold" style="color: #222831;">TOPF</h1>
</div>
<h2 class="text-3xl mt-5" style="color: #795649;">Open-Sourcing PostFinance's Tool to Migrate</h2>
<h2 class="text-3xl mt-4" style="color: #795649;">and Manage Talos Linux Clusters</h2>

<div class="mt-8 flex items-start justify-center gap-14">

<div class="flex flex-col items-center">
<p class="text-xl" style="color: #222831;"><strong>Clément Nussbaumer</strong></p>
<div class="mt-2 flex items-center gap-3">
<a href="https://clement.n8r.ch/en/articles/" style="font-size: 1.1rem; color: #222831;" target="_blank">clement.n8r.ch</a>
<a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" style="color: #222831;"
  class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-linkedin />
</a>
<a href="https://github.com/clementnuss" target="_blank" style="color: #222831;"
  class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-github />
</a>
</div>
</div>

<div class="flex flex-col items-center">
<p class="text-xl" style="color: #222831;"><strong>Sebastian Stephan</strong></p>
<div class="mt-2 flex items-center gap-3">
<a href="https://stephan.li" style="font-size: 1.1rem; color: #222831;" target="_blank">stephan.li</a>
<a href="https://www.linkedin.com/in/sebastian-stephan-ab128617b/" target="_blank" style="color: #222831;"
  class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-linkedin />
</a>
<a href="https://github.com/sebastian-stephan" target="_blank" style="color: #222831;"
  class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-github />
</a>
</div>
</div>

</div>

</div>

<img src="./images/CDS2026-hero-skyline.svg" class="absolute bottom-0 left-1/2 pointer-events-none" style="width: 92%; opacity: 0.9; transform: translateX(-50%);" alt="ContainerDays Hamburg skyline">

---

# Kubernetes at PostFinance


<img src="./images/postfinance-logo.png" class="absolute top-6 right-8" style="width: 11rem;" alt="PostFinance">

- Systemic Swiss bank
- ~35 vanilla (kubeadm) Kubernetes clusters
- ~55 TiB Memory, largest cluster 133 Nodes
- Air-gapped environment
- 2 on-prem datacenters - VSphere Virtualization
- Chaos Monkey on all clusters 🐒 ([postfinance/chaosmonkey](https://github.com/postfinance/chaosmonkey))
- Oldest cluster:

```console
k get ns kube-system
NAME          STATUS   AGE
kube-system   Active   7y53d
```

---

# Starting Point

Debian + kubeadm + Ansible

<div class="grid grid-cols-2 gap-10 mt-6 items-start">
<div class="flex flex-col">

<div class="text-lg leading-relaxed">

- **32** Ansible task files · **1,878** lines of playbooks
- **20** Jinja2 templates — kubeadm, containerd, sysctl, …
- not idempotent

</div>

</div>
<div class="relative flex items-center justify-center" style="min-height: 22rem; border-radius: 0.5rem;">

<v-click at="1">
<div class="absolute" style="width: 26rem; transform: rotate(-6deg) translate(0rem, -6rem); background: #fff8dc; padding: 0.8rem 0.9rem; border-radius: 2px; box-shadow: 0 6px 14px rgba(0,0,0,0.35); --slidev-code-font-size: 0.80rem; --slidev-code-line-height: 1.3;">

```yaml
- name: Kubeadm master - kubeadm_prepare
  with_items: "{{ ansible_play_hosts }}"
  when:
    # this line does the trick ;-)
    - hostvars[host_item].inventory_hostname 
      == inventory_hostname
  loop_control:
    loop_var: host_item
  include_tasks: kubeadm_prepare/main.yml
```

</div>
</v-click>

<v-click at="2">
<div class="absolute" style="width: 30rem; transform: rotate(4deg) translate(0rem, -1.5rem); background: #e8f4d9; padding: 0.8rem 0.9rem; border-radius: 2px; box-shadow: 0 6px 14px rgba(0,0,0,0.35); --slidev-code-font-size: 0.8rem; --slidev-code-line-height: 1.3;">

```yaml
- name: Kernel | Set reboot fact to true when cri 
        socket/kubelet conf does not exist and kernel 
        cmdline is wrong
  set_fact:
    reboot: true
  when:
    - not cri_sock_result.stat.exists
    - not kubelet_stat.stat.exists
    - 'not "systemd.unified_cgroup_hierarchy" in 
       proc_cmdline.stdout'
    - 'not "systemd.legacy_systemd_cgroup_controller" in 
       proc_cmdline.stdout'
```

</div>
</v-click>

<v-click at="3">
<div class="absolute" style="width: 45rem; transform: rotate(-3deg) translate(-15rem, 4rem); background: #fbe4e4; padding: 0.8rem 0.9rem; border-radius: 2px; box-shadow: 0 6px 14px rgba(0,0,0,0.35); --slidev-code-font-size: 0.9rem; --slidev-code-line-height: 1.3;">

```
export ETCDCTL_ENDPOINTS="{%- for node in ansible_play_hosts -%}
https://{{ node }}:{{ etcd_listen_port }}{% if not loop.last -%},{% endif -%}
{%- endfor -%}"
```

</div>
</v-click>

<v-click at="4">
<div class="absolute" style="width: 33rem; transform: rotate(3deg) translate(-2.5rem, 6.5rem); background: #e0e7f5; padding: 0.8rem 0.9rem; border-radius: 2px; box-shadow: 0 6px 14px rgba(0,0,0,0.35); --slidev-code-font-size: 0.8rem; --slidev-code-line-height: 1.3;">

```yaml
- name: Node action | drain and act when needed
  when: |
    (node_restart_mode is defined and last_restart.stdout 
      | int > 72 * 3600) or
    (os_update is defined and dopatch_required) or
    (cri_update is defined and cri_update_needed)
```

</div>
</v-click>

</div>

</div>

<!--
Our starting point was a battle-tested kubeadm + Ansible system: 32 task files,
nearly 1,900 lines of playbooks, 20 Jinja2 templates for kubeadm, containerd,
sysctl and more. Real coverage — init, joins, upgrades, resets, etcd, preflight.

It was mostly idempotent, but not always. The classic trap: some actions — like
regenerating static pod manifests — were gated on the `changed` attribute of a
rendered template. If a job failed between rendering the template and running
the dependent action, the file was already written. On the next run Ansible saw
no change, the conditional didn't fire, and the action was silently skipped.

It wasn't terrible. But it had grown large, it was slow to develop against, and
it was getting harder and harder to maintain. We wanted Talos's declarative,
opinionated node-image model instead.
-->

---

# Talos Linux

[An operating system with exactly one job: run Kubernetes](https://docs.siderolabs.com/talos/v1.13/learn-more/philosophy)[^talos-philosophy]

<div class="grid grid-cols-2 gap-10 mt-8">
<div>

- < 50 OS binaries
- < 80 MB OS footprint
- Immutable root filesystem
- No package manager
- No SSH, no shell
- No shell
- Interaction purely through an (mTLS gRPC) API
- Declarative configuration

[^talos-philosophy]: <https://docs.siderolabs.com/talos/v1.13/learn-more/philosophy>

</div>
<div>

<v-click>

```console
$ cat machineconfig.yaml
version: v1alpha1
machine:
    install:
        disk: /dev/sda
...
cluster:
    network:
        podSubnets:
            - 10.244.0.0/16
        serviceSubnets:
            - 10.96.0.0/12
```

```console
$ talosctl apply -f machineconfig.yaml -n 10.0.1.11
Applied configuration without a reboot
```

</v-click>
</div>
</div>

<!--
Talos is a Linux distribution with a single purpose: running Kubernetes.
Fewer than 50 binaries, ~100 MB, immutable root filesystem.

No package manager, no SSH, no shell — there is no node to log into. You write
a machine config and apply it through the API, and the node converges.

That property is what made building tooling on top of it possible.
-->

---


# Our initial plan: ClusterAPI + Talos

<div class="grid grid-cols-5 gap-4">
<div class="col-span-2 flex flex-col flex-items-start">

<br>

- Declarative cluster lifecycle
- CRDs for clusters/nodes

**but...**

- Siderolabs shifted away from CAPI[^talos-capi-community]
- Kubernetes to manage Kubernetes
- CAPI complexity vs simplicity goal

</div>
<div class="col-span-3 h-full flex items-start justify-center">
  <div style="transform: scale(0.85);">
    <Excalidraw
      drawFilePath="./drawings/capi-overview.excalidraw"
    />
  </div>
</div>
</div>

[^talos-capi-community]: <https://www.siderolabs.com/blog/talos-linux-capi-community-maintenance>

<!--
We planned to migrate to ClusterAPI with Talos. CAPI gives you declarative
cluster management, machine rollouts, GitOps integration. It looked great on
paper. We even gave talks about it.

Kubernetes to manage Kubernetes: Chicken Egg
CAPI complexity: Don't delete your cluster by accident!
Shorter migration path: IPAM and other resources already via Terraform
                        static workload, no autoscaling required
                        easier to pre-provision VMs
Baremetal: Future workstream, goodbye vSphere
-->

---

# Our Options

<div class="mt-12 px-6">

<div class="grid gap-4 mb-8" style="grid-template-columns: 38% 22% 10% 30%;">

<div class="rounded-lg p-3 min-h-28 flex items-center justify-center" style="--slidev-code-font-size: 0.62rem; --slidev-code-line-height: 1.25;">

```yaml
- name: Apply Talos machine config
  ansible.builtin.command: |
    talosctl apply -f {{ config }}
```

</div>

<div class="rounded-lg p-3 min-h-28 flex flex-col items-center justify-center gap-2" style="transition: opacity 0.5s ease, filter 0.5s ease;" :style="$clicks >= 1 ? 'opacity: 0.4; filter: grayscale(1);' : ''">
<img src="./images/talhelper-logo.svg" style="height: 2.5rem;" alt="Talhelper logo">
<span class="text-sm">Talhelper</span>
</div>

<v-click at="2">
<div class="rounded-lg p-3 min-h-28 flex items-center justify-center">
<span class="text-5xl font-700" style="color: #795649;">?</span>
</div>
</v-click>

<div class="rounded-lg p-3 min-h-28 flex items-center justify-center gap-3">
<img src="./images/omni-logo.png" style="height: 2.5rem;" alt="Omni logo">
<span class="text-2xl" style="height: 2.5rem; line-height: 2.5rem;">Omni</span>
</div>

</div>

<div class="relative">
<div class="absolute left-0 right-0 h-1 rounded-full" style="top: 0.4rem; background: linear-gradient(90deg, #cbbfb9, #795649);"></div>
<div class="relative grid gap-4 text-center text-base" style="grid-template-columns: 38% 22% 10% 30%;">

<div class="flex flex-col items-center">
<div class="w-4 h-4 rounded-full border-2 border-white shadow" style="background: #b0a39c;"></div>
<div class="mt-2">manual</div>
</div>

<div class="flex flex-col items-center" style="transition: opacity 0.5s ease, filter 0.5s ease;" :style="$clicks >= 1 ? 'opacity: 0.4; filter: grayscale(1);' : ''">
<div class="w-4 h-4 rounded-full border-2 border-white shadow" style="background: #9a8478;"></div>
<div class="mt-2">config generator</div>
</div>

<v-click at="2">
<div class="flex flex-col items-center">
<div class="w-6 h-6 rounded-full border-2 border-white shadow-lg" style="background: #795649;"></div>
</div>
</v-click>

<div class="flex flex-col items-center">
<div class="w-4 h-4 rounded-full border-2 border-white shadow" style="background: #5d4037;"></div>
<div class="mt-2">turnkey</div>
</div>

</div>
</div>

<v-click at="1">
<div class="absolute" style="left: 50%; bottom: 3.5rem; width: 42rem; transform: translateX(-50%) rotate(-1.5deg); background: #ffffff; border: 1px solid rgba(121, 86, 73, 0.25); border-radius: 4px; box-shadow: 0 8px 22px rgba(0, 0, 0, 0.3); padding: 0.5rem 0.55rem 0.4rem;">

<div class="flex items-center gap-3">

<img src="./images/talhelper-archived.png" alt="Talhelper repository archived notice" style="flex: 1; min-width: 0; border: 1px solid #ddd; border-radius: 2px;">

<img src="./images/so-long-thanks-for-all-the-fish.jpg" alt="So long, and thanks for all the fish" style="height: 7.4rem; border-radius: 2px;">

</div>

<div class="text-center" style="font-size: 0.72rem; margin-top: 0.3rem;">
Archived on <strong>Aug 26th, 2026</strong>
</div>

</div>
</v-click>
</div>

<!--
SideroLabs deprioritized the CAPI providers and shifted focus to Omni. That
left us with: Omni, Ansible-wrapping-talosctl (no thank you), or building our
own purpose-built tool.

The dealbreaker with Omni: it inserts itself as an authentication proxy in
front of the Kubernetes API server — every client request flows
client → Omni → apiserver. We didn't want Omni in the critical path for all
cluster access.

By the way: Talhelper was archived on August 26th, 2026 — its README now
points users to topf and talstomize.

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
  <img border="rounded" src="./images/topf-thing-drawing.jpeg" class="mx-auto" style="max-width: 85%;" alt="">
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

<div class="grid grid-cols-3 gap-8 mt-6 items-center">
<div class="flex flex-col col-span-1">

<div class="text-3xl font-500" style="color: #795649;">

Not an operator.

Not a controller.

A CLI tool.

</div>

<div class="mt-2 text-base opacity-70 italic">

_Topf_ is also German for a **(plant) pot**

</div>

<!-- <img src="./images/topf-logo.png" class="w-40 mt-10" alt="TOPF"> -->

</div>
<div class="flex flex-col col-span-2">

<img src="./images/topf-documentation.png" class="rounded-lg border border-gray-300 shadow-md w-full" alt="TOPF Documentation">
<!-- <img src="./images/topf-github-repo.png" class="rounded-lg border border-gray-300 shadow-md w-full" alt="TOPF GitHub repository"> -->

</div>
</div>

<!--
That thing now has a name...

...

I'm going to show you what TOPF can do, and for that I'm going to start .....with a simple Hello world.
-->

---

# Hello World

<div class="grid grid-cols-2 gap-8">
<div class="flex flex-col">

<div v-if="$clicks < 1">
<pre class="topf-tree">
└── <span class="file-dot" style="color:#2563eb">●</span>topf.yaml</pre>
</div>

<div v-if="$clicks >= 1">
<pre class="topf-tree">
├── all/
│   └── <span class="file-dot" style="color:#059669">●</span>disk.yaml
└── <span class="file-dot" style="color:#2563eb">●</span>topf.yaml</pre>
</div>

<div class="mt-4 text-lg opacity-70" v-click>

Patches are just files with some Talos config, placed in `all/`.

</div>

</div>
<div class="flex flex-col">

<div class="file-badge"><span class="file-dot" style="color:#2563eb">●</span>topf.yaml</div>

```yaml
clusterName: my-cluster
clusterEndpoint: https://192.168.1.11:6443
nodes:
  - host: node1
    ip: 192.168.1.11
    role: control-plane
```

<div v-click="1">
<div class="file-badge"><span class="file-dot" style="color:#059669">●</span>all/disk.yaml — (could be any name)</div>

```yaml
# docs.siderolabs.com/talos/v1.13/reference/configuration/v1alpha1/config#install
machine:
  install:
    disk: /dev/sda
```

</div>

</div>

<div v-click="2" class="col-span-2">

<pre style="background:#0d1117;color:#c9d1d9;padding:0.75rem 1rem;border-radius:0.5rem;font-size:0.85rem;line-height:1.5;overflow-x:auto;"><span style="color:#7ee787">$</span> topf apply --auto-bootstrap
Do you want to apply the above changes to node1 (Mode: NO_REBOOT)? [y/n]: <span style="color:#7ee787">y</span>
<span style="color:#8b949e">13:58:21</span> <span style="color:#58a6ff">INFO</span> applied machine config command=apply node=node1 mode=NO_REBOOT
<span style="color:#8b949e">13:59:11</span> <span style="color:#58a6ff">INFO</span> etcd bootstrap completed successfully command=apply</pre>

</div>

</div>

<!--
Assume you've downloaded the installer image from the Talos website....

This is almost everything you need, but you probably want to change the config of Talos a bit.

One thing that you _need_ to configure...

This is our first patch.

To roll this out... Talos heavy lifting.

This is pretty sufficient for a lot of usecases already... but sooner or later you will probably have more patches...
-->

---

# Patches per Role

<div class="grid grid-cols-2 gap-8">
<div class="flex flex-col">

<pre class="topf-tree">
├── all/
│   └── <span class="opacity-40">disk.yaml</span>
├── control-plane/
│   └── <span class="file-dot" style="color:#d97706">●</span>vip.yaml
├── worker/
│   └── <span class="file-dot" style="color:#9333ea">●</span>kernel-params.yaml
└── <span class="opacity-40">topf.yaml</span></pre>

</div>
<div class="flex flex-col">

<div class="file-badge"><span class="file-dot" style="color:#d97706">●</span>control-plane/vip.yaml</div>

```yaml
apiVersion: v1alpha1
kind: Layer2VIPConfig
name: 192.168.1.100
link: eth0

```


<div class="file-badge"><span class="file-dot" style="color:#9333ea">●</span>worker/kernel-params.yaml</div>

```yaml
machine:
  sysctls:
    vm.max_map_count: "1048576"
```

</div>
</div>

<div class="mt-4 text-lg opacity-70">

Patches in `control-plane/` and `worker/` folders only apply to nodes with that role.

</div>

<!--
... and some of those patches should only go to control-plane nodes or only to worker nodes.

For this we have 2 folders.

topf apply will use the right patches for each node.

So far so good, but at this point you might think....
-->

---

# Why not just `talosctl`?

<div class="text-lg opacity-70 mt-2">Possible, but not as nice</div>

<div style="--slidev-code-font-size: 0.78rem; --slidev-code-line-height: 1.35;">

```console
$ talosctl gen secrets -o secrets.yaml

$ talosctl gen config my-cluster https://192.168.1.100:6443 \
    --with-secrets secrets.yaml \
    --config-patch @disk.yaml \
    --config-patch-control-plane @vip.yaml \
    --config-patch-worker @kernel-params.yaml \
    --output-dir ./generated

$ talosctl apply-config --insecure -n 192.168.1.11 -f ./generated/controlplane.yaml
$ talosctl apply-config --insecure -n 192.168.1.12 -f ./generated/controlplane.yaml
$ talosctl apply-config --insecure -n 192.168.1.13 -f ./generated/controlplane.yaml
$ talosctl apply-config --insecure -n 192.168.1.14 -f ./generated/worker.yaml
$ talosctl apply-config --insecure -n 192.168.1.15 -f ./generated/worker.yaml

$ talosctl bootstrap -n 192.168.1.11 --talosconfig ./generated/talosconfig
```

</div>

<!--
... couldn't I have done this with talosctl directly?

If you try to use this in a Pipeline...

Certain commands should be run only only the first time during bootstrap.

Patches individually

What if you worker nodes are not the same...

As en example for how TOPF can solve this...
-->

---

# Node Specific Patches

<div class="grid grid-cols-2 gap-8">
<div class="flex flex-col">

<pre class="topf-tree">
├── all/
│   └── <span class="opacity-40">disk.yaml</span>
├── control-plane/
│   └── <span class="opacity-40">vip.yaml</span>
├── worker/
│   └── <span class="opacity-40">kernel-params.yaml</span>
├── node/
│   └── node4/
│       └── <span class="file-dot" style="color:#0891b2">●</span>disk.yaml
└── <span class="opacity-40">topf.yaml</span></pre>

</div>
<div class="flex flex-col">

<div class="file-badge"><span class="file-dot" style="color:#0891b2">●</span>node/node4/disk.yaml</div>

```yaml
# node4 has different hardware → override
machine:
  install:
    disk: /dev/nvme0n1
```

<div class="mt-4 text-lg opacity-70">

node4 gets patches from `all/`, `worker/` and `nodes/node4/`.

Patches are overlayed from least specific to specific, so things can be overridden.

</div>

</div>

</div>

<!--
There's a third folder that TOPF will read configs from... node/

Overrides for snowflake nodes.

Good for single nodes. But reality is even more messy. And for that we need the probably most powerful feature of TOPF: TEMPLATING
-->

---

# Templating

<div class="grid grid-cols-2 gap-8">
<div class="flex flex-col">

<pre class="topf-tree">
├── all/
│   └── <span class="file-dot" style="color:#db2777">●</span>hostname.yaml.tpl
└── <span class="file-dot" style="color:#2563eb">●</span>topf.yaml</pre>

Use any data from `topf.yaml`.

</div>
<div class="flex flex-col">

<div class="file-badge"><span class="file-dot" style="color:#db2777">●</span>all/hostname.yaml.tpl</div>

```yaml
apiVersion: v1alpha1
kind: HostnameConfig
hostname: {{ .Node.Host }}
```

<div class="mt-4 text-lg opacity-70">

using any data from...

<div class="file-badge"><span class="file-dot" style="color:#2563eb">●</span>topf.yaml</div>

</div>

```yaml
…
nodes:
  - host: node1 # <-- for example from here
    ip: 192.168.1.11
    role: control-plane
```

<div class="mt-4 text-lg opacity-70">

Patches using go templating must end in `.tpl`.

</div>

</div>
</div>

---

# Templating: Node Data

<div class="grid grid-cols-2 gap-8">
<div class="flex flex-col">

<pre class="topf-tree">
├── all/
│   ├── <span class="file-dot" style="color:#059669">●</span>disk.yaml.tpl
├── worker/
│   ├── <span class="file-dot" style="color:#9333ea">●</span>gpu.yaml.tpl
└── <span class="file-dot" style="color:#2563eb">●</span>topf.yaml</pre>

Add arbitrary data to your nodes.

</div>

<div class="flex flex-col">

<div class="file-badge"><span class="file-dot" style="color:#2563eb">●</span>topf.yaml</div>

```yaml
nodes:
  - host: node4
    data: # <-- arbitrary k/v data
      disk: /dev/sda
      gpu: true
```

<div v-click="1">
<div class="file-badge"><span class="file-dot" style="color:#059669">●</span>all/disk.yaml.tpl</div>

```yaml
machine:
  install:
    disk: {{ .Node.Data.disk }}
```

</div>

<div v-click="2">
<div class="file-badge"><span class="file-dot" style="color:#9333ea">●</span>worker/gpu.yaml.tpl</div>

```yaml
{{ if index .Node.Data "gpu" }}
machine:
  kernel:
    modules:
      - name: nvidia
{{ end }}
```

</div>

</div>
</div>

<!--
In this list of nodes...

Now combine that with templating..

Similar to Helm you have full access to the sprig functions....

We now focused on patches, but what we haven't talked about is the Talos Version itself.
-->

---

# Upgrading Talos

<div class="grid grid-cols-2 gap-8">
<div class="flex flex-col">

<pre class="topf-tree">
├── all/
│   └── <span class="file-dot" style="color:#059669">●</span>disk.yaml
└── <span class="file-dot" style="color:#2563eb">●</span>topf.yaml</pre>

<div class="mt-4 text-lg opacity-70">

Track the desired Talos version in `topf.yaml`, use `topf upgrade` to upgrade.

</div>

</div>
<div class="flex flex-col">

<div class="file-badge"><span class="file-dot" style="color:#2563eb">●</span>topf.yaml</div>

```yaml{3}
clusterName: my-cluster
clusterEndpoint: https://192.168.1.11:6443
talosVersion: 1.13.7
nodes:
  - host: node1
    ip: 192.168.1.11
    role: control-plane
```

</div>


</div>

<div v-click class="mt-6">
  <pre style="background:#0d1117;color:#c9d1d9;padding:0.75rem 1rem;border-radius:0.5rem;font-size:0.85rem;line-height:1.5;overflow-x:auto;"><span style="color:#7ee787">$</span> topf upgrade
<span style="color:#8b949e">level=INFO</span> msg="upgrade required" version_actual=1.13.7 version_desired=1.13.8
Do you want to upgrade node node1 with installer factory.talos.dev..:v1.13.8? [y/n]: y
<span style="color:#8b949e">level=INFO</span> msg="upgrade artifacts installed"
<span style="color:#8b949e">level=INFO</span> msg="draining kubernetes node"
<span style="color:#8b949e">level=INFO</span> msg="reboot initiated"
<span style="color:#8b949e">level=INFO</span> msg="machine ready, waiting for stabilization..."
<span style="color:#8b949e">level=INFO</span> msg="kubernetes node uncordoned"
</pre>

</div>

<!--
Pretty straighforward, specify the Version to use.

If you then bump this and run topf upgrade -> it will upgrade your entire cluster.

It does this safely by doing it one by one and draining and safety checks after each node.

We have a flags to change the draining behavior

For larger clusters...

So at this point you're convinced you wanna try this out. As soon as you have bootstrapped your first cluster you realize something
-->

---


# Secrets Management

<div class="grid grid-cols-2 gap-8">
<div class="flex flex-col">

<pre class="topf-tree">
├── all/
│   └── <span class="file-dot" style="color:black">●</span>wireguard.yaml
├── secrets.yaml <span class="opacity-40"><-- auto generated</span>
└── topf.yaml
</pre>

<div class="flex flex-col gap-1">

<span v-click="1" style="display: inline-block; margin-bottom: 0.6rem;">• <a href="https://github.com/getsops/sops" target="_blank" style="color: #795649;">SOPS</a>[^1] support.</span><br>
<span v-click="2" style="display: inline-block; margin-bottom: 0.6rem;">• <a href="https://github.com/helmfile/vals" target="_blank" style="color: #795649;">Vals</a>[^2] support.</span><br>
<span v-click="3" style="display: inline-block; margin-bottom: 0.6rem;">• Custom logic: `secretsProvider`</span><br>
<span v-click="4" style="display: inline-block; margin-bottom: 0.6rem;">• Secrets are redacted in dry-run outputs</span>
<span v-click="5" style="display: inline-block;">• Secrets everywhere</span><br>

</div>

</div>

<div class="flex flex-col">

<div class="absolute" style="right: 5.5%; bottom: 7%; width: 27rem; transform: rotate(2deg); background: #ffffff; border: 1px solid rgba(121, 86, 73, 0.25); border-radius: 4px; box-shadow: 0 8px 22px rgba(0, 0, 0, 0.3); padding: 0.4rem; z-index: 10; opacity: 0; transition: opacity 0.4s ease;" :style="$clicks >= 5 ? 'opacity: 1;' : ''">
<img src="./images/secrets-everywhere.jpg" alt="Secrets everywhere meme" style="width: 100%; border-radius: 2px;">
</div>

<div v-if="$clicks < 4">

<div class="file-badge"><span class="file-dot" style="color:#dc2626">●</span>secrets.yaml <span v-if="$clicks >= 1">(SOPS-encrypted)</span></div>

<div v-if="$clicks < 1">

```yaml
cluster:
    secret: +JClynQIf1DiEFGF6csvRpNqRHAnNVLzUfScH9W78=
certs:
    etcd:
        crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1...
        key: LS0tLS1CRUdJTiBFQyBQUklWQVRFIEtFWS1IY0B...

```

</div>

<div v-if="$clicks >= 1">

```yaml
cluster:
    secret: ENC[AES256_GCM,data:j8n2nXuB2LB3...
certs:
    etcd:
        crt: ENC[AES256_GCM,data:Pztj+Dnhy2WWl...
        key: ENC[AES256_GCM,data:I42ky3FK7BfRa...
```

</div>

</div>

<div v-if="$clicks >= 2 && $clicks < 4">

<div class="file-badge"><span class="file-dot" style="color:#dc2626">●</span>secrets.yaml <span>(Vals refs)</span></div>

```yaml
cluster:
    secret: ref+awsssm://secrets/cluster-secret
certs:
    etcd:
        key: ref+azurekeyvault://my-vault/etcd-key
```

</div>

<div v-if="$clicks >= 3 && $clicks < 4">
<div class="file-badge"><span class="file-dot" style="color:#2563eb">●</span>topf.yaml</div>

```yaml
…
# secretsProvider: stores and retrieves "secrets.yaml"
secretsProvider: my-custom-secrets-storage.sh
```

</div>

<div v-if="$clicks >= 4">

<div class="file-badge"><span class="file-dot" style="color:#16a34a">●</span>wireguard.yaml <span>(Vals ref)</span></div>

```yaml
kind: WireguardConfig
name: wg.int
privateKey: ref+gitlab://gitlab.com/projects/42/privkey
```

<div class="file-badge"><span class="file-dot" style="color:#2563eb">●</span>topf.yaml <span>(SOPS-encrypted)</span></div>

```yaml
nodes:
  - host: node1
    data:
      privkey: ENC[AES256_GCM,data:Qk9wl3ZmVzcVpsVU...
```

</div>

<div v-click="4">

```console
 +kind: WireguardConfig
 +name: wg.int
 +privateKey: *** redacted ***
 +peers:
 +    - publicKey: 735jkJdcVDninU...
```

</div>

</div>
</div>

[^1]: <https://github.com/getsops/sops>
[^2]: <https://github.com/helmfile/vals>

<style>
.footnotes {
  right: 52%;
}
</style>

<!--
secrets.yaml contains all the key material for this cluster, key fro the Talos PKI, but also API server, etcd certificate so forth

You don't wanna commit this, but you don't wanna lose it.

For that we have... 

SOPS support. If you configure it, TOPF will use it.

Not limited secrets.yaml, but also in every patch and topf.yaml itself.

Recent addition after user feedback: VALS
* Bitwarden
* Hashicorp Vault/Openbao
* AWS Secrets Manager
* huge list

Example: node specific wireguard key

Dry run: TOPF redacts all secrets from secrets.yaml or the ones you encrypted with SOPS or vals automatically, no matter where they appear in config
-->

---
layout: center
class: text-center
---

<img src="./images/topf-logo.png" class="w-40 mx-auto mb-6" alt="TOPF">

# Live Demo 🪴

<div class="text-3xl font-bold mt-4" style="color: #795649;">

[github.com/postfinance/topf](https://github.com/postfinance/topf/)

</div>

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

# Nodes Provider

<div class="text-xl opacity-70 mt-2">Resolve node lists and secrets at runtime from external sources.</div>

<div class="mt-6">

<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">

<div class="mt-2 text-sm opacity-70">instead of a static list…</div>

```yaml
# topf.yaml
nodes:
  - host: node1
    ip: 192.168.1.11
    role: control-plane
```

<div class="mt-1 text-sm opacity-70">…point at a binary:</div>

```yaml
# topf.yaml
nodesProvider: ./nodes-from-terraform.sh
```

<div class="mt-2 text-sm opacity-70">e.g. read nodes from a Terraform output, cloud API, or inventory</div>

</div>

</div>

<!--
Dynamic providers are TOPF's plugin system. Instead of hardcoding a node list,
you point TOPF at a binary that returns nodes — the obvious use case is reading
them straight from a Terraform output, but it could be a cloud API or an
inventory system. Provider nodes are merged with any static ones.

Same idea for secrets. By default TOPF keeps a local secrets.yaml — the Talos
secrets bundle — and transparently SOPS-encrypts it. Or you set a secretsProvider
binary that fetches the bundle from an external store. At PostFinance the nodes
provider hits our internal inventory and the secrets provider talks to Vault.
-->

---

# Schematic Resolution

<div class="text-xl opacity-70 mt-2">

stop juggling Talos Factory [^factory] image hashes

</div>

<div class="grid grid-cols-2 gap-8 mt-6">
<div class="flex flex-col">

<div class="text-xl font-500 mb-2" style="color: #795649;">Before — the Factory UI</div>

<img src="./images/talos-factory.gif" class="rounded-lg border border-gray-300 shadow-md w-full" alt="clicking through factory.talos.dev">

</div>
<div class="flex flex-col">

<div class="text-xl font-500 mb-2" style="color: #795649;">After — a manifest in Git</div>

<div class="file-badge"><span class="file-dot" style="color:#db2777">●</span>manifest.yaml.tpl</div>

```yaml
customization:
  extraKernelArgs:
    - ip={{ .Node.IP }}::10.0.0.1:255.255.255.0::eth0
  systemExtensions:
    officialExtensions:
      - siderolabs/vmtoolsd-guest-agent
```

<div class="file-badge"><span class="file-dot" style="color:#2563eb">●</span>topf.yaml</div>

```yaml
schematicId: "@manifest.yaml.tpl"
```

</div>
</div>

[^factory]: <https://factory.talos.dev/>

<!--
schematicId, combined with the fact that you can reference a file combined with templating ;-)

You don't have to fully understand this, but just remember:

You might wanna use this in environments where you don't have DHCP and need to give each node the initial Network config directly.
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
<div class="col-span-2 flex flex-col">

```diff
$ topf apply --dry-run

  node2  (Mode: NO_REBOOT)
  machine:
    install:
-     disk: /dev/sda
+     disk: /dev/nvme0n1
    kernel:
      modules:
+       - name: nvidia

  1 node changed — exit code 2
```

</div>
</div>

<!--
This is how we run TOPF in production. Each cluster has its own pipeline. Every
run does a dry-run so you can review the diff; apply and upgrade are both manual
gates — nothing touches the cluster unless someone clicks it. Terraform-style
plan/apply, but for Talos.
-->

---

# Give it a Try

<div class="flex flex-col gap-10 mt-14">

<div class="flex items-baseline gap-5">
<div class="text-3xl font-bold flex-shrink-0" style="color: #795649;">•</div>
<div class="text-2xl font-500" style="color: #5d4037;">Kubernetes with Talos is so easy, you might not need a managed Service.</div>
</div>

<div class="flex items-baseline gap-5" v-click=1>
<div class="text-3xl font-bold flex-shrink-0" style="color: #795649;">•</div>
<div class="text-2xl font-500" style="color: #5d4037;">Play around with Talos and TOPF in your Homelab!</div>
</div>

</div>

<div class="flex gap-4 mt-8" v-click=1>
<img src="./images/homelab.jpeg" style="max-width: 50%; max-height: 150px;" alt="Homelab Sebastian">
<img src="./images/homelab-clement.jpg" style="max-width: 50%; max-height: 150px;" alt="Homelab Clement">
</div>

<!--
The take-2 framing: pull the camera back from TOPF's features to the
transferable lessons. Even if you never touch Talos, these three hold:

1.  

And the meta-lesson: if existing tools don't fit, building your own is
legitimate — and open-sourcing it is how it pays you back.
-->

<!--
The take-2 framing: pull the camera back from TOPF's features to the
transferable lessons. Even if you never touch Talos, these three hold:

1. Especially suited for Baremetal. But also Cloud. If you want managed, take a look at Omni the commercial offering from Siderolabs

2. Not everything must be an Operator. Simple tool easier to reason about.

3. \o/
-->

---

<img src="./images/postfinance-logo.png" class="absolute top-6 right-8" style="width: 11rem;" alt="PostFinance">

<div class="flex flex-col items-center justify-center h-full text-center">

<img src="./images/topf-logo.png" style="width: 9rem;" alt="TOPF">

<h1 class="text-6xl font-bold mt-6" style="color: #222831;">Thank you!</h1>

<div class="flex items-center gap-8 mt-10 text-lg">
<a href="https://github.com/postfinance/topf/" target="_blank" style="color: #795649;" class="flex items-center gap-2 !border-none">
<carbon-logo-github /> postfinance/topf
</a>
<a href="https://www.talos.dev/" target="_blank" style="color: #795649;" class="flex items-center gap-2 !border-none">
<carbon-bare-metal-server /> talos.dev
</a>
</div>

<div class="mt-10 flex items-center gap-8">

<div class="flex items-center gap-3">
<a href="https://clement.n8r.ch/en/articles/" style="font-size: 1.1rem; color: #222831;" target="_blank">clement.n8r.ch</a>
<a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" style="color: #222831;"
  class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-linkedin />
</a>
<a href="https://github.com/clementnuss" target="_blank" style="color: #222831;"
  class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-github />
</a>
</div>

<div class="flex items-center gap-3">
<a href="https://stephan.li" style="font-size: 1.1rem; color: #222831;" target="_blank">stephan.li</a>
<a href="https://www.linkedin.com/in/sebastian-stephan-ab128617b/" target="_blank" style="color: #222831;"
  class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-linkedin />
</a>
<a href="https://github.com/sebastian-stephan" target="_blank" style="color: #222831;"
  class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-github />
</a>
</div>

</div>

<div class="mt-12 text-2xl font-bold" style="color: #5d4037;">Questions? 🪴</div>

</div>

---

# Multiple Nodes

<div class="grid grid-cols-2 gap-8">
<div class="flex flex-col">

<pre class="topf-tree">
├── all/
│   └── <span class="file-dot" style="color:#059669">●</span>disk.yaml
└── <span class="file-dot" style="color:#2563eb">●</span>topf.yaml</pre>

Run `topf apply` to join those nodes.

</div>
<div class="flex flex-col">

<div class="file-badge"><span class="file-dot" style="color:#2563eb">●</span>topf.yaml</div>

```yaml
clusterName: my-cluster
clusterEndpoint: https://192.168.1.11:6443
nodes:
  - host: node1
    ip: 192.168.1.11
    role: control-plane
  - host: node2
    ip: 192.168.1.12
    role: control-plane
  - host: node3
    ip: 192.168.1.13
    role: control-plane
  - host: node4
    ip: 192.168.1.14
    role: worker
  - host: node5
    ip: 192.168.1.15
    role: worker
```

</div>
</div>

<!--
* We want HA, so we boot some more nodes
* Add 3 CP nodes and some worker nodes
* Pretty simple, topf apply will send the config to all nodes, they will join the cluster
-->
