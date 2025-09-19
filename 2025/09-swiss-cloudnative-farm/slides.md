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

<div class="grid grid-cols-3 gap-8 h-85 items-start">
<div class="bg-white bg-opacity-10 backdrop-filter backdrop-blur-md rounded-lg p-6 border border-white border-opacity-20">

## 👨‍💻 **Clément Nussbaumer**

- Platform Engineer at PostFinance 🏦
- 6+ years with Kubernetes ☸️
- Golang enthusiast 🐹
- Musician in a Brass Band 🎺

</div>
<div class="bg-white bg-opacity-10 backdrop-filter backdrop-blur-md rounded-lg p-6 border border-white border-opacity-20">

## 🚜 **My Wife's Family Farm**

- Dairy operation in rural Switzerland 🇨🇭
- Biogas plant ⚡️
- 65 cows 🥛
- 250 chicken 🥚
- Work (silage, etc.) for third parties 🌾

</div>
<div class="flex flex-col justify-center items-center h-full">

<img src="./images/selfie-with-Jura.jpeg" class="rounded-xl shadow-2xl max-h-80 w-auto border-4 border-white border-opacity-30" alt="Clément with Jura the cow">

<div class="mt-4 bg-white bg-opacity-20 backdrop-filter backdrop-blur-md rounded-lg p-3 border border-white border-opacity-30">
<p class="text-sm text-gray-800 font-medium text-center">
Recent selfie with Jura (cow #33) <img src="./images/Jura.png" width="1.2rem" class="inline mx-1" alt="Jura flag"> 🐄
</p>
</div>

</div>
</div>

---
layout: default
---

# The Challenge

<div class="grid grid-cols-5 gap-8 h-60 items-start">
<div class="col-span-2 bg-white bg-opacity-10 backdrop-filter backdrop-blur-md rounded-lg border border-white border-opacity-20 mt-8">

## **The Challenge:**

- Legacy systems with old protocols 📟
- Outdated/slow GUIs 🐌
- Limited monitoring 📊

## **Goal:**

- Real-time data collection ⚡
- Customized alerting 🔔

</div>
<div class="col-span-3 flex flex-col justify-center items-center h-full">

<img src="./images/old-farm.jpg" class="rounded-xl shadow-2xl max-h-80 w-auto border-4 border-white border-opacity-30" alt="Traditional swiss farm">

<div class="mt-4 bg-white bg-opacity-20 backdrop-filter backdrop-blur-md rounded-lg p-3 border border-white border-opacity-30">
<p class="text-sm text-gray-800 font-medium text-center">
<strong>"Swiss Farm" (1883)</strong> by Eugène Burnand<br>
<em>Oil on canvas, farm in Ecublens near Seppey, Vaud</em>
</p>
</div>

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

<img src="./images/cloud-cave-analogy.jpg" class="rounded-lg shadow-lg max-h-96 w-auto" alt="Cloud cave analogy">

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
- Encrypted secrets with SOPS
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
layout: default
---

# Network Architecture

<div class="grid grid-cols-2 gap-8 h-full items-start">
<div class="flex flex-col justify-start">

**Dual-Stack Cluster**

- Init7 🐇 copper connection 250/70MBps 
- IPv6 `2001:1620:5386::/48` range: `2001:1620:5386:0000:0000:0000:0000:0000` - `2001:1620:5386:ffff:ffff:ffff:ffff:ffff`

**MetalLB Load Balancer**

- Routable IPv6 service range
- L2 Advertisement via NDP protocol
- Zero-cost HA with node failover
- no need for port-forwarding/NAT with IPv6

</div>
<div class="h-full flex items-start justify-center">
  <div style="transform: scale(1); transform-origin: top;">
    <Excalidraw
      drawFilePath="./drawings/network-ipv6.excalidraw"
    />
  </div>
</div>
</div>

---
layout: default
---

# Stateful Storage

<div class="grid grid-cols-2 gap-12">
<div class="flex justify-center items-center">

<!-- Image placeholder for storage diagram -->
<img src="./images/k8s-cluster-photo.jpg" class="rounded-lg shadow-lg max-h-96 w-auto" alt="Kubernetes cluster overview">

</div>
<div>

**Distributed Storage**

- Longhorn for replicated block storage
- VictoriaMetrics PVCs for time-series data
- HA MariaDB & PostgreSQL databases

**Backup Strategy**

- PVC snapshots via Velero and copied to offsite S3
- Database-specific backups[^db-backup]:

```bash
mariadb-dump | gzip --rsyncable && restic backup
```

- Incremental backups every 15 minutes

[^db-backup]: https://clement.n8r.ch/en/articles/backing-up-mariadb-on-kubernetes/

</div>
</div>

---
layout: default
---

# Monitoring Stack

<div class="grid grid-cols-2 gap-8 h-full items-start">
<div class="flex flex-col justify-start mt-6">

**Why VictoriaMetrics?**
- Better resource usage than Prometheus
- Simple architecture
- Easy horizontal scaling
- Long-term data retention
- Drop-in Prometheus replacement

**Grafana Integration**
- Farm operations dashboards
- Custom alerting rules

</div>
<div class="h-full flex items-start justify-center">
  <div style="transform: scale(1); transform-origin: top;">
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

# Long-term Storage Strategy

<div class="grid grid-cols-2 gap-8 h-95 items-start">
<div class="flex flex-col justify-start ">

**Two VictoriaMetrics Clusters[^vm-config]**
- **Short-term**: 3 months retention
- **Long-term**: 10 years retention

**Smart Routing**
- vmagent sends to long-term only if `retention_period=long-term`

**vmselect Proxy**
- Distributes and deduplicates queries across clusters

[^vm-config]: https://github.com/clementnuss/k8s-gitops/tree/main/workloads/metrics

</div>
<div class="h-full flex items-start justify-center">
  <div style="transform: scale(1.15); transform-origin: top;">
    <Excalidraw
      drawFilePath="./drawings/victoriametrics-long-term.excalidraw"
    />
  </div>
</div>
</div>

<!--
Two-tier VictoriaMetrics setup with smart routing and query deduplication
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

# DeLaval Milking Robot
##

<div class="grid grid-cols-5 gap-8 h-90 items-start">
<div class="col-span-2 flex flex-col justify-start">

**DeLaval VMS™ Installed December 2024**

- Automated milking system
- 65 cows, 2.4 milkings per day average

**DelPro Farm Manager Software**

- Individual cow tracking & health monitoring
- Centralized herd management system
- Health & reproduction tracking
- Feeding optimization

</div>
<div class="col-span-3 flex flex-col justify-center items-center">

<img src="./images/milk-robot.jpg" class="mt-2 rounded-lg shadow-lg w-auto" alt="Milking robot">

<p class="text-xs text-gray-600 mt-2 text-center italic">
Milking Robot
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
- Manual data export processes

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

**Custom-Built DelPro Exporter[^delpro-exporter]**
- Golang service that queries MS SQL database

**Live Mode: `/metrics`**

- Real-time Prometheus exposition format
- Current milking data and cow status

**Historical Mode: `/historical-metrics`**

- Prometheus format with timestamps
- Backfilling historical data into VictoriaMetrics[^vm-import]

[^delpro-exporter]: https://github.com/clementnuss/delpro-exporter
[^vm-import]: https://docs.victoriametrics.com/victoriametrics/#how-to-import-data-in-prometheus-exposition-format

</div>
<div class="flex flex-col justify-center">

```go
// Query DelPro MS SQL database
records := db.Query(`
  SELECT animal_number, milk_yield, duration
  FROM milking_sessions 
  WHERE session_end > ?
`, lastUpdate)

// Convert to Prometheus metrics
for _, r := range records {
  metrics.GetOrCreateGauge(
    "milk_yield_liters", 
    map[string]string{
      "animal": r.AnimalNumber,
    }).Set(r.Yield)
}
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

# Biogas Plant Operations

<div class="grid grid-cols-3 gap-6 h-80 items-start">
<div class="flex flex-col justify-center items-center">

<img src="./images/biogas-digester-overview.jpeg" class="rounded-lg shadow-lg max-h-94 w-auto" alt="Biogas plant exterior view">

<p class="text-xs text-gray-600 mt-2 text-center italic">
External biogas facility
</p>

</div>
<div class="flex flex-col justify-start items-center">

<img src="./images/saia-pcd.JPG" class="rounded-lg shadow-lg max-h-48 w-auto" alt="Biogas plant interior systems">

<p class="text-xs text-gray-600 mt-2 text-center italic">
Control systems & monitoring
</p>

<img src="./images/engine-interior.jpeg" class="rounded-lg shadow-lg max-h-48 w-auto " alt="Biogas engine overview">

<p class="text-xs text-gray-600 mt-2 text-center italic">
Engine overview
</p>

</div>
<div class="flex flex-col justify-start">

**Energy Production**

- 2x220 kW electrical capacity
- Waste-to-energy conversion
- Grid-connected power generation
- Heat recovery for farm operations

**Key Metrics to Monitor**

- Temperature profiles
- Electrical output
- Digester volume

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

- Windows-based management software
- Manual data export only

**Key Limitations**

- Limited remote capabilities (VNC only)
- Data locked in legacy system
- Outdated dashboard capabilities

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
- Network-based communication (UDP, port 5050)

**Existing Python Library**

- Found `digimat-saia` library
- Implements EtherSBus protocol


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
<div v-click class="p-6 bg-orange-100 bg-opacity-80 border-l-4 border-orange-500 rounded backdrop-filter backdrop-blur-md text-center max-w-3xl">

**Problem: I don't want to implement a prometheus exporter in Python again.[^alpro]**

</div>
</div>

[^alpro]: <https://github.com/clementnuss/alpro-openmetrics-exporter>

---
layout: default
---

# gRPC Service Implementation

<div class="grid grid-cols-2 gap-8 h-90 items-start">
<div class="flex flex-col justify-start">

**SAIA gRPC Service[^saia-grpc]**

- Python service using digimat-saia
- ConnectRPC framework (CNCF sandbox)

**ConnectRPC Benefits**

- Simplified gRPC development

**Service Capabilities**

- Real-time parameter reading/setting
- Error handling & retries

[^saia-grpc]: https://github.com/clementnuss/saia-grpc-service/blob/main/saia_grpc_service.py

</div>
<div class="flex flex-col justify-center items-center">

```python
# gRPC service using ConnectRPC
class SaiaService(SaiaServiceServicer):
    def ReadFlag(
        self, 
        request: saia_pb2.ReadFlagRequest, 
        context: grpc.ServicerContext
    ) -> saia_pb2.ReadFlagResponse:
        r = typing.cast(
            SAIAItemFlag, 
            server.flags[request.address]
        )

        if r is None or not r.isAlive():
            context.abort(
                grpc.StatusCode.INTERNAL, 
                "unable to read register value"
            )

        return saia_pb2.ReadFlagResponse(value=r.bool)
```

</div>
</div>

---
layout: default
---

# Prometheus Metrics Exporter

<div class="grid grid-cols-2 gap-8 h-90 items-start">
<div class="flex flex-col justify-start">

**SAIA PCD Exporter[^saia-exporter]**

- Golang service for metrics collection
- Queries gRPC service periodically
- uses `VictoriaMetrics/metrics` go library

**Data Pipeline Flow**

1. SAIA PCD → EtherSBus protocol
2. gRPC service → JSON/Protobuf
3. delpro-exporter → metrics format
4. VictoriaMetrics → storage
5. Grafana → visualization

[^saia-exporter]: https://github.com/clementnuss/saia-pcd-exporter

</div>
<div class="flex flex-col justify-center">

```go
// Query gRPC service and export metrics
func (e *Exporter) collectMetrics() {
  resp, err := e.grpcClient.GetBiogasMetrics(ctx)
  if err != nil {
    log.Printf("gRPC error: %v", err)
    return
  }

  gasFlowGauge.Set(resp.GasFlow)
  powerOutputGauge.Set(resp.PowerOutput)
  temperatureGauge.WithLabelValues(
    resp.Sensor
  ).Set(resp.Temperature)
}
```

**Monitoring Benefits**

- Real-time biogas performance, custom alerts

</div>
</div>

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

- Shelly MQTT relays for power control
- Kubernetes-hosted MQTT cluster
- Home Assistant integration

**Use Cases**

- Emergency fence shutdown / repairs

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
<div class="p-3 bg-blue-100 bg-opacity-30 border-l-4 border-blue-500 rounded backdrop-filter backdrop-blur-md max-w-md">
  <p class="font-bold text-blue-800 text-center">
    🔌 Shelly → MQTT ← Home Assistant
  </p>
</div>
</div>

---
layout: default
---

# Milk Vending Machine

<div class="grid grid-cols-2 gap-8 h-90 items-center">
<div class="flex flex-col justify-start">

**Self-Service Farm Shop**
- Fresh eggs, flour, sausages, and milk

**LiDAR Integration Challenge**

- Monitor milk levels in the 40L tank
- Automated alerts when machine is empty

<div v-click class="mt-6 p-4 bg-blue-100 bg-opacity-30 border-l-4 border-blue-500 rounded backdrop-filter backdrop-blur-md">
<p class="text-sm font-bold text-blue-800 text-center mb-3">
Tank Geometry: 1cm height = 1 liter 🧮
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

# Farm Invoicing System

<div class="grid grid-cols-2 gap-8 h-90 items-center">
<div class="flex flex-col justify-start">

**InvoiceNinja[^invoiceninja] - Open Source Invoicing**

- Complete invoicing and billing solution
- Customer management and payment tracking

**Farm Use Cases**

- Silage work for third parties
- Hay sales and crop drying

**Cloud-Native Deployment**
- MariaDB Operator[^mariadb-operator] → HA MariaDB
- InvoiceNinja Helm Chart

[^invoiceninja]: https://invoiceninja.com/
[^mariadb-operator]: https://github.com/mariadb-operator/mariadb-operator

</div>
<div class="flex flex-col justify-center items-center">

<img src="./images/invoiceninja.png" class="rounded-lg shadow-lg mt-14 max-h-64 w-auto" alt="InvoiceNinja dashboard">

<p class="text-xs text-gray-600 mt-2 text-center italic">
InvoiceNinja dashboard
</p>

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

<div class="mt-8 p-4 bg-green-100 bg-opacity-30 border-l-4 border-green-500 rounded backdrop-filter backdrop-blur-md">
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
