# Conventions du lab

Ces règles s'appliquent à tout le dépôt. Elles servent à garder des noms prévisibles,
des coûts maîtrisés et un code propre. Toute exception est notée dans un ADR.

## 1. Nommage des ressources Azure

Schéma : <type>-<projet>-<rôle>-<région>[-<instance>]
Tout en minuscules, mots séparés par des tirets.

Exemples : rg-lab-governance-frc, vnet-lab-hub-frc, kv-lab-core-frc-01, ag-budget-alerts.

| Ressource | Préfixe | Exemple |
|---|---|---|
| Groupe d'administration | mg- | mg-lab, mg-workloads |
| Abonnement | sub- | sub-kestrel-lab |
| Groupe de ressources | rg- | rg-lab-network-frc |
| Réseau virtuel | vnet- | vnet-lab-hub-frc |
| Sous-réseau | snet- | snet-lab-workload-frc |
| Groupe de sécurité réseau | nsg- | nsg-lab-workload-frc |
| Key Vault | kv- | kv-lab-core-frc-01 |
| Compte de stockage | st (sans tiret) | stlabtfstatefrc01 |
| Espace Log Analytics | law- | law-lab-security-frc |
| Groupe d'actions | ag- | ag-budget-alerts |
| Identité managée | id- | id-lab-github-oidc |
| IP publique | pip- | pip-lab-bastion-frc |

Contraintes à retenir :
- Stockage : 3 à 24 caractères, minuscules et chiffres uniquement, nom unique dans tout Azure.
- Key Vault : 3 à 24 caractères, nom unique dans tout Azure.
- Un nom ne se modifie pas après création pour la plupart des ressources : bien le choisir dès le départ.
- Aucune donnée sensible dans un nom (pas de mot de passe, d'identifiant, d'adresse personnelle).

## 2. Région

Région par défaut : France Central (francecentral, abréviation frc).
Raison : données en Europe, faible latence depuis la France, large catalogue de services.
Toute autre région doit être justifiée dans la session concernée.

## 3. Tags obligatoires

Chaque groupe de ressources et chaque ressource qui les accepte portent :

| Tag | Valeurs | Rôle |
|---|---|---|
| owner | tom | Qui est responsable |
| project | lab-cloudsec | Rattachement au projet |
| bloc | b1, b2, b3, b4 | Bloc de séances |
| cost-center | lab | Suivi des coûts |
| lifecycle | permanent ou ephemeral | ephemeral = détruit automatiquement chaque nuit |
| data-class | public, internal, confidential ou restricted | Sensibilité des données portées |

Les tags sont posés par Terraform (locals communs), jamais à la main, sauf pendant
les phases d'exploration manuelle du portail.

## 4. Terraform

- Fichiers : main.tf, variables.tf, outputs.tf, providers.tf, versions.tf par module.
- Noms de ressources et variables en snake_case (ex. azurerm_key_vault.core).
- Versions du fournisseur azurerm et de Terraform figées dans versions.tf.
- Aucun secret en dur : pas de mot de passe, clé ou jeton dans le code ni dans les .tfvars.
- Le state est distant (stockage Azure), chiffré, accès contrôlé : il est traité comme un secret.
- terraform fmt et terraform validate avant chaque commit ; plan relu avant apply.
- Un module ou dossier par thème (réseau, identité, supervision).

## 5. Principes de sécurité par défaut

- Moindre privilège : rôles RBAC les plus étroits, à la portée la plus basse possible.
- Pas de clés ni de mots de passe quand une identité managée ou l'OIDC est possible.
- Accès public désactivé par défaut (stockage, Key Vault, bases) ; ouvert seulement avec justification.
- Journaux de diagnostic activés sur les ressources sensibles, envoyés vers Log Analytics.
- Chiffrement en transit (TLS 1.2 minimum) et au repos.
- Rôles élevés temporaires seulement (accès élevé, Propriétaire), retirés après usage.

## 6. Coûts

- Budget mensuel de 40 EUR, avec alertes à 50, 75, 90 et 100 % (réel) et 100 % (prévisionnel).
- Les ressources coûteuses (VM, firewall, Bastion, passerelle VPN) vont dans des groupes de
  ressources lifecycle = ephemeral, détruits chaque nuit.
- Vérification du suivi des coûts à la fin de chaque séance.


## 7. Ce qui n'entre jamais dans le dépôt

Secrets, clés privées, jetons, fichiers .tfstate, .tfvars contenant des valeurs sensibles,
bases de mots de passe (.kdbx), corrigés des séances, données personnelles.
Le dépôt est public : gitleaks (pre-commit) et le secret scanning de GitHub sont des filets
de sécurité, pas des autorisations.

## 8. Git

- Aucun push direct sur main (règle imposée par un ruleset GitHub).
- Cycle de travail : git pull sur main, nouvelle branche, commits, push de la branche,
  pull request, merge, suppression de la branche.
- Branches : sNN-sujet (ex. s02-backend-state).
- Commits : "SNN : action à l'infinitif ou au présent" (ex. "S02 : ajouter le backend Terraform").
- Un commit = une modification cohérente et relisible.

## 9. Documentation

- Une décision d'architecture = un ADR numéroté dans docs/adr/.
- Un journal par séance dans docs/sessions/ (fait, appris, bloqué, coût).
- Les risques sont suivis dans docs/risques.md.
