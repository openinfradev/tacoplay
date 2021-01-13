TACOPLAY CI 
=============================

본 CI는 Tacoplay라는 ansible-playbook을 사용하여, 준비된 환경 위에 Taco cluster를 배포하는 task를 수행한다.[(Jenkinsfile)](https://github.com/openinfradev/tacoplay/blob/main/Jenkinsfile)

Job 수행시 미리 준비된 Openstack 환경에 실시간으로 VM(들)을 생성하고 그 위에 k8s cluster를 배포하게 된다. Job parameter에 따라 배포 형상이 조금씩 달라지게 되지만, 기본적으로 Pull request 제출 시 자동으로 trigger되는 job의 경우 default 설정을 사용하므로 자세한 사항은 특별히 숙지하지 않아도 된다.
참고적으로 job 수행에 영향을 미치는 주요 job parameter는 다음과 같다.

 - SITE (inventory)명: centos-all-in-one, ubuntu-multimodes 등 테스트 시 사용할 inventory명 ('taco-gate-inventories'라는 private repo에 포함되어 있는 내용임)
 - INCLUDED_APPS: k8s 설치 후 추가적으로 설치할 application list
 - OS: 생성할 VM의 OS distribution
 - JOIN_K8S_POOL: HANU CI 환경에서는 손쉬운 app 배포를 위해 필요시 즉각 사용할 수 있는 k8s cluster pool 을 가지고 있다. 본 Parameter를 true로 하게 되면, 성공적으로 k8s cluster 배포 시, 해당 클러스터의 endpoint가 etcd 에 등록되어 k8s cluster pool에 포함되게 되며, 향후 application 배포를 위한 기반 환경으로 사용되도록 한다.


Job 세부 로직
=============

 1. Jenkins slave 상에서 inventory 등 필요한 파일을 준비한다. 
 2. 필요한 갯수만큼 VM을 생성한다. (default는 AIO(all-in-one) 환경이므로 VM 1개만 생성됨)
 3. ansible이 설치되는 admin 노드로 tacoplay, inventory 및 필요 script들을 전송한다
	(AIO 형상일 경우는 해당 노드 자체가 admin 노드로도 사용되며, 멀티 노드 형상일 경우에는 첫번째 노드가 admin 노드가 된다)
 4. Admin 노드에서 ansible을 사용하여 taco cluster 설치
 5. 배포 성공시 Etcd에 k8s endpoint 등록


Troubleshooting
================

Job이 완료되면, Pull request 페이지의 comment 에 job 수행결과가 표시되며, 'details'라고 표시되는 job link 를 클릭하여 Jenkins의 해당 job console 화면을 볼 수 있다.
