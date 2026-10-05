$url = "http://localhost:11434/api/tags"
try {
  $r = Invoke-WebRequest -Uri $url -TimeoutSec 5
  Write-Host "Ollama is reachable." -ForegroundColor Green
  Write-Host $r.Content
} catch {
  Write-Host "Ollama is not reachable at http://localhost:11434" -ForegroundColor Red
  Write-Host "Start Ollama, then run this script again."
}
