# Kubernetes 컨트롤 플레인 복구

Kubespray "recover\-control\-plane.yml" 플레이북을 기반으로 컨트롤 플레인 노드 장애 복구 방법을 설명한다.
* 참고: Kubespray [관련 문서](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/recover-control-plane.md)

복구가 지원되는 장애 상황 및 조건은 다음과 같다.
* master 노드 일부 혹은 전체의 데이터 손실
* etcd 노드 일부 혹은 전체의 데이터 손실 
* 전체 데이터 손실일 경우 백업 데이터 필요
* etcd 복구를 위한 etcd 및 etcdctl이 설치된 노드
* 신규 노드는 동일한 IP 주소 사용
* 현재 설치 환경 구성 정보가 저장된 inventory: hosts.ini, extra-vars.yml 등

## 백업 대상 및 방법
컨트롤 플레이 컴포넌트 중 백업 대상은 etcd와 인증서/키 파일들이다.

### etcd 백업
etcd가 동작 중인 노드에서 아래와 같이 실행한다. (/tmp/etcd-snapshot.db로 저장)
```
# ETCDCTL_API=3 /usr/local/bin/etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/ssl/etcd/ssl/ca.pem --cert=/etc/ssl/etcd/ssl/member-$HOSTNAME.pem --k
ey=/etc/ssl/etcd/ssl/member-$HOSTNAME-key.pem snapshot save /tmp/etcd-snapshot.db
```

### Kubernetes 인증서/키 파일
Kubernetes master 노드에서 아래 디렉티리와 파일을 백업한다.
* /etc/kubernetes/ssl (디렉토리)
* /etc/kubernetes/pki (심볼릭 링크)

전체 노드 장애로 데이터 손실이 발생할 경우 복구 과정에서 백업 데이터가 필요하며 그 외의 경우에는 "etcd"와 "kube-master" 그룹의 첫 번째 노드 데이터를 기준으로 복구를 진행한다.

## 컨트롤 플레인 복구 절차

* 신규 노드를 동일한 IP 주소를 가지도록 프로비저닝 한다.
* hosts.ini 수정
  * "etcd"와 "kube-master" 그룹의 첫번 째 노드에서 복구 작업이 수행되기 때문에 정상 동작하는 노드를 각 그룹의 첫 번째로 이동시킨다.
    * "etcd" 그룹의 경우 첫번 째 노드의 "etcd\_member\_name" 변수를 반드시 설정한다. 이전 구축 시 해당 변수를 설정하지 않았다면 그룹 내 노드 순서대로 etcd1, etcd2, etcd3와 같이 자동 설정되어 있다.
  * 장애가 발생한 etcd 노드를 "broken_etcd" 그룹으로 이동시키고 "etcd\_member\_name" 변수를 반드시 설정한다. 복구할 etcd 노드가 없더라도 "broken_etcd" 그룹 항목은 남겨둔다.
  * 장애가 발생한 master 노드를 "broken\_kube-master" 그룹으로 이동시킨다. 복구한 master 노드가 없더라도 "broken\_kube-master" 그룹 항목은 남겨둔다.
* master 노드 전체 장애일 경우 백업한 Kubernetes 인증서/키 파일을 "kube-master" 그룹의 첫 번째 노드에 동일한 위치로 복사하고 아래와 같이 /etc/kubernetes 디렉토리 보안 권한을 모두 해제한다.  `# chmod 777 /etc/kubernetes`

### hosts.ini 수정 예제
* 기본
```
[kube-master]
taco-m1
taco-m2
taco-m3

[etcd]
taco-m1
taco-m2
taco-m3
taco-w1
taco-w2
```

* 수정 후
```
[kube-master]
taco-m1
taco-m2
taco-m3

[etcd]
taco-w1 etcd_member_name=etcd4
taco-m1
taco-m2
taco-m3
taco-w2

[broken_etcd]
taco-m1 etcd_member_name=etcd1
taco-m2 etcd_member_name=etcd2
taco-m3 etcd_member_name=etcd3

[broken_kube-master]
taco-m1
taco-m2
taco-m3
```
다음과 같이 ```--limit etcd,kube-master```, ```-e etcd_retries=10```, ```--skip-tags=external-provisioner``` 옵션을 추가하여 플레이북을 실행한다.
```
$ ansible-playbook -b -i inventory/sample/hosts.ini -e @inventory/sample/extra-vars.yml recover-k8s-control-plane.yml --limit etcd,kube-master -e etcd_retries=10 --skip-tags=external-provisioner
```

etcd 백업 데이터를 사용할 경우 "etcd\_snapshot" 변수를 사용한다.
```
$ ansible-playbook -b -i inventory/sample/hosts.ini -e @inventory/sample/extra-vars.yml recover-k8s-control-plane.yml --limit etcd,kube-master -e etcd_snapshot=/home/sample/k8s_backup/etcd-snapshot.db -e etcd_retries=10 --skip-tags=external-provisioner
```

__장애 상황과 동일한 테스트 환경 구성하여 사전 검증 수행하는 것을 권장한다__

## 추가 정보
master, etcd 정상 동작 여부에 따라 2가지 방법으로 복구 작업이 수행된다.

* 정상 동작 기준
  * master 복구: ```kubectl delete node``` 명령어 수행 가능
  * etcd 복구: ```etcdctl member remove``` 명령어 수행 가능

* 정상 동작한다면 "broken\_kube-master", "broken\_etcd" 그룹 노드를 제거하고 cluster.yml 플레이북을 통해 신규 노드 재 구축
* 정상 동작하지 않는다면 etcd는 백업 데이터를 기반으로 single 클러스터를 구성하고 cluster.yml 플레이북을 통해 신규 노드 재 구축
  * kubespray 내부적으로 kubeadm 호출시 ```--ignore-preflight-errors=all``` 옵션을 사용하고 있기 때문에 인증서/키가 이미 존재하는 경우 해당 내용을 재사용
  * "broken\_kube-master", "broken\_etcd" 내용이 실제로 사용되지는 않음
