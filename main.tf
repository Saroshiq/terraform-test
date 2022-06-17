data "github_team" "existing_team" {
  count = (var.teams[0] == "" ? 0 : length(var.teams))
  slug  = var.teams[count.index]
}

data "github_team" "approval_team" {
  count = (var.approvals[0] == "" ? 0 : length(var.approvals))
  slug  = var.approvals[count.index]
}

resource "github_repository" "users_repos" {
  name                   = var.repo_name
  description            = var.repo_desc
  auto_init              = "true"
  visibility             = var.visibility
  has_issues             = true
  has_projects           = true
  has_downloads          = true
  has_wiki               = true
  delete_branch_on_merge = true
  topics                 = (var.topics[0] == "" ? [] : var.topics)
}

resource "github_team_repository" "teams_repo" {
  count      = (var.teams[0] == "" ? 0 : length(var.teams))
  team_id    = data.github_team.existing_team[count.index].id
  repository = var.repo_name
  permission = var.teams_perm[count.index]
  depends_on = [github_repository.users_repos]
}

resource "github_team_repository" "approvals_repo" {
  count      = (var.approvals[0] == "" ? 0 : length(var.approvals))
  team_id    = data.github_team.approval_team[count.index].id
  repository = var.repo_name
  permission = "push"
  depends_on = [github_repository.users_repos]
}

resource "github_repository_collaborator" "repo_collab" {
  count      = (var.collab[0] == "" ? 0 : length(var.collab))
  repository = var.repo_name
  username   = var.collab[count.index]
  permission = var.collab_perm[count.index]
  depends_on = [github_repository.users_repos]
}