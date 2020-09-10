.PHONY: lint create-jenkins update-jenkins delete-jenkins docker-build docker-run docker-stop docker-clean

lint:
	tidy -q -e *.html
	docker run --rm -i hadolint/hadolint < Dockerfile

docker-build:
	docker build -t udacity-cloud-devops-capstone .

docker-run:
	docker run -it --rm -d -p 80:80 --name web udacity-cloud-devops-capstone

docker-stop:
	docker container stop web

docker-clean: docker-stop
	docker image prune -f

create-jenkins:
	aws cloudformation create-stack --stack-name jenkins-server --template-body file://jenkins-setup.yml --parameters file://jenkins-setup-params.json --capabilities CAPABILITY_NAMED_IAM

update-jenkins:
	aws cloudformation update-stack --stack-name jenkins-server --template-body file://jenkins-setup.yml --parameters file://jenkins-setup-params.json --capabilities CAPABILITY_NAMED_IAM

delete-jenkins:
	aws cloudformation delete-stack --stack-name jenkins-server
