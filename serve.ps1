$port = if ($env:PORT) { $env:PORT } else { 8000 }
$root = $PSScriptRoot
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving $root on http://localhost:$port"

while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $localPath = $ctx.Request.Url.LocalPath.TrimStart('/')
    if ($localPath -eq '') { $localPath = 'index.html' }
    $filePath = Join-Path $root $localPath

    if (Test-Path $filePath -PathType Leaf) {
        $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
        $mime = switch ($ext) {
            '.html' { 'text/html; charset=utf-8' }
            '.css'  { 'text/css' }
            '.js'   { 'application/javascript' }
            '.json' { 'application/json' }
            '.png'  { 'image/png' }
            '.jpg'  { 'image/jpeg' }
            '.svg'  { 'image/svg+xml' }
            default { 'application/octet-stream' }
        }
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $ctx.Response.ContentType = $mime
        $ctx.Response.ContentLength64 = $bytes.Length
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $ctx.Response.StatusCode = 404
        $ctx.Response.ContentLength64 = 0
    }
    $ctx.Response.Close()
}
