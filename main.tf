# Create the Terraform Cloud Organization
resource "tfe_organization" "technicloud" {
  name  = "technicloud"
  email = "rebecca@technicloud.com"
}

# Create the Technicloud Workspace
resource "tfe_workspace" "technicloud-wordpress" {
  name         = "technicloud-wordpress"
  organization = tfe_organization.technicloud.id
}

# Add Web Dev Team
resource "tfe_team" "web-dev" {
  name = "technicloud-web-dev"
  organization = tfe_organization.technicloud.id
}

# Add User to Web Dev Team
resource "tfe_team_member" "user1" {
  team_id  = tfe_team.web-dev.id
  username = "rfitzhugh"
}

resource "tfe_team_access" "test" {
  access       = "plan"
  team_id      = tfe_team.web-dev.id
  workspace_id = tfe_workspace.technicloud-wordpress.id
}