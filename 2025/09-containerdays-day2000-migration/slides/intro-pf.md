---
title: Kubernetes @ PostFinance
# transition: slide-up
---

# Kubernetes @ PostFinance
Some context

<div grid="~ cols-2 gap-4">
<div>

- 35 Vanilla v1.32 Kubernetes, 450 nodes

- Oldest cluster: `AGE = 6y70d`

- 2 on-prem datacenters - VSphere Virtualization

- Chaos Monkey on all clusters 🐒

- Namespace self-service thanks to an in-house operator

- ArgoCD and GitOps for almost all deployments

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

- **1500** namespaces across **30** Kubernetes clusters
- **18'000** pods, **4200** ingresses
- **450 nodes** (24 CPU / 64 GiB RAM)
  - 14 GPU nodes for machine learning workloads
- **4000 RPS** peak load across all ingresses
- **400** card transaction per second
-->
