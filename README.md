# Mid-project-2020

## OpsSchool Mid project 2020 goals:
To create the basic infrastruture for final project, simulate a CI pipline.
Goal is to make the project automatically (as much as possible) and highly available.

## This module uses these tools:

* Ansible
* Terraform
* K8s
* Docker
* Consul
* Jenkins 

## How to fully execute:
* User clones the git repository
* Runs terraform apply –auto-approve
* Connect to Ansible server
* Run command  `ansible-playbook -i hosts docker.yaml`
* Connect to Jenkins:
* Configure the slaves connection
* Add docker hub credentials
* Create pipeline job
	* Execute pipeline job Steps:
	* Clone Git repository
	* Build Docker container
	* Register image to DockerHub
	* Deploy to K8s