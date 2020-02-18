Tacoplay ansible variables
==========================

이 문서는 tacoplay에 정의된 tags, roles, vars를 비롯하여 tacoplay에서 include하는 playbook인 kubespray, ceph-ansible의 주요 vars에 대해 다룬다.

***
Tacoplay ansible tags
---------------------
### site.yml에 정의된 tags
| Tag name           | 설명
|--------------------|-------
| package-repository | pip, yum, apt 등의 패키지 저장소를 비롯해 k8s설치에 필요한 binary 를 담고 있는 저장소를 구축
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

Tacoplay ansible roles
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
| package-repository/conf-repos    | local repository에 접근하기 위한 설정 구성
| package-repository/install       | local repository 구성을 위한 webserver 구성
| prepare-artifact                 | 
| setup-os                         |
| taco-apps/deploy                 |
| taco-apps/lma                    |
| taco-apps/openstack/client       |
| taco-apps/openstack/pre-install  |
| taco-apps/setup-os               |

Tacoplay ansible vars
--------------------

주요 kubespray vars
-------------------

주요 ceph-ansible vars
----------------------
