---
title: "[Tutorial]: Kubernetes stateful pod migration"
categories: ["Programming"]
date: 2022-04-06
---

This is an extensive tutorial on how to set up a Kubernetes cluster that supports pod migration.

## Why

Statelessness is the basic foundation for microservices run inside Kubernetes. Outside it's main application domain, the platform also appeals to the High Performance Computing (HPC) community for that infrastructure management can be delegated to cloud providers and it's on-demand scaling. The challenge is that HPC jobs are usually long running and stateful. Jobs such as simulations or optimization problems usually keep their state in memory and state checkpointing on disk is not always available.
This is undesirable because failures are expected to occur.
Matters becomes even worse for jobs with unpredictable resource requirements. Unexpected spikes in memory can lead to out-of-memory node situations, which results in pods being killed. The catastrophic consequence is the complete loss of job progress from many hours or even days of compute time.
To avoid this, a migration of stateful pods to another node would be desirable.

## Status quo

Currently, Kubernetes does not support pod migration.
However, a PoC of a pod migration n prior work by [Jakob Schrettenbrunner](https://www.researchgate.net/publication/349662156_Migrating_Pods_in_Kubernetes) showed the feasibility. A [proposal](https://github.com/kubernetes/enhancements/pull/1990) to support very basic checkpointing (forensic checkpoiting without restore) functionality has recently been accepted by the Kubernetes community as well and is expected to be available in future releases.

## Goal

Building on the prior PoC of Jakob Schrettenbrunner, I want to show you step by step how to set up a Kubernetes cluster with pod migration functionality. Bootstrapping a Kubernetes cluster from scratch is not a trivial task, but `kubeadm` will help us. Jakob also provided some [documentation](https://docs.google.com/document/d/1E5p_FOHDGAp5YEQ23dCi9I8wPnMzd4aOazxI4uO_AMo/edit#) on his setup and while very helpful it is far from complete and does not mention all potential gotchas. You might suspect already that this won't be a quick and easy process, but I hope to make it a lot easier for you through this extensive tutorial.

## Demo

To see what to expect, here is a quick demo of the steps to migrate a pod:

<iframe width="560" height="315" src="https://www.youtube.com/embed/IPY852th_T0" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## 1. Cluster setup

The cluster consists of 1 master node and 2 worker nodes. The VMs are provisioned in Microsoft Azure. For migrating the pod across a worker node, [Azure's SMB file share server](https://docs.microsoft.com/en-us/azure/storage/files/files-smb-protocol?tabs=azure-portal)) is used. You might also use an NFS server (and it might even make things easier as mentioned later..), but this was not possible for company policy reasons in my case.

Kubernetes is bootstrapped using `kubeadm`. It's tested with version `v1.19.0-beta.0.1015+b521fb5114995f-dirty` ( binaries are available [here](https://github.com/elchead/kubernetes/releases/tag/v8.1.0), but I recommend building from source).

### Network setup

To set up the cluster network, I followed [this tutorial](https://blog.nillsf.com/index.php/2021/10/29/setting-up-kubernetes-on-azure-using-kubeadm/). You can use the web shell on Azure for this:

```bash
az group create -n kubeadm -l westus2

az network vnet create \
    --resource-group kubeadm \
    --name kubeadm \
    --address-prefix 192.168.0.0/16 \
    --subnet-name kube \
    --subnet-prefix 192.168.0.0/16

az network nsg create \
    --resource-group kubeadm \
    --name kubeadm

az network nsg rule create \
    --resource-group kubeadm \
    --nsg-name kubeadm \
    --name kubeadmssh \
    --protocol tcp \
    --priority 1000 \
    --destination-port-range 22 \
    --access allow

az network nsg rule create \
    --resource-group kubeadm \
    --nsg-name kubeadm \
    --name kubeadmWeb \
    --protocol tcp \
    --priority 1001 \
    --destination-port-range 6443 \
    --access allow

az network vnet subnet update \
    -g kubeadm \
    -n kube \
    --vnet-name kubeadm \
    --network-security-group kubeadm
# load balancer:
az network public-ip create \
    --resource-group kubeadm \
    --name controlplaneip \
    --sku Standard \
    --dns-name nilfrankubeadm

 az network lb create \
    --resource-group kubeadm \
    --name kubemaster \
    --sku Standard \
    --public-ip-address controlplaneip \
    --frontend-ip-name controlplaneip \
    --backend-pool-name masternodes

az network lb probe create \
    --resource-group kubeadm \
    --lb-name kubemaster \
    --name kubemasterweb \
    --protocol tcp \
    --port 6443

az network lb rule create \
    --resource-group kubeadm \
    --lb-name kubemaster \
    --name kubemaster \
    --protocol tcp \
    --frontend-port 6443 \
    --backend-port 6443 \
    --frontend-ip-name controlplaneip \
    --backend-pool-name masternodes \
    --probe-name kubemasterweb \
    --disable-outbound-snat true \
    --idle-timeout 15 \
    --enable-tcp-reset true

az network nic ip-config address-pool add \
    --address-pool masternodes \
    --ip-config-name ipconfigkube-master-1 \
    --nic-name kube-master-1VMNic \
    --resource-group kubeadm \
    --lb-name kubemaster

az network nic ip-config address-pool add \
    --address-pool masternodes \
    --ip-config-name ipconfigkube-master-2 \
    --nic-name kube-master-2VMNic \
    --resource-group kubeadm \
    --lb-name kubemaster
```

### VM provisioning

**Master**

The specs of my master node VM are as follows on Ubuntu 21.04 (20.04 LTS could also be used):

```json
{
  "name": "kube-master-3",

  "location": "westeurope",

  "name": "ubuntu-21-04-lts",

  "publisher": "tidalmediainc",

  "product": "ubuntu-21-04-lts",

  "vmSize": "Standard_D2ds_v4"
}
```

**Worker**

Both worker VMs share the same specs:

```json
{

"name": "zone2/zone3",

"location": "westeurope",

"vmSize": "Standard_E16-4ds_v4",


"imageReference": {

"publisher": "canonical",

"offer": "0001-com-ubuntu-server-focal",

"sku": "20_04-lts-gen2",

"version": "latest"

}
```

After connecting to the VM, go into root mode:
`sudo -s`
All following steps assume this!

## 2. Kernel downgrade

### Worker

As mentioned [here](https://github.com/checkpoint-restore/criu/issues/860), recent Ubuntu kernels broke compatibility with CRIU.
Hence we downgrade the kernel:
`apt install -y linux-image-unsigned-5.4.0-1068-azure`

Follow [these steps](https://meetrix.io/blog/aws/changing-default-ubuntu-kernel.html) to change the boot kernel.

## 3. Install Prequisites

### Master node

#### Containerd + Kubelet

On the master node, you can install the official releases:

```bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt update

apt install -y containerd kubelet
```

But for safety, you should replace the `kubelet` with the binary path defined in the systemd service (`/usr/bin/kubelet`).
You can get the customized kubelet like this:

```bash
wget https://github.com/elchead/kubernetes/releases/download/v8.1.0/kubelet
chmod +x ./kubelet
cp ./kubelet /usr/bin
```

#### Kubeadm

To get the `kubeadm` version compatible with our modified kubernetes. Inside your home directory, do:

```bash
wget https://github.com/elchead/kubernetes/releases/download/v8.1.0/kubeadm
chmod +x ./kubeadm
```

#### Kubectl

Install as described [here](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

### Worker node

I recommend to perform the following steps in parallel on both worker VMs. You might use [tmux](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/01-prerequisites.md#running-commands-in-parallel-with-tmux) or iTerm on Mac ( `Cmd+Shift+i`).

#### CRIU

As described [here](https://software.opensuse.org/download/package?package=criu&project=devel%3Atools%3Acriu):

```bash
echo 'deb http://download.opensuse.org/repositories/devel:/tools:/criu/xUbuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/devel:tools:criu.list
curl -fsSL https://download.opensuse.org/repositories/devel:tools:criu/xUbuntu_20.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/devel_tools_criu.gpg > /dev/null
sudo apt update
sudo apt install -y criu
```

Verify the version to be 3.16.1:
`criu --version`

#### Golang

Follow [here](https://go.dev/doc/install). I installed v1.17.8:

```bash
wget https://go.dev/dl/go1.17.8.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.17.8.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
```

#### Containerd

##### Install dependencies

```
apt install btrfs-progs libbtrfs-dev runc
```

##### Systemd service

I took the dirty path and used `apt` to install an official release :

```
apt update
apt install containerd
```

Then, I later replaced the binary defined in the systemd config with my fork binary.
The file looks like this:

```bash
cat /lib/systemd/system/containerd.service

# Copyright The containerd Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
```

##### Build

I recommend to build from source, but you may also use the binaries inside `bin`.

Clone my fork and checkout the `checkpoint` branch. If you want to use the version that only uploads a zip to the file server (please read under [6. Set up file server](#6. Set up file server), use `checkpoint-zip`

```bash
mkdir -p /root/go/src/github.com/containerd && cd /root/go/src/github.com/containerd
git clone https://github.com/elchead/containerd.git
cd containerd
git checkout checkpoint
```

Build from source:
`make && make install`

#### Update systemd svc to custom binary

Stop the service:
`systemctl stop containerd

Inside root of the repository, do:

```bash
cp ./bin/containerd /usr/bin/containerd
systemctl start containerd
```

#### Configure CNI plugins

```bash
export GOPATH=/root/go
./script/setup/install-cni
```

In the output the CNI version is set to 1.0.0 which is wrong. So we change it to a supported version such as 0.3.0 :
`vim /etc/cni/net.d/10-containerd-net.conflist`

To be safe, restart the containerd service after after configuring the CNI plugins:
`systemctl restart containerd

#### Kubelet

```bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

sudo apt -y install kubelet

Then replace the binary:
```

```bash
wget https://github.com/elchead/kubernetes/releases/download/v8.1.0/kubelet
chmod +x ./kubelet
cp ./kubelet /usr/bin
```

Modify the systemd service:

```bash
vim /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS --container-runtime-endpoint=/run/containerd/containerd.sock --v=9 --read-only-port=0 --anonymous-auth=true --authorization-mode=AlwaysAllow --container-runtime=remote
~
```

The kubelet config should look like this:

```yaml
cat /var/lib/kubelet/config.yaml
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 0s
    cacheUnauthorizedTTL: 0s
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local
cpuManagerReconcilePeriod: 0s
evictionPressureTransitionPeriod: 0s
fileCheckFrequency: 0s
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 0s
imageMinimumGCAge: 0s
kind: KubeletConfiguration
nodeStatusReportFrequency: 0s
nodeStatusUpdateFrequency: 0s
resolvConf: /run/systemd/resolve/resolv.conf
rotateCertificates: true
runtimeRequestTimeout: 50m0s
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 0s
syncFrequency: 0s
volumeStatsAggPeriod: 0s
```

It's important to set the `runtimeRequestTimeout` to a higher value (default is 2 minutes), if you intend to migrate big containers (~50GB+)!

#### Kubeadm

Install as above for the master node:

```
wget https://github.com/elchead/kubernetes/releases/download/v8.1.0/kubeadm
chmod +x ./kubeadm
```

## 4. Kubernetes bootstrapping

### Networking

First, we set up the networking and containerd.
I followed [this tutorial](https://blog.nillsf.com/index.php/2021/10/29/setting-up-kubernetes-on-azure-using-kubeadm/), but it might not be necessary:

```bash
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

sudo systemctl restart containerd

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

### Kubeadm init

On the master node, create a config file in your home directory:

```bash
vim conf.yaml
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
imageRepository: sadrian99
kind: ClusterConfiguration
kubernetesVersion: v1.19.16
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  criSocket: "/run/containerd/containerd.sock"
```

Through this, the registry with the customized Kubernetes components will be used.

Then, start the cluster with:
`./kubeadm init --upload-certs --cri-socket "/run/containerd/containerd.sock" --config conf.yaml`

Note: Ideally, the cluster is exposed with a DNS endpoint, but this did not work for me!

As the output indicates, perform:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Then, copy the output to join the cluster on a worker node. It looks like this:

```bash
kubeadm join 192.168.0.7:6443 --token 90djfo.2386gkxicg6y2ywo \
    --discovery-token-ca-cert-hash sha256:0834d5d47c16799e2b1b4df3431923570549fe903f9339f875dd1f2f9d2dd2ef
```

Finally, set up CNI:

```bash
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=1.19"
```

### Verify cluster state

`kubectl get node -w`
Should show a ready node after a few seconds.

`kubectl get po -A`
Should show all pods running (including coredns!).

### (Debugging)

If the node does not get ready, check the logs of the kubelet:

```
journalctl -u kubelet [-f]
```

Or if you don't find any hints from there, look here:

```
journalctl -u  containerd [-f]
```

It happened to me, that I got the error `cni plugin not initialized`.
If this is the case, be sure to repeat step the CNI plugin installation from above again.

If a pod is not running, use `kubectl describe` to debug.

Otherwise, a cluster reset might also help:
`./kubeadm reset --cri-socket "/run/containerd/containerd.sock"`

### Join worker

Install crictl as prequisite:

```
VERSION="v1.23.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

```

On the worker node, run the previously copied join command.
You might need to add `--cri-socket "/run/containerd/containerd.sock"`:

```
./kubeadm join 192.168.0.7:6443 --token 90djfo.2386gkxicg6y2ywo     --discovery-token-ca-cert-hash sha256:0834d5d47c16799e2b1b4df3431923570549fe903f9339f875dd1f2f9d2dd2ef --cri-socket "/run/containerd/containerd.sock"
```

To verify, go back to the master node and check that the new node appears ready.

### Copy kubeconfig

Now, copy the kubeconfig from the master node (`$HOME/.kube/config`) to the worker node inside `config` and export it:
`export KUBECONFIG=$HOME/config`

The migration PoC needs the kubeconfig inside a special directory:

```
mkdir -p /var/lib/kubelet
cp $HOME/config /var/lib/kubelet/kubeconfig
```

## 5. Demo (test migration)

### Deploy stateful pod

Now it's time to test the migration, with a simple memory allocating pod (here 50 MB):
`kubectl run counter1 --restart=Never --image "ghcr.io/schrej/podmigration-testapp:latest" -- -m 50`. It's important to set `restartPolicy:Never` to prevent the original container from restarting during migration (relevant for large migrations)!

Through `kubectl get po -owide`, you can get pod IP and increment a stateful counter.
Be sure to do this on the worker node:
`curl $POD_IP:8080`
Repeat the counter increment a few times, to validate the successful migration later.

### Clone pod

The pod spec is identical, except that it has an additional field `spec.clonePod` :

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: counter1
  name: mcounter1
spec:
  clonePod: counter1
  containers:
    - args:
        - -m
        - "50"
      image: ghcr.io/schrej/podmigration-testapp:latest
      name: counter1
      resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

The migration should be very fast.
Currently, the old pod gets broken during the migration. But the cloned pod should be running.
Requesting it's endpoint with `curl` should return a number bigger than 1. Voila - you have successfully cloned a stateful pod in Kubernetes!

## 6. Set up file server

### Important warning

I had consistency problems for bigger file uploads with SMB. The container restore command is issued 1 second after the disk checkpoint has been saved completely.
However, at this time not all files of the checkpoint directory were uploaded successfully.

I circumvented this problem by storing the checkpoint on local disk and only storing a zipped archive on the server.
The temporary local-disk location is `/var/lib/kubelet/check`. Since, the OS disk is usually only 30GB, you will need to create a symbolic link to a bigger disk. In my case, a temporary disk with 500GB was mounted in `/mnt`.
To solve this, do:

```
rm -r /var/lib/kubelet/check/
ln -s /mnt /var/lib/kubelet/check
```

Interestingly, the compression immensly reduced the checkpoint size for the simple example app. For 50GB of allocated memory, the compressed zip was only around 20MB!
This modification was done inside containerd in the branch `checkpoint-zip`.

### Steps

The procedure is specific to Azure and is well documented [here](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux?tabs=smb311). The server should be mounted inside `/var/libe/kubelet/migration`. I used the static mount and my /etc/fstab entry looks like this:

```
//SERVER_URL/checkpoints /var/lib/kubelet/migration cifs nofail,credentials=/etc/smbcredentials/STORAGECLASSNAME.cred,serverino,cache=none
```

## Development

If you want to develop further or quickly test changes, it is much easier to work with a local cluster.
Inside the kubernetes repo root, run:

```
CONTAINER_RUNTIME=remote CONTAINER_RUNTIME_ENDPOINT="unix:///run/containerd/containerd.sock" CGROUP_DRIVER="systemd" KUBELET_AUTHORIZATION_WEBHOOK="false" KUBELET_FLAGS="--read-only-port=0 --anonymous-auth=true --authorization-mode=AlwaysAllow" ./hack/local-up-cluster.sh
```

To read the logs for the kubelet, you can use: `tail -f /tmp/kubelet.log`.

## End

I admit that this was a long tutorial and it's likely not everything went smooth while following along. If you are stuck at some step, you can contact me and I can try to help :)
