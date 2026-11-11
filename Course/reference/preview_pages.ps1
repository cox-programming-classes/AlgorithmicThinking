# Page previews of a finished PDF, so a page layout can be looked at as images.
# Claude's Read tool can't render a PDF's pages on Jason's Windows computer,
# and this can:  the Windows PDF renderer turns every page into a PNG, plus a
# contact sheet of the whole document.
#
#     powershell -ExecutionPolicy Bypass -File Course/reference/preview_pages.ps1
#     powershell -ExecutionPolicy Bypass -File Course/reference/preview_pages.ps1 -Pdf Course/chapters/build/pdf/Chapter01_Meeting3.pdf
#
# Defaults to the finished book, Course/chapters/build/book/Book_Draft.pdf.
# Writes Course/chapters/build/preview/<name>_page_NN.png and <name>_contact.png.
#
# Adapted 2026-11-10 from the Field Guide's preview_pages.ps1 (written by Codex,
# 2026-10-26), which exported Word files first.  This one starts from a PDF.
# Kept ASCII, for PowerShell 5.1.
param([string]$Pdf = (Join-Path $PSScriptRoot '..\chapters\build\book\Book_Draft.pdf'))
$ErrorActionPreference = 'Stop'
$pdfPath = (Resolve-Path $Pdf).Path
$name = [IO.Path]::GetFileNameWithoutExtension($pdfPath)
$previewDir = Join-Path $PSScriptRoot '..\chapters\build\preview'
New-Item -ItemType Directory -Force -Path $previewDir | Out-Null

Add-Type -AssemblyName System.Runtime.WindowsRuntime
Add-Type -AssemblyName System.Drawing
$null = [Windows.Storage.StorageFile,Windows.Storage,ContentType=WindowsRuntime]
$null = [Windows.Data.Pdf.PdfDocument,Windows.Data.Pdf,ContentType=WindowsRuntime]
$null = [Windows.Storage.Streams.InMemoryRandomAccessStream,Windows.Storage.Streams,ContentType=WindowsRuntime]
$asTask = [System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
    $_.Name -eq 'AsTask' -and $_.IsGenericMethod -and $_.GetParameters().Count -eq 1 -and
    $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
} | Select-Object -First 1
$asAction = [System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
    $_.Name -eq 'AsTask' -and -not $_.IsGenericMethod -and $_.GetParameters().Count -eq 1 -and
    $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncAction'
} | Select-Object -First 1
function Await-Operation($Operation, [Type]$ResultType) {
    $task = $asTask.MakeGenericMethod($ResultType).Invoke($null, @($Operation))
    $task.Wait()
    $task.Result
}

$storageFile = Await-Operation ([Windows.Storage.StorageFile]::GetFileFromPathAsync($pdfPath)) ([Windows.Storage.StorageFile])
$doc = Await-Operation ([Windows.Data.Pdf.PdfDocument]::LoadFromFileAsync($storageFile)) ([Windows.Data.Pdf.PdfDocument])
$rows = [int][Math]::Ceiling($doc.PageCount / 3.0)
$sheet = New-Object Drawing.Bitmap 1530, ($rows * 700)
$graphics = [Drawing.Graphics]::FromImage($sheet)
$graphics.Clear([Drawing.Color]::LightGray)
$font = New-Object Drawing.Font 'Calibri', 12
try {
    for ($index = 0; $index -lt $doc.PageCount; $index++) {
        $page = $doc.GetPage([uint32]$index)
        $stream = New-Object Windows.Storage.Streams.InMemoryRandomAccessStream
        try {
            $options = New-Object Windows.Data.Pdf.PdfPageRenderOptions
            $options.DestinationWidth = 1275
            $action = $asAction.Invoke($null, @($page.RenderToStreamAsync($stream, $options)))
            $action.Wait()
            $stream.Seek(0)
            $reader = New-Object Windows.Storage.Streams.DataReader ($stream.GetInputStreamAt(0))
            $null = Await-Operation ($reader.LoadAsync([uint32]$stream.Size)) ([uint32])
            $bytes = New-Object byte[] ([int]$stream.Size)
            $reader.ReadBytes($bytes)
            $pngPath = Join-Path $previewDir ('{0}_page_{1:D2}.png' -f $name, ($index + 1))
            [IO.File]::WriteAllBytes($pngPath, $bytes)
            $reader.Dispose()
            $img = [Drawing.Image]::FromFile($pngPath)
            try {
                $x = ($index % 3) * 510
                $y = [int][Math]::Floor($index / 3.0) * 700
                $graphics.DrawString("page $($index + 1)", $font, [Drawing.Brushes]::Black, $x + 8, $y + 4)
                $graphics.DrawImage($img, $x + 5, $y + 25, 500, 647)
            } finally { $img.Dispose() }
        } finally { $stream.Dispose(); $page.Dispose() }
    }
    $sheet.Save((Join-Path $previewDir "${name}_contact.png"), [Drawing.Imaging.ImageFormat]::Png)
} finally { $font.Dispose(); $graphics.Dispose(); $sheet.Dispose() }
Write-Output "$name rendered:  $($doc.PageCount) page PNGs and a contact sheet in $previewDir"
