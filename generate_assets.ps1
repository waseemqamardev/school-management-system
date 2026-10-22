Add-Type -AssemblyName System.Drawing

$assetsDir = "C:\Users\imwas\.gemini\antigravity\scratch\darearqam_school\assets\images"
if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Force -Path $assetsDir | Out-Null
}

function Create-SchoolLogo {
    $bmp = New-Object System.Drawing.Bitmap 512, 512
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.Clear([System.Drawing.Color]::Transparent)

    $goldBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(212, 175, 55))
    $emeraldBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush (New-Object System.Drawing.Point 256, 32), (New-Object System.Drawing.Point 256, 480), ([System.Drawing.Color]::FromArgb(15, 81, 50)), ([System.Drawing.Color]::FromArgb(8, 51, 32))
    $whiteBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)

    # Outer Gold Ring
    $g.FillEllipse($goldBrush, 16, 16, 480, 480)

    # Deep Emerald Inner Circle
    $g.FillEllipse($emeraldBrush, 32, 32, 448, 448)

    # Inner Gold Dashed Ring
    $innerGoldPen = New-Object System.Drawing.Pen $goldBrush, 4
    $innerGoldPen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
    $g.DrawEllipse($innerGoldPen, 46, 46, 420, 420)

    # Top Star & Crescent
    $g.FillEllipse($goldBrush, 236, 75, 40, 40)
    $darkEmerald = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(12, 65, 40))
    $g.FillEllipse($darkEmerald, 246, 72, 34, 34)

    # Small 5-point star
    $starPts = [System.Drawing.Point[]]@(
        (New-Object System.Drawing.Point 270, 85),
        (New-Object System.Drawing.Point 274, 94),
        (New-Object System.Drawing.Point 283, 94),
        (New-Object System.Drawing.Point 276, 100),
        (New-Object System.Drawing.Point 278, 108),
        (New-Object System.Drawing.Point 270, 103),
        (New-Object System.Drawing.Point 262, 108),
        (New-Object System.Drawing.Point 264, 100),
        (New-Object System.Drawing.Point 257, 94),
        (New-Object System.Drawing.Point 266, 94)
    )
    $g.FillPolygon($goldBrush, $starPts)

    # Open Book
    $leftPage = [System.Drawing.Point[]]@(
        (New-Object System.Drawing.Point 252, 175),
        (New-Object System.Drawing.Point 135, 190),
        (New-Object System.Drawing.Point 135, 290),
        (New-Object System.Drawing.Point 252, 275)
    )
    $g.FillPolygon($whiteBrush, $leftPage)

    $rightPage = [System.Drawing.Point[]]@(
        (New-Object System.Drawing.Point 260, 175),
        (New-Object System.Drawing.Point 377, 190),
        (New-Object System.Drawing.Point 377, 290),
        (New-Object System.Drawing.Point 260, 275)
    )
    $g.FillPolygon($whiteBrush, $rightPage)

    # Gold lines on pages
    $linePen = New-Object System.Drawing.Pen $goldBrush, 3
    $g.DrawLine($linePen, 155, 215, 230, 205)
    $g.DrawLine($linePen, 155, 235, 230, 225)
    $g.DrawLine($linePen, 155, 255, 230, 245)
    $g.DrawLine($linePen, 282, 205, 357, 215)
    $g.DrawLine($linePen, 282, 225, 357, 235)
    $g.DrawLine($linePen, 282, 245, 357, 255)

    # Rehal stand
    $woodPen = New-Object System.Drawing.Pen $goldBrush, 8
    $g.DrawLine($woodPen, 175, 315, 337, 260)
    $g.DrawLine($woodPen, 337, 315, 175, 260)

    # Golden Banner at Bottom
    $bannerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush (New-Object System.Drawing.Point 80, 360), (New-Object System.Drawing.Point 432, 420), ([System.Drawing.Color]::FromArgb(245, 158, 11)), ([System.Drawing.Color]::FromArgb(217, 119, 6))
    $bannerPts = [System.Drawing.Point[]]@(
        (New-Object System.Drawing.Point 70, 380),
        (New-Object System.Drawing.Point 90, 355),
        (New-Object System.Drawing.Point 422, 355),
        (New-Object System.Drawing.Point 442, 380),
        (New-Object System.Drawing.Point 422, 415),
        (New-Object System.Drawing.Point 90, 415)
    )
    $g.FillPolygon($bannerBrush, $bannerPts)
    $borderPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), 2
    $g.DrawPolygon($borderPen, $bannerPts)

    $font = New-Object System.Drawing.Font ('Arial', [float]20, [System.Drawing.FontStyle]::Bold)
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString('DAR-E-ARQAM', $font, $whiteBrush, [float]256, [float]385, $sf)

    $subFont = New-Object System.Drawing.Font ('Arial', [float]12, [System.Drawing.FontStyle]::Bold)
    $g.DrawString('SCHOOLS SYSTEM', $subFont, $goldBrush, [float]256, [float]435, $sf)

    $bmp.Save("$assetsDir\dar_e_arqam_logo.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Output "dar_e_arqam_logo.png created!"
}

function Create-BoyAvatar {
    $bmp = New-Object System.Drawing.Bitmap 256, 256
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)

    # Background circle
    $bgBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(209, 231, 221))
    $g.FillEllipse($bgBrush, 8, 8, 240, 240)

    # Hair (Back)
    $hairBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(35, 25, 20))
    $g.FillEllipse($hairBrush, 68, 40, 120, 120)

    # Face
    $skinBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(245, 195, 150))
    $g.FillEllipse($skinBrush, 83, 65, 90, 95)

    # Hair (Front/Bangs)
    $bangs = [System.Drawing.Point[]]@(
        (New-Object System.Drawing.Point 78, 65),
        (New-Object System.Drawing.Point 128, 48),
        (New-Object System.Drawing.Point 178, 65),
        (New-Object System.Drawing.Point 160, 85),
        (New-Object System.Drawing.Point 130, 75),
        (New-Object System.Drawing.Point 95, 85)
    )
    $g.FillPolygon($hairBrush, $bangs)

    # Eyes & Smile
    $eyeBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(40, 40, 40))
    $g.FillEllipse($eyeBrush, 105, 100, 10, 12)
    $g.FillEllipse($eyeBrush, 141, 100, 10, 12)
    $smilePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(180, 80, 60)), 3
    $g.DrawArc($smilePen, 115, 115, 26, 20, 0, 180)

    # School Uniform (Dar-e-Arqam Emerald Blazer/Shirt)
    $uniformBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(15, 81, 50))
    $g.FillPie($uniformBrush, 38, 155, 180, 180, 180, 180)

    # White Shirt Collar
    $whiteBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
    $collarL = [System.Drawing.Point[]]@(
        (New-Object System.Drawing.Point 128, 160),
        (New-Object System.Drawing.Point 105, 190),
        (New-Object System.Drawing.Point 128, 205)
    )
    $collarR = [System.Drawing.Point[]]@(
        (New-Object System.Drawing.Point 128, 160),
        (New-Object System.Drawing.Point 151, 190),
        (New-Object System.Drawing.Point 128, 205)
    )
    $g.FillPolygon($whiteBrush, $collarL)
    $g.FillPolygon($whiteBrush, $collarR)

    # Green & Gold Tie
    $tieBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(212, 175, 55))
    $tie = [System.Drawing.Point[]]@(
        (New-Object System.Drawing.Point 124, 185),
        (New-Object System.Drawing.Point 132, 185),
        (New-Object System.Drawing.Point 135, 240),
        (New-Object System.Drawing.Point 128, 250),
        (New-Object System.Drawing.Point 121, 240)
    )
    $g.FillPolygon($tieBrush, $tie)

    $bmp.Save("$assetsDir\avatar_student_boy.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Output "avatar_student_boy.png created!"
}

function Create-GirlAvatar {
    $bmp = New-Object System.Drawing.Bitmap 256, 256
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)

    # Background circle
    $bgBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(254, 243, 199))
    $g.FillEllipse($bgBrush, 8, 8, 240, 240)

    # Scarf / Hijab (White with soft shadow)
    $hijabBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
    $hijabShadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(220, 225, 230))
    $g.FillEllipse($hijabShadow, 65, 38, 126, 140)
    $g.FillEllipse($hijabBrush, 68, 40, 120, 136)

    # Face Cutout
    $skinBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(245, 195, 150))
    $g.FillEllipse($skinBrush, 88, 70, 80, 88)

    # Eyes & Smile
    $eyeBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(40, 40, 40))
    $g.FillEllipse($eyeBrush, 106, 102, 9, 11)
    $g.FillEllipse($eyeBrush, 141, 102, 9, 11)
    $smilePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(180, 80, 60)), 3
    $g.DrawArc($smilePen, 116, 118, 24, 18, 0, 180)

    # School Uniform Body (Emerald)
    $uniformBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(15, 81, 50))
    $g.FillPie($uniformBrush, 38, 160, 180, 180, 180, 180)

    # Scarf Drapes across shoulders
    $drapeBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(248, 250, 252))
    $drapePts = [System.Drawing.Point[]]@(
        (New-Object System.Drawing.Point 88, 148),
        (New-Object System.Drawing.Point 128, 175),
        (New-Object System.Drawing.Point 168, 148),
        (New-Object System.Drawing.Point 178, 195),
        (New-Object System.Drawing.Point 78, 195)
    )
    $g.FillPolygon($drapeBrush, $drapePts)

    $bmp.Save("$assetsDir\avatar_student_girl.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Output "avatar_student_girl.png created!"
}

function Create-TrophyBadge {
    $bmp = New-Object System.Drawing.Bitmap 256, 256
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)

    $goldBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush (New-Object System.Drawing.Point 64, 40), (New-Object System.Drawing.Point 192, 180), ([System.Drawing.Color]::FromArgb(252, 211, 77)), ([System.Drawing.Color]::FromArgb(217, 119, 6))
    $darkGold = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(180, 83, 9))
    $woodBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(15, 81, 50)) # School emerald base

    # Trophy Cup
    $cupPts = [System.Drawing.Point[]]@(
        (New-Object System.Drawing.Point 70, 50),
        (New-Object System.Drawing.Point 186, 50),
        (New-Object System.Drawing.Point 176, 125),
        (New-Object System.Drawing.Point 128, 155),
        (New-Object System.Drawing.Point 80, 125)
    )
    $g.FillPolygon($goldBrush, $cupPts)

    # Handles
    $handlePen = New-Object System.Drawing.Pen $goldBrush, 8
    $g.DrawArc($handlePen, 45, 60, 45, 50, 90, 180)
    $g.DrawArc($handlePen, 166, 60, 45, 50, 270, 180)

    # Stem
    $g.FillRectangle($darkGold, 120, 155, 16, 30)

    # Base
    $g.FillRectangle($woodBrush, 86, 185, 84, 28)
    $goldPlate = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(254, 240, 138))
    $g.FillRectangle($goldPlate, 96, 191, 64, 16)

    # Star on cup
    $starBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
    $starPts = [System.Drawing.Point[]]@(
        (New-Object System.Drawing.Point 128, 75),
        (New-Object System.Drawing.Point 133, 88),
        (New-Object System.Drawing.Point 146, 88),
        (New-Object System.Drawing.Point 136, 96),
        (New-Object System.Drawing.Point 140, 108),
        (New-Object System.Drawing.Point 128, 101),
        (New-Object System.Drawing.Point 116, 108),
        (New-Object System.Drawing.Point 120, 96),
        (New-Object System.Drawing.Point 110, 88),
        (New-Object System.Drawing.Point 123, 88)
    )
    $g.FillPolygon($starBrush, $starPts)

    $bmp.Save("$assetsDir\trophy_badge.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Output "trophy_badge.png created!"
}

function Create-EmptyDiary {
    $bmp = New-Object System.Drawing.Bitmap 256, 256
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)

    # Soft glowing circle
    $glowBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(240, 253, 244))
    $g.FillEllipse($glowBrush, 12, 12, 232, 232)

    # Open Notebook
    $coverBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(15, 81, 50))
    $pageBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)

    # Cover back
    $g.FillRectangle($coverBrush, 40, 55, 176, 140)

    # Pages
    $g.FillRectangle($pageBrush, 46, 60, 80, 130)
    $g.FillRectangle($pageBrush, 130, 60, 80, 130)

    # Page ruled lines
    $rulePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(226, 232, 240)), 2
    for ($y = 80; $y -le 170; $y += 18) {
        $g.DrawLine($rulePen, 54, $y, 118, $y)
        $g.DrawLine($rulePen, 138, $y, 202, $y)
    }

    # Bookmark ribbon
    $ribbonBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(212, 175, 55))
    $g.FillRectangle($ribbonBrush, 124, 50, 8, 80)

    # Checkmark badge
    $checkBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(16, 185, 129))
    $g.FillEllipse($checkBrush, 160, 145, 48, 48)
    $checkPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), 4
    $g.DrawLines($checkPen, [System.Drawing.Point[]]@(
        (New-Object System.Drawing.Point 172, 168),
        (New-Object System.Drawing.Point 180, 176),
        (New-Object System.Drawing.Point 196, 158)
    ))

    $bmp.Save("$assetsDir\empty_diary.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Output "empty_diary.png created!"
}

Create-SchoolLogo
Create-BoyAvatar
Create-GirlAvatar
Create-TrophyBadge
Create-EmptyDiary
Write-Output "ALL ASSETS GENERATED SUCCESSFULLY!"
