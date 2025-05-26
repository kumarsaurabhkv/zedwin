param (
    [string]$RustFlags
)

if (-not $RustFlags) {
    Write-Host "No rustflags provided. Skipping setup."
    exit 0
}

# Ensure the .cargo directory exists
$cargoDir = ".cargo"
if (-not (Test-Path $cargoDir)) {
    New-Item -ItemType Directory -Path $cargoDir | Out-Null
    Write-Host "Created $cargoDir directory."
}

$configPath = "$cargoDir/config.toml"

# Load existing config or initialize a new object
if (Test-Path $configPath) {
    Write-Host "Loading existing $configPath"
    $config = Get-Content $configPath | ConvertFrom-Toml
} else {
    Write-Host "Creating new config object"
    $config = @{}
}

# Initialize [target.cfg(all())] if not present
if (-not $config.ContainsKey("target")) {
    $config["target"] = @{}
}

$targetKey = "cfg(all())"
if (-not $config["target"].ContainsKey($targetKey)) {
    $config["target"][$targetKey] = @{}
}

# Set rustflags as array
$rflagsArray = $RustFlags -split '\s+'
$config["target"][$targetKey]["rustflags"] = $rflagsArray

# Save the modified config back to the file
$config | ConvertTo-Toml -Depth 5 | Out-File -FilePath $configPath -Encoding UTF8

Write-Host "Set rustflags in $configPath:"
Write-Host ($rflagsArray -join " ")
