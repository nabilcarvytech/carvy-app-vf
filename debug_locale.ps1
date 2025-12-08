# Script de debug pour capturer les logs de locale
Write-Host "=== Démarrage du debug de locale ===" -ForegroundColor Green

# Attendre que l'application démarre
Start-Sleep -Seconds 5

# Lire les logs en continu
$logFile = "app_logs.txt"
if (Test-Path $logFile) {
    Write-Host "`n=== Logs de locale trouvés ===" -ForegroundColor Yellow
    Get-Content $logFile | Select-String -Pattern "lanValue|locale|translation|Selected locale|Get.locale|Test translation|Available translation|Reading locale|Found locale|No valid locale|Restored|Saving lanValue" | Select-Object -Last 50
} else {
    Write-Host "Fichier de logs non trouvé. Attente de 20 secondes..." -ForegroundColor Red
    Start-Sleep -Seconds 20
    if (Test-Path $logFile) {
        Get-Content $logFile | Select-String -Pattern "lanValue|locale|translation" | Select-Object -Last 50
    }
}

Write-Host "`n=== Fin du debug ===" -ForegroundColor Green


