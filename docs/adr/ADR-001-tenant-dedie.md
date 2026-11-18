# ADR-001 : Tenant dédié et gouvernance de base

Statut : accepté
Date : 2026-11-18

## Contexte

Lab personnel destiné à monter en compétence sur le cloud Azure, l'IAM, la sécurité et Terraform, avec pour objectif la certification SC-500. Une évolution vers une infrastructure hybride (on-prem sous VMware et Azure) est prévue.

Contraintes : budget de 40 EUR par mois, séparation totale avec l'environnement du travail, structure propre dès le départ pour pouvoir tout reconstruire avec de l'IaC.

## Décision

- Un tenant dédié, créé avec une adresse e-mail dédiée. Le domaine initial `tomlab1outlook.onmicrosoft.com` est conservé.
- Une hiérarchie de groupes d'administration : `mg-lab` avec `mg-platform`, `mg-workloads` et `mg-sandbox`. L'abonnement `sub-kestrel-lab` est placé dans `mg-workloads`.
- Deux comptes brise-glace (`bg-01`, `bg-02`), cloud-only, Administrateur général permanent, authentifiés par passkey Authenticator. Des clés FIDO2 physiques sont prévues.
- Un compte administrateur quotidien (`tom.admin`). Le PIM et les rôles éligibles sont prévus en S06.
- Un budget de 40 EUR avec alertes (50, 75 et 100 % réel, 100 % prévisionnel) et un groupe d'actions.

## Alternatives écartées

- Utiliser le tenant de l'entreprise : écarté pour des raisons de risque, de droits et de séparation.
- Domaine personnalisé : écarté, coût et gain nul pour un lab.
- Compte administrateur unique sans compte brise-glace : écarté, risque de verrouillage du tenant.

## Conséquences

- Isolation complète du tenant de travail et base propre pour les séances suivantes.
- Risque accepté : accès élevé et rôle Propriétaire temporaires à la racine pour l'amorçage, retirés une fois la configuration terminée.
- Dettes à traiter : clés FIDO2 physiques pour les comptes brise-glace, PIM et rôle personnalisé en S06, passage en paiement à l'usage avant S02.
- Le choix des services (PaaS et coûts) fera l'objet d'un ADR distinct.
