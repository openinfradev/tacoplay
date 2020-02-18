TACO에서 Ceph 사용을 위한 설정
=============================

tacoplay에서는 아래와 같은 Ceph 구성 및 사용을 지원한다.
* Ceph 클러스터 신규 구축 후 사용: 공식 저장소나 내부 미러링 저장소를 통해 설치
* 별도로 구축된 기존 Ceph 클러스터 사용
* Ceph을 사용하지 않음

이 문서에서는 Ceph 구성과 관련된 부분만을 설명하며 저장소 구축, 연동 부분은 [내부 저장소 구축 및 사용하기](local-package-repo.md) 문서에서 다룬다.

* * *
Ceph 클러스터 신규 구축 및 사용하는 경우
-------------------------
### hosts.ini 설정
Ceph를 설치하고자 하는 호스트를 아래 그룹에 배치한다.
* [mons]: (필수) Monitor 데몬이 실행 (3대 권장)
* [mgrs]: (필수) Manager 데몬이 실행 (mons와 동일하게 구성)
* [osds]: (필수) 실제 데이터가 저장되는 OSD 데몬이 실행
* [mdss]: (옵션) CephFS 메타데이터 데몬이 실행

**(예제)**
```
[mons]
ceph-1
ceph-2
ceph-3

[mgrs]
ceph-1
ceph-2
ceph-3

[osds]
ceph-1
ceph-2
ceph-3
ceph-4
```

### extra-vars.yml 설정
| 설정 값             | 설명                                       | 
|---------------------|--------------------------------------------|
| monitor_interface   | Ceph monitor 주소가 할당된 인터페이스 이름 |
| public_network      | Ceph public network 대역                   |
| cluster_network     | Ceph cluster network 대역                  |
| lvm_volumes         | Ceph에서 사용할 lvm volume 목록            |
| ceph_conf_overrides | Ceph 설정 파일인 ceph.conf에 추가할 내역   |
| openstack_config    | Ceph Pool 및 사용자 생성 여부              |
| openstack_pools     | 생성할 Ceph Pool 내역                      |

**(예제)**
```
monitor_interface: bond0
public_network: 192.168.1.0/24
cluster_network: 192.168.2.0/24
ceph_conf_overrides:
      global:
        mon_allow_pool_delete: true
        osd_pool_default_size: 1
        osd_pool_default_min_size: 1
openstack_config: true
kube_pool:
  name: "kube"
  pg_num: 64
  pgp_num: 64
  type: 1
  erasure_profile: ""
  expected_num_objects: ""
  application: "rbd"
openstack_pools:
  - "{{ kube_pool }}"
```
* * *

기존 Ceph 클러스터 연동하는 경우
------------------
연동하고자 하는 Ceph 클러스터에 필요한 Pool과 사용자를 생성한다.
* Kubernetes Persistent Volume용
* OpenStack Glance용
* OpenStack Cinder용
* OpenStack Nova용

### hosts.ini 설정
Ceph 관련 그룹 정의는 그대로 두되 호스트는 비워둔다.

**(예제)**
```
[mons]
# empty

[mgrs]
# empty

[osds]
# empty
```

### extra-vars.yml 설정
| 설정 값                     | 설명                                                    |
|-----------------------------|---------------------------------------------------------|
| ceph_monitors               | 연동하고자 하는 Ceph 클러스터의 Monitor IP 주소         |
| ceph_admin_keyring          | 위Ceph 클러스터 client.admin의 Keyring                  |
| rbd_provisioner_pool        | K8S Persistent 볼륨용 Pool의 이름                       |
| rbd_provisioner_admin_id    | K8S Persistent 볼륨용 Pool에 접근할 Ceph User ID        |
| rbd_provisioner_secret      | 위 Ceph User의 Keyring |
| rbd_provisioner_user_id     | rbd_provisioner_admin_id와 동일한 값으로 설정|
| rbd_provisioner_user_secret | rbd_provisioner_secret과동일한 값으로 설정|

**(예제)**
```
ceph_monitors: "192.168.1.51,192.168.1.52,192.168.1,53"
ceph_admin_keyring: 'AQD+3INa1wtjEhAAUFQ1xmhsc7PccAx0r+NGPA=='
rbd_provisioner_admin_id: kube
rbd_provisioner_secret: 'AQAPn8tUmPBwCxAAeIfvpDKA1fGvrBeXGdc6xQ=='
rbd_provisioner_user_id: kube
rbd_provisioner_user_secret: 'AQAPn8tUmPBwCxAAeIfvpDKA1fGvrBeXGdc6xQ=='
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
