---
title: ArgoCD ApplicationSet
hideInToc: true
transition: fade
---
# ArgoCD Application

What is it ?

````md magic-move {lines: true}
```text
> kubectl explain application.spec
GROUP:      argoproj.io
KIND:       Application
VERSION:    v1alpha1

DESCRIPTION:
    ApplicationSpec represents desired application state. Contains link to
    repository with application definition and additional parameters link
    definition revision.

FIELDS:
  destination   <Object> -required-
    Destination is a reference to the target Kubernetes server and namespace

  ignoreDifferences     <[]Object>
    IgnoreDifferences is a list of resources and their fields which should be
    ignored during comparison

  info  <[]Object>
    Info contains a list of information (URLs, email addresses, and plain text)
    that relates to the application

  project       <string> -required-
    Project is a reference to the project this application belongs to. The empty
    string means that application belongs to the 'default' project.

  revisionHistoryLimit  <integer>
    RevisionHistoryLimit limits the number of items kept in the application's
    revision history, which is used for informational purposes as well as for
    rollbacks to previous versions. This should only be changed in exceptional
    circumstances. Setting to zero will store no history. This will reduce
    storage used. Increasing will increase the space used to store the history,
    so we do not recommend increasing it. Default is 10.

  source        <Object>
    Source is a reference to the location of the application's manifests or
    chart

  sources       <[]Object>
    Sources is a reference to the location of the application's manifests or
    chart

  syncPolicy    <Object>
    SyncPolicy controls when and how a sync will be performed
```

```text {7-12}
> kubectl explain application.spec
GROUP:      argoproj.io
KIND:       Application
VERSION:    v1alpha1

FIELDS:
  destination   <Object> -required-
    Destination is a reference to the target Kubernetes server and namespace

  source        <Object>
    Source is a reference to the location of the application's manifests or
    chart

  syncPolicy    <Object>
    SyncPolicy controls when and how a sync will be performed
```

````

---
title: ArgoCD ApplicationsSet
hideInToc: false
transition: fade
---
# ArgoCD ApplicationSet

What is it ?

````md magic-move {lines: true}
```text
> kubectl explain applicationset.spec
GROUP:      argoproj.io
KIND:       ApplicationSet
VERSION:    v1alpha1

FIELDS:
  generators    <[]Object> -required-
    <no description>

  syncPolicy    <Object>
    <no description>

  template      <Object> -required-
    <no description>
```

```text {13-14}
> kubectl explain applicationset.spec
GROUP:      argoproj.io
KIND:       ApplicationSet
VERSION:    v1alpha1

FIELDS:
  generators    <[]Object> -required-
    <no description>

  syncPolicy    <Object>
    <no description>

  template      <Object> -required-
    <no description>
```
````

---
title: ArgoCD ApplicationsSet
hideInToc: true
transition: slide-up
---

# ArgoCD ApplicationSet

<div class="v-full flex justify-center items-center " >

<img src="/images/argocd-appset-example.png" alt="" width="65%">
</div>

---
title: ArgoCD ApplicationsSet
hideInToc: true
transition: fade
---

# ArgoCD ApplicationSet

`metrics-server` example

````md magic-move {lines: true}

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: kube-metrics-metrics-server
spec:
  template:
    metadata:
      name: "{{server}}-metrics-server"
      namespace: kube-metrics
    spec:
      project: kube-metrics-appset
      source:
        repoURL: git@.../kube-metrics/metrics-server.git
        targetRevision: "{{values.revision}}"
        path: .
      syncPolicy:
        automated:
          selfHeal: true
      destination:
        server: "{{server}}"
        namespace: kube-metrics
```

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: kube-metrics-metrics-server
spec:
  generators:
  - clusters:
      selector:
        matchLabels:
          stage: lab
      values:
        revision: HEAD
  - clusters:
      selector:
        matchLabels:
          stage: test
      values:
        revision: v0.1.4
```
````
