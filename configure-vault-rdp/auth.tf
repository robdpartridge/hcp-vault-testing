#------------------------------------------------------------
# Enable userpass auth method in the 'admin/test' namespace
#------------------------------------------------------------
resource "vault_auth_backend" "cloud_userpass" {
  depends_on = [vault_namespace.cloud]
  provider = vault.cloud
  type = "userpass"
}

#-----------------------------------------------------------
# Create a user named 'student' with password, 'changeme'
#-----------------------------------------------------------
resource "vault_generic_endpoint" "pdev_admon" {
  depends_on           = [vault_auth_backend.cloud_userpass]
  provider = vault.cloud
  path                 = "auth/userpass/users/pdev_admon"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["changeme-policies"],
  "password": "changeme"
}
EOT
}

# -----------------------------------------------------------
# Create a gcp auth method and role
# -----------------------------------------------------------

## do not use yet try vault_gcp_auth_backend first
# resource "vault_auth_backend" "gcp" {
#    path = "gcp"
#    type = "gcp"
# }

# resource "vault_gcp_auth_backend" "cloud_gcpauth" {
#     provider = vault.cloud
#     depends_on = [vault_namespace.cloud]
#     credentials  = file("vault-gcp-credentials.json")
#     path = "gcp"
#     description = "gcp mount created by tf"
# }

# resource "vault_gcp_auth_backend_role" "cloud_gcpauth_role1" {
#     provider = vault.cloud
#     depends_on = [vault_namespace.cloud]
#     backend                = vault_gcp_auth_backend.cloud_gcpauth.path
#     project_id             = "changeme-project-id"
#     bound_service_accounts = ["pdevbuild@changeme-project-id.iam.gserviceaccount.com"]
#     token_policies         = ["pdevbuild"]
# }

#-----------------------------------------------------------
# Create a github auth backend
#-----------------------------------------------------------

#resource "vault_auth_backend" "github" {
#    path = "github"
#    type = "github"
#}

resource "vault_github_auth_backend" "cloud" {
    provider = vault.cloud
    depends_on = [vault_namespace.cloud]
  organization = "teampartridge"
  description = "Manages the github auth backed"
  token_type       = "service"
  #default_lease_ttl = "600s"
  #max_lease_ttl = "3600s"
}

#These arguments are common across several Authentication Token resources since Vault 1.2.
#token_ttl - (Optional) The incremental lifetime for generated tokens in number of seconds. Its current value will be referenced at renewal time.
#token_max_ttl - (Optional) The maximum lifetime for generated tokens in number of seconds. Its current value will be referenced at renewal time.
#token_period - (Optional) If set, indicates that the token generated using this role should never expire. The token should be renewed within the duration specified by this value. At each renewal, the token's TTL will be set to the value of this field. Specified in seconds.
#token_policies - (Optional) List of policies to encode onto generated tokens. Depending on the auth method, this list may be supplemented by user/group/other values.
#token_bound_cidrs - (Optional) List of CIDR blocks; if set, specifies blocks of IP addresses which can authenticate successfully, and ties the resulting token to these blocks as well.
#token_explicit_max_ttl - (Optional) If set, will encode an explicit max TTL onto the token in number of seconds. This is a hard cap even if token_ttl and token_max_ttl would otherwise allow a renewal.
#token_no_default_policy - (Optional) If set, the default policy will not be set on generated tokens; otherwise it will be added to the policies set in token_policies.
#token_num_uses - (Optional) The maximum number of times a generated token may be used (within its lifetime); 0 means unlimited.
#token_type - (Optional) The type of token that should be generated. Can be service, batch, or default to use the mount's tuned default (which unless changed will be service tokens). For token store roles, there are two additional possibilities: default-service
# and default-batch which specify the type to return unless the client requests a different type at generation time.


resource "vault_github_team" "pdev_github_builder_team" {
    provider = vault.cloud
  backend  = vault_github_auth_backend.cloud.id
  team     = "pdev_github_builder_team"
  policies = ["developer", "read-only"]
}

resource "vault_github_user" "pdev_github_builder_user" {
  provider = vault.cloud
  backend  = vault_github_auth_backend.cloud.id
  user     = "robdpartridge"
  policies = ["developer", "read-only"]
}

#-----------------------------------------------------------
# Create an approle auth backend
#-----------------------------------------------------------


resource "vault_auth_backend" "cloud_approle" {
  depends_on = [vault_namespace.cloud]
  provider = vault.cloud
  type = "approle"
}

resource "vault_approle_auth_backend_role" "cloud_approle_testrole" {
  provider = vault.cloud
  backend        = vault_auth_backend.cloud_approle.path
  role_name      = "testrole"
  token_policies = ["default", "dev", "prod"]
}


#-----------------------------------------------------------
# Create an jwt and oidc auth backend
#-----------------------------------------------------------

#jwt
resource "vault_jwt_auth_backend" "cloud_jwtauth" {
    provider = vault.cloud
    depends_on = [vault_namespace.cloud]
    description         = "Demonstration of the Terraform JWT auth backend"
    path                = "jwt"
    oidc_discovery_url  = "https://myco.auth0.com/"
    bound_issuer        = "https://myco.auth0.com/"
}

#oidc
resource "vault_jwt_auth_backend" "cloud_oidcauth" {
    provider = vault.cloud
    depends_on = [vault_namespace.cloud]
    description         = "Demonstration of the Terraform OIDC auth backend"
    path                = "oidc"
    type                = "oidc"
    oidc_discovery_url  = "https://myco.auth0.com/"
    oidc_client_id      = "1234567890"
    oidc_client_secret  = "secret123456"
    bound_issuer        = "https://myco.auth0.com/"
    tune {
        listing_visibility = "unauth"
    }
}

#with provider config
# resource "vault_jwt_auth_backend" "cloud_oidcgsuiteauth" {
#    provider = vault.cloud
#    depends_on = [vault_namespace.cloud]
#     description = "OIDC backend"
#     oidc_discovery_url = "https://accounts.google.com"
#     path = "oidc"
#     type = "oidc"
#     provider_config = {
#         provider = "gsuite"
#         fetch_groups = true
#         fetch_user_info = true
#         groups_recurse_max_depth = 1
#     }
# }

