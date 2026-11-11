# Draws the title-page picture for each chapter of the printed book, and the
# spot pictures finish_book.ps1 uses to fill large gaps.
#
#     powershell -ExecutionPolicy Bypass -File Course/reference/make_art.ps1
#
# Writes Course/chapters/build/book/art/chNN.png and spot_*.png.
#
# Recycled 2026-11-10 from the robotics team's Field Guide
# (WinsorRobotics26-27, doc/FieldGuide/reference/make_art.ps1), with Jason's
# go-ahead:  its drawing helpers and spot pictures unchanged, and its Chapter 6
# picture ("The Layered Robot Model") as this book's Chapter 1.  Only the
# output folder and these comments changed.  Kept ASCII, because Windows
# PowerShell 5.1 misreads UTF-8 source without a BOM.
#
# PowerShell ignores the case of variable names, so $R and $r are the same
# variable.  Every name here differs by more than case.

Add-Type -AssemblyName System.Drawing

$outDir = Join-Path $PSScriptRoot '..\chapters\build\book\art'
New-Item -ItemType Directory -Force $outDir | Out-Null

$W = 1600; $Hgt = 900
$blue  = [System.Drawing.ColorTranslator]::FromHtml('#1F4E79')
$mid   = [System.Drawing.ColorTranslator]::FromHtml('#2B6CB0')
$pale  = [System.Drawing.ColorTranslator]::FromHtml('#EAF2FB')
$light = [System.Drawing.ColorTranslator]::FromHtml('#CFE0F3')
$red   = [System.Drawing.ColorTranslator]::FromHtml('#B03A2E')
$gray  = [System.Drawing.ColorTranslator]::FromHtml('#8A9AAA')
$white = [System.Drawing.Color]::White

function New-Canvas {
  $script:bmp = New-Object System.Drawing.Bitmap $W, $Hgt
  $script:g = [System.Drawing.Graphics]::FromImage($script:bmp)
  $script:g.SmoothingMode = 'AntiAlias'
  $script:g.TextRenderingHint = 'AntiAliasGridFit'
  $script:g.Clear([System.Drawing.Color]::Transparent)
}
function Save-Canvas([string]$name) {
  $path = Join-Path $outDir $name
  $script:bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $script:g.Dispose(); $script:bmp.Dispose()
  "wrote $path"
}
function Pen([System.Drawing.Color]$c, [float]$wid) {
  $p = New-Object System.Drawing.Pen $c, $wid
  $p.LineJoin = 'Round'; $p.StartCap = 'Round'; $p.EndCap = 'Round'
  $p
}
function Brush([System.Drawing.Color]$c) { New-Object System.Drawing.SolidBrush $c }
function Font([string]$family, [float]$px, [string]$style = 'Regular') {
  New-Object System.Drawing.Font $family, $px, ([System.Drawing.FontStyle]$style), ([System.Drawing.GraphicsUnit]::Pixel)
}
function Center-Text([string]$text, $font, [System.Drawing.Color]$c, [float]$x, [float]$y, [float]$wid, [float]$hei) {
  $fmt = New-Object System.Drawing.StringFormat
  $fmt.Alignment = 'Center'; $fmt.LineAlignment = 'Center'
  $script:g.DrawString($text, $font, (Brush $c), (New-Object System.Drawing.RectangleF $x, $y, $wid, $hei), $fmt)
}
function Rounded([float]$x, [float]$y, [float]$wid, [float]$hei, [float]$rad) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = 2 * $rad
  $path.AddArc($x, $y, $d, $d, 180, 90)
  $path.AddArc($x + $wid - $d, $y, $d, $d, 270, 90)
  $path.AddArc($x + $wid - $d, $y + $hei - $d, $d, $d, 0, 90)
  $path.AddArc($x, $y + $hei - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  $path
}
function Box([float]$x, [float]$y, [float]$wid, [float]$hei, [System.Drawing.Color]$fill, [float]$stroke = 8, [float]$rad = 24) {
  $path = Rounded $x $y $wid $hei $rad
  $script:g.FillPath((Brush $fill), $path)
  $script:g.DrawPath((Pen $blue $stroke), $path)
}
function Label-Box([float]$x, [float]$y, [float]$wid, [float]$hei, [string]$text, [System.Drawing.Color]$fill, [float]$px = 50) {
  Box $x $y $wid $hei $fill 7 22
  $ink = if ($fill -eq $blue) { $white } else { $blue }
  Center-Text $text (Font 'Consolas' $px) $ink $x $y $wid $hei
}
function Arrow([float]$x1, [float]$y1, [float]$x2, [float]$y2, [float]$wid = 8) {
  $p = Pen $blue $wid
  $p.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap 4, 5
  $script:g.DrawLine($p, $x1, $y1, $x2, $y2)
}
function Dashed([float]$x1, [float]$y1, [float]$x2, [float]$y2, [System.Drawing.Color]$c, [float]$wid = 6) {
  $p = Pen $c $wid
  $p.DashStyle = 'Dash'
  $script:g.DrawLine($p, $x1, $y1, $x2, $y2)
}
function Pt([float]$x, [float]$y) { New-Object System.Drawing.PointF $x, $y }
function Polar([float]$cx, [float]$cy, [double]$radius, [double]$angle) {
  Pt ([float]($cx + $radius * [Math]::Cos($angle))) ([float]($cy + $radius * [Math]::Sin($angle)))
}
function Hexagon([float]$cx, [float]$cy, [float]$radius, [System.Drawing.Color]$fill, [float]$stroke = 8) {
  $hex = @(); foreach ($i in 0..5) { $hex += Polar $cx $cy $radius ($i * [Math]::PI / 3) }
  $script:g.FillPolygon((Brush $fill), [System.Drawing.PointF[]]$hex)
  $script:g.DrawPolygon((Pen $blue $stroke), [System.Drawing.PointF[]]$hex)
}
# A spur gear on a hex bore.  $turn rotates it, in fractions of a tooth, so two
# gears can mesh.
function Gear([float]$cx, [float]$cy, [float]$tipR, [int]$teeth, [System.Drawing.Color]$fill, [float]$stroke = 8, [double]$turn = 0) {
  $rootR = $tipR - [Math]::Max(22, $tipR * 0.12)
  $step = 2 * [Math]::PI / $teeth
  $pts = @()
  for ($t = 0; $t -lt $teeth; $t++) {
    $a = ($t + $turn) * $step - [Math]::PI / 2
    $pts += Polar $cx $cy $rootR ($a - 0.5 * $step)
    $pts += Polar $cx $cy $rootR ($a - 0.28 * $step)
    $pts += Polar $cx $cy $tipR ($a - 0.16 * $step)
    $pts += Polar $cx $cy $tipR ($a + 0.16 * $step)
    $pts += Polar $cx $cy $rootR ($a + 0.28 * $step)
  }
  $script:g.FillPolygon((Brush $fill), [System.Drawing.PointF[]]$pts)
  $script:g.DrawPolygon((Pen $blue $stroke), [System.Drawing.PointF[]]$pts)
  Hexagon $cx $cy ([Math]::Max(18, $tipR * 0.18)) $white ($stroke * 0.8)
}
# An AprilTag-style square:  a dark border one cell wide around a 6-by-6 field
# of cells, inside a white margin.  The pattern is fixed, and decorative.
$TAG_BITS = '101100011010110101001110100011011001'
function Tag([float]$x, [float]$y, [float]$size) {
  $cell = $size / 10
  $script:g.FillRectangle((Brush $white), $x, $y, $size, $size)
  $script:g.DrawRectangle((Pen $gray 3), $x, $y, $size, $size)
  $script:g.FillRectangle((Brush $blue), ($x + $cell), ($y + $cell), (8 * $cell), (8 * $cell))
  for ($i = 0; $i -lt 36; $i++) {
    if ($TAG_BITS[$i] -eq '0') {
      $col = $i % 6; $row = [Math]::Floor($i / 6)
      $script:g.FillRectangle((Brush $white), ($x + (2 + $col) * $cell), ($y + (2 + $row) * $cell), ($cell + 0.5), ($cell + 0.5))
    }
  }
}
function Magnifier([float]$cx, [float]$cy, [float]$radius, [float]$stroke = 16) {
  $a = [Math]::PI / 4
  $x1 = $cx + $radius * [Math]::Cos($a); $y1 = $cy + $radius * [Math]::Sin($a)
  $script:g.DrawLine((Pen $blue ($stroke * 2.2)), $x1, $y1, ($x1 + 0.9 * $radius), ($y1 + 0.9 * $radius))
  $script:g.DrawEllipse((Pen $blue $stroke), ($cx - $radius), ($cy - $radius), (2 * $radius), (2 * $radius))
}
# A gamepad, seen from above.
function Gamepad([float]$cx, [float]$cy, [float]$scale) {
  $body = New-Object System.Drawing.Drawing2D.GraphicsPath
  $body.AddEllipse(($cx - 330 * $scale), ($cy - 60 * $scale), (260 * $scale), (300 * $scale))
  $body.AddEllipse(($cx + 70 * $scale), ($cy - 60 * $scale), (260 * $scale), (300 * $scale))
  $body.AddPath((Rounded ($cx - 260 * $scale) ($cy - 150 * $scale) (520 * $scale) (240 * $scale) (90 * $scale)), $false)
  $region = New-Object System.Drawing.Region $body
  $script:g.FillRegion((Brush $pale), $region)
  foreach ($k in 0..1) {
    $sx = $cx + (-160 + 320 * $k) * $scale
    $script:g.FillEllipse((Brush $light), ($sx - 45 * $scale), ($cy + 30 * $scale), (90 * $scale), (90 * $scale))
    $script:g.DrawEllipse((Pen $blue (7 * $scale)), ($sx - 45 * $scale), ($cy + 30 * $scale), (90 * $scale), (90 * $scale))
  }
  $dx = $cx - 200 * $scale; $dy = $cy - 70 * $scale
  $script:g.FillRectangle((Brush $blue), ($dx - 14 * $scale), ($dy - 40 * $scale), (28 * $scale), (80 * $scale))
  $script:g.FillRectangle((Brush $blue), ($dx - 40 * $scale), ($dy - 14 * $scale), (80 * $scale), (28 * $scale))
  foreach ($b in @(@(0, -38), @(38, 0), @(0, 38), @(-38, 0))) {
    $bx = $cx + 200 * $scale + $b[0] * $scale; $by = $cy - 70 * $scale + $b[1] * $scale
    $script:g.FillEllipse((Brush $mid), ($bx - 16 * $scale), ($by - 16 * $scale), (32 * $scale), (32 * $scale))
  }
  $outline = Pen $blue (9 * $scale)
  $script:g.DrawEllipse($outline, ($cx - 330 * $scale), ($cy - 60 * $scale), (260 * $scale), (300 * $scale))
  $script:g.DrawEllipse($outline, ($cx + 70 * $scale), ($cy - 60 * $scale), (260 * $scale), (300 * $scale))
  $script:g.FillPath((Brush $pale), (Rounded ($cx - 250 * $scale) ($cy - 140 * $scale) (500 * $scale) (220 * $scale) (85 * $scale)))
  $script:g.DrawPath($outline, (Rounded ($cx - 260 * $scale) ($cy - 150 * $scale) (520 * $scale) (240 * $scale) (90 * $scale)))
  # Redraw the controls the body fill just covered.
  foreach ($k in 0..1) {
    $sx = $cx + (-160 + 320 * $k) * $scale
    $script:g.FillEllipse((Brush $light), ($sx - 45 * $scale), ($cy + 30 * $scale), (90 * $scale), (90 * $scale))
    $script:g.DrawEllipse((Pen $blue (7 * $scale)), ($sx - 45 * $scale), ($cy + 30 * $scale), (90 * $scale), (90 * $scale))
  }
  $script:g.FillRectangle((Brush $blue), ($dx - 14 * $scale), ($dy - 40 * $scale), (28 * $scale), (80 * $scale))
  $script:g.FillRectangle((Brush $blue), ($dx - 40 * $scale), ($dy - 14 * $scale), (80 * $scale), (28 * $scale))
  foreach ($b in @(@(0, -38), @(38, 0), @(0, 38), @(-38, 0))) {
    $bx = $cx + 200 * $scale + $b[0] * $scale; $by = $cy - 70 * $scale + $b[1] * $scale
    $script:g.FillEllipse((Brush $mid), ($bx - 16 * $scale), ($by - 16 * $scale), (32 * $scale), (32 * $scale))
  }
}
function Bubble([float]$x, [float]$y, [float]$wid, [float]$hei, [bool]$tailLeft, [System.Drawing.Color]$fill) {
  $path = Rounded $x $y $wid $hei 50
  $script:g.FillPath((Brush $fill), $path)
  $script:g.DrawPath((Pen $blue 9), $path)
  if ($tailLeft) { $pts = @(@(($x + 90), ($y + $hei - 4)), @(($x + 40), ($y + $hei + 90)), @(($x + 190), ($y + $hei - 4))) }
  else { $pts = @(@(($x + $wid - 190), ($y + $hei - 4)), @(($x + $wid - 40), ($y + $hei + 90)), @(($x + $wid - 90), ($y + $hei - 4))) }
  $tail = [System.Drawing.PointF[]]($pts | ForEach-Object { Pt $_[0] $_[1] })
  $script:g.FillPolygon((Brush $fill), $tail)
  $script:g.DrawLine((Pen $blue 9), $tail[0], $tail[1]); $script:g.DrawLine((Pen $blue 9), $tail[1], $tail[2])
}


# ---------------------------------------------------------------------------
# Chapter 1:  the robot object model.  The Field Guide's Chapter 6 picture.
New-Canvas
Label-Box 590 40 420 120 'OpMode' $blue 54
Arrow 800 160 800 215 7
Label-Box 590 220 420 120 'Robot' $light 54
Arrow 700 340 420 420 7
Arrow 900 340 1140 420 7
Label-Box 180 425 480 120 'DriveTrain' $white 52
Label-Box 880 425 540 120 'MechAssembly' $white 52
foreach ($k in 0..2) {
  $bx = 600 + 330 * $k
  Arrow (1150) 545 ($bx + 150) 635 6
  Label-Box $bx 640 310 110 'MechComponent' $pale 36
}
Save-Canvas 'ch01.png'

# ---------------------------------------------------------------------------
# Spot pictures:  small things from the shop and the field, for filling a
# large gap at the foot of a page.  finish_book.ps1 places them, sparingly.
# No words.

$W = 900; $Hgt = 900

New-Canvas
Gear 450 450 340 24 $pale 10 0
Save-Canvas 'spot_gear.png'

# A combination wrench.
New-Canvas
$g.TranslateTransform(450, 450); $g.RotateTransform(-40)
$g.FillPath((Brush $light), (Rounded -320 -45 640 90 40)); $g.DrawPath((Pen $blue 10), (Rounded -320 -45 640 90 40))
$g.FillEllipse((Brush $pale), -420, -110, 220, 220); $g.DrawEllipse((Pen $blue 10), -420, -110, 220, 220)
$g.FillEllipse((Brush $white), -360, -50, 100, 100); $g.DrawEllipse((Pen $blue 8), -360, -50, 100, 100)
$g.FillPie((Brush $pale), 200, -120, 240, 240, 0, 360); $g.DrawEllipse((Pen $blue 10), 200, -120, 240, 240)
$g.FillRectangle((Brush $white), 330, -45, 140, 90)
$g.DrawLine((Pen $blue 9), 330, -45, 430, -45); $g.DrawLine((Pen $blue 9), 330, 45, 430, 45); $g.DrawLine((Pen $blue 9), 330, -45, 330, 45)
$g.ResetTransform()
Save-Canvas 'spot_wrench.png'

New-Canvas
Tag 150 150 600
Save-Canvas 'spot_tag.png'

# A mecanum wheel, seen from the side:  rollers at 45 degrees.
New-Canvas
$rim = New-Object System.Drawing.Drawing2D.GraphicsPath
$rim.AddEllipse(110, 110, 680, 680)
$g.FillPath((Brush $pale), $rim)
$g.SetClip($rim)
for ($k = -6; $k -le 6; $k++) {
  $g.TranslateTransform((450 + 110 * $k), 450); $g.RotateTransform(45)
  $g.FillPath((Brush $light), (Rounded -45 -420 90 840 40)); $g.DrawPath((Pen $blue 7), (Rounded -45 -420 90 840 40))
  $g.ResetTransform()
}
$g.ResetClip()
$g.DrawEllipse((Pen $blue 12), 110, 110, 680, 680)
$g.FillEllipse((Brush $white), 360, 360, 180, 180); $g.DrawEllipse((Pen $blue 10), 360, 360, 180, 180)
Hexagon 450 450 40 $light 7
Save-Canvas 'spot_wheel.png'

# A battery pack.
New-Canvas
Box 170 260 560 420 $pale 12 30
$g.FillRectangle((Brush $blue), 290, 200, 90, 60); $g.FillRectangle((Brush $blue), 520, 200, 90, 60)
$bolt = [System.Drawing.PointF[]]@((Pt 480 320), (Pt 380 490), (Pt 450 490), (Pt 410 620), (Pt 530 440), (Pt 460 440), (Pt 510 320))
$g.FillPolygon((Brush $mid), $bolt); $g.DrawPolygon((Pen $blue 7), $bolt)
Save-Canvas 'spot_battery.png'

# A servo with its horn.
New-Canvas
Box 200 330 500 340 $pale 12 26
$g.FillRectangle((Brush $pale), 120, 450, 80, 100); $g.DrawRectangle((Pen $blue 10), 120, 450, 80, 100)
$g.FillRectangle((Brush $pale), 700, 450, 80, 100); $g.DrawRectangle((Pen $blue 10), 700, 450, 80, 100)
$g.FillEllipse((Brush $light), 310, 230, 140, 140); $g.DrawEllipse((Pen $blue 10), 310, 230, 140, 140)
$g.DrawLine((Pen $blue 30), 380, 300, 600, 190)
$g.FillEllipse((Brush $white), 360, 280, 40, 40)
Save-Canvas 'spot_servo.png'

# A bolt and a nyloc nut.
New-Canvas
Hexagon 300 300 150 $light 10
$g.FillRectangle((Brush $pale), 260, 440, 80, 380); $g.DrawRectangle((Pen $blue 9), 260, 440, 80, 380)
for ($i = 0; $i -lt 10; $i++) { $g.DrawLine((Pen $blue 5), 260, (460 + 36 * $i), 340, (482 + 36 * $i)) }
Hexagon 640 560 150 $pale 10
$g.FillEllipse((Brush $white), 570, 490, 140, 140); $g.DrawEllipse((Pen $blue 9), 570, 490, 140, 140)
$g.DrawEllipse((Pen $mid 8), 545, 465, 190, 190)
Save-Canvas 'spot_bolt.png'

# A game ball, mid-roll.
New-Canvas
$g.FillEllipse((Brush $light), 200, 180, 520, 520); $g.DrawEllipse((Pen $blue 12), 200, 180, 520, 520)
$g.DrawArc((Pen $blue 8), 260, 180, 400, 520, 270, 180)
$g.DrawArc((Pen $blue 8), 200, 300, 520, 280, 180, 180)
foreach ($k in 0..2) { $g.DrawLine((Pen $gray 10), (60 + 30 * $k), (560 + 50 * $k), (170 + 10 * $k), (560 + 50 * $k)) }
Save-Canvas 'spot_ball.png'
