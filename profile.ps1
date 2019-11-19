Import-Module posh-git
# Welcome message
"You are now entering PowerShell : " + $env:Username

#------------------------------------------------------------------------------------------
#Repos folder  
$github_repo = "C:\Users\$env:Username\source\repos\github.com"
if(![System.IO.Directory]::Exists($github_repo)){
    write-host "Creating Github Repo - $github_repo"
    [System.IO.Directory]::CreateDirectory($github_repo)
}

#Tools directory
$tools_dir = "$PSScriptRoot\tools\"
if(![System.IO.Directory]::Exists($tools_dir)){
    write-host "Creating Tools Directory - $tools_dir"
    [System.IO.Directory]::CreateDirectory($tools_dir)
}

function repos { set-location "C:\Users\$env:Username\source\repos" }
function home { set-location $env:HOMEPATH }
function doc { set-location "C:\Users\$env:UserName\Documents" }
function github { set-location "C:\Users\$env:Username\source\repos\github.com" }
function psroot { set-location $PSScriptRoot}
function snippets {set-location "$env:APPDATA\Code\User\snippets"}
#------------------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------------
#show env vars
function env {
    # gci env:* | sort-object name
    Get-ChildItem env:* | sort-object name
}

function paths {
    $paths = $env:Path.Split(";");
    foreach($item in $paths){
        $item;
    }
}


#-------------------------------------------------------------------------------------
#nuget.exe commands

function rnuget(){
    #make sure the path is nuget.exe is global
    nuget restore
}


#-------------------------------------------------------------------------------------
#git switch credentials
function githotmail(){
    #Clear Credentials
    git config --global --unset credential.helper
    git config --system --unset credential.helper

    #Set Credentials
    git config --global user.name perezca6576
    git config --global user.email perezca6576@hotmail.com
    git config --global credential.helper store

    #Show credentials
    git config user.name
    git config user.email
}

function gitgmail(){
    #Clear Credentials
    git config --global --unset credential.helper
    git config --system --unset credential.helper

    #Set Credentials
    git config --global user.name carlosap6576
    git config --global user.email carlosap6576@gmail.com
    git config --global credential.helper store
    
    #Show credentials
    git config user.name
    git config user.email
}

function gityahoo(){
    #Clear Credentials
    git config --global --unset credential.helper
    git config --system --unset credential.helper

    #Set Credentials
    git config --global user.name carlosap6576
    git config --global user.email perezca6576@yahoo.com
    git config --global credential.helper store
    
    #Show credentials
    git config user.name
    git config user.email
}