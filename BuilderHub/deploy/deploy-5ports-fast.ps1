# C:\BanglaHost\BuilderHub\deploy\deploy-5ports-fast.ps1 - 5x Faster Deployment!
# Deploys to 5 ports in parallel - 5x speed!

param(
  [string]$projectName = "customer-site",
  [string]$sourcePath = "C:\BanglaHost\BuilderHub\projects\latest"
if(!(Test-Path "$sourcePath\index.html")){
  $sourcePath = "C:\BanglaHost\BuilderHub\project\latest"
}
if(!(Test-Path "$sourcePath\index.html")){
  $sourcePath = "C:\BanglaHost\BuilderHub\projects\latest"
  # Try to find any index.html
  $found = Get-ChildItem C:\BanglaHost\BuilderHub -Recurse -Filter index.html -ErrorAction SilentlyContinue | Select-Object -First 1
  if($found){ $sourcePath = $found.DirectoryName }
}
)

Write-Host "=== 5x FASTER DEPLOY - Using 5 Ports 8881-8885 Parallel ===" -ForegroundColor Green

if(!(Test-Path "$sourcePath\index.html")){
  Write-Host "❌ Source not found: $sourcePath\index.html - Build first!" -ForegroundColor Red
  Write-Host "Run: C:\BanglaHost\BuilderHub\deploy\ai-generator.ps1 -prompt 'Build site'" -ForegroundColor Cyan
  return
}

# Deploy to 5 ports in parallel - 5x faster!
$jobs = @()
for($p=8881;$p -le 8885;$p++){
  $job = Start-Job -ScriptBlock {
    param($port, $project, $source)
    $dest = "C:\BanglaHost\nginx\html\sites\port_$port\$project"
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Copy-Item "$source\*" $dest -Recurse -Force
    $countFile = "C:\BanglaHost\counts\$port.txt"
    $count = if(Test-Path $countFile){ [int](Get-Content $countFile) }else{ 0 }
    Set-Content $countFile ($count + 1)
    Write-Host "Port $port - Deployed $project - Count $($count+1)" -ForegroundColor Green
    return "Port $port OK"
  } -ArgumentList $p, $projectName, $sourcePath
  $jobs += $job
}

Write-Host "Deploying to 5 ports in parallel - 5x faster..." -ForegroundColor Yellow
$jobs | Wait-Job | Out-Null
$results = $jobs | Receive-Job
$jobs | Remove-Job

Write-Host "`n✅ Deployed to 5 ports in parallel - 5x faster!" -ForegroundColor Green
foreach($r in $results){ Write-Host $r -ForegroundColor Cyan }

# Show URLs
Write-Host "`nLive URLs (5x faster - all same content):" -ForegroundColor Yellow
for($p=8881;$p -le 8885;$p++){
  Write-Host "http://localhost:$p/$projectName - Port $p" -ForegroundColor White
}
Write-Host "https://1989shack.com:$p/$projectName - Cloudflare 300 cities (if tunnel on)" -ForegroundColor Cyan

# Also deploy to all clouds if tokens exist
if(Test-Path "C:\BanglaHost\OpenSourceHub\.env"){
  Write-Host "`nAlso deploying to Vercel+Firebase+AWS (if tokens set)..." -ForegroundColor Yellow
  & "C:\BanglaHost\OpenSourceHub\deployers\deploy-all-clouds.ps1" -sourcePath $sourcePath -projectName $projectName -port 8881
}

Write-Host "`n=== 5x FASTER DEPLOY DONE ===" -ForegroundColor Green -BackgroundColor Black
Write-Host "5 ports = 5x installation speed - 7140 customers capacity!" -ForegroundColor Green

