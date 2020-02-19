내부 저장소 구축 및 사용하기
============================

tacoplay에서 필요한 패키지, 바이너리 저장소는 다음과 같다.
* OS 배포본 저장소: [CentOS](http://mirror.centos.org/centos/)/[EPEL](https://download.fedoraproject.org/pub/epel/) YUM, [Ubuntu](http://archive.ubuntu.com/ubuntu/) APT
* [Python PIP](https://pypi.org) 패키지 저장소
* kubeadm, etcd, calicoctl 등 Kubernetes 설치, 실행에 필요한 바이너리
* Ceph 패키지 저장소: CentOS YUM, Ubuntu APT (http://download.ceph.com)

또한 각각의 저장소가 사용되는 방법은 아래의 3가지 경우로 나누어진다.
1. 공식 저장소 사용
2. tacoplay에서 미러링 저장소 신규 구축 후 사용
3. 별도 구축된 미러링 저장소 사용

이 문서에서는 저장소 구축에 관해서만 다루며 미러링 방법 자체는 아래 링크 등을 참고하기 바람.
 * https://wiki.centos.org/HowTos/CreateLocalMirror
 * https://www.tecmint.com/setup-local-repositories-in-ubuntu/
 * https://github.com/ceph/ceph/tree/master/mirroring

* * *

공식 저장소 사용하기
--------------------

### extra-vars.yml 설정
아래 저장소 구축 및 사용 관련 변수들을 비활성화 한다.

| 설정 값 | 설명 | 기본 값 |
|---------|------|---------|
| local_pip_repo_enabled | PIP 저장소 구축 및 사용 | false |
| local_pkg_repo_enabled | 배포본 YUM / APT 저장소 구축 및 사용 | false |
| local_k8s_binary_repo_enabled | K8S 바이너리 저장소 구축 및 사용 | false |
| local_ceph_repo_enabled | Ceph YUM / APT 저장소 구축 및 사용 | false |

**(예제)**
```
local_pip_repo_enabled: false
local_pkg_repo_enabled: false
local_k8s_binary_repo_enabled: false
local_ceph_repo_enabled: false
```
* * *

내부 저장소 구축 후 사용하기
----------------------------
제약 사항: 단일 저장소 구축만 지원하며 종류 별 저장소는 지원하지 않음.

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
│   └── ... │   └── ..
├── pip
│   └── ...
└── k8s
    └── ...
```

### hosts.ini 설정
[package-repository] 그룹에 저장소를 구축할 호스트를 추가한다.

**(예제)**
```
[package-repository]
pkg_repo_host
```

### extra-vars.yml 설정
위 '공식 저장소 사용하기'에서 설명한 저장소 구축 및 사용 관련 변수들을 활성화 한다.

구축할 저장소 내용을 위 저장소 구성 규칙에 따라 생성하고 압축 파일로 만든 다음 구축 과정에서 자동 해제되도록 설정할 수 있다.

| 설정 값 | 설명 | 기본 값 |
|---------|------|-----------|
| pkg_repo_volume_archived | 저장소 압축 파일을 지정한 디렉토리에 자동 해제 | false  |
| pkg_repo_volume_archive_file | 저장소 내용을 압축한 파일 경로 |  "{{ inventory_dir }}/pkg_repo.tar" |
| pkg_repo_volume_path | 저장소 루트 디렉토리 (압축 파일이 해제될 경로) | "/DATA/taco_pkg_repo" |

저장소를 위한 웹 서버가 사용할 포트 번호를 지정할 수 있다. 

| 설정 값 | 설명 | 기본 값 |
|---------|------|-----------|
| local_reposerver_port | 저장소 웹 서버 포트 번호 | 80  |

**(예제)**
```
local_pip_repo_enabled: true
local_pkg_repo_enabled: true
local_k8s_binary_repo_enabled: true
local_ceph_repo_enabled: true

local_reposerver_port: 8080

pkg_repo_volume_archived: true
pkg_repo_volume_archive_file: "/media/USB/pkg_repo.tar"
pkg_repo_volume_path: "/DATA/taco_pkg_repos"

```

* * *

내부 저장소 연동하여 사용하기
-----------------------------
**연동할 내부 저장소는 구축 후 사용하기 부분의 내용과 동일하기 구성해야 한다.**

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
