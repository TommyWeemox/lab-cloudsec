# -----------------------------------------------------------------------------
# main.tf : ressources de la plateforme commune
# -----------------------------------------------------------------------------
# Syntaxe d'une ressource :
#   resource "<type azure>" "<nom local>" { ... }
# Le nom local (ici "platform") n'existe que dans Terraform : on s'y réfère
# par <type>.<nom local>.<attribut>, ex. azurerm_resource_group.platform.name.

# Groupe de ressources qui accueille les services partagés du lab.
resource "azurerm_resource_group" "platform" {
  # Interpolation "${...}" : construit "rg-lab-platform-frc" à partir des variables.
  name     = "rg-${var.project}-platform-${local.location_short}"
  location = var.location
  tags     = local.tags
}

# Espace Log Analytics : point central où arriveront les journaux
# (diagnostics, Defender, Sentinel dans les séances suivantes).
resource "azurerm_log_analytics_workspace" "platform" {
  name = "law-${var.project}-platform-${local.location_short}"

  # Références plutôt que valeurs en dur : Terraform en déduit l'ordre de création
  # (le groupe d'abord, l'espace ensuite) et suit le groupe s'il change.
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location

  # PerGB2018 : paiement au Go ingéré, le seul tarif proposé aux nouveaux espaces.
  sku = "PerGB2018"

  # 30 jours : durée incluse dans le prix d'ingestion (au-delà, rétention facturée).
  retention_in_days = 30

  # Plafond d'ingestion quotidien en Go. Au-delà, la collecte s'arrête jusqu'au
  # lendemain : c'est le garde-fou budgétaire (0,1 Go par jour, quelques centimes).
  daily_quota_gb = 0.1

  # Permet de donner accès aux journaux d'UNE ressource (via le RBAC de cette
  # ressource) sans donner accès à tout l'espace. Mode recommandé.
  allow_resource_only_permissions = true

  tags = local.tags
}
