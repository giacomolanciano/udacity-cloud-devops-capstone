.PHONY: create-jenkins update-jenkins delete-jenkins

create-jenkins:
	aws cloudformation create-stack --stack-name jenkins-server --template-body file://jenkins-setup.yml --parameters file://jenkins-setup-params.json --capabilities CAPABILITY_NAMED_IAM

update-jenkins:
	aws cloudformation update-stack --stack-name jenkins-server --template-body file://jenkins-setup.yml --parameters file://jenkins-setup-params.json --capabilities CAPABILITY_NAMED_IAM

delete-jenkins:
	aws cloudformation delete-stack --stack-name jenkins-server
