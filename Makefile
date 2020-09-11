.PHONY: lint lint-dockerized lint-cloudformation create-jenkins update-jenkins delete-jenkins docker-build docker-run docker-stop docker-clean

lint:
	tidy -q -e src/*.html
	hadolint Dockerfile

lint-dockerized:
	tidy -q -e src/*.html
	docker run --rm -i hadolint/hadolint < Dockerfile

lint-cloudformation:
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

eks-cluster-create:
	eksctl create cluster --name cloud-devops-capstone-cluster --version 1.17 --region us-east-2 --nodegroup-name linux-nodes --node-type t2.medium --nodes 3 --nodes-min 1 --nodes-max 4 --ssh-access --ssh-public-key udacity-capstone-devops --managed

eks-cluster-delete:
	eksctl delete cluster --name cloud-devops-capstone-cluster

eks-cluster-cfn-update:
	aws cloudformation update-stack --stack-name eksctl-cloud-devops-capstone-cluster-cluster --template-body file://cloudformation/eks-cluster.yml --capabilities CAPABILITY_IAM
	aws cloudformation update-stack --stack-name eksctl-cloud-devops-capstone-cluster-nodegroup-linux-nodes --template-body file://cloudformation/eks-node-group.yml --capabilities CAPABILITY_IAM

kubectl-config:
	aws eks --region us-east-2 update-kubeconfig --name cloud-devops-capstone-cluster

kubectl-switch-context:
	kubectl config use-context `aws eks describe-cluster --name cloud-devops-capstone-cluster | python3 -c "import sys, json; print(json.load(sys.stdin)['cluster']['arn'])"`

deploy:
	kubectl apply -f kubernetes/web-app.yml
	@echo
	kubectl get deployments
	@echo
	kubectl rollout restart deployment.v1.apps/udacity-cloud-devops-capstone-deployment
	@echo
	kubectl rollout status deployment.v1.apps/udacity-cloud-devops-capstone-deployment
	@echo
	kubectl get all

decommision:
	kubectl delete -f kubernetes/web-app.yml
	@echo
	kubectl get all

jenkins-create:
	aws cloudformation create-stack --stack-name jenkins-server --template-body file://cloudformation/jenkins-setup.yml --parameters file://cloudformation/jenkins-setup-params.json --capabilities CAPABILITY_NAMED_IAM

jenkins-update:
	aws cloudformation update-stack --stack-name jenkins-server --template-body file://cloudformation/jenkins-setup.yml --parameters file://cloudformation/jenkins-setup-params.json --capabilities CAPABILITY_NAMED_IAM

jenkins-delete:
	aws cloudformation delete-stack --stack-name jenkins-server
