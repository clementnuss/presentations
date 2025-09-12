---
theme: ./theme
themeConfig:
  primary: "#E85C0D"
# color palette: #FABC3F #E85C0D #C7253E #821131
title: "A Swiss Cloud-Native Farm 🐄"
author: Clément Nussbaumer
info: |-
  Join me for a virtual tour of my wife's family farm, where cloud-native tools
  monitor milking data, manage the biogas plant, remotely control electric
  fences, and more.

  I'll demonstrate the complete technology stack: Kubernetes on bare-metal
  nodes running Talos Linux, Grafana and VictoriaMetrics for monitoring, custom
  golang applications, and GitOps tooling for management.

  I'll explain the decision to host infrastructure on-premises rather than in
  the cloud, and showcase how I implemented a nearly zero-cost IPv6 load
  balancer.

  In conclusion, I'll provide practical guidance for building a cost-effective
  home Kubernetes environment and demonstrate the tangible benefits of applying
  cloud-native principles to agricultural operations.

class: text-center
highlighter: shiki
mdc: true
hideInToc: true
layout: two-cols-header
layoutClass: cover text-right
exportFilename: a-swiss-cloud-native-farm
---

# A Swiss Cloud-Native Farm 🐄
##

**Clément Nussbaumer**

<a href="https://clement.n8r.ch/en/articles/" style="font-size: 1.5rem;" target="_blank" alt="Blog" class="absolute right-8rem top-20rem m-6 text-xl">clement.n8r.ch</a>

<img src="./images/Jura.png" width="23rem" class="absolute right-6rem top-20rem m-6 text-xl" alt="Jura flag">

<a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" alt="Blog"
  class="absolute right-4rem top-20rem m-6  text-xl icon-btn opacity-100 !border-none "><carbon-logo-linkedin />
</a>

<a href="https://github.com/clementnuss" target="_blank" alt="GitHub"
  class="absolute right-2rem top-20rem m-6 text-xl icon-btn opacity-100 !border-none"><carbon-logo-github />
</a>

<img src="./images/logo-cnd.svg" width="40%" class="absolute top-10rem left-3rem m-0" alt="CDS 2025 logo">

<!--
Speaker notes for the first slide
-->

---
layout: default
---

# About Me

<div class="grid grid-cols-2 gap-12">
<div>

**Clément Nussbaumer**
- Platform Engineer at PostFinance
- 6+ years with Kubernetes
- Golang enthusiast
- Musician a Brass Band

</div>
<div>

**My Wife's Family Farm**
- Dairy operation in rural Switzerland
- 65 cows 🥛
- 250 chicken 🥚
- Biogas plant ⚡️
- Work (silage, etc.) for third parties

</div>
</div>

---
layout: default
---

# The Challenge

<div class="grid grid-cols-5 gap-12">
<div class="col-span-2">

**The Challenge:**

- Legacy systems with old protocols
- Outdated/slow GUIs
- Limited monitoring capabilities

**Goal:**
- Real-time data collection
- Modern interfaces
- Customized alerting

</div>
<div class="col-span-3 flex flex-col justify-center items-center">

<img src="./images/old-farm.jpg" class="rounded-lg shadow-lg max-h-80 w-auto" alt="Traditional swiss farm">

<p class="text-xs text-gray-600 mt-2 text-center italic">
"Swiss Farm" (1883) by Eugène Burnand<br>
Oil on canvas, farm in Ecublens near Seppey, Vaud
</p>

</div>
</div>

<!--
Setting the stage - why bring cloud-native to a farm?
-->

---
layout: default
---

# The Farm

<div class="grid grid-cols-2 gap-8 h-80">
<div class="flex flex-col justify-center items-center">

<img src="./images/farm-main-site.jpg" class="rounded-lg shadow-lg max-h-96 w-auto" alt="Main farm site with cows and dairy facilities">

<p class="text-sm font-semibold text-center mt-4">
<strong>Main Site</strong><br>
65 cows, dairy facilities, milk vending machine
</p>

</div>
<div class="flex flex-col justify-center items-center">

<img src="./images/farm-biogas-site.jpg" class="rounded-lg shadow-lg max-h-96 w-auto" alt="Biogas plant site">

<p class="text-sm font-semibold text-center mt-4">
<strong>Biogas Plant Site</strong><br>
Energy production
</p>

</div>
</div>

<!--
Overview of the two farm sites: main dairy operation and biogas plant location
-->

---
layout: default
---

# The Biogas Cycle

<div class="w-1/2 flex flex-col justify-center h-80">

A complete **circular economy** on the farm:

- Waste becomes energy
- Residual heat is used to heat up the digesters
- ... and to dry up crops
- Solid digestate is used as fertilizer to further grow crops

</div>

<div class="absolute right-0 top-0 w-1/2 h-full flex justify-center items-center">
  <div style="transform: scale(0.8); transform-origin: center;">
    <Excalidraw
      drawFilePath="./drawings/farm.excalidraw"
    />
  </div>
</div>


<!--
The complete biogas cycle showing how waste becomes energy and fertilizer in a closed loop
-->

---
layout: image-right
image: ./images/cow.jpg
---

<div class="flex items-center justify-center h-full">
  <h1 class="text-6xl font-bold text-center">
    Let's Turn the Farm<br>Cloud Native
  </h1>
</div>

---
layout: default
---

# Infrastructure Foundation

<div class="grid grid-cols-2 gap-8 h-full items-start">
<div class="flex justify-center mt-6">

<img src="./images/k8s-cluster-photo.jpg" class="rounded-lg shadow-lg max-h-96 w-auto" alt="Kubernetes cluster hardware">

</div>

<div>

**Kubernetes Cluster**
- 4x HP EliteDesk Mini PCs
- Intel i5/i7 processors
- 16GB RAM each
- 256GB-512GB NVMe storage
- Talos Linux OS

**Operating Costs**
- Power: 1.4 kWh/day @ 26.87¢ = **137 CHF/year**
- Hardware amortization: **250 CHF/year** (=1 node)
- **Total: 387 CHF/year (~32 CHF/month)**

</div>
</div>

<!-- **Edge Devices** -->
<!-- - RPi 4: Milk vending metrics -->
<!-- - RPi 4: Biogas Telegram alerts -->
<!-- - Mini Dell: Custom metrics exporter -->

---
layout: default
---

# Home Operations Community

<div class="grid grid-cols-2 gap-8 h-95 items-start">
<div class="flex flex-col justify-start mt-8">

**Inspired by Home Operations[^1]**
- "We love to break production at home" 🏠
- Key contributors: `bjw-s`, `onedr0p`
- **GitOps**-first approach with FluxCD
- Open-source home lab configurations
- Active Discord & GitHub community

[^1]: <https://home-operations.com/>

</div>
<div class="flex flex-col justify-center items-center">

<img src="./images/onedr0p-home-ops.png" class="rounded-lg shadow-lg max-h-80 w-auto" alt="onedr0p home-ops GitHub repository">

<p class="text-xs text-gray-600 mt-2 text-center">
<a href="https://github.com/onedr0p/home-ops" target="_blank" class="hover:underline">github.com/onedr0p/home-ops</a>
</p>

</div>
</div>

---
layout: default
---

# Talos Linux
The 12 binaries' O.S.[^12-bin]

<div class="grid grid-cols-2 h-80 items-start">
<div class="flex flex-col justify-start">

> immutable, minimal, secure \
> declarative configuration file and gRPC API [^talos-philosophy]

[^talos-philosophy]: <https://www.talos.dev/v1.11/learn-more/philosophy/>
[^12-bin]: <https://www.siderolabs.com/blog/there-are-only-12-binaries-in-talos-linux/>

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
<div class="h-full flex items-start justify-center">
  <div style="transform: scale(0.8); transform-origin: top;">
    <Excalidraw
      drawFilePath="./drawings/talos-linux.excalidraw"
    />
  </div>
</div>
</div>

---
layout: image-right
image: ./images/victoriametrics.png
---

# Monitoring Stack

**VictoriaMetrics**
- Time-series storage
- Better resource usage than Prometheus
- Long-term data retention
- Clustering support

**Grafana Dashboards**
- Farm operations overview
- Equipment health monitoring
- Alert visualization

<!--
Why VictoriaMetrics was chosen over Prometheus
-->

---
layout: default
---

# Use Cases

<div class="flex flex-col justify-center" style="height: 80%">

<div class="grid grid-cols-3 gap-6">
<div class="text-center">

## 🥛 **Milking Data**
Real-time collection & analysis

</div>
<div class="text-center">

## ⚡ **Biogas Plant**
Performance metrics & alerts

</div>
<div class="text-center">

## 🚧 **Electric Fences**
Remote control & monitoring

</div>
</div>

<div class="grid grid-cols-2 gap-8 mt-8">
<div class="text-center">

## 📊 **Milk Vending Machine**
LiDAR sensor integration

</div>
<div class="text-center">

## 🧾 **Invoicing Solution**
Billing for e.g.silage work

</div>
</div>

</div>

---
layout: default
---

# Custom Applications

<div class="grid grid-cols-2 gap-8">
<div>

**Golang Services**
- Milk data collector
- Biogas metrics processor
- Fence controller API
- Weather station aggregator

</div>
<div>

**Integration Challenges**
- Legacy equipment protocols
- Serial communication
- File-based data exchange
- Network reliability

</div>
</div>

---
layout: image-right
image: ./images/old-vs-new.png
---

# Data Integration Evolution

**Before:**
- Manual CSV imports
- Weekly data processing
- Limited visibility
- Error-prone workflows

**After:**
- Real-time streaming
- Automated processing
- Live dashboards
- Reliable data pipelines

<!--
Show the transformation from manual to automated processes
-->

---
layout: center
---

# Network Architecture

<div class="text-center">

## IPv6-First Strategy

**Zero-cost Load Balancer**
- Native IPv6 routing
- No external dependencies
- High availability

**Connectivity**
- Fiber internet (100/100 Mbps)
- 4G backup connection
- Starlink as tertiary

</div>

---
layout: image-right
image: ./images/gitops-workflow.png
---

# GitOps Operations

**ArgoCD Management**
- Declarative configuration
- Automated deployments
- Configuration drift detection

**Talos Configuration**
- Git-stored machine configs
- Encrypted secrets with SOPS
- Rolling updates

<!--
How GitOps principles apply to farm infrastructure
-->

---
layout: default
---

# Backup Strategy

<div class="grid grid-cols-2 gap-12">
<div>

**Application Data**
- Velero for K8s resources
- PVC snapshots
- Cross-region replication

</div>
<div>

**Database Backups**
```bash
mariadb-dump | \
  gzip --rsyncable | \
  restic backup
```
- Incremental backups
- Encrypted at rest
- Multiple destinations

</div>
</div>

---
layout: image-right
image: ./images/grafana-dashboard.png
---

# Live Demo

**Real Farm Data**
- Current milk production
- Biogas plant performance
- Weather conditions
- System health

**GitOps Deployment**
- Configuration changes
- Rolling updates
- Health monitoring

<!--
Show actual live dashboards from the farm
-->

---
layout: center
---

# Lessons Learned

<div class="grid grid-cols-2 gap-8">
<div>

## ✅ **What Worked**
- On-premises cost savings
- Reliable bare-metal performance
- Talos Linux stability
- GitOps workflow

</div>
<div>

## 🔄 **Challenges**
- Hardware failure isolation
- Remote troubleshooting
- Legacy system integration
- Rural connectivity issues

</div>
</div>

---
layout: image-right
image: ./images/cost-comparison.png
---

# On-Premises vs Cloud

**Cost Benefits:**
- 80% savings over cloud
- No egress fees
- Predictable costs
- Hardware depreciation

**When to Choose On-Premises:**
- Predictable workloads
- Data sovereignty requirements
- Cost-sensitive environments
- Reliable internet connectivity

<!--
Real numbers comparing cloud vs on-premises costs
-->

---
layout: default
---

# Building Your Home Lab

<div class="grid grid-cols-3 gap-6">
<div>

**Hardware**
- Start with 3x Intel NUCs
- Add storage nodes later
- Consider power efficiency
- Plan for growth

</div>
<div>

**Networking**
- Managed switches
- VLANs for isolation
- Backup connectivity
- IPv6 support

</div>
<div>

**Software**
- Talos Linux
- ArgoCD for GitOps
- VictoriaMetrics
- Join k8s-at-home community

</div>
</div>

---
layout: center
---

# Common Pitfalls

**Avoid These Mistakes:**
- Undersized control plane
- Single points of failure
- Inadequate backup testing
- Ignoring security updates
- Over-engineering from day one

**Start Simple, Scale Smart**

---
layout: image-right
image: ./images/Jura.png
---

# Thank You!

**Questions?**

Cloud-native principles work everywhere – 
even on Swiss farms! 🐄

<div class="mt-8">
<a href="https://clement.n8r.ch/en/articles/" target="_blank">clement.n8r.ch</a>
</div>

<!--
Wrap up and invite questions about farm infrastructure, Talos Linux, or home labs
-->
