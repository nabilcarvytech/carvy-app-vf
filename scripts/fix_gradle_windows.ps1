# Corrige java.net.BindException (Gradle daemon) et libère les verrous de build.
$ErrorActionPreference = "Continue"

Write-Host "==> Arret des daemons Gradle..."
Push-Location "$PSScriptRoot\..\android"
& .\gradlew.bat --stop 2>$null
Pop-Location

Write-Host "==> Nettoyage du registre daemon utilisateur..."
$daemonDir = Join-Path $env:USERPROFILE ".gradle\daemon"
if (Test-Path $daemonDir) {
    Get-ChildItem $daemonDir -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "==> Arret des processus Java Gradle orphelins..."
Get-Process -Name "java" -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId=$($_.Id)" -ErrorAction SilentlyContinue).CommandLine
        if ($cmd -match "GradleDaemon|gradle-launcher") {
            Write-Host "    Stop PID $($_.Id)"
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        }
    } catch {}
}

Write-Host ""
Write-Host "OK. Relancez ensuite depuis la racine du projet :"
Write-Host "  flutter run --release"
Write-Host ""
Write-Host "Si echec, build manuel sans daemon :"
Write-Host "  cd android"
Write-Host "  .\gradlew.bat assembleRelease --no-daemon"
Write-Host "  cd .."
Write-Host "  flutter install --release"
