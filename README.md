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
#tf commands for setting up the infra
terraform init
terraform plan
terraform validate
terraform apply



Assignment 5:

Added private service access line in subnets.
Enabled service networking API manually in console.
Set up variables in tfvars.
verify the version of the postgres, which was initially tested and now set up.
Set up cloud sql db instance and user setup.
Get the script written for compute instance
CloudSQL instance should not be accessible from the internet. -> IPV4 to be done False


Network Security part:

resource "google_compute_address" "internal_ip" {
  name   = "internal-ip"
  region = "your-region"
}
 And access config block addition

Error: Error, failed to create instance because the network doesn't have at least 1 private services connection. Please see https://cloud.google.com/sql/docs/mysql/private-ip#network_requirements for how to create this connection.

https://github.com/hashicorp/terraform-provider-google/issues/16275

Solution:     #enable_private_path_for_google_cloud_services= true
