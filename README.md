# Udacity Cloud DevOps Engineer Nanodegree - Capstone Project

## Project Overview

In this project, I have applied the skills and knowledge acquired throughout the Cloud DevOps Nanodegree program, such
as:

- Working with AWS
- Using Jenkins to implement CI/CD pipelines
- Building Docker containers
- Deploying Kubernetes clusters with CloudFormation

The project consists of a rather simple containerized Nginx application that is deployed to an AWS EKS cluster. All the
required steps are automated through a Jenkins pipeline, that is triggered as soon as new commits are pushed to the
remote GitHub repository.

## Jenkins Server Setup

Jenkins setup on AWS EC2 is partially automated via a CloudFormation script, that can be run with `make jenkins-create`.
Before running the script, the file `cloudformation/jenkins-setup-params.json` must be created and filled with the
required information (`cloudformation/jenkins-setup-params.json.template` is available as a template).

After the stack creation has terminated with success, the installation procedure must be completed through the Jenkins
GUI. Login to Jenkins, using the URL listed among the outputs of the CloudFormation script, follow the setup
instructions (in particular, install recommended plugins and create an admin user) and install the following plugins:

- Blue Ocean
- GitHub API (version `1.115`, available [here](http://updates.jenkins-ci.org/download/plugins/github-api/))
- Pipeline: AWS Steps

The following plugins should be automatically installed together with the previous ones:

- Blue Ocean Pipeline Editor
- Blue Ocean Executor Info
- Config API for Blue Ocean
- Display URL for Blue Ocean
- Events API for Blue Ocean
- Git Pipeline for Blue Ocean
- GitHub Pipeline for Blue Ocean
- Pipeline Implementation for Blue Ocean

After Jenkins has restarted, navigate to `/credentials/store/system/domain/_/` and add the following credentials (making
sure to associate them to a **global scope** and not only to the scope of your admin user profile):

| ID                       | Description                      |
| ------------------------ | -------------------------------- |
| `docker-hub-credentials` | Docker Hub username and password |

Then, switch to Blue Ocean interface and create a new pipeline associated to the remote GitHub repository. At this
stage, you will be prompted to create a GitHub Access Token, to be provided to Jenkins in order to interact with the
repository. It can be useful to set to a low value (e.g., 1 minute) the time period after which Jenkins checks the
repository for new pushed commits (clicking on the gear icon will bring you to the standard pipeline settings
interface).

If you experience `HTTP 403` errors very often, consider navigating to `/configureSecurity/` and check "Enable proxy
compatibility", under "CSRF Protection" section. **WARNING: this setting may increase Jenkins server vulnerability**.

## AWS EKS Cluster Setup

Run `make eks-cluster-cfn-create` to deploy an AWS EKS cluster (in `us-east-2` region) with CloudFormation. The same
result can be achieved by running `make eks-cluster-create` that leverages on [`eksctl`](https://eksctl.io/).

If the EKS cluster has not been created from the EC2 instance used to deploy the Jenkins server, which is set to assume
the `Jenkins` IAM Role to get the required permissions, an additional procedure must be performed to allow the Jenkins
pipeline for deploying the application on the EKS cluster (described in details
[here](https://aws.amazon.com/premiumsupport/knowledge-center/eks-api-server-unauthorized-error/)):

1. From AWS console, fetch the ARN of `Jenkins` IAM Role.
2. With the credentials used to create the EKS cluster, run `kubectl edit configmap aws-auth -n kube-system` and add the
   following lines to the ConfigMap:

   ```bash
   mapRoles: |
     - rolearn: <Jenkins IAM Role ARN>
       username: Jenkins
       groups:
         - system:masters
   ```

3. From the Jenkins server, run

   ```bash
   aws eks update-kubeconfig --name cloud-devops-capstone-cluster --region us-east-2
   ```

   or, equivalently, `make kubectl-config` (that should be also automatically run by the Jenkins pipeline).

## Linting

Run `make lint` (or `make lint-dockerized`, if you do not have `hadolint` installed in your local environment) to lint
application source code and `Dockerfile`. The same linting steps will be also automatically run by Jenkins.

In addition, you can also run `make lint-cloudformation` to lint CloudFormation scripts in `cloudformation/` with
[`cfn-lint`](https://github.com/aws-cloudformation/cfn-python-lint).

## Docker

Run `make docker-build` to build the containerized Nginx application and `make docker-push` to upload it on Docker Hub.
The same steps will be also automatically run by Jenkins.

In addition, you can also run `make docker-run` to start the web app on your local environment (available at
`localhost:80`) and `make docker-stop` to stop it. Run `make docker-clean` to reclaim disk space.

## Deploy on AWS EKS

In order to deploy the application on AWS EKS, run

```bash
make kubectl-config
make kubectl-switch-context
make deploy
```

The above commands will, respectively, fetch the Kubernetes configurations of the AWS EKS cluster, switch the context of
your local environment so that you can interact with it and deploy the application on it. The same steps will be also
automatically run by Jenkins.

## Clean Up

In order to delete all the resources deployed in this project, run

```bash
make decommission
make jenkins-delete
make eks-cluster-cfn-delete
```

If you prefer using `eksctl`, the last command can be alternatively run as `make eks-cluster-delete`.
