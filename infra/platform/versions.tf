# -----------------------------------------------------------------------------
# versions.tf : versions exigées et emplacement du state
# -----------------------------------------------------------------------------
# Ce fichier est lu en premier par "terraform init". Il dit :
#   1. quelle version de Terraform est acceptée ;
#   2. quels fournisseurs (providers) télécharger, et dans quelle version ;
#   3. où stocker le state (le fichier qui mémorise ce qui a été déployé).

terraform {
  # Refuse de tourner avec un Terraform plus ancien que 1.9.
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm" # registre officiel : registry.terraform.io/hashicorp/azurerm
      # "~> 4.0" = toute version 4.x, jamais 5.0 (une version majeure peut casser le code).
      # La version exacte retenue est notée dans .terraform.lock.hcl, qui est commité.
      version = "~> 4.0"
    }
  }

  # Backend distant : le state est stocké dans le compte créé par
  # scripts/azure/bootstrap-state.ps1, et non sur le disque local.
  # Un bloc backend n'accepte PAS de variables : les valeurs sont écrites en dur.
  # Aucune n'est secrète (le nom du compte contient 6 caractères de l'ID
  # d'abonnement, ce qui n'est pas une donnée sensible).
  backend "azurerm" {
    resource_group_name  = "rg-lab-tfstate-frc"
    storage_account_name = "stlabtfstate7242f4"
    container_name       = "tfstate"
    key                  = "platform.tfstate" # nom du blob : un fichier de state par racine Terraform

    # Authentification par identité Entra (celle de "az login") au lieu de la clé
    # du compte. Obligatoire ici : la clé partagée est désactivée sur le compte.
    # Il faut donc le rôle "Storage Blob Data Contributor" sur le compte.
    use_azuread_auth = true
  }
}
