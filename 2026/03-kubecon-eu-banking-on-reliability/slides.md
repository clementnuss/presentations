---
theme: ./theme
themeConfig:
  primary: '#ff7f15'
# KubeCon EU 2026 color: #ff7f15
title: "Banking on Reliability: Cloud Native SRE Practices in Financial Services"
author: Clément Nussbaumer
info: |-
  Real-world stories from 5 years operating a Kubernetes platform at a major
  Swiss bank. From SLOs driving cascading improvements, to open-source monitoring
  tools, continuous end-to-end testing, and an interactive debugging session
  tracking down rare 502 errors - critical in banking where failed requests mean
  denied payments.

class: text-center
highlighter: shiki
# mdc: true
hideInToc: true
layout: default
exportFilename: banking-on-reliability-kubecon-eu-2026
---
<!-- prettier-ignore-start -->

<div class="absolute inset-0 z-0" style="background-color: #ff7f15; opacity: 0.12;"></div>
<img src="./images/kceu26-bg-top-left.png" class="absolute top-5 right-5 w-60 z-0" style="margin: 0;" alt="">
<img src="./images/kceu26-bg-bottom.png" class="absolute bottom-0 left-0 w-full z-0" style="margin: 0;" alt="">

<div class="relative z-10 text-left mt-22 ml-4">

<h1 class="text-5xl font-bold" style="color: #1a1a2e;">Banking on Reliability</h1>
<h2 class="text-2xl mt-2" style="color: #ff7f15;">Cloud Native SRE Practices in Financial Services</h2>

<p class="mt-6 text-lg" style="color: #1a1a2e;"><strong>Clément Nussbaumer</strong></p>

<div class="mt-4 flex items-center gap-4">
<a href="https://clement.n8r.ch/en/articles/" style="font-size: 1.3rem; color: #1a1a2e;" target="_blank">clement.n8r.ch</a>
<img src="./images/Jura.png" width="23rem" alt="Jura flag">
<a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" style="color: #1a1a2e;"
  class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-linkedin />
</a>
<a href="https://github.com/clementnuss" target="_blank" style="color: #1a1a2e;"
  class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-github />
</a>
</div>

</div>

<!--
Welcome everyone! Today I'll share real-world stories from 5 years of operating
a Kubernetes platform at a major Swiss bank, focusing on reliability practices
that have been battle-tested in production.
-->

---
layout: default
---

# About Me

<div class="grid grid-cols-3 gap-8 h-85 items-start">
<div class="bg-white bg-opacity-80 rounded-lg p-6 border border-gray-200 shadow-md">

## 👨‍💻 **Clément Nussbaumer**

- Systems Engineer at PostFinance 🏦 🇨🇭
- Living on a farm 🐄
- Musician in a Brass Band 🎺
- Father of 1 👶

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-6 border border-gray-200 shadow-md">

## 🏦 **PostFinance**

- Systemic Swiss financial institution
- ~35 Kubernetes clusters
- Air-gapped environment
- Strict regulatory requirements

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-6 border border-gray-200 shadow-md">

## 🖥️ **The Platform**

- 5+ years in production
- kubeadm / Debian clusters
- ongoing Talos + [TOPF](https://github.com/postfinance/topf/) migration

</div>
</div>

<div v-click class="p-2 bg-orange-100 bg-opacity-80 border-l-4 border-orange-500 rounded  text-center">

**Every failed request = potential denied payment** 💸

</div>

<!--
A quick introduction - I'm a platform engineer at PostFinance, a major Swiss
financial institution where reliability is not just nice-to-have, it's regulated.
-->

---
layout: default
---

# Part 1: Service Level Objectives (SLOs) as a Driver

From "it feels slow" to data-driven reliability

<div class="grid grid-cols-5 gap-6">
<div class="col-span-3">

- "The cluster feels slow today" 🤷 — devs complaining, sluggish **k9s** sessions
- Basic Grafana dashboards, but no clear target
- Degraded performance for **months** — never properly investigated

<div v-click="1" class="mt-4 p-3 bg-orange-100 bg-opacity-80 border-l-4 border-orange-500 rounded ">

Without a target and a timeline, "slow" is subjective and easy to ignore.

</div>

</div>
<div v-click="1" class="col-span-2 flex justify-center items-center">

<img src="./images/skeleton computer.png" class="rounded-lg shadow-lg max-h-60 w-auto" alt="Slow cluster experience">

</div>
</div>

<!--
Before SLOs, our reliability signal was vibes. Developers would complain,
we'd shrug, nobody prioritized fixing it.
-->

---
layout: default
---

# API Server SLOs
##

Three SLOs defined for the Kubernetes API server[^sre-book]:

- **Availability** — less than 0.1% of requests return 5xx or 429
- **Latency (read)** — GET/LIST within threshold (varies by subresource & scope)
- **Latency (write)** — POST/PUT/PATCH/DELETE within **1s**


Defining the PromQL queries was tedious but **sloth**[^sloth] made it tractable:

```yaml
slos:
  - name: apiserver-availability
    objective: 99.9
    sli:
      events:
        error_query: sum(apiserver_request_total{code=~"5..|429"})
        total_query: sum(apiserver_request_total)
```

→ generates all recording rules, multi-window burn-rate alerts, error budget calculations


[^sre-book]: <https://sre.google/sre-book/service-level-objectives/>
[^sloth]: <https://github.com/slok/sloth>

<!--
Got the task of implementing SLOs, wasn't thrilled at first. Sloth was a game
changer - define error_query + total_query, get dozens of recording rules for free.
-->

---
layout: default
---

# SLOs Reveal the Truth
##

<img src="./images/k8s-slo-dashboard.png" class="rounded-lg shadow-lg w-full" alt="Kubernetes SLO dashboard">

<div v-click class="mt-3 p-3 bg-orange-100 bg-opacity-80 border-l-4 border-orange-500 rounded">

"the cluster feels slow" → "we burned 40% of our error budget during Tuesday's upgrade"

</div>

<!--
Once SLOs were live, we could clearly see that cluster upgrades were our biggest
source of degradation. Impossible to dismiss now.
-->

---
layout: default
---

# Fix #1: etcd Topology — Before

##

Each apiserver connects to all 3 etcd members

<div class="grid grid-cols-5">
<div class="col-span-4 flex justify-start items-start">
  <div style="transform: scale(0.75); transform-origin: top left;">
    <Excalidraw
      drawFilePath="./drawings/etcd-initial-topology.excalidraw"
    />
  </div>
</div>
<div v-click class="col-span-1 absolute right-8 top-1/2 -translate-y-1/2">
  <img src="./images/meme-complex-junction-road.jpg" class="rounded-lg shadow-lg w-80" alt="Complex Junction road meme">
</div>
</div>

<!--
Our initial topology was a variant of the external topology, but with each
apiserver connecting to all 3 etcd members. The idea was redundancy, but
when one etcd node gets upgraded, all 3 apiservers are impacted.
-->

---
layout: default
---

# Fix #1: etcd Topology — After
##

Stacked topology: each apiserver talks to its local etcd[^ha-topo]

[^ha-topo]: <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/>

<div class="h-90 overflow-hidden">
<div class="flex justify-start items-start">
  <div style="transform: scale(0.70); transform-origin: top center;">
    <Excalidraw
      drawFilePath="./drawings/etcd-stacked-topology.excalidraw"
    />
  </div>
</div>
</div>

<!--
With stacked topology, each apiserver talks to its local etcd only.
An etcd upgrade now only impacts one apiserver instead of all three.
Already a significant improvement.
-->

---
layout: default
---

# Fix #2: etcd Leadership Migration
Moving leader away before maintenance

<div class="grid grid-cols-5">
<div class="col-span-3">

- Before upgrading a node, move etcd leadership to another member
- Avoids leader election during maintenance window
- Light improvement, but not the full solution

<p></p>

```bash
# move etcd leadership away from the node being upgraded
etcdctl move-leader $NEW_LEADER_ID
```

</div>
<div class="col-span-2 absolute right-8 top-1/2 -translate-y-1/2">
  <img src="./images/meme-etcd-leadership-hot-potato.jpg" class="rounded-lg shadow-lg w-80" alt="etcd leadership hot potato meme">
</div>
</div>

<!--
We modified our playbooks to migrate etcd leadership before touching a node.
This helped, but wasn't enough - the next fix was the real game changer.
-->

---
layout: default
---

# Fix #3: The Real Culprit

<div class="grid grid-cols-5 gap-6">
<div class="col-span-3">

One CP node doing all the work, the other two idle.

- **Long-lived HTTP/2 connections** never redistributed
- Clients open a connection once → reuse it forever

<div v-click="1">

**The fix:** `--goaway-chance=0.001`[^goaway]

→ 1/1000 requests get a GOAWAY, client reconnects through LB

</div>

</div>
<div v-click="1" class="col-span-2 p-4 bg-gray-100 bg-opacity-80 rounded font-mono text-xs border border-gray-300 self-start mt-4">

**RFC 7540 §6.8 — GOAWAY**[^rfc7540]

The GOAWAY frame (type=0x7) is used to initiate shutdown of a connection.

GOAWAY allows an endpoint to **gracefully stop accepting new streams** while still **finishing processing of previously established streams**.

</div>
</div>

[^goaway]: <https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/>
[^rfc7540]: <https://datatracker.ietf.org/doc/html/rfc7540#section-6.8>

<!--
This was the game changer. Long-lived HTTP/2 connections meant clients would
stick to one apiserver forever. The goaway-chance flag randomly closes
connections, forcing clients to reconnect through the load balancer. Once all
apiservers were handling traffic and had warm caches, upgrades stopped being
a problem.
-->

---
layout: default
---

# Part 2: Open-Source Monitoring Tools

Built from production needs, improved by the community

<div class="grid grid-cols-2 gap-8 mt-4">
<div class="bg-white bg-opacity-80 rounded-lg p-6 border border-gray-200 shadow-md">

## 🏥 **kubenurse**[^kubenurse]

- DaemonSet performing continuous network health checks
- Node-to-node, apiserver, ingress, service & DNS connectivity
- Latency histograms + error counters with httptrace events

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-6 border border-gray-200 shadow-md relative overflow-visible">

## 🔍 **hostlookuper**[^hostlookuper]

- Periodically resolves DNS targets, exports latency + errors as Prometheus metrics
- DNS is an excellent **network congestion indicator**: UDP packets are not retried and result in errors

<img v-click src="./images/meme-always-dns.jpg" class="absolute -right-8 -bottom-8 w-72 rounded-lg shadow-xl" style="z-index: 10;" alt="It's always DNS meme">

</div>
</div>

[^kubenurse]: <https://github.com/postfinance/kubenurse>
[^hostlookuper]: <https://github.com/postfinance/hostlookuper>

<style>
img.slidev-vclick-target {
  transition: all 0.4s cubic-bezier(0.22, 1, 0.36, 1);
}
img.slidev-vclick-hidden {
  transform: rotate(8deg) scale(3) !important;
  opacity: 0 !important;
}
img.slidev-vclick-target:not(.slidev-vclick-hidden) {
  transform: rotate(8deg) scale(1);
  opacity: 1;
}
</style>

<!--
Two open-source tools we built at PostFinance. hostlookuper is simpler — just DNS checks —
but surprisingly useful because DNS failures are often the first sign of network congestion.
kubenurse is more advanced and is what we'll focus on.
-->

---
layout: default
---

# kubenurse: 5 Request Types

A single DaemonSet, $n$ network paths checked every $x$ seconds


<div class="">
<div class="flex justify-center items-start">
  <div style="transform: scale(0.70); transform-origin: top center;" class="bg-white bg-opacity-80 rounded-lg p-8 shadow-lg">
    <Excalidraw
      drawFilePath="./drawings/kubenurse-request-types.excalidraw"
    />
  </div>
</div>
</div>

<!--
kubenurse validates 5 different network paths from every node: apiserver direct,
apiserver DNS, me-ingress, me-service, and neighborhood checks. The drawing
shows how a single pod reaches out to all these paths.
-->

---
layout: default
---

# kubenurse: httptrace Instrumentation

##

<div class="grid grid-cols-5 gap-6">
<div class="col-span-2">

Metrics are labeled with **httptrace event types** — precise breakdown of each request phase:

- `dns_start` / `dns_done`
- `connect_start` / `connect_done`
- `tls_handshake_start` / `tls_handshake_done`
- `got_conn` / `got_first_response_byte`

<div v-click class="mt-4 p-3 bg-orange-100 bg-opacity-80 border-l-4 border-orange-500 rounded ">

On errors, the **event label** tells you exactly which phase failed

</div>

</div>
<div class="col-span-3">

<img src="./images/kubenurse-dashboard.png" class="rounded-lg shadow-lg" alt="kubenurse Grafana dashboard">

</div>
</div>

<!--
The httptrace integration is what makes kubenurse really powerful. You don't just
know that a request failed — you know exactly which phase failed. Was it DNS? TCP?
TLS? This makes debugging network issues much faster.
-->

---
layout: default
---

# kubenurse: $O(n²)$ → $O(n)$

Community discussion via [GitHub issue #55](https://github.com/postfinance/kubenurse/issues/55) sparked the fix

<div class="grid grid-cols-5 gap-6 mt-2">
<div class="col-span-2">

**The problem:** every pod checked every other pod → $O(n^2)$

**The fix:** deterministic neighbor filtering

- Node names are hashed → each pod checks **$n$ neighbors** based on hash order (default: $n=10$)
- Distribution is random but deterministic → stable metrics across restarts

</div>
<div class="col-span-3 -mt-16 ml-28">
  <HashRing />
</div>
</div>

<!--
The community pointed out the quadratic scaling issue and the discussion that
followed sparked the deterministic hashing solution. Each node always checks
the same neighbors, so metrics are stable and meaningful. This is why you open-source.
-->

---
layout: default
---

# Graceful Shutdown: a Generic Problem

SLOs on kubenurse revealed errors on the `me_ingress` check during upgrades/maintenance

<div class="grid grid-cols-5 gap-6 mt-4">
<div class="col-span-3">

**The problem:** not specific to ingress-nginx — affects **any** process behind a load balancer

`SIGTERM` arrives, but the LB doesn't know yet → requests still routed to a dying process → errors

<div v-click>

**The fix:** lameduck shutdown[^lameduck] (inspired by CoreDNS)

- On `SIGTERM`: **keep serving** for a few seconds (default: **5s**)
- LB / proxies / CNI (hopefully) catch up and stop sending traffic
- Then stop the server

</div>

</div>
<div v-click class="col-span-2 flex justify-center items-center">

<img src="./images/meme-not-dead-yet.jpg" class="rounded-lg shadow-lg w-80" alt="I'm not dead yet meme">

</div>
</div>

[^lameduck]: <https://github.com/postfinance/kubenurse/commit/cef5f2ef>

<!--
After introducing SLOs for kubenurse itself, we noticed errors during node
maintenance. The ingress controller kept sending traffic to pods that were
already shutting down. The fix is simple: sleep a few seconds before actually
stopping, giving time for endpoint changes to propagate to the proxy/CNI.
CoreDNS calls this "lameduck" mode.
-->

---
layout: default
---

# Part 3: Continuous End-to-End Testing

Your end users should NOT be your end-to-end tests

<div class="grid grid-cols-2 gap-8 mt-4">
<div>

**Why?**

- Complex interactions between components
- Networking, storage, security, DNS validations

**Our approach**

- Go test suite using `e2e-framework`[^e2e-fw], scheduled as a **K8s CronJob** (every 15min)
- Results captured with **OpenTelemetry** → Grafana dashboards

</div>
<div>

```go
func TestKubernetesDeployment(t *testing.T) 
    start := time.Now()

    t.Cleanup(func() {
      metricsCollector.RecordTestExecution(
        t, time.Since(start),
      )
    })

    dep := newDeployment("nginx", 3)
    err := env.Create(ctx, dep)
    require.NoError(t, err)

    waitForPodsReady(t, dep, 30*time.Second)
}
```

</div>
</div>

[^e2e-fw]: <https://github.com/kubernetes-sigs/e2e-framework>

<!--
Our e2e tests run continuously on all 35 clusters, not just in CI.
Results flow into OTEL and Grafana so we see degradation trends over time.
-->

---
layout: default
---

# Open-Source: e2e-tests[^e2e-tests]

An analogous open-source implementation you can try today

<div class="grid grid-cols-2 gap-8 mt-4">
<div>

| Test | What it validates |
| --- | --- |
| **Deployment** | Pod scheduling, container runtime, workload lifecycle |
| **Storage (CSI)** | PV provisioning, read/write operations |
| **Networking** | DNS resolution, service discovery, inter-pod connectivity |
| **RBAC** | Role-based access boundaries, permission enforcement |

</div>
<div>

**How it runs**

- Deployed as a K8s **CronJob** (every 15min)
- Runs in-cluster: creates a namespace, provisions test resources, validates everything works
- Metrics stream to OTLP endpoint → VictoriaMetrics / Grafana

<div v-click class="mt-4 p-3 bg-orange-100 bg-opacity-80 border-l-4 border-orange-500 rounded ">

Fork it, adapt the tests to your platform, deploy as a CronJob → instant cluster health monitoring

</div>

</div>
</div>

[^e2e-tests]: <https://github.com/clementnuss/e2e-tests>

---
layout: default
---

# E2E Test Results

##

<div class="grid grid-cols-5 gap-6">
<div class="col-span-2">

- Tests run every **15 minutes** across all clusters
- Results visualized per cluster, per test category

<div v-click="1" class="mt-4 p-3 bg-orange-100 bg-opacity-80 border-l-4 border-orange-500 rounded ">

Alert rules trigger on test failures → we know before users do

</div>

</div>
<div class="col-span-3">

<img src="./images/e2e-tests-dashboard.png" class="rounded-lg shadow-lg" alt="e2e tests Grafana dashboard">

</div>
</div>

<div v-click="1" class="absolute right-15 bottom-24">
  <img src="./images/meme-tests-everywhere.jpg" class="rounded-lg shadow-lg w-62" alt="Tests everywhere meme">
</div>

<!--
The dashboard gives us continuous visibility into all 35 clusters.
When a test starts failing, we get alerted immediately.
-->

[^e2e-tests]: <https://github.com/clementnuss/e2e-tests>

<!--
Our internal e2e tests are not open-source, but I've written an analogous
implementation that covers the same patterns. Fork it and adapt to your needs.
-->

---
layout: default
---

# Part 4: The 502 Mystery

Tomcat-based e-finance app — 502s caused real user impact when retrieving e-banking resources

~1.7M requests/day on one ingress. **8–10 failures per day.** Where would you look?

<div class="grid grid-cols-5 gap-6 mt-4">
<div class="col-span-3">

- 502s uniformly distributed across all ingress-nginx pods
- No pattern in time, endpoint, or client
- App pods healthy, no errors in application logs
- CPU / memory fine, network policies correct
- Load testing with **K6** couldn't reproduce it
- Errors correlate with request volume — more traffic, more 502s
- But the **rate** stays constant: ~6 per million

</div>
<div class="col-span-2 flex flex-col items-center justify-center">

<img src="./images/claper-kubecon-qr.png" class="rounded-lg shadow-md w-64" alt="Claper poll QR code">

<div class="mt-2 text-center">

### **claper.n8r.ch** · code: **#KUBECON**

</div>

</div>
</div>

<!--
Show the QR code, give the audience 30 seconds to vote on where they'd look.
Then reveal the results and continue with the investigation.
-->

---
layout: default
---

# The Investigation

The breakthrough: finding the right log line

<div class="mt-4">

ingress-nginx error logs contain the **FQDN**, not the ingress name — we were searching for the wrong thing.

</div>

<div v-click class="mt-4 p-4 bg-gray-100 bg-opacity-80 rounded font-mono text-sm border border-gray-300">

upstream prematurely closed connection while reading response header from upstream

</div>

<div v-click class="mt-6">

This tells us:

- nginx **had** an open connection to the upstream (backend pod)
- It sent a request on that connection
- The backend **closed the connection** before responding
- nginx has no response to return → **502 Bad Gateway**

</div>

<!--
Once we found the right log line, the picture became clearer. This is about
keepalive connection reuse, not about the backend being unhealthy.
-->

---
layout: default
---

# The Race Condition

##

<div class="grid grid-cols-5 gap-6">
<div class="col-span-2">

Two conflicting keepalive timeouts:

- **nginx**: keeps connections open for **60s** (default)
- **Tomcat**: closes idle connections after **20s** (default)

<div v-click="1" class="mt-4">

The race window:

1. Connection sits idle for ~20s
2. Tomcat sends **FIN** to close it
3. At the same moment, nginx sends a **new request** on that connection
4. → **502 Bad Gateway**

</div>

</div>
<div class="col-span-3">
  <RaceCondition502 />
</div>
</div>

<div v-click="2" class="absolute right-0 top-0 bottom-0 z-10 flex items-center justify-center" style="left: 40%;">
  <img src="./images/meme-race-condition.jpg" class="rounded-lg shadow-xl w-90" alt="Race condition meme">
</div>

<!--
This is the aha moment. Two perfectly reasonable defaults — 60s and 20s —
create a tiny race window. The meme covers the diagram on purpose — it's funnier that way.
-->

---
layout: default
---

# The Fix[^blog-502]

One environment variable:

```bash
export TC_HTTP_KEEPALIVETIMEOUT="75000"  # 75s > nginx's 60s
```

<div class="grid grid-cols-2 gap-8 mt-4">
<div>

**The rule:** upstream `keepalive_timeout` must be **greater** than the reverse proxy's

- nginx default: **60s**
- Tomcat was: **20s** → now **75s**
- Backend always outlives the proxy's connection → no more race

</div>
<div>

**Lessons**

- K6 load tests failed because they didn't test **idle + burst** patterns
- Connection lifecycle timeouts must be coordinated **end-to-end**
- The fix is trivial — finding it is the hard part

</div>
</div>


[^blog-502]: <https://clement.n8r.ch/en/articles/502-upstream-errors/>

<!--
The fix was a single environment variable. But the journey to get there
required understanding keepalive semantics, reproducing with specific
idle+burst load patterns, and coordinating timeouts end-to-end.
-->

---
layout: default
---

# Key Takeaways

<div class="grid grid-cols-2 gap-8 mt-10 text-sm">
<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">

### **SLOs are a forcing function**

From "it feels slow" to data-driven fixes

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">

### **Open-source your tools**

The best fixes and discussions come from the community — not always code, sometimes just the right conversation

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">

### **Test continuously, in-cluster**

Your end users should not be your e2e tests

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md">

### **Every error matters**

8 out of 1.7M — still worth fixing

</div>
</div>

<!--
Each takeaway maps directly to what we covered: SLOs drove the etcd/goaway fixes,
open-source tools gave us kubenurse and community contributions, continuous testing
catches regressions, and the 502 story — found through a customer ticket — shows
why even tiny error rates matter and deserve investigation.
-->

---
layout: default
---

<div class="grid grid-cols-5 gap-6 h-full items-center">
<div class="col-span-3">

# Thank you!

<div class="grid grid-cols-3 gap-4 mt-4">
<div class="bg-white bg-opacity-80 rounded-lg p-4 border border-gray-200 shadow-md text-sm">

**[kubenurse](https://github.com/postfinance/kubenurse)**

Network monitoring DaemonSet

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-4 border border-gray-200 shadow-md text-sm">

**[e2e-tests](https://github.com/clementnuss/e2e-tests)**

K8s cluster validation CronJob

</div>
<div class="bg-white bg-opacity-80 rounded-lg p-4 border border-gray-200 shadow-md text-sm">

**[502 blog post](https://clement.n8r.ch/en/articles/502-upstream-errors/)**

Full debugging walkthrough

</div>
</div>

<div class="mt-6 flex items-center gap-4">
<a href="https://clement.n8r.ch/en/articles/" style="font-size: 1.1rem; color: #1a1a2e;" target="_blank">clement.n8r.ch</a>
<img src="./images/Jura.png" width="20rem" alt="Jura flag">
<a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" style="color: #1a1a2e;"
  class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-linkedin />
</a>
<a href="https://github.com/clementnuss" target="_blank" style="color: #1a1a2e;"
  class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-github />
</a>
</div>

</div>
<div class="col-span-2 flex flex-col items-center text-center">

<img src="./images/claper-kubecon-qr.png" class="rounded-lg shadow-md w-52" alt="Claper QR code">

<div class="mt-3 text-lg font-bold">Questions? Ask here!</div>
<div class="mt-1 text-sm"><strong>claper.n8r.ch</strong> · code: <strong>#KUBECON</strong></div>

</div>
</div>

<!--
Thank you! Happy to take questions on SLOs, kubenurse, e2e testing,
or debugging connection lifecycle issues.
-->

---
layout: default
---

# Appendix: Reproducing the 502 with K6

The key: **idle → burst** stages with varying idle durations to hit the keepalive race window

<div class="grid grid-cols-2 gap-6 mt-2 text-xs">
<div>

```js
// Cycle: ramp up → sustain → ramp down → idle
// Idle duration increases (4s→11s) to maximize
// chance of hitting Tomcat's 20s timeout boundary
function generate_stages() {
    var stages = []
    for (let i = 4; i < 12; i++) {
        stages.push({ duration: "5s", target: 100 });
        stages.push({ duration: "55s", target: 100 });
        stages.push({ duration: "5s", target: 0 });
        stages.push({ duration: i + "s", target: 0 });
    }
    return stages
}
```

</div>
<div>

```js
export let options = {
    noConnectionReuse: true,
    noVUConnectionReuse: true,
    scenarios: {
        http_502: {
            stages: generate_stages(),
            executor: 'ramping-vus',
            gracefulRampDown: '1s',
        },
    },
};

export default function() {
    let data = { data: 'Hello World' };
    for (let i = 0; i < 10; i++) {
        let res = http.post(
          `${__ENV.URL}`, JSON.stringify(data));
        check(res, {
          "status was 200": (r) => r.status === 200
        });
    }
    sleep(1);
}
```

</div>
</div>

<style>
.slidev-code {
  font-size: 0.7rem !important;
  line-height: 1.3 !important;
}
</style>

<!--
This K6 script reproduces the 502 by cycling through load → idle → load phases.
The varying idle durations (4s to 11s) increase the chance of hitting the exact
moment when Tomcat's 20s keepalive timer fires while nginx still thinks the
connection is alive. noConnectionReuse ensures fresh connections on each VU iteration.
-->
<!-- prettier-ignore-end -->
