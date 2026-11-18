# -----------------------------------------------------------------------------
# providers.tf : configuration du fournisseur Azure
# -----------------------------------------------------------------------------
# Le provider azurerm traduit le code Terraform en appels à l'API Azure.
#
# Authentification : aucune information ici. Le provider réutilise la session
# "az login" (Azure CLI). Aucun secret n'est donc stocké dans le code.
#
# Abonnement cible : depuis azurerm 4.x, il est OBLIGATOIRE. On ne l'écrit pas
# dans le code (dépôt public) : le provider le lit dans la variable
# d'environnement ARM_SUBSCRIPTION_ID, à définir avant chaque session :
#   $env:ARM_SUBSCRIPTION_ID = az account show --query id -o tsv

provider "azurerm" {
  # Bloc obligatoire, même vide. Il sert à régler des comportements fins
  # (ex. purge des Key Vault à la suppression). Les valeurs par défaut suffisent.
  features {}
}
