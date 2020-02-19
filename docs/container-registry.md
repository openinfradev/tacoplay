컨테이너 레지스트리 구축 및 사용하기
===================================

tacoplay는 컨테이너 이미지 레지스트리를 사용하는 방법으로 아래 2 가지를 지원한다.
* 컨테이너 레지스트리 신규 구축 후 사용
* 기존 컨테이너 레지스트리 사용

* * *

컨테이너 레지스트리 구축 후 사용
-------------------------------
tacoplay에서 구축하는 컨테이너 레지스트리는 docker 기반 컨테이너로 실행된다.

#### hosts.ini 설정
[taco-registry] 그룹에 컨테이너 레지스트리를 구축할 호스트를 추가한다.

**(예제)**
```
[taco-registry]
container-registry-host
```

#### extra-vars.yml 설정

| 설정 값 | 설명 | 기본 값 |
|---------|------|---------|
| container_registry_enabled | 컨테이너 레지스트리 구축 작업 수행 여부 | false |
| container_registry_name | 레지스트리 컨테이너 이름 | "taco_registry" |
| container_registry_imag | 호스트에 저장될 레지스트리 이미지 이름과 태크 | name: registry, tag: 2.6.2 |
| container_registry_env | 레지스트리 컨테이너 실행 시 전달할 환경 변수 | "" |
| container_registry_expose | 레지스트리 컨테이너 실행 시 노출할 포트 번호 | 5000 |
| container_registry_ports  | 레지스트리 컨테이너와 연결할 호스트 포트와 컨테이너에서 노출된 포트 번호 묶음 | 5000:5000 |
| container_registry_volume | 컨테이너 이미지들이 저장되어 컨테이너 레지스트리에서 서비스로 제공하게 될 경로 | "/DATA/container_registry" |
| registry_volume_archived | 준비한 컨테이너 이미지들이 압축되어 있는 지 여부 | false |
| container_registry_volume_archive | 준비한 컨테이너 이미지 압축 파일 경로 | "{{ inventory_dir }}/container_registry.tar.gz" |
| container_registry_volume_dir | 준비한 컨테이너 이미지 디렉토리 경로 | "{{ playbook_dir }}/container_registry" |

**(예제)**
```
container_registry_enabled: true
```

* * *

기존 컨테이너 레지스트리 사용
-----------------------------

#### extra-vars.yml 설정
container_registries 변수에 리스트 형태로 사용하고자 하는 레지스트리 정보를 설정한다.

| 설정 값 | 설명 |
|---------|------|
|  endpoint | 레지스트리 도메인 이름, IP 주소 설정 가능 |
|  ip | 레지스트 IP 주소 |
|  cert | 레지스트리 인증서, null로 지정할 경우 insecure 레지스트리로 간주됨 |

**(예제)**
```
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
