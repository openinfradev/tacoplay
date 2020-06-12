Helm v2 및 v3 사용하기
===================

tacoplay는 helm v3를 기본 설치할 수 있고, 필요에 따라 helm v2
를 동시 설치할 수 있도록 기능을 지원한다.

* helm version3 설치
* helm version 2와 version3 동시 설치 (armada 배포 지원을 위한 추가 기능)

* * *

helm version3 설치
-----------------

#### extra-vars.yml 설정
kubespray v2.13.1 버전부터 helm v3를 기본적으로 설치한다.

| 설정 값 | 설명 | 기본 값 |
|---------|------|---------|
| helm_version | 설치할 helm 버전 | kubespray 버전에 따라 상이함. |

**(예제)**
```
helm_version: v3.2.1
```

* * *

helm version2와 version3 동시 설치 지원
-----------------------------------

#### extra-vars.yml 설정
taco apps를 armada를 통해 설치하기 위해서 helm v2를 동시에 설치하는 기능을 지원한다.

| 설정 값 | 설명 | 기본 값 |
|---------|------|------|
|  use_helmv2_for_armada | helm v2 동시 설치 여부 | true
|  helmv2_version | 동시에 설치되는 helm v2 상세 버전 | v2.16.7

**(예제)**
```
use_helmv2_for_armada: true
helmv2_version: v2.16.7
```

helm 2to3 plugin 설치 지원
------------------------
tacoplay에서는 helm v2 동시 설치 기능을 사용할 경우 v2에서 v3로 설정 및 릴리즈를
이주시키는 2to3 plugin 설치를 지원한다.

#### 사용방법

**(설정파일을 v2에서 v3로 이동)**
```
helm2 2to3 move config
```

**(릴리즈를 v2에서 v3로 이동)**
```
helm2 2to3 convert {release name}
```

**(helm v2 삭제)**
```
helm2 2to3 cleanup
```
NOTE: helm v2 삭제 명령어의 경우, tiller server의 삭제도 진행되므로 필요한 주의하도록 한다.