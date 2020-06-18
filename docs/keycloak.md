Keycloak for tacoplay
=====================

Keycloak은 Kubernetes에 사용자 인증기능을 사용하기 위해 tacoplay에서 설치하는 
인증 서비스이다.

설치방법
--------

site.yml플레이북에서  kube_oidc_auth 변수를 true로 설정하여 실행한다.
```
$  ansible-playbook -b -i inventory/test/hosts.ini -e @inventory/test/extra-vars.yml -e kube_oidc_auth=true site.yml 
```

환경변수
--------
kube_oidc_* 변수는 kubespray에서 사용하는 변수로 keycloak을 사용하기 위해 
필수적으로 설정해야한다. kube_oidc_* 변수 설정 시 kube-apiserver에 옵션으로 
추가된다.


| Key | default value | 설명
|-----|---------------|-----
| kube_oidc_auth | true | keycloak으로 사용자 인증을 할 것인지 유무
| kube_oidc_url | https:// | keycloak url
| kube_oidc_client_id | kubernetes | keycloak에서 설정한 kubernetes용 client_id 
| kube_oidc_username_claim | preferred_username | keycloak 인증token에서 username으로 사용할 필드이름
| kube_oidc_username_prefix | - | keycloak 인증token에서 넘어오는 username의 접두어, '-' 일경우 무시
| kube_oidc_groups_claim | groups | keycloak 인증token에서 groups로 사용할 필드이름
| keycloak_domain | keycloak.example.com | keycloak의 도메인 이름
