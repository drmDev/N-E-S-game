# Set the base assets directory (adjust if running from elsewhere)
$baseDir = "C:\Code\N-E-S\assets"
Set-Location $baseDir

Write-Host "Starting asset directory restructuring..." -ForegroundColor Cyan

# 1. Create the new directory structure
$newDirs = @(
    "audio\music",
    "audio\sfx",
    "ui",
    "worlds\intro",
    "worlds\forest_glitch"
)

foreach ($dir in $newDirs) {
    $targetPath = Join-Path $baseDir $dir
    if (-not (Test-Path $targetPath)) {
        New-Item -ItemType Directory -Path $targetPath | Out-Null
        Write-Host "Created directory: $dir" -ForegroundColor Green
    }
}

# 2. Move Audio Files (combining oggs & wavs)
if (Test-Path "oggs") {
    Move-Item -Path "oggs\intro.ogg" -Destination "audio\music\" -ErrorAction SilentlyContinue
    Move-Item -Path "oggs\nav.ogg" -Destination "audio\sfx\" -ErrorAction SilentlyContinue
}
if (Test-Path "wavs") {
    Move-Item -Path "wavs\select.wav" -Destination "audio\sfx\" -ErrorAction SilentlyContinue
    Move-Item -Path "wavs\static1.wav" -Destination "audio\sfx\" -ErrorAction SilentlyContinue
}

# 3. Move General UI Graphics
$uiFiles = @(
    "btnRewind.png", "dialog1.png", "dpadDown.png", "dpadLeft.png",
    "dpadRight.png", "dpadUp.png", "ejectBtn.png", "gearBtn.png",
    "greenBtns.png", "playBtn.png", "triangle.png"
)
foreach ($file in $uiFiles) {
    if (Test-Path "pngs\$file") {
        Move-Item -Path "pngs\$file" -Destination "ui\" -ErrorAction SilentlyContinue
    }
}

# 4. Move Intro World Assets (Maps + introRoom PNGs)
if (Test-Path "maps") {
    Move-Item -Path "maps\*" -Destination "worlds\intro\" -ErrorAction SilentlyContinue
}
if (Test-Path "pngs\introRoom") {
    Move-Item -Path "pngs\introRoom\*" -Destination "worlds\intro\" -ErrorAction SilentlyContinue
}

# 5. Move Forest Glitch Tape Assets
if (Test-Path "pngs\tapes\forestGlitch") {
    Move-Item -Path "pngs\tapes\forestGlitch\*" -Destination "worlds\forest_glitch\" -ErrorAction SilentlyContinue
}

# 6. Clean up empty legacy directories
Write-Host "Cleaning up old empty folders..." -ForegroundColor Yellow
$legacyDirs = @(
    "pngs\introRoom",
    "pngs\tapes\forestGlitch",
    "pngs\tapes",
    "pngs",
    "oggs",
    "wavs",
    "maps"
)

foreach ($dir in $legacyDirs) {
    $targetPath = Join-Path $baseDir $dir
    if ((Test-Path $targetPath) -and ((Get-ChildItem $targetPath -Recurse).Count -eq 0)) {
        Remove-Item -Path $targetPath -Force
        Write-Host "Removed empty folder: $dir" -ForegroundColor DarkGray
    }
}

Write-Host "Asset restructuring complete!" -ForegroundColor Cyan