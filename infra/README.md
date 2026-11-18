# infra/

Une racine Terraform = un dossier avec son propre backend (un fichier de state par dossier).

| Dossier | State | Contenu |
|---|---|---|
| platform/ | platform.tfstate | Groupe de ressources, Log Analytics, budget de l'abonnement (S02) |

Fichiers d'une racine :

    versions.tf    (versions + backend)   providers.tf    variables.tf
    locals.tf      main.tf                budget.tf       outputs.tf
    terraform.tfvars (valeurs non sensibles)   .terraform.lock.hcl (commite)
