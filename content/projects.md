---
title: Projects
template: "projects.html"
description: "This is a list of my featured projects which are mostly Open Source."
---
[![My GitHub stats](https://github-readme-stats.vercel.app/api?username=elchead)](https://github.com/elchead)

## Cloud
**Kubernetes** related projects where I extensively worked with **Go** and services from the big cloud providers (Azure, AWS, GCP).


---

### [Constellation](https://github.com/edgelesssys/constellation)
*the secure K8s distribution based on confidental computing*

**Stack:** Terraform, Helm, AWS, Azure GCP

**Contributions:**  lots of smaller ones but noticeable ones include:
- spearheaded a bigger refactoring effort to make the CLI declarative through an apply command to allow reliable cluster upgrades (example for [helm](https://github.com/edgelesssys/constellation/pull/2244))
- integration of the [aws-load-balancer-controller](https://github.com/edgelesssys/constellation/pull/2090) to fix issues with load balancer resource management
- [new API endpoint](https://github.com/edgelesssys/constellation/pull/1808) for managing Azure machine versions

---
### [Gardener](https://github.com/gardener/gardener)
*Kubernetes as a Service platform managed by K8s*

**Stack:** Terraform, Azure

**Contributions:**
- implement an [Azure infrastructure reconciler](https://github.com/gardener/gardener-extension-provider-azure/pull/596) to replace Terraform

---
### Operations for supply-chain optimization
* resource-intense optimizations jobs running on K8s*

**Stack:** Azure, containerd, Redis, influxDB

**Contributions:**
- Master's thesis topic: [Optimizing cluster utilization in Kubernetes](https://blog.adrianstobbe.com/the-potential-of-pod-migrations-in-kubernetes)
	- built a PoC to migrate stateful workloads on Kubernetes and proved feasibility even for containers consuming more than 100 GB of memory
	- developed a [K8s controller](https://github.com/elchead/k8s-migration-controller) to preemptively migrate workloads before exhausting node memory
	- [simulated](https://github.com/elchead/k8s-cluster-simulator) the resource saving potential based on production data showing that cluster resources could be reduced down to 1/4

---
### Observability at [Kyma](https://github.com/kyma-project/kyma)
*K8s project aggregating tools to deploy & manage enterprise applications*

**Stack:** Helm, Prometheus, Graphana, FluentBit

**Contributions:**
- set up Prometheus alerting and Grafana dashboards for SRE team
- build CI/CD pipeline
- observability stack and CLI contributions

---

## Web / Apps
### Security-first app for a human right NGO

**Stack:** Svelte, Typescript, Go, SQLite, Kotlin

**Contributions:**
- frontend for reporting incidents and seeing matches with reports from other organizations
- backend for storing reports and sharing data securely across organizations based on field matches

---
### [Personal search engine](https://github.com/elchead/misou)
a native application built with Go using web technologies. The app that scans through sources from different apps (local file system, browser, Readwise, Instapaper and my personal CRM - people).

**Stack:** Go, React, Typescript

---
### [Personal CRM](https://github.com/elchead/people)
a progressive web app with offline support to add notes about people I care about

**Stack:** React, Typescript


---

### [Meal planner web app](https://github.com/elchead/mealwheel)
team lead at the [Techlabs Web Dev Track ](https://techlabs.org/web/) in Munich to build a meal planner app with recommendations based on ML.

**Stack:** MERN - (MongoDB, Express, React, Node), AWS S3

**Contributions:**
- in charge of backend, deployment and organization


---

## Miscellaneous
- built a [small library in Rust](https://github.com/CAGS295/engine-rs) on the Rusti hackathon based on the actor model for executing various trading strategies on Binance

**Stack:** Rust, Actix

---
-  optimize and parallelize workloads with OpenMP and MPI
	-  my biggest project was building a coupled FEM+SPH simulation for the inhibition inside a 3D laundry machine in coorporation with a big industry partner at [dive](https://www.dive-solutions.de/)

**Stack:** C++, OpenMP

---
- built a PoC for a Function as a Service (FaaS) platform based on Amazon's firecracker

**Stack:** Python, Firecracker, Rust

---
- built a new Python post-processing library interacting with C++ for application engineers to analyze and visualize CFD simulation results

**Stack:** Python,  C++, Paraview

---
