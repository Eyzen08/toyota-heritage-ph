$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$imgDir = Join-Path $root 'assets\img'
New-Item -ItemType Directory -Force -Path $imgDir | Out-Null

function Get-CommonsMap {
    $html = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'toyota-philippines.html'), [Text.Encoding]::UTF8)
    $set = New-Object System.Collections.Generic.HashSet[string]
    foreach ($m in [regex]::Matches($html, 'Special:FilePath/([^"''\s>]+)')) {
        [void]$set.Add([uri]::UnescapeDataString($m.Groups[1].Value).Replace('_', ' '))
    }
    foreach ($m in [regex]::Matches($html, "img:'([^']+)'")) {
        [void]$set.Add($m.Groups[1].Value)
    }
    return @($set | Where-Object { $_ -notmatch '^\$\{' -and $_ -notmatch '^https?://' } | Sort-Object)
}

$names = Get-CommonsMap
Write-Host "Commons files: $($names.Count)"

$ua = 'ToyotaHeritagePH/1.0 (+https://toyota-heritage-ph.vercel.app)'
$titles = ($names | ForEach-Object { 'File:' + $_ }) -join '|'
$api = 'https://commons.wikimedia.org/w/api.php?action=query&format=json&prop=imageinfo&iiprop=url&iiurlwidth=1280&titles=' + [uri]::EscapeDataString($titles)
$resp = Invoke-RestMethod -Uri $api -UserAgent $ua -Headers @{ 'Accept-Language' = 'en' }
$pages = $resp.query.pages.PSObject.Properties.Value
Write-Host "API pages returned: $($pages.Count)"

$info = @{}
foreach ($p in $pages) {
    if ($p.imageinfo) {
        $info[$p.title.Substring(5)] = $p.imageinfo[0]
    } else {
        Write-Warning "No imageinfo for: $($p.title)"
    }
}

$map = @{}
$i = 0
foreach ($name in $names) {
    $i++
    $meta = $info[$name]
    if (-not $meta) { Write-Warning "SKIP: $name"; continue }

    $url = if ($meta.thumburl) { $meta.thumburl.Split('?')[0] } else { $meta.url }
    $ext = [IO.Path]::GetExtension(([uri]$meta.url).AbsolutePath).ToLower()
    if (-not $ext) { $ext = '.jpg' }
    if ($ext -eq '.jpeg') { $ext = '.jpg' }

    $slug = ($name -replace '\.[^.]+$', '') -replace '[^A-Za-z0-9]+', '-'
    $slug = $slug.Trim('-').ToLower()
    if ($slug.Length -gt 70) { $slug = $slug.Substring(0, 70).Trim('-') }
    $file = '{0:D2}-{1}{2}' -f $i, $slug, $ext

    $dest = Join-Path $imgDir $file
    if (-not (Test-Path $dest)) {
        curl.exe -L -s --retry 4 --retry-delay 5 -A $ua -o $dest $url
        if (-not (Test-Path $dest) -or (Get-Item $dest).Length -lt 5000) { throw "download failed: $name" }
        Start-Sleep -Milliseconds 900
    }
    $size = [math]::Round((Get-Item $dest).Length / 1KB)
    $map[$name] = 'assets/img/' + $file
    Write-Host ("{0,2}/{1}  {2,5} KB  {3}" -f $i, $names.Count, $size, $file)
}

$map.GetEnumerator() | Sort-Object Name | ForEach-Object { [pscustomobject]@{ source = $_.Key; local = $_.Value } } |
    ConvertTo-Json -Depth 3 | Set-Content (Join-Path $PSScriptRoot 'image-map.json') -Encoding utf8

Write-Host "DONE: $($map.Count) images"


