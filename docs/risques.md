# Registre de risques

| Risque | Impact | Probabilité | Mesure | Statut |
|---|---|---|---|---|
| Dépassement du budget (VM, firewall oublié) | Moyen | Moyenne | Alertes 50/75/100 %, ressources ephemeral détruites chaque nuit | Actif |
| Perte d'accès au tenant | Élevé | Faible | Deux comptes brise-glace testés ; clés FIDO2 physiques à ajouter | Partiel |
| Fuite de secret dans le dépôt public | Élevé | Faible | gitleaks en pre-commit, secret scanning et push protection | Actif |
| Droits trop larges à la racine | Élevé | Faible | Accès élevé et Propriétaire temporaires retirés ; PIM et rôle personnalisé en S06 | En cours |
| Fin de l'essai Azure (crédit de 30 jours) | Moyen | Certaine | Noter la date, passer en paiement à l'usage avant S02 | À faire |
