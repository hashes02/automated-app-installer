
# Automated Application Installer Script

This repository provides a PowerShell script that automates the installation of multiple applications on a fresh Windows system. The script:

- Downloads and installs the latest versions of specified applications.
- Checks if applications are already installed to avoid redundant installations.
- Handles silent installations with correct parameters.
- Logs installation progress and errors.
- Prompts for system reboot if required.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Applications Installed](#applications-installed)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Script Details](#script-details)
  - [Logging](#logging)
  - [Error Handling](#error-handling)
  - [Silent Install Parameters](#silent-install-parameters)
  - [Reboot Handling](#reboot-handling)
- [Customization](#customization)
  - [Adding Applications](#adding-applications)
  - [Modifying Silent Install Parameters](#modifying-silent-install-parameters)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

## Prerequisites

- **Windows 10 or later**: The script utilizes features available in Windows 10 and newer versions.
- **PowerShell**: Ensure you are running PowerShell 5.0 or higher.
- **Administrative Privileges**: The script must be run as an administrator.
- **Internet Connection**: Required to download applications and updates.
- **Execution Policy**: Set to allow script execution. You can set it temporarily using:

  ```powershell
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

---

## Applications Installed

The script automates the installation of the following applications:

1. **Visual Studio Code**
2. **Google Chrome**
3. **Discord**
4. **VLC Media Player**
5. **7-Zip**
6. **AnyDesk**
7. **Laravel Herd**
8. **Steam**
9. **GitHub Desktop**
10. **Razer 7.1 Surround Sound**
11. **Logitech G HUB**
12. **PuTTY**

---

## Getting Started

### Download the Script

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/hashes02/automated-app-installer.git
   ```

2. **Or Download Directly**:

   - Download the `InstallAllApps.ps1` script file from the repository.

---

## Usage

1. **Open PowerShell as Administrator**:

   - Right-click on the Start menu.
   - Select **Windows PowerShell (Admin)**.

2. **Navigate to the Script Directory**:

   ```powershell
   cd path\to\script\directory
   ```

3. **Run the Script**:

   ```powershell
   .\InstallAllApps.ps1
   ```

4. **Follow Prompts**:

   - If any application requires a system reboot, you will be prompted at the end of the script.
   - Enter `Y` to reboot immediately or `N` to reboot later.

---

## Script Details

### Logging

- **Log File Location**: `%USERPROFILE%\InstallAppsLog.txt` (e.g., `C:\Users\YourName\InstallAppsLog.txt`).
- **Information Logged**:
  - Installation start and completion messages.
  - Errors encountered during installation.
  - Reboot prompts and user responses.

### Error Handling

- The script uses `try-catch` blocks to handle exceptions.
- Errors are logged with `[ERROR]` in the log file for easy identification.

### Silent Install Parameters

- The script uses correct silent install parameters for each application to ensure installations proceed without user interaction.
- **Winget** handles silent installations internally using the `--silent` flag.

### Reboot Handling

- A global variable `$rebootRequired` tracks if a reboot is necessary.
- Applications known to require a reboot set this flag after installation.
- At the end of the script, if a reboot is required, the user is prompted to reboot immediately or postpone.

---

## Customization

### Adding Applications

To add more applications to the script:

1. **Check Winget Availability**:

   - Use `winget search <app name>` to find the application ID.

2. **Add to the `$wingetApps` Array**:

   ```powershell
   @{
       Name = "Application Name"
       Id = "Publisher.AppId"
       SilentArgs = "--silent"
   }
   ```

3. **For Non-Winget Applications**:

   - Find the official download URL.
   - Determine silent install parameters.
   - Add an installation block similar to existing ones in the script.

### Modifying Silent Install Parameters

If an application requires different silent install arguments:

1. **Locate the Application in the `$wingetApps` Array**.
2. **Modify the `SilentArgs` Property**:

   ```powershell
   SilentArgs = "--silent --additional-arguments"
   ```

---

## Security Considerations

- **Official Sources**: All download URLs point to official websites or trusted repositories.
- **Execution Policy**: Be cautious when changing execution policies. Only run scripts from trusted sources.
- **Administrative Rights**: Required for installing applications and managing system reboots.

---

## Troubleshooting

- **Script Not Running**:

  - Ensure you are running PowerShell as an administrator.
  - Check the execution policy: `Get-ExecutionPolicy -List`.

- **Applications Not Installing**:

  - Review the log file at `%USERPROFILE%\InstallAppsLog.txt` for errors.
  - Verify internet connectivity.

- **Reboot Prompt Not Appearing**:

  - Ensure applications that require a reboot call `Set-RebootRequired` in the script.

- **Silent Install Not Working**:

  - Verify silent install parameters for the application.
  - Consult the application's documentation or support resources.

---

## License

This script is provided under the [MIT License](LICENSE). You are free to use, modify, and distribute it as per the license terms.

---

**Disclaimer**: Always ensure you have the rights and licenses to download and install software. This script is provided as-is, and you should review and adjust it according to your specific needs and comply with all software licensing agreements.

---

**Author**: hashes

**Contact**: admin@hashes.me

**Repository**:  https://github.com/hashes02/automated-app-installer.git

---

## Contributions

Contributions are welcome! Please open an issue or submit a pull request for any improvements or additions.

---

# Appendices

## Full Script

For reference, here is the full `InstallAllApps.ps1` script:

```powershell
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
```

---

## Feedback and Support

If you encounter any issues or have suggestions for improvements, please open an issue on the repository or contact admin@hashes.me.

---

Thank you for using the Automated Application Installer Script!