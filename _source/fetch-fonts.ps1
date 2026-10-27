$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$fontDir = Join-Path $root 'assets\fonts'
New-Item -ItemType Directory -Force -Path $fontDir | Out-Null

$ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36'
$cssPath = Join-Path $PSScriptRoot 'fonts-source.css'
$css = [IO.File]::ReadAllText($cssPath, [Text.Encoding]::UTF8)

$urls = [regex]::Matches($css, 'url\((https://fonts\.gstatic\.com/[^)]+)\)') |
    ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
Write-Host "font files: $($urls.Count)"

$i = 0
foreach ($u in $urls) {
    $i++
    $name = [IO.Path]::GetFileName(([uri]$u).AbsolutePath)
    $dest = Join-Path $fontDir $name
    if (-not (Test-Path $dest)) {
        curl.exe -L -s --retry 4 --retry-delay 3 -A $ua -o $dest $u
        Start-Sleep -Milliseconds 120
    }
    if ((Get-Item $dest).Length -lt 1000) { throw "bad font: $name" }
    $css = $css.Replace($u, 'fonts/' + $name)
}

[IO.File]::WriteAllText((Join-Path $root 'assets\fonts.css'), $css, [Text.Encoding]::UTF8)
Write-Host "DONE: $($urls.Count) font files, css bytes: $($css.Length)"

