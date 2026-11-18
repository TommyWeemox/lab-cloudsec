# -----------------------------------------------------------------------------
# budget.tf : budget mensuel de l'abonnement, géré par Terraform
# -----------------------------------------------------------------------------
# Remplace le budget créé à la main en S01 (à supprimer dans le portail ensuite).

# "data" = source de données : Terraform LIT un objet existant sans le gérer.
# Ici : l'abonnement courant (celui de ARM_SUBSCRIPTION_ID). Rien n'est écrit en dur.
data "azurerm_subscription" "current" {}

resource "azurerm_consumption_budget_subscription" "monthly" {
  name = "budget-${var.project}-monthly"

  # .id renvoie "/subscriptions/<guid>", le format attendu par azurerm 4.x.
  subscription_id = data.azurerm_subscription.current.id

  amount     = var.monthly_budget
  time_grain = "Monthly" # le compteur repart à zéro chaque mois

  time_period {
    start_date = var.budget_start_date
    # end_date absent : Azure fixe une fin lointaine (environ 10 ans).
  }

  # Bloc "dynamic" : génère un bloc notification par entrée de la map
  # var.budget_notifications (4 par défaut). Ajouter un seuil = ajouter une ligne
  # dans la variable, sans copier-coller de bloc ici.
  dynamic "notification" {
    for_each = var.budget_notifications

    # Dans "content", notification.value désigne l'entrée en cours de la boucle.
    content {
      enabled        = true
      threshold      = notification.value.threshold
      threshold_type = notification.value.threshold_type
      operator       = "GreaterThanOrEqualTo" # alerte dès que le seuil est atteint
      contact_emails = var.alert_emails
    }
  }
}
