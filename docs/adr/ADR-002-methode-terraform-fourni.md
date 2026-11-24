# ADR-002 : Terraform fourni et lancé en local, priorité à la SC-500

- Statut : accepté
- Date : 2026-11-23
- Séance : S05 (s'applique à S03, S04, S06 et aux labs à partir de S07)

## Contexte
La roadmap v3.0 prévoyait pour chaque séance une partie B où je reconstruis la brique en
Terraform à partir d'exigences, un déploiement par pipeline GitHub Actions avec OIDC, et
la destruction chaque nuit, par un workflow, des ressources taguées lifecycle=ephemeral.

Avec environ 3 h par semaine et l'examen SC-500 la semaine du 14 juin 2027, ce rythme ne
tient pas. L'examen évalue la sécurité des services Azure à travers le portail et les
concepts, pas l'écriture de Terraform. En S02 à S04, la partie B a pris l'essentiel du
temps, au détriment des notions évaluées.

## Options envisagées
1. Garder les parties B en exercice de code.
2. Tout faire à la main dans le portail.
3. Terraform fourni et commenté, lancé en local, sans exercice de code.
4. Garder le pipeline OIDC pour chaque lab.

## Décision
Option 3.
- Priorité à Azure et à la SC-500. Terraform n'est plus un objectif d'apprentissage d'ici
  l'examen, reprise après avec la Terraform Associate.
- La partie A (portail et CLI) reste faite par moi, guidée pas à pas.
- L'infrastructure coûteuse des labs (VM, Bastion, pare-feu, passerelles) est fournie en
  Terraform prêt à lancer et commenté, avec 2 ou 3 points de lecture.
- Un dossier et un state par lab (par exemple `infra/lab-network`, `lab-network.tfstate`),
  dans le compte de state existant.
- Déploiement en local via Claude Code : apply en début de séance, destroy en fin de
  séance. Pipeline en pause.
- Les réglages Entra (accès conditionnel, PIM, consentement) restent dans le portail.

Option 1 écartée : incompatible avec 3 h par semaine. Option 2 : pas de destroy fiable,
risque de dépassement du budget. Option 4 : utile en entreprise, mais coûteux en
maintenance sans gain pour l'examen.

## Conséquences
- S03 E5, E6 et E8 (pipeline, Checkov, workflow de destruction) suspendus. L'écart sur
  les identités de déploiement fera l'objet d'un ADR distinct.
- S04 partie B et S06 E3 (racine `iam/`, state `iam.tfstate`) fournis. Je les lis et les
  applique moi-même, après activation PIM pour `iam/`.
- Compétence Terraform limitée à la lecture du code et des plans, toujours visible dans
  le repo.
- Le state reste centralisé et protégé (accès Entra, versioning, verrou). Lancer en local
  suppose que mon compte ait Storage Blob Data Contributor sur le conteneur tfstate.

## Risques acceptés
- Oublier un destroy en fin de séance. Mesure : vérifier qu'aucune ressource ne reste
  dans les groupes de ressources éphémères avant de clore, et alertes de
  budget-lab-monthly (40 EUR).
- Moindre pratique de la conception Terraform jusqu'à juin 2027.
