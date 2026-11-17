# lab-cloudsec : Kestrel Lab

Lab personnel d'architecture hybride on-prem / Azure sécurisée, construit séance par séance
pour préparer **SC-500** (Cloud and AI Security Engineer) et le métier d'ingénieur sécurité cloud.

Entreprise fictive : **Kestrel Immobilier**, un SI on-prem (AD, firewall) qui migre vers Azure.

## Principes
- Infrastructure 100 % en Terraform, déployée par GitHub Actions avec OIDC (aucun secret stocké).
- Chaque contrôle de sécurité est justifié (ADR) puis vérifié (critères de réussite).
- Garde-fous de coût : budget, plafond de logs, destruction nocturne des ressources éphémères.

## Arborescence
| Dossier | Contenu |
|---|---|
| infra/ | Code Terraform de l'infra (écrit séance par séance) |
| identity/ | Configuration Entra exportée (accès conditionnel, méthodes d'auth) |
| iam/ | Racine Terraform séparée pour les rôles (appliquée à la main sous PIM) |
| detections/ | Requêtes de chasse et règles de détection |
| scripts/ | Scripts ponctuels (bootstrap, on-prem, Python) |
| docs/ | Conventions, ADR, registre des risques, journal des séances |
| .github/workflows/ | Pipelines |

## Avertissement
Lab personnel. Aucune donnée, configuration ou identifiant d'une organisation réelle.
