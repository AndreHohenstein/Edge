
<#PSScriptInfo

.VERSION 1.0.1

.GUID 86f1ab54-a34b-42e9-9a67-09ff4992e897

.AUTHOR Andre Hohenstein Contact: a.hohenstein@outlook.com / https://twitter.com/AndreHohenstein

.COMPANYNAME Andre Hohenstein IT-Consulting & Training

.COPYRIGHT © 2020 by André Hohenstein - Alle Rechte vorbehalten

.TAGS Edge Script PowerShell Browser Download Microsoft Stable Dev Beta Policy Automation

.LICENSEURI

.PROJECTURI https://github.com/AndreHohenstein/Edge

.ICONURI https://raw.githubusercontent.com/AndreHohenstein/Edge/main/media/powershell.png

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
1.0.0 Initial .ps1 script version of Download-MicrosoftEdge
1.0.1 Change in Invoke-WebRequest UseBasicParsing added and new Project-URL

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Download Microsoft Edge with PowerShell 5.1 or PowerShellCore 7.03

#> 
[CmdletBinding()]
param(
  [Parameter(Mandatory = $True, HelpMessage = 'Channel to download, Valid Options are: Dev, Beta, Stable, EdgeUpdate, Policy')]
  [ValidateSet('Dev', 'Beta', 'Stable', 'EdgeUpdate', 'Policy')]
  [string]$Channel,    
  [Parameter(Mandatory = $True, HelpMessage = 'Folder where the file will be downloaded')]
  [ValidateNotNullOrEmpty()]
  [string]$Folder,
  [Parameter(Mandatory = $false, HelpMessage = 'Platform to download, Valid Options are: Windows or MacOS')]
  [ValidateSet('Windows', 'MacOS', 'any')]
  [string]$Platform = "Windows",
  [Parameter(Mandatory = $false, HelpMessage = "Architecture to download, Valid Options are: x86, x64, arm64, any")]
  [ValidateSet('x86', 'x64', 'arm64', 'any')]
  [string]$Architecture = "x64",
  [parameter(Mandatory = $false, HelpMessage = "Specifies which version to download")]
  [ValidateNotNullOrEmpty()]
  [string]$ProductVersion,
  [parameter(Mandatory = $false, HelpMessage = "Overwrites the file without asking")]
  [Switch]$Force
)

Write-Host "Getting available files from https://edgeupdates.microsoft.com/api/products?view=enterprise" -ForegroundColor Green
$response = Invoke-WebRequest -Uri "https://edgeupdates.microsoft.com/api/products?view=enterprise" -Method Get -ContentType "application/json" -ErrorAction Stop -UseBasicParsing
$jsonObj = ConvertFrom-Json $([String]::new($response.Content))
Write-Host "Succefully retrived data" -ForegroundColor Green

$SelectedIndex = [array]::indexof($jsonObj.Product, "$Channel")

if ([string]::IsNullOrEmpty($ProductVersion)) {
  Write-host "No version specified, getting the latest for $Channel" -ForegroundColor Green
  $SelectedVersion = (([Version[]](($jsonObj[$SelectedIndex].Releases | Where-Object { $_.Architecture -eq $Architecture -and $_.Platform -eq $Platform }).ProductVersion) | Sort-Object -Descending)[0]).ToString(4)
  Write-Host "Latest Version for Chanel $Channel is $SelectedVersion" -ForegroundColor Green
  $SelectedObject = $jsonObj[$SelectedIndex].Releases | Where-Object { $_.Architecture -eq $Architecture -and $_.Platform -eq $Platform -and $_.ProductVersion -eq $SelectedVersion }
}
else {
  Write-Host "Matching $ProductVersion on Channel $Channel" -ForegroundColor Green
  $SelectedObject = ($jsonObj[$SelectedIndex].Releases | Where-Object { $_.Architecture -eq $Architecture -and $_.Platform -eq $Platform -and $_.ProductVersion -eq $ProductVersion })
  $SelectedObject
  If ($null -eq $SelectedObject) {
    Write-Host "No version matching $ProductVersion found using Channel $channel and Arch $Architecture!" -ForegroundColor Red
    break
  }
  else {
    Write-Host "Found matchings version" -ForegroundColor Green
    $SelectedObject
  }
}

$FileName = ($SelectedObject.Artifacts.Location -split "/")[-1]
Write-Host "File to be downloaded $FileName" -ForegroundColor Green
Write-host "Starting download of $($SelectedObject.Artifacts.Location)" -ForegroundColor Green
if (Test-Path $Folder) {
  if (Test-Path "$Folder\$FileName" -ErrorAction SilentlyContinue) {
    If ($Force) {
      Write-Host "Using Force and to Download and overwrite existing file." -ForegroundColor Green
      Invoke-WebRequest -Uri $SelectedObject.Artifacts.Location -OutFile "$Folder\$FileName" -ErrorAction Stop  
    }
    else {
      Write-Host "$Folder\$FileName already exists!" -ForegroundColor Yellow
      $OverWrite = Read-Host -Prompt "Press Y to overwrite or N to quit." 
      if ($OverWrite -eq "Y") {
        Write-Host "Starting Download" -ForegroundColor Green
        Invoke-WebRequest -Uri $SelectedObject.Artifacts.Location -OutFile "$Folder\$FileName" -ErrorAction Stop
      }
      else {
        Write-Host "User aborted, will not overwrite file." -ForegroundColor Red  
        break
      }
    }
  }
  else {
    Invoke-WebRequest -Uri $SelectedObject.Artifacts.Location -OutFile "$Folder\$FileName" -ErrorAction Stop
  }
  
}
else {
  Write-Host "Folder $Folder does not exist" -ForegroundColor Red
  break
}

if (((Get-FileHash -Algorithm $SelectedObject.Artifacts.HashAlgorithm -Path "$Folder\$FileName").Hash) -eq $SelectedObject.Artifacts.Hash) {
  Write-Host "CheckSum OK" -ForegroundColor Green
}
else {
  Write-host "Checksum mismatch!" -ForegroundColor Red
  Write-Host "Expected Hash : $($SelectedObject.Artifacts.Hash)" -ForegroundColor Yellow
  Write-Host "Downloaded file Hash : $((Get-FileHash -Algorithm $SelectedObject.Artifacts.HashAlgorithm -Path "$Folder\$FileName").Hash)" -ForegroundColor Yellow
}
Write-Host " -- Completed --" -ForegroundColor Green