# Enable kv-v2 secrets engine in the cloud_dev namespace
resource "vault_mount" "cloud_kv2" {
  depends_on = [vault_namespace.cloud]
  provider = vault.cloud
  path = "kv2"
  type = "kv-v2"
}

# Enable kv-v2 secrets engine in the cloud_dev namespace
resource "vault_mount" "cloud_dev_kv2" {
  depends_on = [vault_namespace.cloud_dev]
  provider = vault.cloud_dev
  path = "kv2"
  type = "kv-v2"
}

#-----------------------------------------------------------
# Create a terraform secrets engine, role
#-----------------------------------------------------------
resource "vault_terraform_cloud_secret_backend" "cloud_tfsecret" {
  backend     = "terraform"
  description = "Manages the Terraform Cloud backend"
  token       = "changeme"
  default_lease_ttl_seconds = 600
  max_lease_ttl_seconds = 3600
}

## below is sample code from terraform docs - will need a real subscription to test
# resource "vault_terraform_cloud_secret_role" "cloud_tfsecret_testrole" {
#   backend      = vault_terraform_cloud_secret_backend.cloud_tfsecret.backend
#   name         = "test_role"
#   organization = "example-organization-name"
#   team_id      = "team-ieF4isC..."
# }

#-----------------------------------------------------------
# Create a terraform secrets creds
#-----------------------------------------------------------

#resource "vault_terraform_cloud_secret_creds" "cloud" {
#  backend = vault_terraform_cloud_secret_backend.cloud_tfsecret.backend
#  role    = vault_terraform_cloud_secret_role.cloud_tfsecret_testrole.name
#}
#attributes
#token_id - The public identifier for a specific token. It can be used to look up information about a token or to revoke a token.
#token - The actual token that was generated and can be used with API calls to identify the user of the call.
#organization - The organization associated with the token provided.
#team_id - The team id associated with the token provided.
#lease_id - The lease associated with the token. Only user tokens will have a Vault lease associated with them.



#-----------------------------------------------------------
# Create a gcpkms secrets engine
#-----------------------------------------------------------

resource "vault_mount" "gcpkms" {
    provider = vault.cloud
    depends_on = [vault_namespace.cloud]
  path        = "gcpkms"
  type        = "gcpkms"
  description = "gcpkms engine mount"
}



#resource "vault_generic_endpoint" "gcpkms_config" {
#  provider = vault.cloud
#  depends_on           = [vault_mount.gcpkms]
#  path                 = "gcpkms/config"
#  ignore_absent_fields = true
#  data_json = <<EOT
#{
#  "credentials": "json creds",
##  "scopes": "changeme"
#}
#EOT
#}

#got here
#resource "vault_generic_endpoint" "gcpkms_config" {
#  provider = vault.cloud
#  depends_on           = [vault_mount.gcpkms]
#  path                 = "gcpkms/keys/my-key"
#  ignore_absent_fields = true
#  data_json = <<EOT
#{
#  "key_ring": "changeme",
#  "scopes": "changeme"
#}
#EOT
#}


resource "vault_azure_secret_backend" "cloud_azure" {
  use_microsoft_graph_api = true
  subscription_id         = "11111111-2222-3333-4444-111111111111"
  tenant_id               = "11111111-2222-3333-4444-222222222222"
  client_id               = "11111111-2222-3333-4444-333333333333"
  client_secret           = "12345678901234567890"
  environment             = "AzurePublicCloud"
}

## below is sample code from terraform docs - will need a real subscription to test
# resource "vault_azure_secret_backend_role" "generated_role" {
#   backend                     = vault_azure_secret_backend.cloud_azure.path
#   role                        = "generated_role"
#   ttl                         = 300
#   max_ttl                     = 600

#   azure_roles {
#     role_name = "Reader"
#     scope =  "/subscriptions/${var.azure_subscription_id}/resourceGroups/azure-vault-group"
#   }
# }

# resource "vault_azure_secret_backend_role" "existing_object_id" {
#   backend               = vault_azure_secret_backend.cloud_azure.path
#   role                  = "existing_object_id"
#   application_object_id = "11111111-2222-3333-4444-44444444444"
#   ttl                   = 300
#   max_ttl               = 600
# }