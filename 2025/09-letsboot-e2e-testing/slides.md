---
theme: ./theme
themeConfig:
  primary: "#E85C0D"
# color palette: #FABC3F #E85C0D #C7253E #821131
title: "E2E Testing on Kubernetes Clusters"
author: Clément Nussbaumer
info: |-
  Introduction to End-to-End Testing on Kubernetes Clusters.

  This presentation covers practical approaches to testing Kubernetes
  deployments using the e2e-framework library in Go, with real-world
  examples including deployments, persistent volumes, networking tests.

  Learn how to build comprehensive test suites that validate your
  Kubernetes infrastructure and capture results with OpenTelemetry.

class: text-center
highlighter: shiki
mdc: true
hideInToc: true
layout: two-cols-header
layoutClass: cover text-right orange-yellow-grad
exportFilename: letsboot-e2e-testing-kubernetes
---

# E2E Testing on Kubernetes Clusters
## Practical Testing with Go & OpenTelemetry

**Clément Nussbaumer**

<a href="https://www.letsboot.ch/" target="_blank" alt="letsboot" style="font-size: 1.2rem;" class="absolute left-4rem top-25rem m-6 text-xl orange-accent">letsboot.ch</a>

<a href="https://clement.n8r.ch/en/articles/" style="font-size: 1.5rem;" target="_blank" alt="Blog" class="absolute right-8rem top-25rem m-6 text-xl">clement.n8r.ch</a>

<img src="./images/Jura.png" width="23rem" class="absolute right-6rem top-25rem m-6 text-xl" alt="Jura flag">

<a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" alt="Blog"
  class="absolute right-4rem top-25rem m-6  text-xl icon-btn opacity-100 !border-none "><carbon-logo-linkedin />
</a>

<a href="https://github.com/clementnuss" target="_blank" alt="GitHub"
  class="absolute right-2rem top-25rem m-6 text-xl icon-btn opacity-100 !border-none"><carbon-logo-github />
</a>

<!--
Welcome to this introduction on E2E testing for Kubernetes clusters
-->

---

# Why E2E Testing on Kubernetes?

- **Infrastructure as Code** needs testing too
- **Complex interactions** between components
- **Networking, storage, security** validations
- **Real environment** behavior vs unit tests
- **Confidence** in deployments

<div v-click class="absolute top-15rem right-6rem bg-white bg-opacity-10 backdrop-filter backdrop-blur-md rounded-lg p-5 border border-white border-opacity-20 max-w-80">
<p class="text-sm text-gray-200 font-medium">
💡 <strong>Pro tip:</strong> Your end users should NOT be your end-to-end tests!
<br><br>
You want to know something is broken <em>before</em> they start calling you at 3am 😴
</p>
</div>

<!--
E2E testing ensures your Kubernetes infrastructure works as expected in real scenarios
-->

---
layout: image-right
image: ./images/e2e-framework.png
---

# The e2e-framework Approach

- Built by **kubernetes-sigs** community
- **Go-based** test framework
- **Native Kubernetes** integration
- **Flexible** test scenarios
- **Resource lifecycle** management

```go
func TestKubernetes(t *testing.T) {
    // Create deployment
    // Validate it's running
    // Clean up
}
```

⬇️


```bash
go test ./tests/ -v
```

<!--
The e2e-framework makes it easy to write comprehensive Kubernetes tests
-->

---

# Test Scenarios We'll Cover

- 🚀 **Basic Deployments** - Pod creation & readiness
- 💾 **Persistent Volumes** - Storage functionality
- 🌐 **Networking & CNI** - Service connectivity
- 🔒 **Security Policies** - RBAC validation
- 📊 **Observability** - Metrics & logging integration

<!--
These are common scenarios you'll want to test in any Kubernetes environment
-->

---

# OpenTelemetry Integration

- **Test results** pushed to OTEL collector
- **Dashboard visualization** of test outcomes
- **Historical tracking** of cluster health
- **Metrics correlation** with deployments

```go
// Initialize metrics collector
collector := metrics.NewCollector()

func TestKubernetesDeployment(t *testing.T) {
    start := time.Now()

  // register cleanup function to record test results
    t.Cleanup(func() {
      metricsCollector.RecordTestExecution(t, time.Since(start))
    })

    // ... test logic here ...
}
```

<!--
Observability of your tests is as important as the tests themselves
-->

---

# Live Demo

## 

https://github.com/clementnuss/e2e-tests

- **Real test examples** for Kubernetes
- **Go test framework** in action
- **OpenTelemetry integration**
- **Dashboard results** visualization

<!--
Time to see the actual implementation and test results
-->

---

# Thank You!

## Questions & Discussion

<div class="flex justify-center items-center h-32">
  <div class="text-4xl">
    🚀 Let's test our clusters! 🚀
  </div>
</div>

**Links:**
- 📦 Project: https://github.com/clementnuss/e2e-tests
- 📚 Framework: https://github.com/kubernetes-sigs/e2e-framework

<!--
Thank you for joining this introduction to Kubernetes E2E testing
-->
