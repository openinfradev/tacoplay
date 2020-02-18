Tacoplay ansible variables
==========================

이 문서는 tacoplay에 정의된 inventory, tags, roles, vars를 비롯하여 tacoplay에서 include하는 playbook인 kubespray, ceph-ansible의 주요 vars에 대해 다룬다.

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
### global_taco.yml
| 변수                           | default       | 설명
|-------------------------------|---------------|------------
| container_registry_enabled    | false         | container registry 를 설치한다.
| container_registries          | []            |
| local_pip_repo_enabled        | false         |
| local_pkg_repo_enabled        | false         |
| local_k8s_binary_repo_enabled | false         |
| local_ceph_repo_enabled       | false         |
| local_reposerver_port         | 80            |
| pip_repo_url                  | ""            |
| pkg_repo_url                  | ""            |
| k8s_binary_repo_url           | ""            |
| ceph_repo_url                 | ""            |
| taco_storage_backend          | "ceph"        |
| taco_apps                     | ["openstack"] |
| var_assert_enabled            | false         |

NOTE : container_registry_enabled이 true일 경우 registry endpoint는 자동으로 "{{ groups['container-registry'][0] + ':5000' }}" 로 정의된다. 
만약에 이미 구축된 registry를 사용하고 싶다면 아래와 같은 형식으로 container_registries 변수를 정의한다.
```ShellSession
# Eg.)
container_registries:
 - { endpoint: registry.cicd.stg.taco, ip: 192.168.000.000, cert: |
     -----BEGIN CERTIFICATE-----
     MIIB+DCCAZ6gAwIBAgIUA1dN6Z3t/hNh795tcQD94mvgWGIwCgYIKoZIzj0EAwIw
     WjELMAkGA1UEBhMCS1IxDjAMBgNVBAgTBVNlb3VsMRAwDgYDVQQHEwdKdW5nLWd1
     ...
     AwIDSAAwRQIgc8/FlbbRyw22kt1ILAtqhYKdfibC/FjTqT4bQQ+cFb4CIQCpSBxE
     bAIZhGrI5HT/a4dq3GPZWo1ybJs5RliBnPUtRg==
     -----END CERTIFICATE-----
   }
 - { endpoint: 192.168.000.000, ip: null, cert: null }
```

### global_taco-apps.yml
### global_k8s-cluster.yml
### gloabl_k8s-download.yml
### gloabl_k8s-images.yml
### global_ceph.yml

주요 kubespray vars
-------------------

주요 ceph-ansible vars
----------------------
