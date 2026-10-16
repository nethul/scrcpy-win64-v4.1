$ErrorActionPreference = 'Stop'

function Read-Setting {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Label,

        [Parameter(Mandatory = $true)]
        [string] $Default,

        [Parameter(Mandatory = $true)]
        [scriptblock] $IsValid,

        [Parameter(Mandatory = $true)]
        [string] $ErrorMessage
    )

    while ($true) {
        $value = Read-Host "$Label [$Default]"
        if ([string]::IsNullOrWhiteSpace($value)) {
            $value = $Default
        }

        $value = $value.Trim()
        if (& $IsValid $value) {
            return $value
        }

        Write-Host $ErrorMessage -ForegroundColor Yellow
    }
}

$cameraId = Read-Setting `
    -Label 'Camera ID' `
    -Default '2' `
    -IsValid { param($value) $value -match '^\d+$' } `
    -ErrorMessage 'Enter a numeric camera ID, for example 0 or 2.'

$shutter = Read-Setting `
    -Label 'Shutter duration' `
    -Default '1ms' `
    -IsValid { param($value) $value -match '^[1-9]\d*(ns|us|ms|s)$' } `
    -ErrorMessage 'Enter a positive integer followed by ns, us, ms, or s (for example 1ms or 8333us).'

$iso = Read-Setting `
    -Label 'ISO' `
    -Default '200' `
    -IsValid { param($value) $value -match '^[1-9]\d*$' } `
    -ErrorMessage 'Enter a positive whole number, for example 100, 200, or 400.'

$validOrientations = @(
    '0', '90', '180', '270',
    'flip0', 'flip90', 'flip180', 'flip270',
    '@0', '@90', '@180', '@270',
    '@flip0', '@flip90', '@flip180', '@flip270'
)

$orientation = Read-Setting `
    -Label 'Capture orientation' `
    -Default '@flip270' `
    -IsValid { param($value) $value -cin $validOrientations } `
    -ErrorMessage 'Use 0, 90, 180, 270, flip0, flip90, flip180, or flip270, optionally prefixed by @.'

$scrcpy = Join-Path $PSScriptRoot 'scrcpy.exe'
if (-not (Test-Path -LiteralPath $scrcpy -PathType Leaf)) {
    Write-Host "scrcpy.exe was not found beside this launcher: $scrcpy" -ForegroundColor Red
    exit 1
}

$scrcpyArguments = @(
    '--video-source=camera'
    "--camera-id=$cameraId"
    "--camera-shutter=$shutter"
    "--camera-iso=$iso"
    '--no-audio'
    '--shm-sink=tab'
    "--capture-orientation=$orientation"
    '--no-window'
    '-m1280'
)

Write-Host ''
Write-Host 'Starting scrcpy with:' -ForegroundColor Cyan
Write-Host "  Camera ID:   $cameraId"
Write-Host "  Shutter:     $shutter"
Write-Host "  ISO:         $iso"
Write-Host "  Orientation: $orientation"
Write-Host ''

& $scrcpy @scrcpyArguments
exit $LASTEXITCODE
