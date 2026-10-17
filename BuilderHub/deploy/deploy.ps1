# 1989SHACK Deep Deploy - From Builder Hub to cPanel 8881-8887 + Global Edge
param($projectPath = "C:\BanglaHost\BuilderHub\projects\latest")

Write-Host "=== Deep Root Deploy to Global Architecture ===" -ForegroundColor Green

# Find least loaded cPanel port
$counts = @{}
for($p=8881;$p -le 8887;$p++){
  $countFile = "C:\BanglaHost\counts\$p.txt"
  $counts[$p] = if(Test-Path $countFile){ [int](Get-Content $countFile) }else{ 0 }
}
$selectedPort = ($counts.GetEnumerator() | Sort-Object Value | Select-Object -First 1).Key
Write-Host "Selected Port: $selectedPort (least loaded) - Money goes to YOUR account" -ForegroundColor Cyan

# Detect project type
if(Test-Path "$projectPath\*.html"){ $type = "RocketCake" }
elseif(Test-Path "$projectPath\wp-config.php"){ $type = "WordPress Studio" }
else{ $type = "Generic" }

Write-Host "Project Type: $type" -ForegroundColor Yellow

# Deploy
$dest = "C:\BanglaHost\nginx\html\sites\port_$selectedPort"
New-Item -ItemType Directory -Force -Path $dest | Out-Null

if($type -eq "RocketCake"){
  # RocketCake exports to HTML - copy
  Copy-Item "$projectPath\*.html" $dest -Force -Recurse
  Copy-Item "$projectPath\*.css" $dest -Force -Recurse -ErrorAction SilentlyContinue
  Copy-Item "$projectPath\*.js" $dest -Force -Recurse -ErrorAction SilentlyContinue
  Copy-Item "$projectPath\images" $dest -Force -Recurse -ErrorAction SilentlyContinue
} elseif($type -eq "WordPress Studio"){
  # WordPress Studio - copy wp files + create DB
  Copy-Item "$projectPath\*" $dest -Force -Recurse
  # Create database for this port
  mysql -u root -e "CREATE DATABASE IF NOT EXISTS wp_port_$selectedPort; CREATE USER IF NOT EXISTS 'wp_$selectedPort'@'localhost' IDENTIFIED BY 'Shack2026!$selectedPort'; GRANT ALL ON wp_port_$selectedPort.* TO 'wp_$selectedPort'@'localhost';"
}

# Purge Cloudflare cache - Make 30ms edge
Write-Host "Purging Cloudflare Global Edge cache (300 cities)..." -ForegroundColor Cyan
try{
  Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/purge_cache" -Method Post -Headers @{"Authorization"="Bearer YOUR_CF_TOKEN"} -Body '{"purge_everything":true}' -ErrorAction SilentlyContinue
}catch{ Write-Host "CF purge skipped (add token later)" -ForegroundColor Gray }

# Update count
$countFile = "C:\BanglaHost\counts\$selectedPort.txt"
Set-Content $countFile ([int](Get-Content $countFile -ErrorAction SilentlyContinue) + 1)

Write-Host "✅ DEPLOYED! Site live at:" -ForegroundColor Green
Write-Host "Local: http://localhost:$selectedPort" -ForegroundColor White
Write-Host "Global Edge: https://1989shack.com:$selectedPort (30ms Liberia)" -ForegroundColor White
Write-Host "Via Tunnel: https://your-tunnel.trycloudflare.com:$selectedPort" -ForegroundColor White

# Log for MoMo billing
Add-Content "C:\BH-Logs\deploy.log" "$(Get-Date) - Deployed $type project to port $selectedPort - $dest"

# Open in browser
Start-Process "http://localhost:$selectedPort"
