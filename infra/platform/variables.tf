# -----------------------------------------------------------------------------
# variables.tf : les entrées du code
# -----------------------------------------------------------------------------
# Une variable = un paramètre que l'on peut changer sans toucher au code.
# Chaque variable a :
#   - type        : ce qui est accepté (string, number, list, map, object...) ;
#   - description : affichée par Terraform en cas d'erreur, sert de documentation ;
#   - default     : valeur utilisée si rien n'est fourni (absent = obligatoire) ;
#   - validation  : règle vérifiée AVANT tout appel à Azure (erreur immédiate au plan).
# Les valeurs réelles viennent de terraform.tfvars ou de variables TF_VAR_<nom>.

variable "project" {
  type        = string
  description = "Code court du projet, utilisé dans les noms de ressources (rg-<project>-...)."
  default     = "lab"
}

variable "bloc" {
  type        = string
  description = "Bloc de séances du programme Kestrel (tag bloc) : b1 à b4."

  validation {
    # contains(liste, valeur) renvoie true si la valeur est dans la liste.
    condition     = contains(["b1", "b2", "b3", "b4"], var.bloc)
    error_message = "bloc doit valoir b1, b2, b3 ou b4."
  }
}

variable "location" {
  type        = string
  description = "Région Azure des ressources. France Central par défaut (voir docs/conventions.md)."
  default     = "francecentral"

  validation {
    # Seules les régions qui ont une abréviation dans locals.tf sont acceptées.
    condition     = contains(["francecentral", "westeurope", "northeurope"], var.location)
    error_message = "location doit valoir francecentral, westeurope ou northeurope."
  }
}

variable "monthly_budget" {
  type        = number
  description = "Montant du budget mensuel de l'abonnement, en devise de facturation (EUR)."
  default     = 40

  validation {
    condition     = var.monthly_budget > 0
    error_message = "monthly_budget doit être strictement positif."
  }
}

variable "budget_start_date" {
  type        = string
  description = "Début du budget : premier jour d'un mois, format RFC3339 (ex. 2026-11-01T00:00:00Z)."

  validation {
    # Expression régulière : AAAA-MM-01T00:00:00Z. Azure refuse un autre jour que le 1er.
    # can(...) renvoie false au lieu d'une erreur si regex ne trouve rien.
    condition     = can(regex("^[0-9]{4}-(0[1-9]|1[0-2])-01T00:00:00Z$", var.budget_start_date))
    error_message = "budget_start_date doit être le premier jour d'un mois au format AAAA-MM-01T00:00:00Z."
  }
}

variable "budget_notifications" {
  # map(object(...)) : un dictionnaire dont chaque valeur a la même structure.
  # La clé (ex. "actual_50") sert seulement à identifier le seuil dans le plan.
  type = map(object({
    threshold      = number # pourcentage du budget (50 = 50 %)
    threshold_type = string # "Actual" (dépense réelle) ou "Forecasted" (prévision de fin de mois)
  }))
  description = "Seuils d'alerte du budget, en pourcentage du montant."
  default = {
    actual_50    = { threshold = 50, threshold_type = "Actual" }
    actual_75    = { threshold = 75, threshold_type = "Actual" }
    actual_100   = { threshold = 100, threshold_type = "Actual" }
    forecast_100 = { threshold = 100, threshold_type = "Forecasted" }
  }

  validation {
    # alltrue([...]) : vrai si chaque élément de la liste est vrai.
    # La boucle "for n in ..." parcourt toutes les valeurs de la map.
    condition     = alltrue([for n in values(var.budget_notifications) : contains(["Actual", "Forecasted"], n.threshold_type)])
    error_message = "threshold_type doit valoir Actual ou Forecasted."
  }

  validation {
    condition     = alltrue([for n in values(var.budget_notifications) : n.threshold > 0 && n.threshold <= 1000])
    error_message = "threshold doit être compris entre 0 (exclu) et 1000."
  }
}

variable "alert_emails" {
  type        = list(string)
  description = "Adresses qui reçoivent les alertes de budget. Jamais commitées : fournies par TF_VAR_alert_emails."
  # Pas de valeur par défaut : Terraform refuse de continuer si elle manque.

  # Pas de "sensitive = true" : il masquerait les blocs notification entiers dans
  # le plan (on ne verrait plus les seuils). Une adresse n'est pas un secret : la
  # règle est seulement de ne pas la publier dans le dépôt.

  validation {
    condition     = length(var.alert_emails) > 0 && alltrue([for e in var.alert_emails : can(regex("^[^@ ]+@[^@ ]+\\.[^@ ]+$", e))])
    error_message = "alert_emails doit contenir au moins une adresse e-mail valide."
  }
}
