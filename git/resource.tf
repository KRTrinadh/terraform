#create repo - example
resource "github_repository" "example" {
  name        = "example"
  description = "My awesome codebase"
  has_wiki    = "true"
}


#creating team - example-team
resource "github_team" "own-team" {
  name        = "example-team"
  description = "My new team for use with Terraform"
  privacy     = "closed"
}


#create user(chida) for team in organization
resource "github_team_membership" "own-team-membership" {
  team_id  = "${github_team.own-team.id}"
  username = "chida"
  role     = "member"
}


#create user in organization 
resource "github_membership" "membership_for_some_user" {
  username = "chida"
  role     = "member"
}

