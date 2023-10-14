---
title: Projects
---
[![My GitHub stats](https://github-readme-stats.vercel.app/api?username=elchead)](https://github.com/elchead)

- [ ] TODO: drop Go, Kubernetes in stack everywhere? under Cloud
- [ ] show TOC at the top + headers for each project

## Cloud
**Kubernetes** related projects where I extensively worked with **Go** and cloud services from the big hyperscalers:



---

**Project:** [Constellation](https://github.com/edgelesssys/constellation) - the secure Kubernetes distribution based on cutting edge confidental computing technology

**Stack:** Go, Kubernetes, Terraform, Helm, AWS, Azure GCP

**Contributions:**  lots of smaller ones but noticeable ones include: 
- spearheaded a bigger refactoring effort to make the CLI declarative through an apply command to allow reliable cluster upgrades (example for [helm](https://github.com/edgelesssys/constellation/pull/2244))
- integration of the [aws-load-balancer-controller](https://github.com/edgelesssys/constellation/pull/2090) to fix issues with load balancer resource management
- [new API endpoint](https://github.com/edgelesssys/constellation/pull/1808) for managing Azure machine versions

---
**Project:** [Gardener](https://github.com/gardener/gardener) - Kubernetes as a Service platform managed by Kubernetes

**Stack:** Go, Kubernetes, Terraform, Azure

**Contributions:** 
- implement an [Azure infrastructure reconciler](https://github.com/gardener/gardener-extension-provider-azure/pull/596) to replace Terraform

---
**Project:** SAP operations team for supply-chain optimization - resource-intense optimizations jobs running on Kubernetes

**Stack:** Go, Kubernetes, Azure, containerd, influxDB

**Contributions:**
- Master's thesis topic: [Optimizing cluster utilization in Kubernetes](https://blog.adrianstobbe.com/the-potential-of-pod-migrations-in-kubernetes)
	- built a PoC to migrate stateful workloads on Kubernetes and proved feasibility even for containers consuming more than 100 GB of memory
	- developed a [K8s controller](https://github.com/elchead/k8s-migration-controller) to preemptively migrate workloads before exhausting node memory
	- [simulated](https://github.com/elchead/k8s-cluster-simulator) the resource saving potential based on production data showing that cluster resources could be reduced down to 1/4

---
**Project:** Observability team of [Kyma](https://github.com/kyma-project/kyma) - Kubernetes project aggregating tools to deploy and manage enterprise applications 

**Stack:** Go, Kubernetes, Helm, Prometheus, Graphana, FluentBit

**Contributions:** 
- set up Prometheus alerting and Grafana dashboards for SRE team
- build CI/CD pipeline
- observability stack and CLI contributions

---