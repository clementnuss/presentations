---
theme: "@slidev/theme-seriph"
themeConfig:
  primary: "#07805b"
# Sylva Hackathon 2026 palette: #073b3a (deep) #07805b (green) #b7df57 (lime) #e87942 (orange) #f7f8f2 (paper)
title: "A Swiss Cloud-Native Farm"
author: Clément Nussbaumer
info: |-
  Lightning talk at the Sylva Hackathon 2026 (Swisscom, Bern): a tour of my
  wife's family farm, where Kubernetes on Talos Linux monitors milking data,
  runs the biogas plant dashboards and remotely controls electric fences.
highlighter: shiki
colorSchema: light
hideInToc: true
layout: default
exportFilename: a-swiss-cloud-native-farm-sylva
---

<div class="flex flex-col justify-between px-14 py-10" style="position: absolute; inset: 0; background: radial-gradient(circle at 85% 15%, #07805b 0%, #073b3a 55%); color: #f7fff6; font-family: 'Avenir Next', Avenir, 'Trebuchet MS', sans-serif;">

<div class="flex justify-between items-center" style="font: 700 0.75rem/1.3 'SFMono-Regular', Consolas, 'Liberation Mono', monospace; color: #b7df57; text-transform: uppercase;">
  <span>Sylva Hackathon 2026</span>
  <span class="text-right">Lightning talk<br>Bern · Switzerland</span>
</div>

<div class="grid grid-cols-2 gap-10 items-center">
<div>
  <p style="font: 700 0.75rem 'SFMono-Regular', Consolas, monospace; color: #b7df57; text-transform: uppercase; letter-spacing: 0.08em; margin: 0 0 1rem;">Bare metal · GitOps · Kubernetes</p>
  <h1 style="font-family: inherit; font-size: 3.4rem; line-height: 1; font-weight: 700; color: #f7fff6; margin: 0 0 1.2rem;">A Swiss<br><span style="color: #b7df57;">Cloud-Native</span><br>Farm</h1>
  <p style="color: #d7eee3; font-size: 1.05rem; line-height: 1.45; margin: 0 0 1.5rem;">Cows, biogas and electric fences, run like a telco cloud.</p>
  <div class="flex flex-wrap gap-3" style="font: 700 0.65rem/1.2 'SFMono-Regular', Consolas, monospace;">
    <span style="padding: 0.45rem 0.6rem; border: 1px solid #b7df5766; border-radius: 3px;">23 NOV 2026</span>
    <span style="padding: 0.45rem 0.6rem; border: 1px solid #b7df5766; border-radius: 3px;">SWISSCOM · BERN</span>
  </div>
</div>
<div class="relative">
  <img src="./images/farm-main-site.jpg" class="rounded shadow-2xl w-full" style="border: 3px solid #b7df57;" alt="The farm">
</div>
</div>

<div class="flex justify-between items-center" style="font: 0.85rem 'SFMono-Regular', Consolas, monospace; color: #a7ccc2;">
  <span class="font-bold" style="color: #f7fff6; font-family: inherit;">Clément Nussbaumer</span>
  <div class="flex items-center gap-4">
    <a href="https://clement.n8r.ch/en/articles/" target="_blank" style="color: #f7fff6; border: none;">clement.n8r.ch</a>
    <img src="./images/Jura.png" style="width: 1rem;" alt="Jura flag">
    <a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" style="color: #f7fff6;" class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-linkedin /></a>
    <a href="https://github.com/clementnuss" target="_blank" style="color: #f7fff6;" class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-github /></a>
  </div>
</div>

</div>

<!--
Lightning talk, 10 min, right after lunch. Keep it light.
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

# The Infrastructure

<div class="grid grid-cols-2 gap-8 items-start">
<div class="flex justify-center mt-6">

<img src="./images/k8s-cluster-photo.jpg" class="rounded-lg shadow-lg max-h-80 w-auto" alt="The actual cluster">

</div>
<div class="flex flex-col justify-start mt-10">

- **4 Linux PCs** sitting on a desk
- **Kubernetes** on **Talos Linux**[^talos]
- Managed with **TOPF**[^topf] (which I co-created)

<div v-click class="mt-10 callout-warn">

That's basically it.

</div>

[^talos]: <https://www.talos.dev>
[^topf]: <https://github.com/postfinance/topf>

</div>
</div>

---
layout: default
---

# Use Cases

<div class="flex flex-col justify-center" style="height: 80%">

<div class="grid grid-cols-2 gap-6 max-w-3xl mx-auto w-full">
<div class="text-center bg-white rounded-lg p-4 border border-gray-200 shadow-md">

### **Milking Data**
Real-time collection & analysis

</div>
<div class="text-center bg-white rounded-lg p-4 border border-gray-200 shadow-md">

### **Biogas Plant**
Performance metrics & alerts

</div>
<div class="text-center bg-white rounded-lg p-4 border border-gray-200 shadow-md">

### **Electric Fences**
Remote control & monitoring

</div>
<div class="text-center bg-white rounded-lg p-4 border border-gray-200 shadow-md">

### **Milk Vending Machine**
LiDAR sensor integration

</div>
</div>

</div>

---
layout: default
---

# Milking at the Farm

<div class="grid grid-cols-5 gap-8 h-90 items-start">
<div class="col-span-2 flex flex-col justify-start">

- Holstein cows
- 65 cows, ~2.3 milkings/day
- DeLaval VMS voluntary milking system
- Cows choose when to be milked
- Managed in DelPro (Windows only)

<img src="./images/delpro-gui.png" class="rounded-lg shadow-lg max-h-58 w-auto mt-3 self-center" alt="DelPro Farm Manager interface">

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

# From DelPro to Grafana

<div class="grid grid-cols-2 gap-8 items-start">
<div class="flex flex-col justify-start">

**DelPro**: Windows app on MS SQL, no API

Custom Go exporter[^delpro-exporter]: SQL → Prometheus metrics

- `/metrics` for live data
- `/historical-metrics` to backfill VictoriaMetrics

[^delpro-exporter]: <https://github.com/clementnuss/delpro-exporter>

</div>
<div class="flex flex-col justify-center items-center mt-4">

<img src="./images/milk-dashboard-individual-cow.png" class="rounded-lg shadow-lg w-auto" alt="Individual cow dashboard for Jura">

<p class="text-xs text-gray-600 mt-2 text-center italic">
Individual cow stats - Jura (#33)
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

# Talking to the Biogas Plant

<div class="grid grid-cols-2 gap-8 items-start -mt-2">
<div class="flex flex-col items-center gap-2">

<img src="./images/saia-pcd.jpg" class="rounded-lg shadow-lg max-h-28 w-auto" alt="SAIA PCD controller">

<img src="./images/biogas-gui.png" class="rounded-lg shadow-lg max-h-36 w-auto" alt="SAIA PCD controller GUI">

<p class="text-xs text-gray-600 text-center italic">
SAIA PCD controller and its Windows GUI (VNC only)
</p>

</div>
<div class="flex flex-col gap-1 text-sm">

<div class="bg-white rounded-lg px-4 py-1.5 border border-gray-200 shadow-md [&>p]:m-0">

**SAIA PCD**: proprietary EtherSBus over UDP

</div>
<div class="text-center text-gray-500 leading-none">↓</div>
<div class="bg-white rounded-lg px-4 py-1.5 border border-gray-200 shadow-md [&>p]:m-0">

**digimat-saia**: existing Python library

</div>
<div class="text-center text-gray-500 leading-none">↓</div>
<div class="bg-white rounded-lg px-4 py-1.5 border border-gray-200 shadow-md [&>p]:m-0">

**gRPC service** (Python, ConnectRPC)[^saia-grpc]

</div>
<div class="text-center text-gray-500 leading-none">↓</div>
<div class="bg-white rounded-lg px-4 py-1.5 border border-gray-200 shadow-md [&>p]:m-0">

**Go exporter** → VictoriaMetrics[^saia-exporter]

</div>

<div v-click class="callout-warn mt-2 text-center">
<strong>I didn't want to write a Prometheus exporter in Python again.</strong>
</div>

</div>
</div>

[^saia-grpc]: <https://github.com/clementnuss/saia-grpc-service>
[^saia-exporter]: <https://github.com/clementnuss/saia-pcd-exporter>

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
<div class="callout max-w-md">
  <p class="font-bold text-center">
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

<div v-click class="mt-6 callout">
<p class="text-sm font-bold text-center mb-3">
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

<div class="flex flex-col justify-center items-center h-full text-center">

<h1 class="mt-8">Thank You!</h1>

<div class="text-xl font-bold mt-4 mb-6">
Questions?
</div>

<div class="text-lg text-gray-700 mb-12">
Cloud-native principles work everywhere, 
even on Swiss farms!
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

<div class="mt-8 callout">
<p class="text-sm font-bold">
From Kubernetes to Cows - Happy to discuss both!
</p>
</div>
</div>
</div>
</div>

</div>

<!--
Wrap up and invite questions about farm infrastructure, Talos Linux, or home labs
-->
