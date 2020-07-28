PowerShell Scripts for Microsoft Edge

Available parameters:

Channel (Mandatory)
Channel to download, Valid Options are: Dev, Beta, Stable, EdgeUpdate, Policy.
Folder (Mandatory)
Where the file will be downloaded to
Platform
Platform to download, Valid Options are: Windows or MacOS, if using channel "Policy" this should be set to "any"
Defaults to Windows if not set.
Architecture
Architecture to download, Valid Options are: x86, x64, arm64, if using channel "Policy" this should be set to "any"
Defaults to x64 if not set.
Version
If set the script will try and download a specific version. If not set it will download the latest.
Force
Overwrites the file without asking.
Downloads the MSI into C:\Temp and overwrites any previous file already there.

Example:
.\Download-MicrosoftEdge.ps1 -Channel Stable -Folder C:\temp -Force

Example:
.\Download-MicrosoftEdge.ps1 -Channel Stable -Version 82.1.2.54  -Folder C:\temp -Force

Example:
.\Download-MicrosoftEdge.ps1 -Channel Beta -Folder C:\temp -Force

Example:
.\Download-MicrosoftEdge.ps1 -Channel Dev -Folder C:\temp -Force
