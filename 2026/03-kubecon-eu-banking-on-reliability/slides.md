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
mdc: true
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

# Agenda

<br>

<div class="grid grid-cols-2 gap-8">
<div>

### 1. SLOs as a Driver for Improvement
How Service Level Objectives cascaded into concrete platform fixes

### 2. Open-Source Monitoring Tools
DNS monitoring and kubenurse: node-to-node mesh checks

</div>
<div>

### 3. Continuous End-to-End Testing
A Golang test suite covering all platform aspects

### 4. Interactive Debugging: The 502 Mystery
Tracking down 6-per-million failed requests

</div>
</div>

<!--
Here's what we'll cover today - four stories from our journey building
reliability into a banking Kubernetes platform.
-->

---
layout: default
---

# About Me

<div class="grid grid-cols-3 gap-8 h-85 items-start">
<div class="bg-white bg-opacity-70 backdrop-filter backdrop-blur-md rounded-lg p-6 border border-white border-opacity-0">

## 👨‍💻 **Clément Nussbaumer**

- Systems Engineer at PostFinance 🏦 🇨🇭
- Living on a farm 🐄
- Musician in a Brass Band 🎺
- Father of 1 👶

</div>
<div class="bg-white bg-opacity-70 backdrop-filter backdrop-blur-md rounded-lg p-6 border border-white border-opacity-20">

## 🏦 **PostFinance**

- Systemic Swiss financial institution
- ~35 Kubernetes clusters
- Air-gapped environment
- Strict regulatory requirements

</div>
<div class="bg-white bg-opacity-70 backdrop-filter backdrop-blur-md rounded-lg p-6 border border-white border-opacity-20">

## 🖥️ **The Platform**

- 5+ years in production
- kubeadm / Debian clusters 
- ongoing Talos + [TOPF](https://github.com/postfinance/topf/) migration

</div>
</div>

<div v-click class="p-2 bg-orange-100 bg-opacity-80 border-l-4 border-orange-500 rounded backdrop-filter backdrop-blur-md text-center">

**Every failed request = potential denied payment** 💸

</div>

<!--
A quick introduction - I'm a platform engineer at PostFinance, a major Swiss
financial institution where reliability is not just nice-to-have, it's regulated.
-->

---
layout: default
---

# Part 1: SLOs as a Driver

## How we went from "it feels slow" to data-driven reliability

<br>

<div class="grid grid-cols-2 gap-8">
<div>

**The situation before SLOs**

- "The cluster feels slow today" 🤷
- Devs complaining about sluggish `kubectl` / `k9s` sessions
- We had basic Grafana dashboards showing request times
- Degraded performance for **months** - never properly investigated
- No link to any particular event

</div>
<div>

<div v-click class="p-4 bg-orange-100 bg-opacity-80 border-l-4 border-orange-500 rounded backdrop-filter backdrop-blur-md">

**The problem:** without a clear target and structured measurement, "slow" is subjective and easy to ignore.

We tolerated degradation because we couldn't quantify it.

</div>

</div>
</div>

<!--
Before SLOs, our reliability signal was basically vibes. Developers would
complain, we'd shrug, and life went on. The cluster was slow sometimes,
but it wasn't terrible, so nobody prioritized fixing it.
-->

---
layout: default
---

# Implementing SLOs

## Standing on the shoulders of giants

<div class="grid grid-cols-2 gap-8">
<div>

**Google's SRE Book**[^sre-book] covers SLOs extensively - I won't repeat it here.

Someone on the team suggested we implement SLOs. I got the task and honestly wasn't thrilled at first.

**What we defined for the API server:**

- **Availability**: % of non-5xx/429 responses → target **99.9%**
- **Latency (read-only)**: GET/LIST requests completing within threshold (varies by subresource & scope)
- **Latency (read-write)**: POST/PUT/PATCH/DELETE completing within **1s**

[^sre-book]: <https://sre.google/sre-book/service-level-objectives/>

</div>
<div>

<div v-click>

**The hard part: PromQL queries**

Properly defining the `error_query` and `total_query` for each SLI took real effort.

For latency SLOs, you need to account for different thresholds per verb, subresource, and scope.

```promql
# e.g. read-only latency error query
apiserver_request_duration_seconds_count{
  verb=~"LIST|GET"
} - apiserver_request_sli_duration_seconds_bucket{
  verb=~"LIST|GET"
}
```

</div>

</div>
</div>

<!--
I got the task of implementing SLOs. Wasn't really fond of it at first -
defining the PromQL queries precisely was tedious. You need to handle
different latency thresholds for different verbs and subresources.
-->

---
layout: default
---

# Sloth: Making SLOs Tractable

<div class="grid grid-cols-2 gap-8 h-85 items-start">
<div class="flex flex-col justify-start">

**Sloth**[^sloth] made SLO implementation manageable:

- Define your SLI with just `error_query` + `total_query`
- Generates **all** required recording rules
- Generates multi-window multi-burn-rate alerts
- Clean YAML specification

```yaml
slos:
  - name: apiserver-availability
    objective: 99.9
    sli:
      events:
        error_query: |
          sum(apiserver_request_total{
            code=~"5..|429"})
        total_query: |
          sum(apiserver_request_total)
```

[^sloth]: <https://github.com/slok/sloth>

</div>
<div class="flex flex-col justify-start">

<div v-click>

**What Sloth generates for you:**

- `slo:sli_error:ratio_rate5m`
- `slo:sli_error:ratio_rate30m`
- `slo:sli_error:ratio_rate1h`
- `slo:sli_error:ratio_rate2h`
- `slo:sli_error:ratio_rate6h`
- `slo:sli_error:ratio_rate1d`
- `slo:sli_error:ratio_rate3d`
- Multi-window burn-rate alerts (page / ticket)
- Error budget remaining calculations

Without Sloth, you'd write **dozens** of recording rules by hand.

</div>

</div>
</div>

<!--
Sloth was a game changer. Instead of writing dozens of recording rules by hand,
you define your SLI in a few lines and it generates everything. Highly recommend it.
-->

---
layout: default
---

# SLOs Reveal the Truth

## And then we started seeing what was really going on

<br>

<div class="grid grid-cols-2 gap-8">
<div>

**With SLOs in place, we could finally see:**

- Error budget burning during cluster upgrades
- Latency SLO violations correlating with specific events
- Degraded API server performance was **measurable**, not just "a feeling"

<div v-click class="mt-6 p-4 bg-orange-100 bg-opacity-80 border-l-4 border-orange-500 rounded backdrop-filter backdrop-blur-md">

**The shift:** from "the cluster feels slow" to "we burned 40% of our monthly error budget during last Tuesday's upgrade."

</div>

</div>
<div>

TODO: Add Grafana screenshot of SLO dashboard showing error budget burn during upgrades

</div>
</div>

<!--
This is where it got interesting. Once the SLOs were live, we could clearly see
that cluster upgrades were our biggest source of degradation. What we'd been
ignoring for months was now quantified and impossible to dismiss.
-->

---
layout: default
---

# Part 2: Open-Source Monitoring Tools

## Built from production needs, improved by the community

<br>

<div class="grid grid-cols-2 gap-8">
<div class="bg-white bg-opacity-10 backdrop-filter backdrop-blur-md rounded-lg p-6 border border-white border-opacity-20">

## 🔍 **DNS Monitoring**

- Continuous DNS resolution checks
- Detect silent failures
- Track resolution latency
- Alert before users notice

</div>
<div class="bg-white bg-opacity-10 backdrop-filter backdrop-blur-md rounded-lg p-6 border border-white border-opacity-20">

## 🏥 **kubenurse**

- Node-to-node mesh checks
- Network latency monitoring
- Ingress & service connectivity
- DaemonSet-based, always-on

🔗 github.com/postfinance/kubenurse

</div>
</div>

<!--
Now let's look at two monitoring tools we built and open-sourced.
Both were born from real production incidents.
-->

---
layout: default
---

# DNS Monitoring Tool

<div class="grid grid-cols-2 gap-8 h-85 items-start">
<div class="flex flex-col justify-start">

**Why monitor DNS?**

- DNS is the most common point of failure
- Silent degradation goes unnoticed
- In banking: DNS failure = service outage = denied payments

**How it works**

- Golang service running in-cluster
- Periodically resolves configured domains
- Exposes Prometheus metrics for latency & errors
- Alerts on degradation thresholds

</div>
<div class="flex flex-col justify-start">

TODO: Add architecture diagram or code snippet

</div>
</div>

<!--
DNS monitoring - because DNS is always the problem, and you want to know
before your customers do.
-->

---
layout: default
---

# kubenurse: Node-to-Node Mesh

<div class="grid grid-cols-5 gap-4 h-85 items-start">
<div class="col-span-2 flex flex-col justify-start">

**What kubenurse monitors**

- 🌐 **Node-to-node** network latencies
- 🔌 **Pod-to-apiserver** communication
- 🎯 **Ingress & service** connectivity
- 🔍 **DNS resolution** performance

```yaml
# Deploy with Helm
helm repo add kubenurse \
  https://postfinance.github.io/kubenurse
helm install kubenurse kubenurse/kubenurse
```

<div v-click class="mt-4 bg-white bg-opacity-10 backdrop-filter backdrop-blur-md rounded-lg p-4 border border-white border-opacity-20">

💡 kubenurse runs as a DaemonSet and performs health checks every 5 seconds

</div>

</div>
<div class="col-span-3 flex flex-col justify-start">

TODO: Add kubenurse architecture diagram (Excalidraw)

</div>
</div>

<!--
kubenurse is our distributed mesh for node-to-node checks. It detects network
problems and performance degradations that would otherwise go unnoticed.
-->

---
layout: default
---

# kubenurse metrics

| metric name | labels | description |
| --- | --- | --- |
| `kubenurse_httpclient_requests_total` | `type, code` | counter for total HTTP requests, by code and type |
| `kubenurse_errors_total` | `type, event` | error counter, by httptrace event and request type |
| `kubenurse_httpclient_request_duration_seconds` | `type` | latency histogram, by request type |

<br>

<div v-click>

**Real-world detection example:**

&rarr; How do you notice **random** packet drops?

&rarr; How do you notice a slight latency increase on a single node?

&rarr; kubenurse makes the invisible **visible**.

</div>

<!--
These metrics give you full visibility into your cluster's network health.
Let me show you a real-world example of what kubenurse can detect.
-->

---
layout: default
---

# Community Contributions: O(n²) to O(n)

<div class="grid grid-cols-5 gap-4 h-85 items-start">
<div class="col-span-2 flex flex-col justify-start">

**The scaling problem**

[GitHub issue #55](https://github.com/postfinance/kubenurse/issues/55)

Two problems identified by the community:

1. **No caching** of node discovery results
2. **$O(n^2)$ neighbouring checks**

Every kubenurse pod was checking every other pod, and rediscovering neighbours on each round.

<div v-click class="mt-4 p-4 bg-orange-100 bg-opacity-80 border-l-4 border-orange-500 rounded backdrop-filter backdrop-blur-md">

**After the fix:** $O(n)$ checks with cached discovery. Clusters with 500+ nodes now work smoothly.

</div>

</div>
<div class="col-span-3 flex flex-col justify-start">

TODO: Add screenshot of the GitHub issue or a before/after diagram

</div>
</div>

<!--
One of the best examples of why open-sourcing matters. A community contributor
identified and fixed a quadratic scaling issue we hadn't hit yet at our scale.
-->

---
layout: default
---

# Part 3: Continuous End-to-End Testing

## Your end users should NOT be your end-to-end tests

<br>

<div class="grid grid-cols-2 gap-8">
<div>

**Why E2E testing on K8s?**

- Infrastructure as Code needs testing too
- Complex interactions between components
- Networking, storage, security validations
- **Real environment** behavior vs unit tests

</div>
<div>

**Our approach**

- Go-based test suite using `e2e-framework`[^e2e-fw]
- Tests run **continuously**, not just in CI
- Covers networking, DNS, storage, RBAC, and more
- Results captured with **OpenTelemetry**

[^e2e-fw]: https://github.com/kubernetes-sigs/e2e-framework

</div>
</div>

<div v-click class="mt-4 p-4 bg-blue-100 bg-opacity-30 border-l-4 border-blue-500 rounded backdrop-filter backdrop-blur-md text-center">

💡 **You want to know something is broken _before_ users start calling you at 3am** 😴

</div>

<!--
Let's move on to our approach to end-to-end testing. We want to catch issues
before our banking customers do.
-->

---
layout: default
---

# E2E Test Architecture

<div class="grid grid-cols-2 gap-8 h-85 items-start">
<div class="flex flex-col justify-start">

**Building blocks**

- 🚀 **Deployments** - Pod creation & readiness
- 💾 **Persistent Volumes** - Storage functionality
- 🌐 **Networking & CNI** - Service connectivity
- 🔒 **Security Policies** - RBAC validation
- 📊 **Observability** - Metrics & logging

**OpenTelemetry Integration**

- Test results pushed to OTEL collector
- Dashboard visualization of test outcomes
- Historical tracking of cluster health

</div>
<div class="flex flex-col justify-start">

```go
func TestKubernetesDeployment(t *testing.T) {
    start := time.Now()

    // register cleanup to record results
    t.Cleanup(func() {
      metricsCollector.RecordTestExecution(
        t, time.Since(start),
      )
    })

    // create deployment and wait for ready
    dep := newDeployment("nginx", 3)
    err := env.Create(ctx, dep)
    require.NoError(t, err)

    // validate pods are running
    waitForPodsReady(t, dep, 30*time.Second)
}
```

</div>
</div>

<!--
Here's the architecture of our e2e test suite. Each test is a reproducible
building block that you can adapt for your own clusters.
-->

---
layout: default
---

# E2E Test Results Dashboard

<div class="grid grid-cols-2 gap-8 h-85 items-start">
<div class="flex flex-col justify-start">

**Continuous monitoring with Grafana**

- Tests run every 5 minutes across all clusters
- Results visualized per cluster, per test category
- Historical trends reveal degradation patterns
- Alert rules trigger on test failures

🔗 github.com/clementnuss/e2e-tests

</div>
<div class="flex flex-col justify-center items-center">

TODO: Add screenshot of e2e test Grafana dashboard

</div>
</div>

<!--
The test results flow into Grafana dashboards, giving us continuous visibility
into the health of all 35 clusters.
-->

---
layout: default
---

# Part 4: The 502 Mystery

## Interactive debugging session

<br>

<div class="grid grid-cols-2 gap-8">
<div>

**The symptoms**

- **6 per million** requests returned 502
- Seemingly random, no pattern in time or endpoint
- In banking: failed requests = **denied payments**
- Support tickets from payment processing teams

</div>
<div>

**The stakes**

- Financial regulatory compliance
- Customer trust and satisfaction
- Every 502 = a potentially denied transaction
- 6 per million sounds small, until you calculate the daily volume

<div v-click class="mt-4 p-4 bg-orange-100 bg-opacity-80 border-l-4 border-orange-500 rounded backdrop-filter backdrop-blur-md">

**~10M requests/day × 6/million = ~60 failed requests/day** 💸

</div>

</div>
</div>

<!--
And now for the fun part - let's do some live debugging together.
6 per million sounds negligible, but at scale it's 60 failed requests per day.
-->

---
layout: default
---

# 502 Errors: The Investigation

<div class="grid grid-cols-2 gap-8 h-85 items-start">
<div class="flex flex-col justify-start">

**What we tried first**

- Checked application logs - no errors
- Checked pod resource usage - normal
- Checked node health - all green
- Checked network policies - correct

**The breakthrough**

- 502 = upstream server closed connection
- nginx proxy sitting between client and backend
- The error happens during connection reuse

</div>
<div class="flex flex-col justify-start">

TODO: Add diagram showing the request flow through nginx

</div>
</div>

<!--
We went through the usual debugging checklist and everything looked fine.
The breakthrough came when we looked at the connection lifecycle.
-->

---
layout: default
---

# 502 Errors: Root Cause

## Mismatched connection timeouts

<div class="grid grid-cols-2 gap-8 h-80 items-start">
<div class="flex flex-col justify-start">

**The race condition**

1. nginx keeps connections open for **X seconds**
2. Backend closes idle connections after **Y seconds**
3. When **Y < X**: nginx sends request on a connection the backend just closed
4. Result: **502 Bad Gateway**

**The fix**

- Ensure upstream `keepalive_timeout` > nginx `keepalive_timeout`
- Or: configure nginx to handle upstream connection resets gracefully

</div>
<div class="flex flex-col justify-start">

TODO: Add Excalidraw diagram showing the timeout mismatch race condition

</div>
</div>

<!--
The root cause was a classic timeout mismatch. The backend was closing
connections slightly before nginx expected, creating a tiny race window.
-->

---
layout: default
---

# 502 Errors: The Fix & Lessons

<div class="grid grid-cols-2 gap-8 h-85 items-start">
<div>

**The configuration change**

TODO: Add specific nginx/backend timeout configuration

**Validation**

- Deployed fix to staging
- Monitored for 48 hours
- 502 rate dropped to zero
- Rolled out to all clusters

</div>
<div>

**Lessons learned**

1. **Measure everything** - without SLOs we might never have noticed 6/million
2. **Connection lifecycle matters** - timeouts must be coordinated end-to-end
3. **Small errors compound** - 6/million × millions of daily requests = real impact
4. **Banking context amplifies risk** - every failed request has financial implications

</div>
</div>

<!--
The fix was a simple configuration change, but finding it required
understanding the full request lifecycle. This is why SLOs matter.
-->

---
layout: default
---

# Key Takeaways

<br>

<div class="grid grid-cols-2 gap-8">
<div class="bg-white bg-opacity-10 backdrop-filter backdrop-blur-md rounded-lg p-6 border border-white border-opacity-20">

## **SLOs are a forcing function**

They reveal hidden issues across your stack and give you the data to prioritize fixes.

</div>
<div class="bg-white bg-opacity-10 backdrop-filter backdrop-blur-md rounded-lg p-6 border border-white border-opacity-20">

## **Open-source your tools**

Community contributions can be transformative. The O(n²) → O(n) fix came from a user, not us.

</div>
</div>

<div class="grid grid-cols-2 gap-8 mt-6">
<div class="bg-white bg-opacity-10 backdrop-filter backdrop-blur-md rounded-lg p-6 border border-white border-opacity-20">

## **Test continuously**

Not just in CI, but in production. Your end users should not be your end-to-end tests.

</div>
<div class="bg-white bg-opacity-10 backdrop-filter backdrop-blur-md rounded-lg p-6 border border-white border-opacity-20">

## **Every error matters**

6 per million is too many in banking. Measure, investigate, fix.

</div>
</div>

<!--
Let me wrap up with the key takeaways from today's session.
-->

---
layout: default
---

<div class="flex flex-col justify-center items-center h-full text-center">

<h1 class="mt-8">Thank You! 🙏</h1>

<div class="text-xl font-bold mt-4 mb-6">
Questions?
</div>

<div class="grid grid-cols-2 gap-12 w-full max-w-3xl items-start mt-8">

<div class="flex flex-col items-center">
<div class="text-center">

**Links**

- 🏥 github.com/postfinance/kubenurse
- 🧪 github.com/clementnuss/e2e-tests
- 📝 clement.n8r.ch

</div>
</div>

<div class="flex flex-col justify-start">
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

</div>
</div>
</div>

</div>

<!--
Thank you! I'm happy to take any questions about SLOs, kubenurse,
e2e testing, or debugging connection issues.
-->
<!-- prettier-ignore-end -->
