# -----------------------------------------------------------------------------
# outputs.tf : valeurs affichées après l'apply
# -----------------------------------------------------------------------------
# Une sortie s'affiche à la fin de "terraform apply" et se relit avec
# "terraform output". Elle pourra aussi être lue par d'autres dossiers Terraform
# (ex. envoyer des journaux vers cet espace Log Analytics).

output "resource_group_name" {
  description = "Nom du groupe de ressources de la plateforme."
  value       = azurerm_resource_group.platform.name
}

output "log_analytics_workspace_id" {
  description = "ID Azure complet de l'espace Log Analytics (cible des paramètres de diagnostic)."
  value       = azurerm_log_analytics_workspace.platform.id
}
