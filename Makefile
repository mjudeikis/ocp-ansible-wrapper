MAKEFLAGS += --silent
TERRAFORM_ANSIBLE=https://github.com/adammck/terraform-inventory/releases/download/v0.7-pre/terraform-inventory_v0.7-pre_linux_amd64.zip
TERRAFORM_BINARY=https://releases.hashicorp.com/terraform/0.11.1/terraform_0.11.1_linux_amd64.zip
TF_STATE=./terraform/openshift-terraform-ansible/ec2/terraform.tfstate

setup: setup-terraform setup-ocp-terraform setup-ansible

setup-terraform:
	wget ${TERRAFORM_ANSIBLE} -O /tmp/terraform.zip && \
	unzip -o /tmp/terraform.zip -d ./terraform/inventory/ && \
	wget ${TERRAFORM_BINARY} -O /tmp/terraform_binary.zip && \
	sudo unzip -o /tmp/terraform_binary.zip -d /usr/local/bin/

setup-ocp-terraform:
	rm -rf ./terraform/openshift-terraform-ansible && \
	git clone https://github.com/mjudeikis/openshift-terraform-ansible.git ./terraform/openshift-terraform-ansible && \
	if [ -a ~/aws/credentials.tfvars ] ; \
	then \
    	cp ~/aws/credentials.tfvars ./terraform/openshift-terraform-ansible/ec2/ ; \
        cp ~/aws/config.tfvars ./terraform/openshift-terraform-ansible/ec2/ ; \
		cp ~/aws/all.yml ./group_vars/all.yml ; \
	elif [ -a ~/.aws/credentials.tfvars ] ; \
	then \
        cp ~/.aws/credentials.tfvars ./terraform/openshift-terraform-ansible/ec2/ ; \
        cp ~/.aws/config.tfvars ./terraform/openshift-terraform-ansible/ec2/ ; \
		cp ~/.aws/all.yml ./group_vars/all.yml ; \
	fi; \
	

setup-ansible:
	ansible-galaxy install -r roles/requirements.yml -c && \
	rm -rf ./openshift-ansible && \
	git clone https://github.com/openshift/openshift-ansible.git -b release-3.11
terraform-aws-plan:
	cd terraform/openshift-terraform-ansible/ec2 && \
	make plan

terraform-aws-apply:
	cd terraform/openshift-terraform-ansible/ec2 && \
	make apply

terraform-ansible-print:
	./terraform/inventory/terraform-inventory --list ${TF_STATE} | python -m json.tool

terraform-ansible-test:
	echo "Masters" && \
	TF_STATE=${TF_STATE} ansible role_masters -i ./terraform/terraform-inventory -a hostname && \
	echo "Nodes" && \
	TF_STATE=${TF_STATE} ansible role_nodes -i ./terraform/terraform-inventory -a hostname && \
	echo "GlusterFS" && \
	TF_STATE=${TF_STATE} ansible role_glusterfs -i ./terraform/terraform-inventory -a hostname

terraform-ansible-install-bastion:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/install-bastion.yml

terraform-ansible-install-pre:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/ocp-install-pre.yml

terraform-ansible-install:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/ocp-install.yml

terraform-ansible-adhoc:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/adhoc.yml -v

terraform-ansible-pre:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/ocp-pre.yml

terraform-ansible-post:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/ocp-post.yml

terraform-ansible-uninstall:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/ocp-uninstall.yml

terraform-ansible-install-glusterfs:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/ocp-install-glusterfs.yml

terraform-ansible-install-glusterfs-block:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/ocp-install-glusterfs-block.yml

terraform-ansible-install-hosted:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/ocp-install-hosted.yml

terraform-ansible-install-metrics:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/ocp-install-metrics.yml

terraform-ansible-install-logging:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/ocp-install-logging.yml

terraform-ansible-install-prometheus:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/ocp-install-prometheus.yml

terraform-ansible-uninstall-prometheus:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/ocp-uninstall-prometheus.yml

terraform-ansible-install-grafana:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/ocp-install-grafana.yml

terraform-ansible-scaleup-etcd:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/ocp-etcd-scaleup.yml

terraform-ansible-check-prerequisites:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/ocp-check-prerequisites.yml

terraform-ansible-restart-docker:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/adhoc-restart-docker.yml

terraform-ansible-restart-masterproc:
	TF_STATE=${TF_STATE} ansible-playbook --inventory-file=./terraform/inventory/ playbooks/adhoc-restart-master-proc.yml

