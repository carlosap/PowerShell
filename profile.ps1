# Welcome message
"You are now entering PowerShell : " + $env:Username

#repos folder
#$localpath = Join-Path $env:USERPROFILE 'some\path'
function repos { set-location "C:\Users\$env:Username\source\repos" }
function home { set-location $env:HOMEPATH }
function doc { set-location "C:\Users\$env:UserName\Documents" }

#show env vars
#Set-Alias -Name env -Value "gci env:* | sort-object name"
Import-Module posh-git
