helm repository 설치하기
===================

tacoplay를 이용하면 특정 노드에 helm repository를 설치할 수 있다.
또한 source_chart_list에 정의된 chart 들을 자동으로 설치된 helm repository에 등록할 수 있다.

* helm repository 설치

* * *

helm repository 설치
-----------------------------------

#### extra-vars.yml 설정

| 설정 값 | 설명 | 기본 값 |
|---------|------|------|
|  helm_repo_enabled | helm repository 설치 여부 | true
|  helm_repo_name | helm repository 이름 | "taco-helm-repository"
|  helm_repo_port | helm repository가 사용할 port | 8879
|  source_chart_base_dir | 설치된 helm repository에 등록할 source chart들이 존재하는 디렉토리의 베이스 | "{{ ansible_env.HOME }}/tacoplay/charts"
|  source_chart_list | helm repository에 넣을 source chart 목록 정의 (source_chart_base_dir 아래) | ["taco-helm-charts/*", "taco-addons/*"]


**(예제)**
```
helm_repo_enabled : true
helm_repo_name : "taco-helm-repository"
helm_repo_port : 8879
source_chart_list : ["taco-helm-charts/elasticsearch-operator", "taco-helm-charts/taco-watcher", "taco-addons/*"]
```

위와 같이 extra-vars.yml에 정의하고 site.yml을 돌리면 helm repo가 설치되고 tacoplay/charts/taco-helm-charts/elasticsearch-operator 와 tacoplay/charts/taco-helm-charts/taco-watcher 두개의 chart가 packaging되서 구축된 helm repo에 올라간다. 그리고 taco-addons 디렉토리 아래의 모든 chart들이 구축된 helm repo에 올라간다.

helm repository가 설치될 node는 inventory/hosts.ini에 [helm-repository] 아래에 등록하면 된다.
**(hosts.ini 예제)**
```
[helm-repository]
taco-aio
.
.
.
```
