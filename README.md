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
