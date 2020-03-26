@Library('pipeline-library@master') _

pipeline {
  agent {
    node {
      label 'openstack-prd'
      customWorkspace "workspace/${env.JOB_NAME}/${env.BUILD_NUMBER}"
    }
  }
  parameters {
    string(name: 'TACOPLAY_VERSION',
      defaultValue: 'master',
      description: 'branch or tag of tacoplay (Eg, \'master\' or \'2.0.0\')')
    string(name: 'SITE',
      defaultValue: 'gate-centos-lb-ceph-offline-multinodes',
      description: 'target site(inventory) to deploy taco')
    string(name: 'INCLUDED_APPS',
      defaultValue: '',
      description: 'Apps to include in tarball? (comma-separated list)')
    string(name: 'OS',
      defaultValue: 'centos7',
      description: 'guest OS of target VM')
    string(name: 'FLAVOR',
      defaultValue: 't1.xlarge',
      description: 'flavor of target VM')
    string(name: 'AZ',
      defaultValue: 'jenkins',
      description: 'Availability Zone Name')
    string(name: 'ARTIFACT',
      defaultValue: 'latest-gate-centos-lb-ceph-offline-multinodes',
      description: 'artifact filename on minio server')
    booleanParam(name: 'REINSTALL',
      defaultValue: false,
      description: 'reset before install?')
    string(name: 'TEMPEST_FAIL_THRESHOLD',
      defaultValue: '10',
      description: 'Threshold for failed tempest test cases')
    booleanParam(name: 'CLEANUP',
      defaultValue: true,
      description: 'delete VM once job is finished?')
    string(name: 'VERSION_FILE_NAME',
      defaultValue: 'abcde',
      description: 'arbitrary name of the version file that\'ll be shared to next job (Eg, \'version-190101-abcd\')')
    booleanParam(name: 'EMPHASIZED_NOTIFICATION',
      defaultValue: false,
      description: 'enable emphasized notification going to slack?')
  }
  environment {
    KUBECONFIG = "/root/.kube/config"
    ANSIBLE_SCP_IF_SSH = "y"
  }
  options {
    timeout(time: 240, unit: 'MINUTES')
    timestamps()
  }

  stages {
    stage ('Prepare Tacoplay') {
      steps {
          script {
            ADMIN_NODE = ''
            VM_COUNT = 5
            SECURITY_GROUP = '7db40031-df4a-402a-ac56-53d71de65fc6' // Jenkins project's default sec group
            online = false

            println("*********************************************")
            println("TACOPLAY VERSION: ${params.TACOPLAY_VERSION}")
            println("SITE (Inventory): ${params.SITE}")
            println("*********************************************")

            sh """
              git checkout ${params.TACOPLAY_VERSION}

              git clone https://tde.sktelecom.com/stash/scm/oreotools/vslab-inventories.git
              cp -r vslab-inventories/${params.SITE} ./inventory/

              cp /var/lib/jenkins/.ssh/jenkins.key ./jenkins.key
              rm -rf /var/lib/jenkins/.ssh/known_hosts
            """

            println("SITE: ${params.SITE}")
            if (params.SITE.startsWith("gate")) {
              /**************
              * Gating Test *
              **************/
              println("Gating test selected. Creating VMs...")

              // Use three net interfaces for each VM instance
              networks = [:]
              networks.mgmt = 'mgmt-net'
              networks.flat = 'data-net1'
              networks.vxlan = 'data-net2'

              if (params.SITE.contains("online")) {
                online = true
                networks.mgmt = 'public-net'
                if (!params.SITE.contains("multi")) {
                  VM_COUNT = 1
                }
              } else {
                SECURITY_GROUP = 'offline-rule'
              }

              deleteBdm = true

              if (online) {
                if (params.OS.contains("ubuntu")) {
                  sh "mv gate/cloudInitUbuntuOnline.sh gate/cloudInit.sh"
                } else {
                  sh "mv gate/cloudInitOnline.sh gate/cloudInit.sh"
                }
              } else {
                if (params.OS.contains("ubuntu")) {
                  sh "mv gate/cloudInitUbuntuOffline.sh gate/cloudInit.sh"
                } else {
                  sh "mv gate/cloudInitOffline.sh gate/cloudInit.sh"
                }
              }

              vmNamePrefix = createOpenstackVMs(params.SITE, params.OS, params.FLAVOR, VM_COUNT, [50, 50, 50], "gate/cloudInit.sh", null, SECURITY_GROUP, params.AZ, online, deleteBdm, networks)
              vmMgmtIPs = getOpenstackVMinfo(vmNamePrefix, networks.mgmt)
              vmFlatIPs = getOpenstackVMinfo(vmNamePrefix, networks.flat)
              vmVxlanIPs = getOpenstackVMinfo(vmNamePrefix, networks.vxlan)

              // Disable port-security
              disablePorts(vmMgmtIPs)
              disablePorts(vmFlatIPs)
              disablePorts(vmVxlanIPs)

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
                sh "sed -i 's/VM-NAME-${index+1}/${name}/g' inventory/${params.SITE}/*-manifest.yaml"
                sh "sed -i 's/VM-IP-${index+1}/${ip}/g' inventory/${params.SITE}/hosts.ini"
                sh "sed -i 's/VM-IP-${index+1}/${ip}/g' inventory/${params.SITE}/extra-vars.yml"
                sh "sed -i 's/VM-IP-${index+1}/${ip}/g' inventory/${params.SITE}/*-manifest.yaml"
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
                mv gate/adminInitOffline.sh gate/adminInit.sh
                sed -i 's/SITE_NAME/${params.SITE}/g' gate/adminInit.sh
                sed -i 's/ARTIFACT_NAME/${params.ARTIFACT}/g' gate/adminInit.sh
                scp -o StrictHostKeyChecking=no -i jenkins.key -r inventory/${params.SITE}/hosts.ini inventory/${params.SITE}/extra-vars.yml inventory/${params.SITE}/*-manifest.yaml /var/lib/jenkins/.netrc gate/adminInit.sh taco@$ADMIN_NODE:/home/taco/
              """
            } else {
              /****************************************
              * For online gating and non-gating test *
              ****************************************/
              sh """
                mv gate/adminInitOnline.sh gate/adminInit.sh
                sed -i 's/SITE_NAME/${params.SITE}/g' gate/adminInit.sh
                scp -o StrictHostKeyChecking=no -i jenkins.key -r ./* /var/lib/jenkins/.netrc gate/adminInit.sh taco@$ADMIN_NODE:/home/taco/
              """
            }

            sh """
              ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE chmod 0755 /home/taco/adminInit.sh
              ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE /home/taco/adminInit.sh 
            """

            // Debug cmds
            sh "ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE 'cd tacoplay && git status && cat VERSIONS'"
          }
      }
    }

    stage ('Run Tacoplay') {
      steps {
          script {
            // Should pass this format: '{"taco_apps": ['openstack','lma']}'
            tacoplay_params = "-e '{\"taco_apps\": ["
            add_openstack_param = false

            if (params.INCLUDED_APPS) {
              def app_list = params.INCLUDED_APPS.split(',')

              app_list.eachWithIndex { app, index ->
                if ( app == 'openstack') {
                  if (!params.SITE.startsWith('gate')) {
                    add_openstack_param = true
                  }
                }

                if ( index == app_list.length-1 ) {
                  tacoplay_params += "'${app}'"
                } else {
                 tacoplay_params += "'${app}',"
                }
              }
            }
            tacoplay_params += "]}'"

            if (!params.SITE.startsWith('gate') && add_openstack_param ) {
              tacoplay_params += " -e 'site_name=${params.SITE} openstack_release=${params.OPENSTACK_RELEASE}'"
            }

            println("tacoplay_params: ${tacoplay_params}")

            if (params.REINSTALL) {
              deleteGlanceBootstrapImage(params.SITE)
              sh "ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE 'cd tacoplay && git checkout ${params.TACOPLAY_VERSION} && ansible-playbook -T 30 -vv -u taco -i inventory/${params.SITE}/hosts.ini -e @inventory/${params.SITE}/extra-vars.yml reset-wrapper.yml'"
            }

            // [Robert] Do we need to pass 'site_name' var as a param? (Is there any case where inventory name != manifest name?)
            sh """
              ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE "cd tacoplay && git checkout ${params.TACOPLAY_VERSION} && ansible-playbook -T 30 -vv -u taco -b -i inventory/${params.SITE}/hosts.ini site.yml -e @inventory/${params.SITE}/extra-vars.yml ${tacoplay_params}"
            """

/*
            dir('tacoplay') {
              sh "cp VERSIONS ${params.VERSION_FILE_NAME}"
              sh "mc -C /root/.mc --quiet cp ./${params.VERSION_FILE_NAME} ${env.MINIO}/jenkins/etc/"
            }
*/
          }
      }
    }

    stage ('Run Tempest') {
      when {
        expression { params.INCLUDED_APPS.contains("openstack") }
      }
      steps {
          script {
            if (params.SITE.startsWith("gate")) {
              def job = build(
                job: "Tasks/tempest-new",
                parameters: [
                  booleanParam(name: 'ONLINE', value: online),
                  booleanParam(name: 'EMPHASIZED_NOTIFICATION', value: params.EMPHASIZED_NOTIFICATION),
                  string(name: 'INSECURE_IP', value: "${ADMIN_NODE}"),
                  string(name: 'FAIL_THRESHOLD', value: params.TEMPEST_FAIL_THRESHOLD)
                ],
                propagate: true
              )
              res = job.getResult()
              println("Tempest Result: ${res}")
            } else {
              def job = build(
                job: "Tasks/tempest",
                parameters: [
                  string(name: 'KUBE_CONTEXT', value: "${params.SITE}")
                ],
                propagate: true
              )
              res = job.getResult()
              println("Tempest Result: ${res}")
            }
          }
      }
    }
  }

  post {
    always {
        script {
          if ( params.CLEANUP == true ) {
            deleteOpenstackVMs(vmNamePrefix)
          } else {
            echo "Skipping VM cleanup.."
          }
        }
    }
    success {
      notifyCompleted(true, params.EMPHASIZED_NOTIFICATION)
    }
    failure {
      notifyCompleted(false, params.EMPHASIZED_NOTIFICATION)
    }
  }
}
