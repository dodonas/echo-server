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

## Set Environment Variables

Before you start, set the following environment variables:

- `OUTPUT_PORT`: The port on your local machine where the Docker container will be accessible.
- `INPUT_PORT`: The port inside the Docker container that your application is listening on.
- `ENVIRONMENT_VARIABLE_VALUE`: The value of the environment variable.
- `REGION`: The AWS region where your resources are located.
- `RELEASE_NAME`: The name of your Helm release.
- `$IMAGE_NAME`: The name of your Docker image.

bash:
```bash
export OUTPUT_PORT=5000
export INPUT_PORT=5000
export ENVIRONMENT_VARIABLE_VALUE=development
export REGION=us-west-2
export RELEASE_NAME=echo-server-test
export IMAGE_NAME=echo-server
```
cmd:
```cmd
REM Windows
set OUTPUT_PORT=5000
set INPUT_PORT=5000
set ENVIRONMENT_VARIABLE_VALUE=development
set REGION=us-west-2
set RELEASE_NAME=echo-server-test
set IMAGE_NAME=echo-server
```

### Configure AWS CLI from the terminal
The description below assumes that the user has the necessary tokens and permissions to access the AWS account.

```bash
aws configure
```
When prompted, enter:

* AWS Access Key
* AWS Secret Access Key
* Region ($REGION)
* Output format

### Get your AWS account ID `$AWS_ACCOUNT_ID`
Unix-based:
```
export AWS_ACCOUNT_ID = aws sts get-caller-identity --query "Account" --output text
```
Windows:
```
set AWS_ACCOUNT_ID = aws sts get-caller-identity --query "Account" --output text
``` 

## Docker
Build the Docker Image:
```angular2html
docker build -t echo-server .
```
Run the Docker Container Locally:
```angular2html
docker run -p $OUTPUT_PORT:$INPUT_PORT -e ENVIRONMENT=$ENVIRONMENT_VARIABLE_VALUE $IMAGE_NAME
```
Push the Docker Image to AWS ECR:
```angular2html
docker tag $IMAGE_NAME:latest $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_NAME:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_NAME:latest
```

## Terraform
Terraform is used to provision the AWS infrastructure needed for the Echo Server.
Initialize Terraform:
```angular2html
cd terraform
terraform init
```
Plan the Terraform Deployment:
```angular2html
terraform plan
``` 
Apply the Terraform Deployment:
```angular2html
terraform apply
``` 
Destroy the Terraform Deployment:
```angular2html
terraform destroy
```
## Terragrunt
Terragrunt is used to manage the Terraform state files and to apply the Terraform configuration.
Plan the Terragrunt Deployment:
```angular2html
cd terragrunt
terragrunt plan
```
Apply the Terragrunt Deployment:
```angular2html
terragrunt apply
```

## Update `kubectl` Configuration
Ensure `kubectl` is configured to interact with your EKS cluster.
```angular2html
aws eks update-kubeconfig --name echo-server-eks-cluster --region us-west-2
```
## Create Docker Registry Secret
```angular2html
kubectl create secret docker-registry regcred \
  --docker-server=$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region $REGION)
```

## Helm
Deploy the application using Helm.
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
## Access the Application
To access the application, you need the external IP of the LoadBalancer service.
Get the External IP:
```angular2html
kubectl get services
```
Open a web browser and navigate to the external IP address.
```angular2html
http://<external-ip>/index.html
```
### Local development, debugging, and testing

To run the Echo Server locally, you need to activate the virtual environment, install the required Python packages, and run the Flask application.
Create a Virtual Environment:
```angular2html
python -m venv .venv
```
Activate the Virtual Environment:
```angular2html
# Unix-based
source .venv/bin/activate
# Windows
.venv\Scripts\activate
```
Install the Required Python Packages:
```angular2html
pip install Flask requests
```
Run the application:
```angular2html
python app/echo_server.py
```
Locally it will be accessible at [http://localhost:5000/index.html](http://localhost:5000/index.html)



