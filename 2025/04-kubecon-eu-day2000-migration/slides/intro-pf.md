---
title: Kubernetes @ PostFinance
# transition: slide-up
---

# Kubernetes @ PostFinance
Some context

<div grid="~ cols-2 gap-4">
<div>

35 Vanilla v1.31 Kubernetes

Oldest cluster `AGE 5y274d`

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

- **1500** namespaces across **30** Kubernetes clusters
- **18'000** pods, **4200** ingresses
- **450 nodes** (24 CPU / 64 GiB RAM)
  - 14 GPU nodes for machine learning workloads
- **4000 RPS** peak load across all ingresses
- **400** card transaction per second
-->
