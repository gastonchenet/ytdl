#!/usr/bin/env pwsh

# Initializing variables
$YTDLRoot = if ($env:YTDL_INSTALL) { $env:YTDL_INSTALL } else { "$Home\.ytdl" }
$YTDLPath = "$YTDLRoot\ytdl.exe"

$FileName="ytdl-win-x64"
$URL = "https://github.com/gastonchenet/ytdl/releases/latest/download/$FileName.exe"

# Rebuilding the path to the executable
Remove-Item $YTDLRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path "$YTDLRoot" | Out-Null

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

Write-Output "YTDL succesfully installed!"

$CurrentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

if ($CurrentPath -notmatch [RegEx]::Escape("$YTDLRoot")) {
  $NewPath = "$CurrentPath;$YTDLRoot"
  [System.Environment]::SetEnvironmentVariable("Path", $NewPath, [System.EnvironmentVariableTarget]::User)
} else {
  Write-Warning "`nNote: Another ytdl.exe is already in %PATH% at $($Existing.Source)`nTyping 'ytdl' in your terminal will not use what was just installed."
}

Write-Output "`nStart another terminal to be able to use the command 'ytdl'"