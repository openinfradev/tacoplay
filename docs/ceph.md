TACO에서 Ceph 사용을 위한 설정
=============================

tacoplay에서는 rook를 사용해서 Ceph 구축 작업을 수행한다.

모든 워커 노드의 빈 디스크를 Ceph OSD 데몬을 위한 디스크로 사용하며 taco 라는 이름의 Pool을 생성하고 Kubernetes 연동을 위한 스토리지 클래스까지 자동으로 생성한다.

### extra-vars.yml 설정
| 설정 값 | 기본 값 | 설명 |
|---------|---------|------|
| rook_ceph_cluster_mon_replicas | 3 |  Ceph monitor 데몬 개수 |
| rook_ceph_cluster_taco_pool_size | 3 | 기본 생성하는 Pool의 replica 개수 |
| rook_ceph_cluster_host_networking_enabled | "false" | Ceph 데몬 POD 들이 호스트 네트워크 설정 사용 여부 |
| rook_ceph_cluster_ceph_only_nodes_enabled | "false" | Ceph 전용 노드 구성 사용 여부 |
| rook_ceph_cluster_taco_pool_require_safe_size | "true" | 기본 생성하는 Pool의 replica 설정의 사전 안정성 검사 여부 |

Ceph 전용 노드를 사용하여 구축하는 경우
-------------------------
### hosts.ini 설정
Kubernetes 워커 노드 중 일부를 Ceph 서비스 전용으로만 사용하려고 한다면 호스트 정의에 아래 내용을 추가한다.
* 그룹 [ceph]: [kube-node] 워커 노드 중 Ceph 전용 노드로 사용할 노드를 정의
* [ceph] 그룹 vars: 'role":"storage-node"' 노드 레이블 설정
설정된 [ceph] 그룹 노드에 'storage-node=true:NoSchedule' Taint가 자동으로 추가된다.
rook_ceph_cluster_ceph_only_nodes_enabled 변수를 true로 설정한다.

**(예제)**
```
[ceph]
ceph-1
ceph-2
ceph-3

[ceph:vars]
node_labels={"role":"storage-node"}
```

### extra-vars.yml 설정

**(예제)**
```
rook_ceph_cluster_ceph_only_nodes_enabled: "true"
```

* * *

Ceph을 사용하지 않는 경우
----------------
Ceph을 사용하지 않을 경우 Kubernetes, OpenStack의 스토리지 설정은 별도로 이루어져야 한다.
### extra-vars.yml 설정
| 설정 값              | 설명                                                    |
|----------------------|---------------------------------------------------------|
| taco_storage_backend | TACO에서 사용할 Kubernetes, OpenStack의 백엔드 스토리지 |

**(예제)**
```
taco_storage_backend: ""
```
