# Restart RuoYi Backend Service
# This script stops the current backend and restarts it

Write-Host "=== RuoYi Backend Restart Script ===" -ForegroundColor Cyan

# Step 1: Find and stop Java processes
Write-Host "`nStep 1: Finding Java processes..." -ForegroundColor Yellow
$javaProcesses = Get-Process | Where-Object {$_.ProcessName -like "*java*"}

if ($javaProcesses) {
    Write-Host "Found $($javaProcesses.Count) Java process(es):" -ForegroundColor Green
    $javaProcesses | ForEach-Object {
        Write-Host "  PID: $($_.Id) | Started: $($_.StartTime)" -ForegroundColor White
    }
    
    Write-Host "`nStopping Java processes..." -ForegroundColor Yellow
    $javaProcesses | ForEach-Object {
        try {
            Stop-Process -Id $_.Id -Force -ErrorAction Stop
            Write-Host "  Stopped PID: $($_.Id)" -ForegroundColor Green
        } catch {
            Write-Host "  Failed to stop PID: $($_.Id)" -ForegroundColor Red
        }
    }
    
    Write-Host "`nWaiting for processes to stop..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
} else {
    Write-Host "No Java processes found." -ForegroundColor Yellow
}

# Step 2: Check if processes are stopped
Write-Host "`nStep 2: Verifying processes stopped..." -ForegroundColor Yellow
$remainingProcesses = Get-Process | Where-Object {$_.ProcessName -like "*java*"}
if ($remainingProcesses) {
    Write-Host "Warning: Some Java processes are still running:" -ForegroundColor Red
    $remainingProcesses | ForEach-Object {
        Write-Host "  PID: $($_.Id)" -ForegroundColor Red
    }
    Write-Host "Please stop them manually in IDEA or Task Manager." -ForegroundColor Red
    exit 1
} else {
    Write-Host "All Java processes stopped successfully." -ForegroundColor Green
}

# Step 3: Start backend service
Write-Host "`nStep 3: Starting backend service..." -ForegroundColor Yellow

$backendPath = "RuoYi-Vue-master\ruoyi-admin"
if (-not (Test-Path $backendPath)) {
    Write-Host "Error: Backend path not found: $backendPath" -ForegroundColor Red
    exit 1
}

Write-Host "Backend path: $backendPath" -ForegroundColor White

# Check if we should use Maven or JAR
$pomFile = Join-Path $backendPath "pom.xml"
$jarFile = Join-Path $backendPath "target\ruoyi-admin.jar"

if (Test-Path $jarFile) {
    Write-Host "Found JAR file, starting with java -jar..." -ForegroundColor Green
    Write-Host "Command: java -jar $jarFile" -ForegroundColor White
    Write-Host "`nStarting in new window..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; java -jar target\ruoyi-admin.jar"
} elseif (Test-Path $pomFile) {
    Write-Host "Found pom.xml, starting with Maven..." -ForegroundColor Green
    Write-Host "Command: mvn spring-boot:run" -ForegroundColor White
    Write-Host "`nStarting in new window..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; mvn spring-boot:run"
} else {
    Write-Host "Error: Neither JAR file nor pom.xml found!" -ForegroundColor Red
    Write-Host "Please start the backend manually in IDEA." -ForegroundColor Yellow
    exit 1
}

Write-Host "`n=== Backend service is starting ===" -ForegroundColor Green
Write-Host "Please wait for the service to start completely." -ForegroundColor Yellow
Write-Host "Look for 'Started RuoYiApplication' in the new window." -ForegroundColor Yellow
Write-Host "`nAfter startup completes:" -ForegroundColor Cyan
Write-Host "1. Refresh browser (Ctrl + Shift + R)" -ForegroundColor White
Write-Host "2. Test the question options display" -ForegroundColor White

