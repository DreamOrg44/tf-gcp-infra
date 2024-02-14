# tf-gcp-infra


gcloud projects create csye-6225-cloud;
./google-cloud-sdk/bin/gcloud init
gcloud auth login
gcloud auth application-default login

Credentials saved to file: ["Path_To_The_File"]


Terraform:
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

terraform -v

#manually configure and enable the below apis in the console
Gcloud console-> Apis and services-> library-> compute engine, IAM enable.

#set up .tf file for all theinfra resources and once done run the below commands to verify if correct infra is getting created.
Add content to main.tf file like region,project name and subnet vpc details
#tf commands
terraform init
terraform plan
terraform validate
terraform apply

