Tacoplay ansible variables
==========================

이 문서는 tacoplay에 정의된 inventory, tags, roles, vars를 비롯하여 tacoplay에서 include하는 playbook인 kubespray의 주요 vars에 대해 다룬다.

***

Inventory
---------------------
tacoplay는 아래와 같은 inventory로 node를 group으로 구성한다.
* [kube-master]: kubernetes master node들의 목록
* [etcd]: etcd cluster를 구성할 node들의 목록
* [kube-node]: kubernetes worker node들의 목록
* [k8s-cluster:children]: kubernetes cluster 목록의 묶음
* [mon]: [TACO에서 Ceph 사용을 위한 설정](ceph.md) 문서 참조
* [mgrs]: [TACO에서 Ceph 사용을 위한 설정](ceph.md) 문서 참조
* [osds]: [TACO에서 Ceph 사용을 위한 설정](ceph.md) 문서 참조
* [mdss]: [TACO에서 Ceph 사용을 위한 설정](ceph.md) 문서 참조
* [clients:children]: ceph client가 설치될 node들의 목록 묶음
* [controller-node]: openstack 설치 시 controller node들의 목록
* [compute-node]: openstack 설치 시 compute node들의 목록
* [container-registry] : container registry를 설치할 node
* [package-repository] : package repository를 설치할 node
* [admin-node]: ansible-play를 실행할 node
* [taco:children]: taco를 구성하는 모든 node들의 목록

Tags
---------------------
### site.yml에 정의된 tags
| Tag name           | 설명
|--------------------|-------
| package-repository | pip, yum, apt 등의 패키지 저장소를 비롯해 k8s설치에 필요한 binary를 담고 있는 저장소를 구축
| setup-os           | taco가 설치되는 모든 노드의 host os에 필요한 설정 작업
| container-registry | docker container의 registry를 구축
| ceph               | ceph-ansible을 이용해서 ceph 설치
| ceph-post-install  | ceph 설치 이후 필요한 추가 작업
| k8s                | kubespray를 이용해서 kubernetes 설치
| taco-clients       | admin-node에 각종 client 설치
| openstack          | 구축된 kubernetes위에 openstack 배포를 위한 준비
| lma                | 구축된 kubernetes위에 lma tools 배포를 위한 준비
| deploy             | armada를 이용해서 위 openstack, lma을 kubernetes에 배포
| openstack-client   | openstack client 설치

Roles
----------------------
| role name                        | 설명
|----------------------------------|-------------
| ceph/post-install                | ceph 설치 이후 mon host 정보, admin keyring 정보등을 조회해서 변수 설정
| ceph/setup-repo                  | local ceph repository 구성
| container-registry/client        | container registry에 node들이 접근할 수 있도록 설정
| contanier-registry/server        | local container registry 구성
| docker                           | docker daemon이 필요한 node에 docker 설치
| ironic                           | ironic (standalone mode) 설치
| jenkins                          | kubernetes위에 jenkins ci 환경 구성
| k8s/helm                         | node에 helm client 설치
| k8s/kubectl                      | node에 kubectl 설치
| k8s/tiller                       | tiller의 nodeport open
| package-repository/conf-repos    | local repository에 접근하기 위한 설정
| package-repository/install       | local repository 구성을 위한 webserver 설치 및 설정
| prepare-artifact                 | offline 환경에 구축하기 위해 필요한 charts, docker images, binary등 포함한 tarball 제작
| setup-os                         | taco 설치를 위한 os 환경 설정
| taco-apps/deploy                 | kubernetes 위에 lma, openstack 등을 armada를 이용해서 배포
| taco-apps/lma                    | lma 배포를 위한 준비
| taco-apps/openstack/client       | openstack client container 배포
| taco-apps/openstack/pre-install  | openstack을 설치하기 위한 사전 작업
| taco-apps/setup-os               | openstack을 설치하기 위한 os 환경 설정

Grobal Vars
--------------------
아래는 주요 global 변수에 대해 설명한다.

### global_taco.yml
| 변수                           | default       | 설명
|-------------------------------|---------------|------------
| container_registry_enabled    | false         | container_registry로 정의된 node에 registry 설치
| container_registries          | []            | 이미 구축된 registry 정보 등록
| pip_repo_url                  | ""            | 연동할 pip repo 주소
| pkg_repo_url                  | ""            | 연동할 pkg repo 주소
| k8s_binary_repo_url           | ""            | 연동할 k8s binary repo 주소
| ceph_repo_url                 | ""            | 연동할 ceph repo 주소
| taco_storage_backend          | "ceph"        | taco의 기본 backand storage
| taco_apps                     | ["openstack"] | taco를 통해서 배포할 app의 목록 정의 (openstack, lma)
| var_assert_enabled            | false         | site별 반드시 정의할 변수 선언 및 validate 기능 설정

NOTE : container_registry_enabled이 true일 경우 registry endpoint는 자동으로 "{{ groups['container-registry'][0] + ':5000' }}" 로 정의된다. 
자세한 내용은 [컨테이너 레지스트리 구축 및 사용하기](container-registry.md) 문서 참조

### global_taco-apps.yml
| 변수                       | default  | 설명
|---------------------------|----------|------------
| vfat_config_drive_enabled | false    | host에 vfat, loop등의 module 설치
| pci_passthrough_enabled   | false    | host에 vfio-pci 등의 module 설치
| ovs_package_installed     | false    | host에 openvswitch를 package로 설치
| db_root_user              | root     | db의 root user name
| db_*_password             | password | 각 user의 db password
| os_root_user              | admin    | openstack root user name
| os_*_password             | password | openstack 각 user의 password
| mq_root_user              | rabbitmq | mq의 root user name
| mq_*_password             | password | 각 mq user의 password

### global_k8s-cluster.yml
global_k8s-cluster.yml에 정의된 변수들은 kubespray에 선언된 변수 중 tacoplay에서 기본적으로 값을 바꿔서 사용하는 변수들이다.
즉, 여기서 선언되지 않은 값들은 kubespray에 선언된 기본값이 사용된다.

| 변수                      | default               | 설명
|--------------------------|-----------------------|------------
| preinstall_selinux_state | disabled              | host의 selinux를 disable
| etcd_memory_limit        | 8192M                 | etcd가 사용하는 memory limit 변경
| kubectl_localhost        | true                  | kubectl을 ansible 실행하는 node로 복사
| kubeconfig_localhost     | true                  | kubeconfig를 ansible 실행하는 node로 복사
| kubelet_custom_flags     | ["--registry-qps=30"] | registry에 요청하는 queries for second 값을 5에서 30으로 변경 ( 동시 container image download 숫자 증가 )
| helm_enabled             | true                  | kubespray를 이용해서 helm 배포
| rbd_provisioner_*        |                       | taco_storage_backend가 ceph일 경우를 위한 기본값들


### gloabl_k8s-download.yml
k8s_binary_repo_url이 설정되었을 경우 override하는 k8s binary repo 주소

### gloabl_k8s-images.yml
container_registry_enabled가 true일 경우 override하는 k8s image repo 주소

### global_ceph.yml
ceph_ansible을 이용해서 ceph을 구축할 경우 ceph_ansible에 정의된 기본값들을 override한다.
자세한 내용은 [TACO에서 Ceph 사용을 위한 설정](ceph.md) 문서 참조

주요 kubespray vars
-------------------
아래 변수 목록은 kubespray에 선언된 중요한 변수들로, 환경에 따라서 extra_vars에 선언해서 변경이 필요할 수 있다.

| 변수                    | default        | 설명
|------------------------|----------------|------------
| kube_pods_subnet       | 10.233.64.0/18 | kubernetes에 배포되는 app pod들이 사용하는 대역
| kube_service_addresses | 10.233.0.0/18  | kubernetes service pod이 사용하는 대역
| ipip_mode              | Never          | subnet간 ip in ip encapsulation
| peer_with_router       | false          | enable the peering with the datacenter's border router
