# Script: generar_index_fotos.ps1
# Ejecutar desde la carpeta raíz del repo (donde está index.html)
# Genera un index.json en cada subcarpeta de Fotos/ con la lista de imágenes

$extensiones = @("*.jpg","*.jpeg","*.png","*.webp","*.JPG","*.JPEG","*.PNG")
$raiz = Join-Path $PSScriptRoot "Fotos"

if (-not (Test-Path $raiz)) {
    Write-Host "No se encontró la carpeta Fotos/ en $PSScriptRoot" -ForegroundColor Red
    exit
}

$carpetas = Get-ChildItem -Path $raiz -Recurse -Directory
$total = 0

foreach ($carpeta in $carpetas) {
    $fotos = @()
    foreach ($ext in $extensiones) {
        $fotos += Get-ChildItem -Path $carpeta.FullName -Filter $ext -File
    }
    
    if ($fotos.Count -gt 0) {
        # Ordenar por nombre de archivo
        $fotos = $fotos | Sort-Object Name
        
        $lista = $fotos | ForEach-Object { $_.Name }
        $json = $lista | ConvertTo-Json -Compress
        
        # Si solo hay un elemento, ConvertTo-Json devuelve string sin array
        if ($fotos.Count -eq 1) {
            $json = "[$json]"
        }
        
        $outputPath = Join-Path $carpeta.FullName "index.json"
        $json | Out-File -FilePath $outputPath -Encoding UTF8 -NoNewline
        
        Write-Host "✓ $($carpeta.FullName.Replace($raiz,'')) → $($fotos.Count) fotos" -ForegroundColor Green
        $total++
    }
}

Write-Host "`n✅ Listo! Se crearon index.json en $total carpetas." -ForegroundColor Cyan
Write-Host "Ahora commiteá y pusheá a GitHub para que aparezcan en la web." -ForegroundColor Yellow
