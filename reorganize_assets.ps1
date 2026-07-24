# Set base directory (adjust path if running from another location)
$baseDir = "C:\Code\N-E-S\assets"
Set-Location $baseDir

Write-Host "Starting asset reorganization..." -ForegroundColor Cyan

# Helper function to move and rename safely
function Move-Asset ($src, $dest) {
    $fullSrc = Join-Path $baseDir $src
    $fullDest = Join-Path $baseDir $dest
    $destDir = Split-Path $fullDest -Parent

    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    if (Test-Path $fullSrc) {
        Move-Item -Path $fullSrc -Destination $fullDest -Force
        Write-Host "Moved: $src -> $dest" -ForegroundColor Green
    } else {
        Write-Host "Skip (Source missing): $src" -ForegroundColor Yellow
    }
}

# 1. Audio
Move-Asset "wavs\static1.wav" "audio\sfx\static_1.wav"

# 2. Fonts info files
Move-Asset "fonts\kindly_rewind_info.txt" "fonts\KindlyRewind-BOon.txt"
Move-Asset "fonts\raster_info.txt" "fonts\RasterForgeRegular-JpBgm.txt"

# 3. Sprites - Player Characters & Enemies
$playerFiles = @("idle_down.png", "idle_up.png", "idle_left.png", "idle_right.png", "run_down.png", "run_up.png", "run_left.png", "run_right.png", "lying_down.png")
foreach ($f in $playerFiles) {
    Move-Asset "pngs\mainChar\$f" "sprites\characters\player\$f"
}

Move-Asset "pngs\forestLevel\wendy.png" "sprites\characters\wendy\wendy.png"
Move-Asset "pngs\forestLevel\glitch_monster.png" "sprites\enemies\glitch_monster.png"

# 4. UI - Menu, HUD, and Icons
Move-Asset "ui\playBtn.png" "ui\menu\play_btn.png"
Move-Asset "ui\gearBtn.png" "ui\menu\gear_btn.png"
Move-Asset "ui\ejectBtn.png" "ui\menu\eject_btn.png"
Move-Asset "ui\btnRewind.png" "ui\menu\btn_rewind.png"

Move-Asset "ui\dialog1.png" "ui\hud\dialog_box.png"
Move-Asset "ui\triangle.png" "ui\hud\dialog_arrow.png"
Move-Asset "ui\greenBtns.png" "ui\hud\action_prompt.png"

Move-Asset "ui\dpadUp.png" "ui\icons\dpad_up.png"
Move-Asset "ui\dpadDown.png" "ui\icons\dpad_down.png"
Move-Asset "ui\dpadLeft.png" "ui\icons\dpad_left.png"
Move-Asset "ui\dpadRight.png" "ui\icons\dpad_right.png"

# 5. Worlds - Intro Room Rename & Asset Moves
Move-Asset "pngs\introRoom\floorWall16x16.png" "worlds\intro_room\floor_wall_16x16.png"
Move-Asset "pngs\introRoom\door16x32.png" "worlds\intro_room\door_16x32.png"
Move-Asset "pngs\introRoom\tileset_prison.png" "worlds\intro_room\tileset_prison.png"
Move-Asset "pngs\introRoom\crt_tv.png" "worlds\intro_room\crt_tv.png"

# Move existing intro Tiled files if they live in old worlds/intro/ folder
if (Test-Path "worlds\intro") {
    Get-ChildItem -Path "worlds\intro\*" | ForEach-Object {
        Move-Asset "worlds\intro\$($_.Name)" "worlds\intro_room\$($_.Name)"
    }
}

# 6. Cleanup empty legacy folders
Write-Host "Cleaning up old empty directories..." -ForegroundColor Yellow
$legacyDirs = @(
    "pngs\mainChar",
    "pngs\forestLevel",
    "pngs\introRoom",
    "pngs",
    "worlds\intro"
)

foreach ($dir in $legacyDirs) {
    $targetPath = Join-Path $baseDir $dir
    if ((Test-Path $targetPath) -and ((Get-ChildItem $targetPath -Recurse).Count -eq 0)) {
        Remove-Item -Path $targetPath -Force -Recurse
        Write-Host "Removed empty folder: $dir" -ForegroundColor DarkGray
    }
}

Write-Host "`nAsset reorganization complete!" -ForegroundColor Cyan