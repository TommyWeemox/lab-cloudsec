<#
.SYNOPSIS
  Cree le backend Terraform (compte de stockage du state) de facon durcie.
.DESCRIPTION
  A executer une seule fois, avec un compte Proprietaire de l'abonnement.
  Le script peut etre relance sans risque : chaque etape verifie ou tolere l'existant.
  Note : pas d'accents dans ce fichier (PowerShell 5.1 lit mal l'UTF-8 sans BOM).
#>

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# 1. Variables : le seul endroit a modifier
# ---------------------------------------------------------------------------
$Location      = "francecentral"
$ResourceGroup = "rg-lab-tfstate-frc"
$Container     = "tfstate"
$Tags          = @("owner=tom", "project=lab-cloudsec", "bloc=b1", "cost-center=lab", "lifecycle=permanent")

# Le nom d'un compte de stockage doit etre unique dans tout Azure (3-24 car.,
# minuscules et chiffres). On le rend deterministe avec le debut de l'ID d'abonnement.
$SubscriptionId = az account show --query id -o tsv
$Suffix         = $SubscriptionId.Replace("-", "").Substring(0, 6)
$StorageAccount = "stlabtfstate$Suffix"

Write-Host "Abonnement : $SubscriptionId"
Write-Host "Compte     : $StorageAccount"

# ---------------------------------------------------------------------------
# 2. Groupe de ressources dedie au state
#    (separe du reste : il sera protege par un verrou a la fin)
# ---------------------------------------------------------------------------
az group create --name $ResourceGroup --location $Location --tags $Tags --output none
if ($LASTEXITCODE -ne 0) { throw "Echec : creation du groupe de ressources" }

# ---------------------------------------------------------------------------
# 3. Compte de stockage durci
#    - cle partagee desactivee : l'acces se fait uniquement par identite Entra
#    - acces public anonyme desactive
#    - TLS 1.2 minimum, HTTPS obligatoire
# ---------------------------------------------------------------------------
az storage account create `
  --name $StorageAccount `
  --resource-group $ResourceGroup `
  --location $Location `
  --sku Standard_LRS `
  --kind StorageV2 `
  --allow-shared-key-access false `
  --allow-blob-public-access false `
  --min-tls-version TLS1_2 `
  --https-only true `
  --tags $Tags `
  --output none
if ($LASTEXITCODE -ne 0) { throw "Echec : creation du compte de stockage" }

# ---------------------------------------------------------------------------
# 4. Protection des donnees : historique des versions et retention a la suppression
#    (un state ecrase ou supprime par erreur peut etre restaure)
# ---------------------------------------------------------------------------
az storage account blob-service-properties update `
  --account-name $StorageAccount `
  --resource-group $ResourceGroup `
  --enable-versioning true `
  --enable-delete-retention true --delete-retention-days 14 `
  --enable-container-delete-retention true --container-delete-retention-days 14 `
  --output none
if ($LASTEXITCODE -ne 0) { throw "Echec : protection des blobs" }

# ---------------------------------------------------------------------------
# 5. Role de donnees pour l'utilisateur connecte (sans cle partagee, etre
#    Proprietaire ne donne PAS acces aux blobs : il faut un role de donnees)
# ---------------------------------------------------------------------------
$UserId  = az ad signed-in-user show --query id -o tsv
$Scope   = az storage account show --name $StorageAccount --resource-group $ResourceGroup --query id -o tsv
$Role    = "Storage Blob Data Contributor"

# On recupere la liste en JSON et PowerShell la convertit en objets.
# (Eviter --query "length(@)" : les parentheses cassent l'appel a az sous PowerShell 5.1.)
# Liste vide => $Existing est vide => -not $Existing vaut $true => on cree le role.
$Existing = az role assignment list --assignee $UserId --role $Role --scope $Scope -o json | ConvertFrom-Json
if (-not $Existing) {
    az role assignment create `
      --assignee-object-id $UserId `
      --assignee-principal-type User `
      --role $Role `
      --scope $Scope `
      --output none
    if ($LASTEXITCODE -ne 0) { throw "Echec : attribution du role de donnees" }
    Write-Host "Role attribue. Propagation en cours..."
} else {
    Write-Host "Role deja present."
}

# ---------------------------------------------------------------------------
# 6. Conteneur du state
#    Le role met quelques minutes a se propager : on reessaie jusqu'a 10 fois.
# ---------------------------------------------------------------------------
$ErrorActionPreference = "Continue"
$Created = $false
for ($i = 1; $i -le 10; $i++) {
    az storage container create --name $Container --account-name $StorageAccount --auth-mode login --output none 2>$null
    if ($LASTEXITCODE -eq 0) { $Created = $true; break }
    Write-Host "Tentative $i/10 : autorisation pas encore propagee, nouvel essai dans 30 s..."
    Start-Sleep -Seconds 30
}
$ErrorActionPreference = "Stop"
if (-not $Created) { throw "Echec : creation du conteneur $Container" }

# ---------------------------------------------------------------------------
# 7. Verrou de suppression sur le groupe de ressources (en dernier, sinon il
#    bloquerait les modifications des etapes precedentes)
# ---------------------------------------------------------------------------
az lock create --name "lock-tfstate" --lock-type CanNotDelete --resource-group $ResourceGroup --notes "Protege le state Terraform" --output none
if ($LASTEXITCODE -ne 0) { throw "Echec : creation du verrou" }

# ---------------------------------------------------------------------------
# 8. Recapitulatif : valeurs pour le bloc backend de Terraform (E4)
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Backend Terraform :"
Write-Host "  resource_group_name  = $ResourceGroup"
Write-Host "  storage_account_name = $StorageAccount"
Write-Host "  container_name       = $Container"
