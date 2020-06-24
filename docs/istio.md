istio service mesh 사용하기
===================

tacoplay는 istio service mesh의 설치 및 폐쇄망 환경 설치 기능을 제공한다.

* 폐쇄망 환경에 설치하기 위한 준비 작업
* istio 설치
* 설치 후 istio 설정 변경
* 설치 후 추가 namespace에 istio-injection label 적용
* istio 삭제

* * *

폐쇄망 환경에 설치하기 위한 준비 작업
-----------------

#### extra-vars.yml 설정

| 설정 값 | 설명 | 기본 값 |
|---------|------|---------|
| local_release_dir | istioctl tarball을 download 할 위치 | /tmp/releases |
| download_istio_images | istio 관련 이미지 다운로드 여부 | false |

**(예제)**
```
local_release_dir: "../../mirros/k8s/"
download_istio_images: true

위와 같이 설정 후 site-prepare 실행
> ansible-playbook -b -i inventory/preparation/local.ini -e @inventory/preparation/extra-vars.yml extra-playbooks/site-prepare.yml --tags download,upload,preinstall,untagged --skip-tags upgrade
```

* * *

istio 설치
-----------------------------------

#### extra-vars.yml 설정

| 설정 값 | 설명 | 기본 값 |
|---------|------|------|
|  istio_enabled | istio 설치 여부 | false
|  istio_injection_namespaces | istio injection을 적용할 namespace 목록 | ["default"]


**(예제)**
```
istio_enabled: true
```

위와 같이 istio_enabled: true를 extra-vars.yml에 추가하고 site.yml을 돌리면 istio가 cluster에 설치된다.

**(예제)**
```
> ansible-playbook -b -i inventory/sample/hosts.ini -e @inventory/sample/extra-vars.yml site.yml
```

#### 폐쇄망 설치 시 변경할 값

| 설정 값 | 설명 | 기본 값 |
|---------|------|------|
|  istioctl_binary_repo_url | istioctl binary repo 주소 | "https://github.com/istio/istio/releases/download/{{ istio_version }}"
|  docker_image_repo | istio image 중 docker.io에 등록된 image의 image repo | "docker.io"
|  quay_image_repo | istio image 중 quay.io에 등록된 image의 image repo | "quay.io"

**(예제)**
```
istioctl_binary_repo_url: "http://localrepo:8080/k8s"
docker_image_repo: "localrepo:5000"
quay_image_repo: "localrepo:5000"
```

* * *

설치 후 istio 설정 변경
-----------------

설치가 완료되면 inventory 디렉토리에 istio-profile.yml 파일이 생긴다. istio 형상을 변경하고 싶으면 해당 파일을 수정 후 ansible을 다시 돌리거나 istioctl 명령을 사용한다.

**(예제)**
```
istio-profile.yml 변경 후
> ansible-playbook -b -i inventory/test/hosts.ini -e @inventory/test/extra-vars.yml site.yml --tags deploy-istio --skip-tags setup-os,ceph,k8s,taco-clients
또는
> istioctl manifest apply -f inventory/istio-profile.yml
```

* * *

설치 후 추가 namespace에 istio-injection label 적용
-----------------

설치가 완료된 이후에 아래 명령어로 namespace에 추가로 istio를 적용할 수 있다.

**(예제)**
```
kubectl label namespace NAMESPACE_NAME istio-injection=enabled
```

* * *

istio 삭제
-----------------

아래 명령어로 설치된 istio를 삭제할 수 있다.

**(예제)**
```
istioctl manifest generate -f inventory/istio-profile.yml | kubectl delete -f -
kubectl delete ns istio-system
```
