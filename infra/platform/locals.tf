# -----------------------------------------------------------------------------
# locals.tf : valeurs calculées, réutilisées dans plusieurs ressources
# -----------------------------------------------------------------------------
# Différence avec une variable : un local ne se règle pas de l'extérieur.
# Il sert à calculer une valeur une seule fois (on s'y réfère par local.<nom>).

locals {
  # Abréviation de la région pour les noms (convention <type>-<projet>-<rôle>-<région>).
  # La map associe chaque région autorisée (voir validation de var.location) à son code.
  location_short = {
    francecentral = "frc"
    westeurope    = "weu"
    northeurope   = "neu"
  }[var.location]

  # Le bloc de tags commun, posé sur chaque ressource qui accepte des tags.
  # Un seul endroit à modifier pour changer les tags de tout le dossier.
  tags = {
    owner       = "tom"
    project     = "lab-cloudsec"
    bloc        = var.bloc
    cost-center = "lab"
    lifecycle   = "permanent" # la plateforme n'est pas détruite chaque nuit
  }
}
