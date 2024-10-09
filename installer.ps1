# Set script to stop on errors
$ErrorActionPreference = "Stop"

# Define the log file path
$logFile = "$env:USERPROFILE\InstallAppsLog.txt"

# Variable to track if a reboot is required
$global:rebootRequired = $false

# Function to log messages
function Log-Message {
    param (
        [string]$Message,
        [string]$Type = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Type] $Message"
    Write-Host $logEntry
    Add-Content -Path $logFile -Value $logEntry
}

# Function to check if an application is installed
function Is-AppInstalled {
    param (
        [string]$AppName
    )
    $app = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" `
        -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like "*$AppName*" }
    if ($app) {
        return $true
    } else {
        return $false
    }
}

# Function to set reboot flag
function Set-RebootRequired {
    $global:rebootRequired = $true
}

# Install applications via Winget
$wingetApps = @(
    @{
        Name = "Visual Studio Code"
        Id = "Microsoft.VisualStudioCode"
        SilentArgs = "--silent"
    },
    @{
        Name = "Google Chrome"
        Id = "Google.Chrome"
        SilentArgs = "--silent --accept-package-agreements --accept-source-agreements"
    },
    @{
        Name = "Discord"
        Id = "Discord.Discord"
        SilentArgs = "--silent"
    },
    @{
        Name = "VLC Media Player"
        Id = "VideoLAN.VLC"
        SilentArgs = "--silent"
    },
    @{
        Name = "7-Zip"
        Id = "7zip.7zip"
        SilentArgs = "--silent"
    },
    @{
        Name = "AnyDesk"
        Id = "AnyDesk.AnyDesk"
        SilentArgs = "--silent"
    },
    @{
        Name = "Steam"
        Id = "Valve.Steam"
        SilentArgs = "--silent"
    },
    @{
        Name = "GitHub Desktop"
        Id = "GitHub.GitHubDesktop"
        SilentArgs = "--silent"
    },
    @{
        Name = "Logitech G HUB"
        Id = "Logitech.GHUB"
        SilentArgs = "--silent"
    },
    @{
        Name = "PuTTY"
        Id = "PuTTY.PuTTY"
        SilentArgs = "--silent"
    }
)

foreach ($app in $wingetApps) {
    try {
        # Check if the app is already installed
        $installed = winget list --id $app.Id -q
        if ($installed) {
            Log-Message "$($app.Name) is already installed." "INFO"
        } else {
            Log-Message "Installing $($app.Name)..." "INFO"
            winget install --id=$($app.Id) $app.SilentArgs --accept-package-agreements --accept-source-agreements
            Log-Message "$($app.Name) installation completed." "INFO"
        }
    } catch {
        Log-Message "Failed to install $($app.Name): $_" "ERROR"
    }
}

# Install Laravel Herd
try {
    if (Is-AppInstalled "Herd") {
        Log-Message "Laravel Herd is already installed." "INFO"
    } else {
        Log-Message "Installing Laravel Herd..." "INFO"
        $herdUrl = "https://github.com/laravel/laravel-herd/releases/latest/download/HerdSetup.exe"
        $herdInstaller = "$env:TEMP\HerdSetup.exe"
        Invoke-WebRequest -Uri $herdUrl -OutFile $herdInstaller

        # Install Laravel Herd silently
        Start-Process -FilePath $herdInstaller -ArgumentList "/S" -Wait
        Log-Message "Laravel Herd installation completed." "INFO"
    }
} catch {
    Log-Message "Failed to install Laravel Herd: $_" "ERROR"
}

# Install Razer 7.1 Surround Sound
try {
    if (Is-AppInstalled "Razer Surround") {
        Log-Message "Razer 7.1 Surround Sound is already installed." "INFO"
    } else {
        Log-Message "Installing Razer 7.1 Surround Sound..." "INFO"
        $razerUrl = "https://dl.razerzone.com/drivers/7.1-surround-sound/7.1-surround-sound-win.exe"
        $razerInstaller = "$env:TEMP\Razer7.1SurroundSound.exe"
        Invoke-WebRequest -Uri $razerUrl -OutFile $razerInstaller

        # Install Razer 7.1 Surround Sound silently
        Start-Process -FilePath $razerInstaller -ArgumentList "/silent" -Wait
        Log-Message "Razer 7.1 Surround Sound installation completed." "INFO"

        # Razer 7.1 Surround Sound requires a reboot
        Set-RebootRequired
    }
} catch {
    Log-Message "Failed to install Razer 7.1 Surround Sound: $_" "ERROR"
}

# Check if a reboot is required and prompt the user
if ($rebootRequired) {
    Log-Message "One or more installations require a system reboot." "INFO"
    $response = Read-Host "Do you want to reboot now? (Y/N)"
    if ($response -eq "Y" -or $response -eq "y") {
        Log-Message "System reboot initiated by user." "INFO"
        Restart-Computer
    } else {
        Log-Message "System reboot postponed by user." "INFO"
    }
}

Log-Message "All applications have been processed." "INFO"
