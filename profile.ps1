Import-Module posh-git
# Welcome message
"You are now entering PowerShell : " + $env:Username

#repos folder
#$localpath = Join-Path $env:USERPROFILE 'some\path'
function repos { set-location "C:\Users\$env:Username\source\repos" }
function home { set-location $env:HOMEPATH }
function doc { set-location "C:\Users\$env:UserName\Documents" }

#Android Emulator - make sure you installed in the default location
function androids { 
    set-location "C:\Users\$env:Username\AppData\Local\Android\Sdk\emulator"
    .\emulator.exe -list-avds
}

function android {
    ##TODO HERE.. check for filepath etc.
    set-location "C:\Users\$env:Username\AppData\Local\Android\Sdk\emulator"     
    $device = .\emulator.exe -list-avds -n 1
    write-host "Starting device..$device"
    .\emulator.exe -avd $device
  
}

#show env vars
#Set-Alias -Name env -Value "gci env:* | sort-object name"

