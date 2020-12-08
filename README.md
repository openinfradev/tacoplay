**NOTE: The master branch is currently in maintenance, so use 'hanu-verification' branch instead for now.

TEST

# tacoplay 

tacoplay is a set of ansible playbooks to selectively deploy and configure various services (platforms) developed under TACO project. 

List of services (platforms) is as following: 

* Docker registry
* Ceph (via ceph-ansible) 
* Kubernetes (via Kubespray)
* CSI/CNI
* Helm 
* Airship-armada
* OpenStack (via openstack-helm & armada) 
* Logging, Monitoring, Alarm (via openstack-helm-infra & operators)
* and more tools under TACO project. 

## Document & Installation Guide  
Refer to detailed installation guide on the following documentation site.

**Warning: Use 'sample/aio' inventory for now, since 'sample/5nodes' hasn't been updated to the recent version yet. It'll be updated soon.**

TACO Document: https://taco-docs.readthedocs.io/ko/latest/#




---
Copyright 2017 ~ 2020 SK Telecom., Ltd. 

Licensed under the Apache License, Version 2.0 (the "License");

   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 

See the License for the specific language governing permissions and limitations under the License.
