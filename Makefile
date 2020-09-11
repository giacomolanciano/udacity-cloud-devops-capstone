.PHONY: lint lint-dockerized cloudformation-lint create-jenkins update-jenkins delete-jenkins docker-build docker-run docker-stop docker-clean

lint:
	tidy -q -e src/*.html
	hadolint Dockerfile

lint-dockerized:
	tidy -q -e src/*.html
	docker run --rm -i hadolint/hadolint < Dockerfile

cloudformation-lint:
	cfn-lint -i W2509 -- cloudformation/*.yml

docker-build:
	docker build -t udacity-cloud-devops-capstone .

docker-push:
	docker tag udacity-cloud-devops-capstone:latest glanciano/udacity-cloud-devops-capstone:latest
	docker push glanciano/udacity-cloud-devops-capstone:latest

docker-run:
	docker run -it --rm -d -p 80:80 --name web udacity-cloud-devops-capstone

docker-stop:
	docker container stop web

docker-clean:
	docker system prune -f

jenkins-create:
	aws cloudformation create-stack --stack-name jenkins-server --template-body file://jenkins-setup.yml --parameters file://jenkins-setup-params.json --capabilities CAPABILITY_NAMED_IAM

jenkins-update:
	aws cloudformation update-stack --stack-name jenkins-server --template-body file://jenkins-setup.yml --parameters file://jenkins-setup-params.json --capabilities CAPABILITY_NAMED_IAM

jenkins-delete:
	aws cloudformation delete-stack --stack-name jenkins-server
