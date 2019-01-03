Function Connect-Client{
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$Path
)

$user = Join-Path $Path "\storedUser.txt"
$pass = Join-Path $Path "\storedPassword.txt"

Import-Module MSOnline

#Get Credentials
$powerUser = Get-Content -Path $user
$Password = Get-Content -Path $pass | ConvertTo-SecureString
$O365Cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $powerUser,$Password

#Connect to Exchange Online
Write-Host "Connect-MsolService"
Connect-MsolService -Credential $O365Cred
Write-Host "Session"
$O365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $O365Cred -Authentication Basic -AllowRedirection
Write-Host "Import-PSSession"
Import-PSSession $O365Session -AllowClobber -DisableNameChecking

#Connect to SharePoint Online

$domains = Get-MsolDomain | Where-Object {$_.Name.EndsWith("onmicrosoft.com")} | Select Name
$firstDomainPart = $domains[0].Name.Split('.')[0]
$adminDomain = "https://"+$firstDomainPart+"-admin.sharepoint.com"
Connect-SPOService -Url $adminDomain -Credential $O365Cred
#Add PnP PowerShell Cmdlets
$spoDomain = "https://"+$firstDomainPart+".sharepoint.com"
Connect-PnPOnline -Url $spoDomain -Credentials $O365Cred

#Get Tenant Information
$domain = Get-MsolDomain | Where-Object {$_.IsDefault -eq "True"} | Select Name
$company = Get-MsolCompanyInformation | Select DisplayName
$windowTitle = $company.DisplayName + " Office 365 PowerShell"
$Host.UI.RawUI.WindowTitle = $windowTitle 
Write-Host
Write-Host "Connected to Office 365 tenant" $company.DisplayName -ForeGroundColor Green
Write-Host "Default domain is" $domain.Name -ForeGroundColor Green
Write-Host

}

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

function Get-IPGeolocation {

    param (
        [Parameter( Mandatory = $true)]
        [string]$ip
    )

    $resource = "http://api.ipstack.com/$($ipaddress)?access_key=c9574effa0947ca42c10bafa9542a28d"

    $geoip = Invoke-RestMethod -Method Get -URI $resource

    return $geoip

}


Export-ModuleMember -Function Connect-Client, New-Credential, Get-IPGeolocation 