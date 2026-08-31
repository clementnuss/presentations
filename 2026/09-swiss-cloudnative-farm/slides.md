---
theme: "@slidev/theme-seriph"
themeConfig:
  primary: "#1a3b89"
# CDS 2026 palette: #1a3b89 (navy) #37bcfc (blue) #e5ff71 (lime yellow) #3c4146 (dark gray)
title: "A Swiss Cloud-Native Farm"
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
hideInToc: true
layout: two-cols-header
layoutClass: cover text-right
exportFilename: a-swiss-cloud-native-farm
---

# A Swiss Cloud-Native Farm
##

**Clément Nussbaumer**

<a href="https://clement.n8r.ch/en/articles/" style="font-size: 1.5rem;" target="_blank" alt="Blog" class="absolute right-8rem top-20rem m-6 text-xl">clement.n8r.ch</a>

<img src="./images/Jura.png" style="width: 1rem;" class="absolute right-6rem top-20rem m-6 text-xl" alt="Jura flag">

<a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" alt="Blog"
  class="absolute right-4rem top-20rem m-6  text-xl icon-btn opacity-100 !border-none "><carbon-logo-linkedin />
</a>

<a href="https://github.com/clementnuss" target="_blank" alt="GitHub"
  class="absolute right-2rem top-20rem m-6 text-xl icon-btn opacity-100 !border-none"><carbon-logo-github />
</a>

<img src="./images/cds2026-hero-text.svg" width="38%" class="absolute top-10rem left-3rem m-0" alt="ContainerDays Hamburg 2026">

<!--
Speaker notes for the first slide
-->

---
layout: default
---

# About Me

<div class="flex flex-col justify-center items-center h-full">

<img src="./images/selfie-with-Jura.jpeg" class="rounded-xl shadow-2xl max-h-76 w-auto border-4 border-white border-opacity-30" alt="Clément with Jura the cow">

<div class="mt-4 bg-white bg-opacity-20 rounded-lg p-3 border border-white border-opacity-30">
<p class="text-sm text-gray-800 font-medium text-center">
Recent selfie with Jura (cow #33) <img src="./images/Jura.png" style="width: 1rem; vertical-align: middle;" class="inline mx-1" alt="Jura flag">
</p>
</div>

</div>

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

# Why Cloud-Native?

<div class="grid grid-cols-5 gap-8 h-60 items-start">
<div class="col-span-2 bg-white bg-opacity-10 rounded-lg border border-white border-opacity-20 mt-8">

## What's there

- Old proprietary protocols
- Windows-only GUIs, VNC
- Data locked in silos

## What I wanted

- Real-time data & alerting
- Mobile-friendly dashboards

</div>
<div class="col-span-3 flex flex-col justify-center items-center h-full">

<img src="./images/old-farm.jpg" class="rounded-xl shadow-2xl max-h-80 w-auto border-4 border-white border-opacity-30" alt="Traditional swiss farm">

<div class="mt-4 bg-white bg-opacity-20 rounded-lg p-3 border border-white border-opacity-30">
<p class="text-sm text-gray-800 font-medium text-center">
<strong>"Swiss Farm" (1883)</strong> by Eugène Burnand<br>
<em>Oil on canvas, farm in Ecublens near Seppey, Vaud</em>
</p>
</div>

</div>
</div>

<!--
Why bring cloud-native to a farm? The existing tools are inconvenient and not modern.
The 1883 painting contrasts traditional farming with the cloud-native approach.
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
<div class="flex justify-center mt-6 relative">

<img v-click-hide src="./images/cloud-cave-analogy.jpg" class="rounded-lg shadow-lg max-h-96 w-auto" alt="Cloud cave analogy">

<img v-after src="./images/k8s-cluster-photo.jpg" class="rounded-lg shadow-lg max-h-96 w-auto absolute top-0 left-0" alt="The actual cluster">

</div>

<div>

**Cluster**

- 4x HP EliteDesk Mini PCs
- 16GB RAM, 512GiB NVMe each
- Talos Linux

**Operating Costs**

- Power: 60 Wh = 1.4 kWh/day = 137 CHF/year
- Hardware amortization: **350 CHF/year** (=1 node)
- **Total: 487 CHF/year (~40 CHF/month)**


</div>
</div>

<!-- **Edge Devices** -->
<!-- - RPi 4: Milk vending metrics -->
<!-- - RPi 4: Biogas Telegram alerts -->
<!-- - Mini Dell: Custom metrics exporter -->

---
layout: default
---

# Infrastructure as Code with OpenTofu

<div class="grid grid-cols-2 gap-8 items-start">
<div class="flex flex-col justify-start">

Network config managed with **OpenTofu**[^tofu]:
- MikroTik routers (official provider)
- IPAM (phpIPAM)
- Cloudflare DNS
- WireGuard tunnels
- Secrets in OpenBao[^bao]

[^tofu]: <https://opentofu.org>
[^bao]: <https://openbao.org>

</div>
<div class="flex flex-col justify-center items-center gap-8">

<img src="./images/opentofu.svg" style="width: 10rem;" alt="OpenTofu logo">

<img src="./images/openbao.svg" style="width: 8rem;" alt="OpenBao logo">

</div>
</div>


---
layout: default
---

# Talos Linux

<div class="grid grid-cols-2 h-80 items-start">
<div class="flex flex-col justify-start">

- < 50 OS binaries, < 80 MB footprint
- Immutable root filesystem, no package manager
- No SSH, no shell — interaction via gRPC API
- Declarative configuration

Managed with **TOPF**[^topf]

[^topf]: <https://github.com/postfinance/topf>

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
layout: default
---

# Configuring the cluster

<div class="grid grid-cols-2 gap-8 h-95 items-start">
<div class="flex flex-col justify-start mt-8">

**Inspired by home-ops[^1]**

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

# Network Architecture

<div class="grid grid-cols-2 gap-8 items-start">
<div class="flex flex-col justify-start">

**Dual-stack IPv4 / IPv6**

MetalLB exposes the ingress on an IPv6 address via NDP[^ndp] — no NAT needed

For IPv4-only clients:

- Cloudflare proxy in front of the IPv6 address
- Or a small VPS proxying IPv4 → IPv6

</div>
<div class="flex items-start justify-center">
  <div style="transform: scale(1); transform-origin: top center;">
    <Excalidraw
      drawFilePath="./drawings/network-ipv6.excalidraw"
    />
  </div>
</div>
</div>

[^ndp]: Neighbor Discovery Protocol — the IPv6 equivalent of ARP

---
layout: default
---

# Monitoring Stack

<div class="grid grid-cols-2 gap-8 h-full items-start">
<div class="flex flex-col justify-start mt-6">

**VictoriaMetrics**

- **Simple architecture**
- Drop-in Prometheus replacement
- Better resource usage
- Long-term retention

**Grafana**
- Dashboards + alerting

</div>
<div class="flex items-start justify-center">
  <div style="transform: scale(0.9); transform-origin: top center;">
    <Excalidraw
      drawFilePath="./drawings/victoriametrics.excalidraw"
    />
  </div>
</div>
</div>

<!--
VictoriaMetrics cluster architecture showing separation of concerns and scalability
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

<div class="grid grid-cols-3 gap-6 mt-8">
<div class="text-center">

## 📊 **Milk Vending Machine**
LiDAR sensor integration

</div>
<div class="text-center">

## 🧾 **Self-Hosted Apps**
Invoicing, PDF archive, SSO

</div>
<div class="text-center">

## 📈 **Uptime Monitoring**
All farm devices, status page

</div>
</div>

</div>

---
layout: default
---

# Milking at the Farm

<div class="grid grid-cols-5 gap-8 h-90 items-start">
<div class="col-span-2 flex flex-col justify-start">

- Holstein cows 🐄
- 65 cows, ~2.3 milkings/day
- DeLaval VMS voluntary milking system
- Cows choose when to be milked

</div>
<div class="col-span-3 flex flex-col justify-center items-center">

<img src="./images/milk-robot.jpg" class="mt-2 rounded-lg shadow-lg w-auto" alt="Milking robot">

<p class="text-xs text-gray-600 mt-2 text-center italic">
DeLaval VMS milking robot
</p>

</div>
</div>

---
layout: default
---

# DelPro Farm Manager

<div class="grid grid-cols-5 gap-8 h-90 items-start">
<div class="col-span-3 flex flex-col justify-center items-center">
  <div style="transform: scale(0.9); transform-origin: top;">
    <img src="./images/delpro-gui.png" class="rounded-lg shadow-lg w-auto" alt="DelPro Farm Manager interface">
  </div>

<p class="text-xs text-gray-600 mt-2 text-center italic">
DelPro Farm Manager GUI
</p>

</div>
<div class="col-span-2 flex flex-col justify-start">

**Legacy Management Interface**

- Traditional Windows-based application
- Limited real-time capabilities

**Key Limitations**

- No API access for automation
- Limited mobile access

</div>
</div>

---
layout: default
---

# DelPro Data Extraction

<div class="grid grid-cols-2 gap-8 h-90 items-start">
<div class="flex flex-col justify-start">

Custom Go service: MS SQL → Prometheus format[^delpro-exporter]

- `/metrics` — live data
- `/historical-metrics` — backfill into VictoriaMetrics

[^delpro-exporter]: https://github.com/clementnuss/delpro-exporter

</div>
<div class="flex flex-col justify-center">

```json
delpro_milk_last_somatic_cell{
  animal_number="77",animal_name="Lovely",
  breed="Holstein",destination="Tank",
  lactation="1"} 34
delpro_milk_last_somatic_cell{
  animal_number="78",animal_name="Jessie",
  breed="Holstein",destination="Divert1",
  lactation="3"} 265
delpro_milk_last_yield_liters{
  animal_number="1",animal_name="Jade",
  breed="Holstein",destination="Tank",
  lactation="3"} 14.3
delpro_milk_last_yield_liters{
  animal_number="9",animal_name="Marine",
  breed="Montbéliarde",destination="Tank",
  lactation="1"} 13.2
```

</div>
</div>

---
layout: default
---

# Grafana Dashboard

<div class="grid grid-cols-2 gap-8 h-90 items-center">
<div class="flex flex-col justify-center items-center">

<img src="./images/milk-dashboard-trends.png" class="rounded-lg shadow-lg max-h-80 w-auto" alt="Milk production trends dashboard">

<p class="text-xs text-gray-600 mt-2 text-center italic">
Production trends and analytics
</p>

</div>
<div class="flex flex-col justify-center items-center">

<img src="./images/milk-dashboard-individual-cow.png" class="rounded-lg shadow-lg max-h-80 w-auto" alt="Individual cow dashboard for Jura">

<p class="text-xs text-gray-600 mt-2 text-center italic">
Individual cow stats - Jura (#33) 🐄
</p>

</div>
</div>



---
layout: default
---

# The Biogas Cycle

<div class="grid grid-cols-2 gap-8 items-start">
<div class="flex flex-col justify-center">

A complete circular economy on the farm:

- Cows eat crops → produce manure
- Manure produces methane (CH₄)
- Methane fuels engines → electricity + heat
- Residual heat heats the digesters
- ... and dries crops
- Digestate fertilizes crops

</div>
<div class="flex justify-center items-center">
  <div style="transform: scale(0.8); transform-origin: top center;">
    <Excalidraw
      drawFilePath="./drawings/farm.excalidraw"
    />
  </div>
</div>
</div>

<!--
The complete biogas cycle showing how waste becomes energy and fertilizer in a closed loop
-->

---
layout: default
---

# Biogas Plant Operations

<div class="grid grid-cols-3 gap-6 h-80 items-start">
<div class="flex flex-col justify-center items-center">

<img src="./images/biogas-digester-overview.jpeg" class="rounded-lg shadow-lg max-h-94 w-auto" alt="Biogas plant exterior view">

<p class="text-xs text-gray-600 mt-2 text-center italic">
Digesters and feed mixer
</p>

</div>
<div class="flex flex-col justify-start items-center">

<img src="./images/saia-pcd.jpg" class="rounded-lg shadow-lg max-h-48 w-auto" alt="Biogas plant interior systems">

<p class="text-xs text-gray-600 mt-2 text-center italic">
Control systems & monitoring
</p>

<img src="./images/engine-interior.jpeg" class="rounded-lg shadow-lg max-h-48 w-auto " alt="Biogas engine overview">

<p class="text-xs text-gray-600 mt-2 text-center italic">
Engine overview
</p>

</div>
<div class="flex flex-col justify-start">

**SAIA PCD**
Programmable Control Device — the biogas plant's controller

<img src="./images/saia-pcd-software.png" class="rounded-lg shadow-lg mt-4 max-h-48 w-auto" alt="SAIA PCD programming software">

</div>
</div>

---
layout: default
---

# SAIA PCD Controller GUI

<div class="grid grid-cols-3 gap-8 h-90 items-start">
<div class="col-span-2 flex flex-col justify-center items-center relative">

<div v-click-hide class="flex flex-col justify-center items-center">
  <img src="./images/biogas-gui.png" class="rounded-lg shadow-lg w-auto" alt="SAIA PCD Controller GUI">
  
  <p class="text-xs text-gray-600 mt-2 text-center italic">
    SAIA PCD Management Interface
  </p>
</div>

<div v-after class="absolute top-0 left-0 right-0 bottom-0 flex flex-col justify-center items-center">
  <img src="./images/biogas-gui-old-graphs.png" class="rounded-lg shadow-lg w-auto" alt="SAIA PCD Controller GUI - Historical Graphs">
  
  <p class="text-xs text-gray-600 mt-2 text-center italic">
    Historical Data Visualization
  </p>
</div>

</div>
<div class="col-span-1 flex flex-col justify-start">

**Legacy Control Interface**

- Windows-based
- Manual data export only
- Limited remote capabilities (VNC only)

</div>
</div>

---
layout: default
---

# SAIA EtherSBus Protocol

<div class="grid grid-cols-2 gap-8 h-60 items-start">
<div class="flex flex-col justify-start">

**SAIA PCD Communication**

- Proprietary EtherSBus protocol
- Serial or Ethernet (UDP, port 5050)

**Existing Python Library**

- `digimat-saia` implements EtherSBus

</div>
<div class="flex flex-col justify-center items-center mt-2">

```python
# SAIA EtherSBus communication
from digimat_saia import SAIANode

# Create local node and declare remote server
node = SAIANode(253)
server = node.servers.declare('192.168.1.100')

# Read biogas parameters from remote PCD
gas_flow = server.registers[1000].float32
temperature = server.registers[1001].float32
power_output = server.registers[1002].float32
pump_running = server.flags[10].value
```

</div>
</div>

<div class="flex justify-center mt-8">
<div v-click class="p-6 bg-orange-100 bg-opacity-80 border-l-4 border-orange-500 rounded text-center max-w-3xl">

**Problem: I don't want to implement a Prometheus exporter in Python again.**

</div>
</div>

---
layout: default
---

# gRPC Bridge & Go Exporter

<div class="grid grid-cols-2 gap-8 items-start">
<div class="flex flex-col justify-start">

**gRPC Service (Python)**

- Wraps `digimat-saia`
- ConnectRPC framework (CNCF sandbox)
- Reads/writes registers & flags

**Prometheus Exporter (Go)**

- Polls the gRPC service periodically
- Uses `VictoriaMetrics/metrics` library

</div>
<div class="flex flex-col justify-center">

```
biogaz_poids_balance_kg 13467
biogaz_pression_stockage_gaz_mbar 0.8393750190734863
biogaz_puissance_ccf1_echelonnee 190
biogaz_puissance_ccf2_echelonnee 200
biogaz_reservoir_separateur_vide 1
biogaz_retour_auto_brasseur_fermenteur1_inf 1
biogaz_retour_auto_brasseur_fermenteur1_sup 1
```

</div>
</div>

Both open source: saia-grpc-service[^saia-grpc], saia-pcd-exporter[^saia-exporter]

[^saia-grpc]: https://github.com/clementnuss/saia-grpc-service
[^saia-exporter]: https://github.com/clementnuss/saia-pcd-exporter

---
layout: default
---

# Biogas Plant Dashboard

<div class="flex flex-col justify-center items-center h-90">

<img src="./images/biogas-grafana.png" class="rounded-lg shadow-lg max-h-80 w-auto" alt="Biogas plant Grafana dashboard">

<p class="text-xs text-gray-600 mt-4 text-center italic">
Real-time biogas plant monitoring and analytics
</p>

</div>

---
layout: default
---

# Electric Fence Control

<div class="grid grid-cols-3 gap-6 h-80 items-start">
<div class="flex flex-col justify-start">

**Remote Fence Management**

- Shelly relays for power control
- Kubernetes-hosted MQTT server
- Home Assistant integration

**Use Cases**

- Repairs / emergency fence shutdown

</div>
<div class="flex flex-col justify-center items-center">

<img src="./images/Shelly-1PM-Gen3-main-image.webp" class="rounded-lg shadow-lg max-h-64 w-auto" alt="Shelly 1PM Gen3 relay">

<p class="text-xs text-gray-600 mt-2 text-center italic">
Shelly 1PM Gen3 MQTT relay
</p>

</div>
<div class="flex flex-col justify-center items-center">

<img src="./images/home-assistant.png" class="rounded-lg shadow-lg max-h-70 w-auto" alt="Home Assistant dashboard">

<p class="text-xs text-gray-600 mt-2 text-center italic">
Home Assistant fence control
</p>

</div>
</div>

<div class="flex justify-center mt-6">
<div class="p-3 bg-blue-100 bg-opacity-30 border-l-4 border-blue-500 rounded  max-w-md">
  <p class="font-bold text-blue-800 text-center">
    Shelly → MQTT ← Home Assistant
  </p>
</div>
</div>

---
layout: default
---

# Milk Vending Machine

<div class="grid grid-cols-2 gap-8 h-90 items-center">
<div class="flex flex-col justify-start">

**Measuring Milk Levels**

- No level sensor in the tank
- LiDAR measures the milk surface
- Alerts when the machine is empty

<div v-click class="mt-6 p-4 bg-blue-100 bg-opacity-30 border-l-4 border-blue-500 rounded ">
<p class="text-sm font-bold text-blue-800 text-center mb-3">
Tank Geometry: 1cm height = 1 liter
</p>

$$
\begin{aligned}
1L &= 10^{-3}m^3 = \pi \cdot r^2 \cdot 10^{-2}m \\
r &= \sqrt{\frac{10^{-1}}{\pi}} = 0.178m = 17.8cm
\end{aligned}
$$
</div>

</div>
<div class="flex flex-col justify-center items-center">

<img src="./images/milk-vending-dashboard.png" class="rounded-lg shadow-lg max-h-80 w-auto" alt="Milk vending machine dashboard">

<p class="text-xs text-gray-600 mt-2 text-center italic">
Milk vending machine monitoring dashboard
</p>

</div>
</div>

---
layout: default
---

# Self-Hosted Services

<div class="grid grid-cols-2 gap-8 items-center">
<div class="flex flex-col justify-center">

A nice side-effect of running k8s: self-hosting regular apps is easy

- **InvoiceNinja**[^invoiceninja] — invoicing: silage work, hay sales, crop drying
- **Paperless-ngx**[^paperless] — PDF archival & document management
- **PocketID**[^pocketid] — OIDC SSO for all of the above

[^invoiceninja]: https://invoiceninja.com/
[^paperless]: https://docs.paperless-ngx.io/
[^pocketid]: https://github.com/pocket-id/pocket-id

</div>
<div v-click class="flex flex-col justify-center items-center">

<img src="./images/xkcd-cloud.png" class="rounded-lg bg-white p-2 shadow-lg max-h-72 w-auto" alt="xkcd: The Cloud">

<p class="text-xs text-gray-600 mt-2 text-center italic">
xkcd 908 — "The Cloud"
</p>

</div>
</div>

---
layout: default
---

# Uptime Monitoring with Gatus

<div class="grid grid-cols-2 gap-8 items-start">
<div class="flex flex-col justify-start">

**Gatus**[^gatus] monitors all farm devices:
- Routers, antennas, peripherals
- HTTP, TCP, ICMP checks
- Status page + alerts

[^gatus]: <https://github.com/TwiN/gatus>

</div>
<div class="flex flex-col justify-center items-center">

<img src="./images/gatus-screenshot.png" class="rounded-lg shadow-lg max-h-96 w-auto" alt="Gatus status page">

</div>
</div>

---
layout: default
---

# Live Demo

<div class="grid grid-cols-2 gap-8 h-90 items-start">
<div class="flex flex-col justify-start">

**Real Farm Data**

- Current milk production
- Biogas plant performance
- Electric fence status

**Security Considerations**

- One IT guy 👨‍💻
- Managing electric fences ⚡
- Remotely controlling livestock barriers 🐄
- What could possibly go wrong? 🦕 🦖

</div>
<div class="flex flex-col justify-center items-center">

<img src="./images/jurassic-park-meme.jpeg" class="rounded-lg shadow-lg max-h-75 w-auto" alt="Jurassic Park IT guy Dennis Nedry">

<div class="text-xs text-gray-600 mt-2 text-center italic">

*Jurassic Park[^jurassic]*

</div>

</div>
</div>

[^jurassic]: https://www.jurassicsystems.com/

<!--
Show actual live dashboards from the farm
-->

---
layout: center
---

<h1 class="text-center">Lessons Learned</h1>

<div class="grid grid-cols-2 gap-8 mt-12">
<div>

## ✅ **What Worked**

- On-premises cost savings
- Talos Linux stability
- GitOps workflow

</div>
<div>

## 🔄 **Challenges**

- Legacy system integration
- Reverse engineering

</div>
</div>

---
layout: default
---

<div class="flex flex-col justify-center items-center h-full text-center">

<h1 class="mt-8">Thank You! 🙏</h1>

<div class="text-xl font-bold mt-4 mb-6">
Questions?
</div>

<div class="text-lg text-gray-700 mb-12">
Cloud-native principles work everywhere, 
even on Swiss farms! 🐄
</div>

<div class="grid grid-cols-3 gap-12 w-full max-w-4xl items-start">
<div class="col-span-2 flex flex-col items-center">
<img src="./images/farm-main-site.jpg" class="rounded-lg shadow-lg max-h-65 w-auto" alt="Farm main site">
<p class="text-xs text-gray-600 mt-2 italic">The farm that started it all</p>
</div>

<div class="col-span-1 flex flex-col justify-start">
<div class="text-center">
<a href="https://clement.n8r.ch/en/articles/" target="_blank" class="text-2xl font-bold hover:underline">clement.n8r.ch</a>

<div class="mt-6 flex justify-center space-x-4">
<a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" class="text-xl">
<carbon-logo-linkedin />
</a>
<a href="https://github.com/clementnuss" target="_blank" class="text-xl">
<carbon-logo-github />
</a>
</div>

<div class="mt-8 p-4 bg-green-100 bg-opacity-30 border-l-4 border-green-500 rounded ">
<p class="text-sm font-bold text-green-800">
From Kubernetes to Cows - Happy to discuss both! 🚀🐄
</p>
</div>
</div>
</div>
</div>

</div>

<!--
Wrap up and invite questions about farm infrastructure, Talos Linux, or home labs
-->
