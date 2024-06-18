
---
title: metrics-server
hideInToc: true
---

# Expected state

<div class="grid grid-cols-3 w-full gap-4" >
<div class="col-span-2" >

## `metrics-server`

containing the `v1beta1.metrics.k8s.io` APIService

<img border="rounded" src="/images/metrics-server-workload.png" alt="" width="95%">

</div>
<div>

## `metrics-ns`

containing `kube-metrics` namespace manifest

<img border="rounded" src="/images/metrics-ns-workload.png" alt="">

</div>
</div>

---
title: metrics-server
hideInToc: true
---

# Incident state

<div class="grid grid-cols-3 w-full gap-4" >
<div class="col-span-2" >

## `metrics-server`

<br>

<img border="rounded" src="/images/metrics-server-workload-deleted.png" alt="" >

</div>
<div>

## `metrics-ns`

<br>

<img border="rounded" src="/images/metrics-ns-workload-deleted.png" alt="">

</div>
</div>