# tf-gcp-infra


gcloud projects create csye-6225-cloud;
./google-cloud-sdk/bin/gcloud init
gcloud auth login
gcloud auth application-default login

Credentials saved to file: [/Users/rushikeshdeore/.config/gcloud/application_default_credentials.json]


Terraform:
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

terraform -v



Gcloud console-> Apis and services-> library-> compute engine, IAM enable.


Add content to main.tf file like region,project name and subnet vpc details
terraform init
terraform plan
terraform validate
terraform apply

