@Library('jenkins-pipeline-library@release-v21.06') _

pipeline {
  agent {
    node {
      label 'openstack-slave-pangyo'
      customWorkspace "workspace/${env.JOB_NAME}/${env.BUILD_NUMBER}"
    }
  }
  parameters {
    string(name: 'PROVIDER',
      defaultValue: 'openstack-pangyo',
      description: 'The name of provider defined in clouds.yaml file.')
    string(name: 'TACOPLAY_TAG',
      defaultValue: 'main',
      description: 'tacoplay repository tag or branch')
     string(name: 'GATING_INVENTORIES_TAG',
      defaultValue: 'main',
      description: 'gating inventories repository tag or branch')
    string(name: 'SITE',
      defaultValue: 'gate-centos-lb-ceph-online-aio',
      description: 'target site(inventory) to deploy taco')
    string(name: 'DECAPOD_VERSION',
      defaultValue: 'main',
      description: 'Decapod version: main or release-1.0')
    string(name: 'K8S_VERSION',
      defaultValue: 'v1.18.8',
      description: 'Kubernetes version to deploy. This will be ignored when offline deployment.')
    string(name: 'SONOBUOY_MODE',
      defaultValue: 'quick',
      description: 'custom | quick | non-disruptive-conformance | certified-conformance')
    string(name: 'OS',
      defaultValue: 'centos7',
      description: 'guest OS of target VM')
    string(name: 'FLAVOR',
      defaultValue: 'auto',
      description: 'flavor of target VM')
    string(name: 'VOLUME_TYPE',
      defaultValue: 'rbd1',
      description: 'volume type of of target VM: rbd1(HDD), rbd2(SSD)')
    string(name: 'AZ',
      defaultValue: 'r06',
      description: 'Availability Zone Name')
    string(name: 'ARTIFACT',
      defaultValue: 'latest-gate-centos-lb-ceph-offline-multinodes',
      description: 'artifact filename on minio server')
    booleanParam(name: 'JOIN_K8S_POOL',
      defaultValue: false,
      description: 'If job runs as periodic schedulled job, newly created k8s cluster will join the k8s cluster pool.')
    booleanParam(name: 'CLEANUP',
      defaultValue: true,
      description: 'delete VM once job is finished?')
  }
  environment {
    KUBECONFIG = "/root/.kube/config"
    ANSIBLE_SCP_IF_SSH = "y"
  }
  options {
    timeout(time: 120, unit: 'MINUTES')
    timestamps()
  }

  stages {
    stage ('Prepare Tacoplay') {
      steps {
          script {
            ADMIN_NODE = ''
            VM_COUNT = 5
            SECURITY_GROUP = '57aa4e93-0a9c-4ff9-bcb5-33fe1c1ca344' // Jenkins project's default sec group
            online = true

            // Check k8s cluster pool size and abort job if the size reached the limit
            if ( params.JOIN_K8S_POOL ) {
              if (checkK8sPoolSize("k8s_endpoint") >= env.K8S_POOL_SIZE_LIMIT) {
                currentBuild.result = 'ABORTED'
                error("K8s pool size already reached the limit. Aborting the job...")
              }
            }

            println("*********************************************")
            println("SITE (Inventory): ${params.SITE}")
            println("*********************************************")

            sh """
              git clone https://github.com/openinfradev/taco-gate-inventories.git --branch ${params.GATING_INVENTORIES_TAG} --single-branch
              cp -r taco-gate-inventories/inventories/${params.SITE} ./inventory/
              cp -r taco-gate-inventories/scripts ./gate-scripts
              cp taco-gate-inventories/config/pangyo-clouds.yml ./clouds.yaml

              cp /opt/jenkins/.ssh/jenkins-slave-hanukey ./jenkins.key
              rm -rf ~/.ssh/known_hosts
            """

            println("SITE: ${params.SITE}")
            if (params.SITE.startsWith("gate")) {
              /**************
              * Gating Test *
              **************/
              println("Gating test selected. Creating VMs...")

              // Use three net interfaces for each VM instance
              networks = [:]
              networks.mgmt = 'private-mgmt-online'
              networks.flat = 'private-data1'
              networks.vxlan = 'private-data2'

              if (params.SITE.contains("online")) {
                if (!params.SITE.contains("multi")) {
                  VM_COUNT = 1
                }
              } else {
                networks.mgmt = 'private-mgmt-offline'
                online = false
                //SECURITY_GROUP = 'offline-rule'
              }

              deleteBdm = true

              if (online) {
                if (params.OS.contains("ubuntu")) {
                  sh "mv gate-scripts/cloudInitUbuntuOnline.sh gate-scripts/cloudInit.sh"
                } else {
                  sh "mv gate-scripts/cloudInitOnline.sh gate-scripts/cloudInit.sh"
                }
              } else {
                if (params.OS.contains("ubuntu")) {
                  sh "mv gate-scripts/cloudInitUbuntuOffline.sh gate-scripts/cloudInit.sh"
                } else {
                  sh "mv gate-scripts/cloudInitOffline.sh gate-scripts/cloudInit.sh"
                }
              }

              // Automatically choose flavor ID based on gating inventory 
              // For AIO inventory, larger flavor is used
              flavor = params.FLAVOR
              if (flavor == 'auto') {
                if (!params.SITE.contains("multi")) {
                  flavor = 't1.4xlarge'
                } else {
                  flavor = 't1.xlarge'
                }
              }

              vmNamePrefix = createOpenstackVMs(params.SITE, params.OS, flavor, VM_COUNT, params.VOLUME_TYPE, [50, 50, 50], "gate-scripts/cloudInit.sh", null, SECURITY_GROUP, params.AZ, online, deleteBdm, networks, params.PROVIDER)
              vmMgmtIPs = getOpenstackVMinfo(vmNamePrefix, networks.mgmt, params.PROVIDER)
              vmFlatIPs = getOpenstackVMinfo(vmNamePrefix, networks.flat, params.PROVIDER)
              vmVxlanIPs = getOpenstackVMinfo(vmNamePrefix, networks.vxlan, params.PROVIDER)

              // Disable port-security
              disablePorts(vmMgmtIPs, params.PROVIDER)
              disablePorts(vmFlatIPs, params.PROVIDER)
              disablePorts(vmVxlanIPs, params.PROVIDER)

              vmMgmtIPs.eachWithIndex { name, ip, index ->
                if (index==0)
                  ADMIN_NODE = ip
              }

              println("Waiting for VM's gateway to be ready..")
              sh """
                until ping -c 1 -W 3 $ADMIN_NODE
                do
                  sleep 15
                done

                until ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE 'test -f /tmp/.vm_ready'
                do
                  sleep 15
                done
              """

              // Insert actual IPs into hosts.ini
              vmMgmtIPs.eachWithIndex { name, ip, index ->
                println("name: ${name}, IP: ${ip}, index: ${index}")
                sh "sed -i 's/VM-NAME-${index+1}/${name}/g' inventory/${params.SITE}/hosts.ini"
                sh "sed -i 's/VM-NAME-${index+1}/${name}/g' inventory/${params.SITE}/extra-vars.yml"
                //sh "sed -i 's/VM-NAME-${index+1}/${name}/g' inventory/${params.SITE}/*-manifest.yaml"
                sh "sed -i 's/VM-IP-${index+1}/${ip}/g' inventory/${params.SITE}/hosts.ini"
                sh "sed -i 's/VM-IP-${index+1}/${ip}/g' inventory/${params.SITE}/extra-vars.yml"
                //sh "sed -i 's/VM-IP-${index+1}/${ip}/g' inventory/${params.SITE}/*-manifest.yaml"
                sh "ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE 'sudo -- sh -c \"echo ${ip} ${name} >> /etc/hosts\"'"
                //sh "ssh -o StrictHostKeyChecking=no -i jenkins.key taco@${ip} 'sudo -- sh -c \"echo ${ADMIN_NODE} tacorepo >> /etc/hosts\"'"
              }

            } // End of if(gating)

          }
      }
    }

    stage ('Prepare Admin Node') {
      steps {
          script {
            if (params.SITE.startsWith("gate") && !params.SITE.contains("online")) {
              /***************************************************************************************************
              * In offline gating, only send hosts.ini file and tacoplay will be fetched directry to admin Node. *
              ***************************************************************************************************/
              sh """
                mv gate-scripts/adminInitOffline.sh gate-scripts/adminInit.sh
                sed -i 's/SITE_NAME/${params.SITE}/g' gate-scripts/adminInit.sh
                sed -i 's/ARTIFACT_NAME/${params.ARTIFACT}/g' gate-scripts/adminInit.sh
                scp -o StrictHostKeyChecking=no -i jenkins.key -r inventory/${params.SITE}/hosts.ini inventory/${params.SITE}/extra-vars.yml /opt/jenkins/.netrc gate-scripts/adminInit.sh taco@$ADMIN_NODE:/home/taco/
              """
            } else {
              /****************************************
              * For online gating and non-gating test *
              ****************************************/
              sh """
                mv gate-scripts/adminInitOnline.sh gate-scripts/adminInit.sh
                sed -i 's/SITE_NAME/${params.SITE}/g' gate-scripts/adminInit.sh
                ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE 'mkdir tacoplay'
                scp -o StrictHostKeyChecking=no -i jenkins.key -rp ./* .git taco@$ADMIN_NODE:/home/taco/tacoplay/
                ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE 'cp /home/taco/tacoplay/gate-scripts/adminInit.sh /home/taco/'
                scp -o StrictHostKeyChecking=no -i jenkins.key /opt/jenkins/.netrc taco@$ADMIN_NODE:/home/taco/
              """
            }

            sh """
              ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE chmod 0755 /home/taco/adminInit.sh
              ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE /home/taco/adminInit.sh ${params.TACOPLAY_TAG}
            """

            // Debug cmds
            sh "ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE 'cd tacoplay && git branch && git status && cat VERSIONS'"
          }
      }
    }

    stage ('Run Tacoplay') {
      steps {
        script {
          tacoplay_params = ""
          if (online) {
            tacoplay_params = "-e kube_version=${params.K8S_VERSION}"
            // When offline deployment, all K8S binaries and images have already been prepared in the artifact file.
            // Therefore, kube_version parameter is ignored.
          }
          println("tacoplay_params: ${tacoplay_params}")

          sh """
            ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE "cd tacoplay && git status && ansible-playbook -T 30 -vv -u taco -b -i inventory/${params.SITE}/hosts.ini site.yml -e @inventory/${params.SITE}/extra-vars.yml -e decapod_base_yaml_version=${params.DECAPOD_VERSION} -e decapod_site_version=${params.DECAPOD_VERSION} -e decapod_flow_version=${params.DECAPOD_VERSION} ${tacoplay_params}"
          """
          // Store k8s endpoint to file
          sh "echo ${vmNamePrefix} > /tmp/k8s_vm_\$(date +%y%m%d)"
        }
      }
    }

    stage ('Validate k8s cluster') {
      steps {
        script {
          def job = build(
            job: "validate-k8s",
            parameters: [
              string(name: 'SONOBUOY_VERSION', value: "0.51.0"),
              string(name: 'KUBERNETES_CLUSTER_IP', value: "${ADMIN_NODE}"),
              string(name: 'SONOBUOY_MODE', value: params.SONOBUOY_MODE),
              booleanParam(name: 'OFFLINE_ENV', value: !online)
            ],
            propagate: true
          )
          res = job.getResult()
          println("Validate-k8s result: ${res}")
        }
      }
    }

    stage ('Register endpoint to Etcd') {
      steps {
        script {
          if ( params.JOIN_K8S_POOL ) {
            cluster_name = "cluster-${env.BUILD_NUMBER}"
            putEtcdValue("k8s_endpoint/${cluster_name}", 'vmName', vmNamePrefix)

            /*******************************
            * TEST: get k8s info from etcd *
            *******************************/
            vmNamePrefixRand = getK8sVmName("k8s_endpoint")
            vmIPs = getOpenstackVMinfo(vmNamePrefixRand, networks.mgmt, params.PROVIDER)

            // get API endpoints
            if (vmIPs) {
              vmIPs.eachWithIndex { name, ip, index ->
                if (index==0) {
                  ADMIN_NODE_IP = ip
                  print("Found admin node IP: ${ADMIN_NODE_IP}")
                }
              }
            }
          } else {
            println("Skipping endpoint registration..")
          }
        }
      }
    }

  }

  post {
    always {
        script {
          if ( params.CLEANUP == true ) {
            if (params.JOIN_K8S_POOL) {
              deleteOpenstackVMs(vmNamePrefix, "k8s_endpoint/${cluster_name}/vmName", params.PROVIDER)
            } else {
              deleteOpenstackVMs(vmNamePrefix, '', params.PROVIDER)
            }
          } else {
            echo "Skipping VM cleanup.."
          }
        }
    }
    success {
      notifyCompleted(true)
    }
    failure {
      notifyCompleted(false)
    }
  }
}
