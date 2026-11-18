# -----------------------------------------------------------------------------
# terraform.tfvars : valeurs des variables (fichier versionné)
# -----------------------------------------------------------------------------
# Chargé automatiquement par plan et apply. Valeurs NON sensibles uniquement.
# alert_emails n'est volontairement PAS ici : fournie par la variable
# d'environnement TF_VAR_alert_emails, pour qu'aucune adresse ne soit publiée.

bloc              = "b1"
location          = "francecentral"
monthly_budget    = 40
budget_start_date = "2026-11-01T00:00:00Z"
