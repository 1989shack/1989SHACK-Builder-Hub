$wheelDir = "C:\BanglaHost\BuilderHub\wheel"
$logFile = "$wheelDir\wheel.log"
function Write-WheelLog($msg){ $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; "$time - $msg" | Out-File $logFile -Append -Encoding utf8; Write-Host "🛞 $msg" -ForegroundColor Cyan }
function Test-WheelHealth{
  $healthy=@(); $broken=@(); for($p=8881;$p -le 8885;$p++){ try{ $r=Invoke-WebRequest "http://localhost:$p/" -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop; if($r.StatusCode -eq 200){$healthy+=$p}else{$broken+=$p} } catch{ $broken+=$p } }; return @{healthy=$healthy; broken=$broken}
}
function Rebuild-WheelPort($port){
  Write-WheelLog "Rebuilding Port $port - Self-rebuild started!"; $healthyPort=(Test-WheelHealth).healthy | Select-Object -First 1
  if($healthyPort){ Copy-Item "C:\BanglaHost\nginx\html\sites\port_$healthyPort\*" "C:\BanglaHost\nginx\html\sites\port_$port\" -Recurse -Force -ErrorAction SilentlyContinue; Write-WheelLog "Port $port rebuilt from Port $healthyPort!" }
  else { Copy-Item "C:\BanglaHost\BuilderHub\projects\latest\*" "C:\BanglaHost\nginx\html\sites\port_$port\wheel-rebuild\" -Recurse -Force -ErrorAction SilentlyContinue; New-Item -ItemType Directory -Force -Path "C:\BanglaHost\nginx\html\sites\port_$port\wheel-rebuild" | Out-Null; Copy-Item "C:\BanglaHost\BuilderHub\projects\latest\*" "C:\BanglaHost\nginx\html\sites\port_$port\wheel-rebuild\" -Recurse -Force -ErrorAction SilentlyContinue; Write-WheelLog "Port $port rebuilt from Origin Core!" }
}
Write-WheelLog "🛞 WHEEL SELF-REBUILD STARTED!"
while($true){
  $health=Test-WheelHealth; if($health.broken.Count -gt 0){ foreach($b in $health.broken){ Rebuild-WheelPort $b } }
  $nginx=Get-Process nginx -ErrorAction SilentlyContinue; if(!$nginx){ Write-WheelLog "Nginx down - Restarting!"; Start-Process "C:\BanglaHost\nginx\nginx.exe" -WindowStyle Hidden; Start-Sleep 2 }
  Start-Sleep 10
}
