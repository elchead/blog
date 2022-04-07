---
title: Bootsrapping your custom Kubernetes with kubeadm
categories: [Programming]
date: 2022-04-07
---
In this tutorial, I want to show you how to bootstrap a Kubernetes cluster with `kubeadm` using your customized Kubernetes fork. This might be useful if you want to use new features that are not yet merged in the upstream. For development, it's of course much easier to set up a local cluster (`./hack/local-up-cluster.sh`), but to test functionality across different nodes, you might need a distributed cluster.

One option is to install it [The hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way), but I think it's more convenient to use `kubeadm`.
The challenge is that you need container images for the kube control-plane components.

I found it difficult to find good documentation on this process, so I hope to help you along with this.

## Requirements
By default Kubeadm pulls the Kubernetes version matching the version of kubeadm from the official registry. But it also allows to specify a custom registry.
To install our custom Kubernetes, we will need to build and pull the required container images, tag them with the expected version of kubeadm, and the push them to our registry.

## Build images
I built the images on a Ubuntu machine, since the build is resource intensive. 
Kubernetes is big, so be sure to have enough space on the VM! The build happens inside a docker container, so make sure to have docker installed. VMs usually only have a small disk image, so I created a symbolic link to save the docker files on another attached drive (here mounted on `/mnt`):

```
sudo -s
systemctl stop docker
rm -rf /var/lib/docker 
mkdir -p /mnt/docker
ln -s /mnt/docker /var/lib/docker
systemctl restart docker
```

Then, inside the kubernetes root path, specify your docker registry and run:
`KUBE_SERVER_PLATTFORMS="linux/amd64" KUBE_DOCKER_REGISTRY="sadrian99" KUBE_RELEASE_RUN_TESTS=n ./build/release-images.sh`
I recommend to set a flag for the image version such that the version coincides with what kubeadm expects (version of kubeadm).
In my case, this was `v1.19.16`. 

## Tag images and push to registry
The generated image names have a trailing `amd64` which needs to be removed for `kubeadm`:
`IMGN`: new name for kubadm
`IMG`: old image name
`VER`: old version tag
`VERN`: new version tag
`REPO`: your container registry url
In my case, `REPO=sadrian99`  and `VERN=v.19.16`. Then we tag the image with the new name:

```
export IMG=kube-apiserver-amd64; export IMGN=kube-apiserver
docker tag $REPO/$IMG:$VER sadrian99/$IMGN:$VERN && docker push $REPO/$IMGN:$VERN```
```

You need to do this for these images:
- kube-apiserver:v1.19.16
- kube-controller-manager:v1.19.16
- kube-scheduler:v1.19.16
- kube-proxy:v1.19.16

Additionally you need to pull these images and copy them to your registry:
- pause:3.2
- etcd:3.4.7-0
- coredns:1.6.7

```
export D=coredns:1.6.7
docker pull k8s.gcr.io/$D && docker tag k8s.gcr.io/$D $REPO/$D && docker push $REPO/$D
```

## Kubeadm bootstrap
You can test if the images are all available:
`kubeadm config images pull --image-repository sadrian99 `

Then you can add `--image-repository sadrian99`  to the `init` command to bootstrap your cluster. 

Congrats, you should now have a cluster with your own Kubernetes version! I used this to [migrate pods](/posts/pod-migration) across nodes. Let me know what your use case is!