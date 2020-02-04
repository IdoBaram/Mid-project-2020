# Mid-project-2020
 

How to fully execute:
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




