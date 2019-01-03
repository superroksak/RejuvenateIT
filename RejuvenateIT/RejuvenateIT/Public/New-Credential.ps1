function New-Credential {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 1)]
        [string]$Path,
        [Parameter(Mandatory = $False, Position = 2)]
        [switch]$Force
    )

    $fileNameUser = Join-Path $Path "\storedUser.txt"
    $fileNamePass = Join-Path $Path "\storedPassword.txt"

    if (-not (Test-Path $Path)) {
        Write-Host "Creating new folder $($Path)"
        New-Item -Path $Path -ItemType Directory
    }

    if (Test-Path $fileNameUser) {
        Write-Host "There is already a user file for this client" -Foregroundcolor Yellow
    }
    else {
        Write-Host "Enter the username for the global admin account in Office 365:"
        $secureString = Read-Host
        $secureString | Out-File $fileNameUser
    }

    if ((Test-Path $fileNamePass) -and (-not $Force)) {
        Write-Host "There is already a password file for this client" -Foregroundcolor Yellow    
    }
    else {
        Write-Host "Enter the password for the global admin account in Office 365:"
        $secureString = Read-Host -AsSecureString
        $secureString | ConvertFrom-SecureString | Out-File $fileNamePass
    }
}