//@Library('pipeline-library@master') _
@Library('jenkins-pipeline-library@master') _

pipeline {
  agent {
    node {
      label 'openstack-slave'
      customWorkspace "workspace/${env.JOB_NAME}/${env.BUILD_NUMBER}"
    }
  }
  parameters {
    string(name: 'PROVIDER',
      defaultValue: 'hanu-prod',
      description: 'The name of provider that defined clouds.yaml file.')
    string(name: 'SITE',
      defaultValue: 'gate-centos-lb-ceph-online-aio',
      description: 'target site(inventory) to deploy taco')
    string(name: 'INCLUDED_APPS',
      defaultValue: '',
      description: 'Apps to include in tarball? (comma-separated list)')
    string(name: 'OS',
      defaultValue: 'centos7',
      description: 'guest OS of target VM')
    string(name: 'FLAVOR',
      defaultValue: 'auto',
      description: 'flavor of target VM')
    string(name: 'AZ',
      defaultValue: 'service-az',
      description: 'Availability Zone Name')
    booleanParam(name: 'CLEANUP',
      defaultValue: true,
      description: 'delete VM once job is finished?')
  }
  environment {
    KUBECONFIG = "/root/.kube/config"
    ANSIBLE_SCP_IF_SSH = "y"
  }
  options {
    timeout(time: 60, unit: 'MINUTES')
    timestamps()
  }

  stages {
    stage ('Prepare Tacoplay') {
      steps {
          script {
            ADMIN_NODE = ''
            VM_COUNT = 5
            SECURITY_GROUP = 'default' // Jenkins project's default sec group
            online = true

            println("*********************************************")
            println("SITE (Inventory): ${params.SITE}")
            println("*********************************************")

            sh """
              git clone https://github.com/openinfradev/taco-gate-inventories.git
              cp -r taco-gate-inventories/${params.SITE} ./inventory/

              cp /opt/jenkins/.ssh/jenkins.key ./jenkins.key
              rm -rf /opt/jenkins/.ssh/known_hosts
            """
            
            // This will be deleted after creation for private gate repo.
            sh """
              mc cp hanu-minio/openstack/clouds.yaml .
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

              if (!params.SITE.contains("multi")) {
                VM_COUNT = 1
              }

              deleteBdm = true

              sh "mv gate/cloudInitOnline.sh gate/cloudInit.sh"
              sh "sed -i 's/# CHANGE_ME #/ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGc4hfKJk9fyGAmq5RkQOpirZSZhRg5t08CoVOffl3RF6MIGzEprvL2hK8ky9+3qqWuGyh6zN1y8F8tj+lNgBWnFAycp9eXS8QLqJShhHWmSkETc4sr6Iq649UZu5uRrf+BmoDqnftwyymg3\\/H0ZlOT9PqMrTub5ab2oALn4\\/kyWcNuqXIwM+HfhQBAYvEVtUeSWGv44PTHqiLOT+roWrzPzPGnVQHiikRslevZabxYY6lAJad6mXBaAUWCgxe99SzGvFzHo1\\/FaK3xvql9jaOKNXFMQV1fnXuBLpg0PnDlP3LCr3fOdu+xxm0jjQp2e4DCcAEMPNvxLGTkiNa4y6j jenkins-slave-key/' gate/cloudInit.sh"

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

              vmNamePrefix = createOpenstackVMs(params.SITE, params.OS, flavor, VM_COUNT, [50, 50, 50], "gate/cloudInit.sh", null, SECURITY_GROUP, params.AZ, online, deleteBdm, networks, params.PROVIDER)
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
                #sh "sed -i 's/VM-NAME-${index+1}/${name}/g' inventory/${params.SITE}/*-manifest.yaml"
                sh "sed -i 's/VM-IP-${index+1}/${ip}/g' inventory/${params.SITE}/hosts.ini"
                sh "sed -i 's/VM-IP-${index+1}/${ip}/g' inventory/${params.SITE}/extra-vars.yml"
                #sh "sed -i 's/VM-IP-${index+1}/${ip}/g' inventory/${params.SITE}/*-manifest.yaml"
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
            sh """
              mv gate/adminInitOnline.sh gate/adminInit.sh
              sed -i 's/SITE_NAME/${params.SITE}/g' gate/adminInit.sh
              ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE 'mkdir tacoplay'
              scp -o StrictHostKeyChecking=no -i jenkins.key -rp ./* .git taco@$ADMIN_NODE:/home/taco/tacoplay/
              ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE 'cp /home/taco/tacoplay/gate/adminInit.sh /home/taco/'
              scp -o StrictHostKeyChecking=no -i jenkins.key /opt/jenkins/.netrc taco@$ADMIN_NODE:/home/taco/

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

            if (params.INCLUDED_APPS) {
              def app_list = params.INCLUDED_APPS.split(',')

              app_list.eachWithIndex { app, index ->
                if ( index == app_list.length-1 ) {
                  tacoplay_params += "'${app}'"
                } else {
                 tacoplay_params += "'${app}',"
                }
              }
            }
            tacoplay_params += "]}'"

            println("tacoplay_params: ${tacoplay_params}")

            sh """
              ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE "cd tacoplay && git status && ansible-playbook -T 30 -vv -u taco -b -i inventory/${params.SITE}/hosts.ini site.yml -e @inventory/${params.SITE}/extra-vars.yml ${tacoplay_params}"
            """
          }
      }
    }

  }

  post {
    always {
        script {
          if ( params.CLEANUP == true ) {
            deleteOpenstackVMs(vmNamePrefix, params.PROVIDER)
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
