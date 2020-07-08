# Configure the Terraform Cloud (Enterprise) Provider
provider "tfe" {
  hostname = "app.terraform.io"
  token    = var.token
  version  = "~> 0.15.0"
}