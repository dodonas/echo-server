# Echo Server

This README references the steps to deploy the Echo Server on AWS using Terraform, Terragrunt, Helm, and Docker.

NOTE: It's been a while since I've worked with AWS, Terraform, and Helm, so I had to do some research to refresh my memory.  
I've tried to provide as much detail as possible, but I may have missed some steps.  
The guide is intended to be a high-level overview of the process.  
It's so detailed also because of my own learning process.


## Prerequisites

- Python 3.11
- Docker
- Helm
- Terraform
- Terragrunt
- AWS CLI

## Variables

Before you start, set the following environment variables:

- `OUTPUT_PORT`: The port on your local machine where the Docker container will be accessible.
- `INPUT_PORT`: The port inside the Docker container that your application is listening on.
- `ENVIRONMENT_VARIABLE_VALUE`: The value of the environment variable.
- `REGION`: The AWS region where your resources are located.
- `RELEASE_NAME`: The name of your Helm release.
- `$IMAGE_NAME`: The name of your Docker image.

You can set these environment variables in your terminal session using the  
`export` command (on Unix-based systems)  
or the  
`set` command (on Windows)  
For example:

```bash
export OUTPUT_PORT=5000
export INPUT_PORT=5000
export ENVIRONMENT_VARIABLE_VALUE=development
export REGION=us-west-2
export RELEASE_NAME=echo-server-test
export IMAGE_NAME=echo-server
```


## Setup

### Configure AWS CLI from the terminal
The description below assumes that the user has the necessary tokens and permissions to access the AWS account.


```bash
aws configure
```
When prompted, enter:

* AWS Access Key
* AWS Secret Access Key
* Region `<region>`
* Output format

### Get your AWS account ID `AWS_ACCOUNT_ID`
Unix-based:
```
export AWS_ACCOUNT_ID = aws sts get-caller-identity --query "Account" --output text
```
Windows:
```
set AWS_ACCOUNT_ID = aws sts get-caller-identity --query "Account" --output text
``` 

## Docker
The following commands will build the Docker image,tag it, and push it to the AWS ECR repository.
```angular2html
docker build -t echo-server .
```
To execute the Docker container on your local machine, run the command below:
```angular2html
docker run -p $OUTPUT_PORT:$INPUT_PORT -e ENVIRONMENT=$ENVIRONMENT_VARIABLE_VALUE $IMAGE_NAME
```

To push the Docker image to the AWS ECR repository, use the following commands:
```angular2html
docker tag $IMAGE_NAME:latest $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_NAME:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_NAME:latest
```

## Helm
```angular2html
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
kubectl create secret docker-registry regcred --docker-server=$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com --docker-username=AWS --docker-password=$(aws ecr get-login-password --region $REGION)
```
From root directory, run the following commands to deploy the Helm chart:
```angular2html
helm install $RELEASE_NAME ./helm-chart
```
To check the status of the deployment, run the following command:
```angular2html
kubectl get all
```

## Terraform
Terraform is used to provision the AWS infrastructure needed for the Echo Server  
The following commands will initialize and download the necessary plugins for Terraform.
```angular2html
cd terraform
terraform init
```
To investigate the changes that Terraform will make to the infrastructure, run the following command:
```angular2html
terraform plan
``` 
To apply the changes, run the following command:
```angular2html
terraform apply
``` 
To destroy the infrastructure, run the following command:
```angular2html
terraform destroy
```
## Terragrunt
Terragrunt is used to manage the Terraform state files and to apply the Terraform configuration.
Preview the changes that Terragrunt will make to the infrastructure:
```angular2html
cd terragrunt
terragrunt plan
```
Apply the changes:
```angular2html
terragrunt apply
```



### Local development, debugging, and testing

In order to run the Echo Server locally, you need to activate the virtual environment,  
install the required Python packages ,and run the Flask application.
```angular2html
python -m venv .venv
.\.venv\Scripts\activate
pip install Flask geoip2
python app\echo_server.py
```

Locally it will be accessible at `http://localhost:5000/index.html`



