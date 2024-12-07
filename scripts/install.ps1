#!/usr/bin/env pwsh

# Initializing variables
$YTDLRoot = if ($env:YTDL_INSTALL) { $env:YTDL_INSTALL } else { "$Home\.ytdl" }
$YTDLPath = "$YTDLRoot\ytdl.zip"

$FileName="ytdl-win-x64"
$URL = "https://github.com/gastonchenet/ytdl/releases/latest/download/$FileName.zip"

# Rebuilding the path to the executable
Remove-Item $YTDLRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path "$YTDLRoot\bin" | Out-Null

# Downloading the executable with curl or Invoke-RestMethod
curl.exe -#SfLo $YTDLPath $URL

if ($LASTEXITCODE -ne 0) {
  Invoke-RestMethod -Uri $URL -OutFile $YTDLPath
}

# Checking if the download was successful
if (!(Test-Path $YTDLPath)) {
  Write-Output "Install Failed - could not download $URL"
  Write-Output "The file '$YTDLPath' does not exist. Did an antivirus delete it?`n"
  return 1
}

# Unzipping the executable
try {
  Expand-Archive $YTDLPath $YTDLRoot -Force
} catch {
  Write-Output "Install Failed - could not unzip $YTDLPath"
  Write-Error $_

  return 1
}

# Moving the executable to the bin folder
Move-Item -Path "$YTDLRoot\$FileName.exe" -Destination "$YTDLRoot\bin\ytdl.exe" -Force

# Cleaning up the zip file
Remove-Item $YTDLPath -Force

Write-Output "YTDL succesfully installed!"

$CurrentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

if ($CurrentPath -notmatch [RegEx]::Escape("$YTDLRoot\bin")) {
  $NewPath = "$CurrentPath;$YTDLRoot\bin"
  [System.Environment]::SetEnvironmentVariable("Path", $NewPath, [System.EnvironmentVariableTarget]::User)
} else {
  Write-Warning "`nNote: Another ytdl.exe is already in %PATH% at $($Existing.Source)`nTyping 'ytdl' in your terminal will not use what was just installed."
}

Write-Output "`nStart another terminal to be able to use the command 'ytdl'"

# Adding the uninstall script
$rootKey = $null

try {
  $RegistryKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\YTDL"  
  $rootKey = New-Item -Path $RegistryKey -Force

  New-ItemProperty -Path $RegistryKey -Name "DisplayName" -Value "YTDL" -PropertyType String -Force | Out-Null
  New-ItemProperty -Path $RegistryKey -Name "InstallLocation" -Value "$YTDLRoot" -PropertyType String -Force | Out-Null
  New-ItemProperty -Path $RegistryKey -Name "DisplayIcon" -Value "$YTDLRoot\bin\ytdl.exe" -PropertyType String -Force | Out-Null
  New-ItemProperty -Path $RegistryKey -Name "UninstallString" -Value "powershell -c `"& `'$YTDLRoot\uninstall.ps1`' -PauseOnError`" -ExecutionPolicy Bypass" -PropertyType String -Force | Out-Null
} catch {
  if ($null -ne $rootKey) {
    Remove-Item -Path $RegistryKey -Force
  }
}