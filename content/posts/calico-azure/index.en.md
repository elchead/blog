---
title: Calico config for kubeadm cluster on Azure
categories: [Programming]
resources:
  - name: "featured-image"
    src: "cover.jpg"
date: 2022-04-21
---
Recently, I tried to configure calico networking on a self-managed Kubernetes cluster on Azure.
It did not work out of the box and many instructions on the internet did not work for me.
In the following, I want to share my setup.
To set up the network and VMs, I followed [this tutorial](https://blog.nillsf.com/index.php/2021/10/29/setting-up-kubernetes-on-azure-using-kubeadm/). After installing the [default configuration of calico](
https://projectcalico.docs.tigera.io/getting-started/kubernetes/self-managed-onprem/onpremises), inter-node communication between pods did not work.

My working approach uses User-Defined-Routes (UDR) on Azure to route traffic from the different pod-subnets of each node. 
Be sure to only have one IP address assigned to each network interface! I installed the Azure CNI plugin before, which assigns pod IPs from the secondary IPs of the vnet that are assigned to the network interface. This caused problems in the IP detection in Calico, but it can be easily fixed by deleting the secondary IPs.

When bootstrapping Kubernetes, you should also set the pod subnet (CIDR) to avoid address overlap with the virtual network. 
The default for kubeadm is `192.168.0.0/16` which indeed overlapped with my Azure network.

This is my kubeadm config:
```
cat conf.yaml
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v1.19.16 #-beta.0.1017_d0acb1e3ae68d3-dirty
networking:
  podSubnet: "172.16.0.0/16"
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  criSocket: "/run/containerd/containerd.sock"
```

To bootstrap the cluster, execute:
`./kubeadm init --upload-certs  --cri-socket "/run/containerd/containerd.sock" --config conf.yaml`


Then, get the calico setup from [here](
https://projectcalico.docs.tigera.io/getting-started/kubernetes/self-managed-onprem/onpremises).

In the yaml set the pod CIDR:
```
- name: CALICO_IPV4POOL_CIDR
  value: "172.16.0.0/16" 
```

To configure the inter-node pod communication, I followed these steps [here](
https://stackoverflow.com/a/67242381/10531075).

Before applying I recommend to set up VXLAN instead of ipip mode (see below).
By default, calico uses ipip tunneling for pod communication. A tunnel is a virtual network interface to connect subnets. This did not work in my Azure network. 
Instead, I configured VXLAN.
```
cat vxlan.yaml
apiVersion: crd.projectcalico.org/v1
kind: IPPool
metadata:
  name: ippool-vxlan-1
spec:
  cidr: 172.16.0.0/16
  vxlanMode: Always
  natOutgoing: true
```
Traffic to the pod network (outside the node)  should then not be routed to `tunl0`  anymore:
```
ip a
4: tunl0@NONE: <NOARP,UP,LOWER_UP> mtu 1480 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
```

Install `calioctl` and verify that there is only one ippool:
`calicoctl get ippools`

If not, delete the other pool:
`calicoctl delete pool default-ipv4-ippool`

You need to reboot, to force a reassignment of the pod IPs to the new network.

Then doublecheck that the the CIDR did not change:
````yaml
kubectl get ipamblocks.crd.projectcalico.org \
-o jsonpath="{range .items[*]}{'podNetwork: '}{.spec.cidr}{'\t NodeIP: '}{.spec.affinity}{'\n'}"
````

Otherwise, you need to update the Azure routing table!

If you want to dig deeper into the different networking options in calico for Azure, I recommend this video:

<iframe width="560" height="315" src="https://www.youtube.com/embed/JyLtg_SJ1lo" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>