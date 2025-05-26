param (
    [string]$RustFlags
)

if (-not $RustFlags) {
    Write-Host "No rustflags provided. Skipping setup."
    exit 0
}

$cargoDir = ".cargo"
if (-not (Test-Path $cargoDir)) {
    New-Item -ItemType Directory -Path $cargoDir | Out-Null
}

$configPath = "$cargoDir/config.toml"

# Load or initialize config
if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Toml
} else {
    $config = @{}
}

if (-not $config.ContainsKey("target")) {
    $config["target"] = @{}
}

$targetKey = "cfg(all())"
if (-not $config["target"].ContainsKey($targetKey)) {
    $config["target"][$targetKey] = @{}
}

$rflagsArray = $RustFlags -split '\s+'
$config["target"][$targetKey]["rustflags"] = $rflagsArray

$config | ConvertTo-Toml -Depth 5 | Out-File -FilePath $configPath -Encoding UTF8
Write-Host "Set rustflags in ${configPath}: $RustFlags"
