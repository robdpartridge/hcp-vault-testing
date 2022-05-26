#------------------------------------------------------------------------------
# The best practice is to use remote state file and encrypt it since your
# state files may contains sensitive data (secrets).
#------------------------------------------------------------------------------
# terraform {
#       backend "s3" {
#             bucket = "remote-terraform-state-dev"
#             encrypt = true
#             key = "terraform.tfstate"
#             region = "us-east-1"
#       }
# }


#------------------------------------------------------------------------------
# To leverage more than one namespace, define a vault provider per namespace
#
#   admin
#    ├── education
#    │   └── training
#    │       └── boundary
#    └── test
#------------------------------------------------------------------------------

provider "vault" {
  alias = "admin"
  namespace = "admin"
}

#--------------------------------------
# RP Create 'top-level' namespaces
#--------------------------------------
resource "vault_namespace" "lbg" {
  provider = vault.admin
  path = "lbg"
}

resource "vault_namespace" "gcp" {
  provider = vault.admin
  path = "gcp"
}

resource "vault_namespace" "cloud" {
  provider = vault.admin
  path = "cloud"
}
provider "vault" {
  alias = "cloud"
  namespace = "admin/cloud"
}
#--------------------------------------
# Create 'admin/cloud/dev' namespace
#--------------------------------------

resource "vault_namespace" "cloud_dev" {
  depends_on = [vault_namespace.cloud]
  provider = vault.cloud
  path = "dev"
}

provider "vault" {
  alias = "cloud_dev"
  namespace = "admin/cloud/dev"
}



