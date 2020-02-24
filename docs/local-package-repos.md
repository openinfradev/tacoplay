내부 저장소 구축 및 사용하기
============================

tacoplay에서 필요한 패키지, 바이너리 저장소는 다음과 같다.
* OS 배포본 저장소: [CentOS](http://mirror.centos.org/centos/)/[EPEL](https://download.fedoraproject.org/pub/epel/) YUM, [Ubuntu](http://archive.ubuntu.com/ubuntu/) APT
* [Python PIP](https://pypi.org) 패키지 저장소
* kubeadm, etcd, calicoctl 등 Kubernetes 설치, 실행에 필요한 바이너리
* Ceph 패키지 저장소: CentOS YUM, Ubuntu APT (http://download.ceph.com)

또한 각각의 저장소가 사용되는 방법은 아래의 3가지 경우로 나누어진다.
1. 공식 저장소 사용
2. 별도 구축된 내부 미러링 저장소 사용

이 문서에서는 저장소 구축에 관해서만 다루며 미러링 방법 자체는 아래 링크 등을 참고하기 바람.
 * https://wiki.centos.org/HowTos/CreateLocalMirror
 * https://www.tecmint.com/setup-local-repositories-in-ubuntu/
 * https://github.com/ceph/ceph/tree/master/mirroring

***

공식 저장소 사용하기
--------------------

tacoplay 기본 설정이 공식 저장소를 사용하는 것이므로 추가 작업은 필요하지 않다.

***

내부 미러링 저장소 사용하기
----------------------------

### 내부 저장소 구성
저장소 디렉토리 구성은 아래와 같이 저장소 루트 디렉토리에 저장소 종류 별 디렉토리가 존재해야 하고 각 저장소의 하위 디렉토리 구성은 원본 그대로를 유지해야함.
```
(repository root)
.
├── centos
│   ├── 7
│   │   ├── os
│   │   │   ├── x86_64
│   │   │   │   └── ...
│   └── ...
├── ubuntu
│   ├── dists
│   │   ├── bionic
│   │   ... └── ...
│   ├── pool
│   │   ├── main
│   └── ... └── ...
├── epel
│   ├── 7
│   │   ├── x86_64
│   │   │   └── ..
│   └── ...
├── ceph
│   ├── rpm-nautilus
│   │   ├── el7
│   │   │   ├── x86_64
│   ├── debian-nautilus
│   │   ├── db
│   │   ├── dists
│   │   └── pool
├── pip
│   └── simple
└── k8s
    ├── kubeadm-v1.15.3-amd64
    ├── hyperkube-v1.15.3-amd64
    └── ...
```

또한, Ceph YUM 저장소는 추가로 각 호스트에서 저장소 설정을 위한 YUM REPO 파일 자체를 (repository root)/ceph/ceph.repo 위치에 두어야 한다.
```
[ceph_stable]
baseurl = http://CEPH_REPO_IP:PORT/ceph/rpm-nautilus/el7/$basearch
gpgcheck = 0
name = Ceph Stable $basearch repo
priority = 2

[ceph_stable_noarch]
baseurl = http://CEPH_REPO_IP:PORT/ceph/rpm-nautilus/el7/noarch
gpgcheck = 0
name = Ceph Stable noarch repo
priority = 2
```

### extra-vars.yml 설정
아래 저장소 주소 관련 변수를 환경에 맞게 설정한다.

| 설정 값 | 설명 | 기본 값 |
|---------|------|---------|
| pip_repo_url        | PIP 내부 저장소 주소, 예) 192.168.1.1:8080 | "" |
| pkg_repo_url        | 배포본 내부 저장소 주소, 예) 192.168.1.1:8080 | "" |
| k8s_binary_repo_url | 바이너리 내부 저장소 주소, 예) 192.168.1.1:8080 | "" |
| ceph_repo_url       | Ceph 내부 저장소 주소, 예) 192.168.1.1:8080 | "" |

**(예제)**
```
pip_repo_url: "192.168.1.1:8080"
pkg_repo_url: "192.168.1.1:8080"
k8s_binary_repo_url: "192.168.1.1:8080"
ceph_repo_url: "192.168.1.1:8080"
```
