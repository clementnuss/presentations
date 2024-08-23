---
theme: seriph
background: /images/corno-nero.jpeg
layout: cover
title: "RUD: Rapid Unscheduled Deletion of Critical Infrastructure Workloads"

author: Clément Nussbaumer
info: |-
  Managing Kubernetes clusters often involves deploying a variety of
  infrastructure workloads for tasks like observability (log/metric collection),
  security (validation webhooks), monitoring (DNS, network), and more.
  This session delves into how PostFinance effectively manages its infrastructure
  workloads across 30 vanilla Kubernetes clusters using ArgoCD ApplicationSets,
  and shows how rapidly it was possible to trigger an incident across all our
  clusters with a simple "Sync" operation.
  Finally, we'll unpack the lessons learned, including safeguards and circular
  dependency considerations, to prevent similar incidents in your own ArgoCD
  environments.

class: text-center
highlighter: shiki
mdc: true
hideInToc: true
---

## RUD: Rapid Unscheduled Deletion of
## Critical Infrastructure Workloads

Kubernetes Community Days Zürich - 13th of June 2024

**Clément Nussbaumer**

<a href="https://github.com/clementnuss" target="_blank" alt="GitHub"
  class="abs-br m-6 text-xl icon-btn opacity-100 !border-none !hover:text-dark-500"><carbon-logo-github />
</a>

---
title: RU..Disassembly
hideInToc: true
---

# RUD - Rapid Unscheduled ...

<div grid="~ cols-2 gap-5" m="t-2" place-items="center" class="text-center">

<div v-click at='1'>

### Disassembly 🚀 💥
</div>

<div v-click at='2'>

### Deletion of Critical Infrastructure Workload 🥱 ⏳
</div>

<img v-click='1' border="rounded" src="/images/RUD-spacex.jpeg" width="90%" alt="">

<img v-click='2' border="rounded" src="/images/RUD-argocd.png" alt="">

</div>

---
title: awesomeness - IT incident vs rockets
hideInToc: true
---

# Awesomeness scale

<img src="/images/awesomeness.png" alt="" width="90%">

---
transition: slide-up
layout: center
title: Agenda
hideInToc: true
---

Agenda:

<Toc minDepth="1" maxDepth="1"></Toc>

---
title: Kubernetes @ PostFinance
transition: slide-up
---

# Kubernetes @ PostFinance

<div grid="~ cols-2 gap-4">
<div>

Some figures:

- **1406** namespaces across **30** Kubernetes clusters
- **18'000** pods, **4200** ingresses
- **450 nodes** (24 CPU / 64 GiB RAM)
  - 14 GPU nodes for machine learning workloads
- **4000 RPS** peak load across all ingresses
- **400** card transaction per second

</div>


<div v-click='1'>

Some facts:

- **Vanilla v1.28 Kubernetes**
  - Oldest cluster will soon turn **5 years old**
- **Self-service repository + controller** to manage all namespaces
- **ArgoCD** and GitOps for almost all deployments
- **Chaos Monkey** on all clusters 🐒

</div>
</div>

<br>
<br>

<div v-click='2' class="flex justify-center" >

Most critical workload: **card payment services** 💳 💰

</div>
---
title: Infrastructure Workloads
transition: fade
---

# Infastructure Workloads

A little overview



````md magic-move {lines: true}

```console {*|4,7,9,10,16-18|10}
> kubectl get ns | grep kube-
kube-cert-manager                           Active        17d
kube-chaos-mesh                             Active        154d
kube-contour                                Active        215d
kube-e2e                                    Active        3y224d
kube-gateway-api                            Active        215d
kube-ingress-nginx                          Active        4y343d
kube-k6                                     Active        108d
kube-log                                    Active        215d
kube-metrics                                Active        215d
kube-monkey                                 Active        130d
kube-namespace-creator                      Active        60d
kube-nurse                                  Active        215d
kube-opa-gatekeeper                         Active        215d
kube-otel                                   Active        215d
kube-system                                 Active        4y343d
kube-telemetry                              Active        215d
kube-trident                                Active        4y177d
```

```console
> kubectl get namespace kube-metrics
NAME           STATUS   AGE
kube-metrics   Active   215d

> kubectl --namespace=kube-metrics get deployments.apps
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
kube-state-metrics   1/1     1            1           215d
metrics-server       1/1     1            1           215d

> kubectl --namespace=kube-metrics get daemonsets.apps
NAME            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
node-exporter   103       103       103     103          103         kubernetes.io/os=linux   215d

> kubectl get apiservice v1beta1.metrics.k8s.io
NAME                     SERVICE                       AVAILABLE   AGE
v1beta1.metrics.k8s.io   kube-metrics/metrics-server   True        216d

```
````

---
level: 2
title: Infrastructure Workloads - deployment
transition: slide-up
---

# Infastructure Workloads

How to deploy them on all clusters ?

Up until September 2022: combination of `ansible`, `helm`, and GitLab pipelines &rarr; 🐢

<v-click at='1'>

After September 2022: migration to ArgoCD `ApplicationSets` &rarr; 🐇

<div v-click='1' class="grid grid-cols-3 w-full gap-4" >
<div class="col-span-2" >

<img border="rounded" src="/images/appset-overview.png" alt="" width="95%">

</div>
<div>

<logos-argo-icon size="90%" />

</div>
</div>

</v-click>

---
src: ./slides/argocd.md
---

---
src: ./slides/rud-incident.md
---

---
title: Questions
layout: cover
background: /images/sunrise.jpeg
hideInToc: true
class: my-top
---

# Questions ?
