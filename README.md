## Домашнее задание по теме Установка Kubernetes кластера

### Подготовка

1. Написал [сценарий terraform](tf/main.tf) для создания ВМ в Yandex Cloud
2. Применил сценарий создания 1 master и 4 worker nodes

```
$ terraform apply
data.yandex_compute_image.ubuntu: Reading...
data.yandex_compute_image.ubuntu: Read complete after 0s [id=fd8sjgpd03nsicrg3tlt]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.kube-master-01 will be created
  + resource "yandex_compute_instance" "kube-master-01" {
...
Plan: 7 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_vpc_network.kuber: Creating...
yandex_vpc_network.kuber: Creation complete after 2s [id=enpjb0m0d4duqfb3lmok]
yandex_vpc_subnet.kuber: Creating...
...
yandex_compute_instance.kube-worker-02: Creation complete after 50s [id=fhm5vmqhmeuagmqqrqe8]
yandex_compute_instance.kube-worker-04: Creation complete after 53s [id=fhmc0ourvk2o66chpcc5]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.
```

3. Проверил, что на новых узлах отсутствует swap, включил поддержку net.ipv4.ip_forward=1
4. Установил на всех узлах containerd

```
alex@uxtu-note:~/Study/kuber9/tfnodes$ ssh ubuntu@kw3 "sudo apt update; sudo apt install -y containerd"

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Hit:1 http://mirror.yandex.ru/ubuntu focal InRelease
Hit:2 http://mirror.yandex.ru/ubuntu focal-updates InRelease
Hit:3 http://mirror.yandex.ru/ubuntu focal-backports InRelease
Hit:4 http://security.ubuntu.com/ubuntu focal-security InRelease
Reading package lists...
...
Setting up containerd (1.7.24-0ubuntu1~20.04.2) ...
Created symlink /etc/systemd/system/multi-user.target.wants/containerd.service → /lib/systemd/system/containerd.service.
Processing triggers for man-db (2.9.1-1) ...
```

5. Проверил что установлены зависимости и подключил репозитории k8s
6. Установил на все узлы основные компоненты

```
lex@uxtu-note:~/Study/kuber9hw/kuber9$ for i in km1 kw1 kw2 kw3 kw4 ; do ssh ubuntu@$i 'sudo apt-get update; sudo apt update; sudo apt install -y kubelet kubeadm kubectl'; done
Hit:1 http://mirror.yandex.ru/ubuntu focal InRelease
...
Setting up kubeadm (1.33.12-1.1) ...
Setting up kubectl (1.33.12-1.1) ...
Setting up kubernetes-cni (1.6.0-1.1) ...
Setting up kubelet (1.33.12-1.1) ...
```

7. Включил сервис kubelet

```
alex@uxtu-note:~/Study/kuber9hw/kuber9$ for i in km1 kw1 kw2 kw3 kw4 ; do ssh ubuntu@$i 'sudo systemctl enable --now kubelet; sudo systemctl status kubelet'; done
● kubelet.service - kubelet: The Kubernetes Node Agent
     Loaded: loaded (/lib/systemd/system/kubelet.service; enabled; vendor preset: enabled)
    Drop-In: /usr/lib/systemd/system/kubelet.service.d
             └─10-kubeadm.conf
...
```

Однако серив на всех узлах в состоянии Failed, так как не найден конфигурационный файл /var/lib/kubelet/config.yaml
Судя по поиску, файл создастся при инициализации кластера с помощью kubeadm

8. Проинициализировал master ноду кластера

```
ubuntu@kube-master-01:~$ sudo kubeadm init --apiserver-advertise-address=10.0.1.13 --pod-network-cidr=10.244.0.0/16 --apiserver-cert-extra-sans=93.77.185.78
I0520 21:06:56.114962   12395 version.go:261] remote version is much newer: v1.36.1; falling back to: stable-1.33
[init] Using Kubernetes version: v1.33.12
[preflight] Running pre-flight checks
...
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.0.1.13:6443 --token 8vyq1p.x9g6a9qqyvapswql \
	--discovery-token-ca-cert-hash sha256:cf4dde8879297a3e699c7a7734f71081449dd5616bdfa1102603da0b422f2d3f
```

9. Сконфигурировал kubectl как подсказано в выводе kubeadm

```
ubuntu@kube-master-01:~$ mkdir ~/.kube
ubuntu@kube-master-01:~$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
ubuntu@kube-master-01:~$ sudo chown $(id -u):$(id -g) $HOME/.kube/config

```

10. Присоединил к кластеру worker ноды

```
alex@uxtu-note:~/Study/kuber9hw/kuber9$ ssh ubuntu@kw2 'sudo kubeadm join 10.0.1.13:6443 --token 8vyq1p.x9g6a9qqyvapswql --discovery-token-ca-cert-hash sha256:cf4dde8879297a3e699c7a7734f71081449dd5616bdfa1102603da0b422f2d3f'
[preflight] Running pre-flight checks
	[WARNING SystemVerification]: cgroups v1 support is in maintenance mode, please migrate to cgroups v2
[preflight] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[preflight] Use 'kubeadm init phase upload-config --config your-config-file' to re-upload it.
W0520 21:13:39.767119   13421 utils.go:69] The recommended value for "bindAddress" in "KubeProxyConfiguration" is: ::; the provided value is: 0.0.0.0
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-check] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s
[kubelet-check] The kubelet is healthy after 501.998684ms
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

```

11. Проверил состояние узлов с помощью kubectl

```
ubuntu@kube-master-01:~$ kubectl get nodes
NAME             STATUS     ROLES           AGE     VERSION
kube-master-01   NotReady   control-plane   10m     v1.33.12
kube-worker-01   NotReady   <none>          5m49s   v1.33.12
kube-worker-02   NotReady   <none>          3m52s   v1.33.12
kube-worker-03   NotReady   <none>          28s     v1.33.12
kube-worker-04   NotReady   <none>          18s     v1.33.12
```

12. Установил плагин Calico

```
ubuntu@kube-master-01:~$ kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml
poddisruptionbudget.policy/calico-kube-controllers created
serviceaccount/calico-kube-controllers created
serviceaccount/calico-node created
serviceaccount/calico-cni-plugin created
configmap/calico-config created
customresourcedefinition.apiextensions.k8s.io/bgpconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/bgpfilters.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/bgppeers.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/blockaffinities.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/caliconodestatuses.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/clusterinformations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/felixconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworksets.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/hostendpoints.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamblocks.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamconfigs.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamhandles.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ippools.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipreservations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/kubecontrollersconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networksets.crd.projectcalico.org created
clusterrole.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrole.rbac.authorization.k8s.io/calico-node created
clusterrole.rbac.authorization.k8s.io/calico-cni-plugin created
clusterrolebinding.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrolebinding.rbac.authorization.k8s.io/calico-node created
clusterrolebinding.rbac.authorization.k8s.io/calico-cni-plugin created
daemonset.apps/calico-node created
deployment.apps/calico-kube-controllers created

```

13. Через некоторое время все ноды перешли в состояние Ready

```
ubuntu@kube-master-01:~$ kubectl get nodes
NAME             STATUS   ROLES           AGE     VERSION
kube-master-01   Ready    control-plane   16m     v1.33.12
kube-worker-01   Ready    <none>          11m     v1.33.12
kube-worker-02   Ready    <none>          9m39s   v1.33.12
kube-worker-03   Ready    <none>          6m15s   v1.33.12
kube-worker-04   Ready    <none>          6m5s    v1.33.12

```
