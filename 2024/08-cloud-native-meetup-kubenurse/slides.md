---
theme: seriph
themeConfig:
  primary: '#E85C0D'
# color palette: #FABC3F #E85C0D #C7253E #821131
addons:
  - slidev-addon-excalidraw
background: /images/IMG_0719_Original.jpeg
layout: cover
title: "Kubenurse: The In-Cluster Nurse Making Network Rounds"

author: Clément Nussbaumer
info: |-
  Have you ever encountered unexplained application instability that may be
  linked to network issues, but struggled to identify the underlying cause?
  Introducing Kubenurse, an open-source monitoring tool developed by PostFinance.
  It functions as an in-cluster nurse, continuously monitoring the health of
  network paths between pods, services, ingresses, and neighboring nodes.
  Kubenurse benefits application developers by preventing them from chasing
  elusive bugs originating from infrastructure issues. It also aids cluster
  operators in pinpointing bottlenecks, identifying nodes with network problems,
  and uncovering issues such as DNS failures and interrupted TCP/TLS
  negotiations.
  Overall, Kubenurse provides a metrics-based assessment of a cluster's stability
  and performance, and is simply one DaemonSet away from your cluster!

class: text-center
highlighter: shiki
mdc: true
hideInToc: true
---

# Kubenurse
## The In-Cluster Nurse Making Network Rounds

Cloud Native Bern Meetup - 28th of August 2024

**Clément Nussbaumer**

<a href="https://clement.n8r.ch/en/articles/" style="font-size: 1.5rem;" target="_blank" alt="Blog" class="absolute right-6rem bottom-30px m-6 text-xl">clement.n8r.ch</a>

<a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" alt="Blog"
  class="absolute right-4rem bottom-30px m-6  text-xl icon-btn opacity-100 !border-none "><carbon-logo-linkedin />
</a>

<a href="https://github.com/clementnuss" target="_blank" alt="GitHub"
  class="absolute right-2rem bottom-30px m-6 text-xl icon-btn opacity-100 !border-none"><carbon-logo-github />
</a>

---

```yaml
title: Kubernetes @ PostFinance
transition: slide-up
```

# Kubernetes @ PostFinance

<div grid="~ cols-2 gap-4">
<div>

30 Vanilla v1.29 Kubernetes

Oldest cluster `AGE 5y57d`

450 nodes (15 with GPU)

Namespace self-service with inhouse operator

ArgoCD and GitOps for almost all deployments

Chaos Monkey on all clusters 🐒

</div>
<div>
<figure>
  <img border="rounded" src="/images/postfinance-intro.webp" width="90%" alt="">
  <footer><cite style="font-size: 70%;display: block;text-align: center;" >Created with FLUX.1 [dev] by Black Forest Labs</cite></footer>
</figure>
</div>
</div>

<!--
Some figures:

- **1406** namespaces across **30** Kubernetes clusters
- **18'000** pods, **4200** ingresses
- **450 nodes** (24 CPU / 64 GiB RAM)
  - 14 GPU nodes for machine learning workloads
- **4000 RPS** peak load across all ingresses
- **400** card transaction per second
-->


---

```yaml
title: Computers are random access machines
```

# Computers are random access machines
<div class="grid grid-cols-4 w-full gap-4" >
<div class="col-span-2 v-full flex justify-center items-center ">

> Definition: A model of computation whose memory consists of an unbounded
> sequence of registers, each of which may hold an integer. In this model,
> arithmetic operations are allowed to compute the address of a memory
> register.
> <cite style="font-size: 70%;line-height: 1rem;display:block">Algorithms and Theory of Computation Handbook, CRC Press LLC, 1999, "random access machine", in Dictionary of Algorithms and Data Structures , Paul E. Black, ed. 17 December 2004. Available from: <a href="https://www.nist.gov/dads/HTML/randomaccess.html" target="_blank">https://www.nist.gov/dads/HTML/randomaccess.html</a></cite>

</div>
<div place-items="center" class="flex col-span-2">
<figure>
  <img border="rounded" src="/images/random-machine-flux1schnell.webp" width="90%" alt="">
  <footer><cite style="font-size: 70%;display: block;text-align: center;" >Created with FLUX.1 [schnell] by Black Forest Labs</cite></footer>
</figure>

</div>
</div>

<!--
in the context of theoretical computer science, servers/computers can be
considered as a practical realization of random (access) machines

-->

---

```yaml
title: Computers are random
hideInToc: true
transition: slide-up
```

# Computers are **random** ~~access machines~~

<div class="grid grid-cols-4 w-full gap-4" >
<div place-items="center" class="flex col-span-2">
<figure>
  <img border="rounded" src="/images/server-exploding-flux1schnell.webp" width="90%" alt="">
  <footer><cite style="font-size: 70%;display: block;text-align: center;" >Created with FLUX.1 [schnell] by Black Forest Labs</cite></footer>
</figure>
</div>
<div class="col-span-2 v-full flex justify-center items-center ">

> Definition: Computers always suprise us in random ways.
>
> Some examples: power failure, network links instability, disk failure,
> library incompatibilities, CPU overload, network bottlenecks, DDoS attacks,
> DNS problems (always), file system corruption, ...
> <cite style="font-size: 70%;line-height: 1rem;display:block">Clément Nussbaumer, 2024 (and the list keeps getting longer)</cite>

</div>
</div>
---

```yaml
title: Kubenurse image
hideInToc: true
```
# Kubenurse


<div class="grid grid-cols-4 w-full gap-4" >
<div class="col-span-2">
<figure>
  <img border="rounded" src="/images/kubenurse-flux1dev.jpg" width="90%" alt="">
  <footer><cite style="font-size: 70%;display: block;text-align: center;" >Created with FLUX.1 [dev] by Black Forest Labs</cite></footer>
</figure>
</div>

<div place-items="center" class="flex col-span-2" style="text-align: center;">

## The In-Cluster Nurse Making Network Rounds
</div>
</div>

---

```yaml
title: Kubenurse history
hideInToc: true
```
# Kubenurse

<div class="grid grid-cols-5 w-full gap-4" >
<div place-items="center" class="flex col-span-2">
<img border="rounded" src="/images/kubenurse-timeline.png" alt="">
</div>

<div class="col-span-3">
<img border="rounded" src="/images/kubenurse-star-history-2024827.png" alt="">
</div>
</div>
---

```yaml
title: Kubenurse
```

# Kubenurse

```console
❯ kubectl get daemonset kubenurse
NAME        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
kubenurse   6         6         6       6            6           <none>          35h

❯ kubectl top pod
NAME              CPU(cores)   MEMORY(bytes)
kubenurse-74gd4   34m          38Mi
kubenurse-gfb7x   31m          38Mi
kubenurse-h86h4   38m          38Mi
kubenurse-ptj8n   35m          42Mi
kubenurse-rv66b   31m          32Mi
kubenurse-snpmz   39m          38Mi

❯ kubectl get pods -o yaml | yq '.items[0].spec.containers[].env'
- name: KUBENURSE_HISTOGRAM_BUCKETS
  value: .0005,.001,.0025,.005,.01,.025,.05,0.1,0.25,0.5,1
- name: KUBENURSE_CHECK_INTERVAL
  value: 0.5s
- name: KUBENURSE_REUSE_CONNECTIONS
  value: "false"
- ...
```

---

```yaml
title: Kubenurse - request types
```

# Kubenurse request types

<div class="v-full flex justify-center items-center " >

<img border="rounded" src="/images/kubenurse-request-type.png" width="50%" alt="">
</div>
<div>
</div>

---

# Kubenurse metrics

| metric name                                           | labels               | description                                                                                                                  |
| ----------------------------------------------------- | -------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `kubenurse httpclient requests total`                 | `type, code` | counter for the total number of http requests, partitioned by HTTP code and request type                            |
| `kubenurse errors total`                              | `type, event`        | error counter, partitioned by httptrace event and request type                                                               |
| `kubenurse httpclient request duration seconds`       | `type`               | latency histogram for request duration, partitioned by request type                                                          |

---

```yaml
transition: slide-up
```

# Kubenurse dashboard

<div class="v-full flex justify-center items-center " >
<img border="rounded" src="/images/grafana-dashboard.png" width="80%" alt="">
</div>
<div>
</div>

---

```yaml
transition: slide-up
```

# Real-world example

<div class="grid grid-cols-5 w-full gap-4" >

<div class="col-span-1">

&rarr; how do you notice **random** packet drops ?

&rarr; how do you notice a slight latency increase ?

</div>

<div v-click='at=1' class="col-span-4">
<img border="rounded" src="/images/example-esxi-failure.png" width="90%" alt="">
</div>
</div>

---

```yaml
transition: slide-up
```

# Demo


<div class="grid grid-cols-4 w-full gap-4" >
<div class="col-span-2">

<figure>
  <img border="rounded" src="/images/demo-monkey.webp" width="95%" alt="">
  <footer><cite style="font-size: 70%;display: block;text-align: center;" >Created with FLUX.1 [dev] by Black Forest Labs</cite></footer>
</figure>
</div>

<div place-items="center" class="flex col-span-2" style="text-align: center; justify-content: center;">

### Installing Kubenurse

</div>
</div>
---

# Node discovery at scale
[GitHub issue #55](https://github.com/postfinance/kubenurse/issues/55)

<div class="grid grid-cols-5 w-full gap-4" >

<div class="col-span-2">

mostly 2 problems:

1. no caching

1. $O(n^2)$ neighbouring checks

</div>

<div class="col-span-3">
<img border="rounded" class="border b-gray-2 shadow" src="/images/gh-issue-node-discovery-scale.png" width="90%" alt="">
</div>
</div>



---

# Node discovery at scale

<div class="v-full flex justify-center items-center " >

<img class="p-4 border b-gray-2 shadow" border="rounded" src="/images/node-discovery.png" width="80%" alt="">
</div>


---

```yaml
title: measure randomness !
```

<div class="grid grid-cols-4 w-full gap-4" >
<div class="col-span-2 v-full flex justify-center items-center" style="flex-direction: column;" >

<h1 style="font-weight: 700;" >measure randomness</h1 >

<div style="display:flex; align-items: baseline; ">
<a href="https://clement.n8r.ch/en/articles/" style="font-size: 1.5rem;" target="_blank" alt="Blog" class="m-2 text-xl ">clement.n8r.ch</a>

<a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" alt="Blog"
  class="m-2 text-xl icon-btn opacity-100 !border-none "><carbon-logo-linkedin />
</a>

<a href="https://github.com/clementnuss" target="_blank" alt="GitHub"
  class="m-2 text-xl icon-btn opacity-100 !border-none"><carbon-logo-github />
</a>
</div>


</div>
<div place-items="center" class="flex col-span-2">
<figure>
  <img border="rounded" src="/images/kubenurse-measure-randomness.webp" width="100%" alt="">
  <footer><cite style="font-size: 70%;display: block;text-align: center;" >Created with FLUX.1 [dev] by Black Forest Labs</cite></footer>
</figure>

</div>
</div>