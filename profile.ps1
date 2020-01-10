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

#--------------------------------------------------------------------------------------------
#GoPath folder
$go_code_dir = "C:\Users\$env:Username\gocode"
$go_pkg_dir = "C:\Users\$env:Username\gocode\pkg"
$go_bin_dir = "C:\Users\$env:Username\gocode\bin"
$go_src_dir = "C:\Users\$env:Username\gocode\src"
$go_github_dir = "C:\Users\$env:Username\gocode\src\github.com"

if(![System.IO.Directory]::Exists($go_code_dir)){
    write-host "Creating gocode Directory - $go_code_dir"
    [System.IO.Directory]::CreateDirectory($go_code_dir)
}

if(![System.IO.Directory]::Exists($go_pkg_dir)){
    write-host "Creating pkg Directory - $go_pkg_dir"
    [System.IO.Directory]::CreateDirectory($go_pkg_dir)
}

if(![System.IO.Directory]::Exists($go_bin_dir)){
    write-host "Creating bin Directory - $go_bin_dir"
    [System.IO.Directory]::CreateDirectory($go_bin_dir)
}

if(![System.IO.Directory]::Exists($go_src_dir)){
    write-host "Creating src Directory - $go_src_dir"
    [System.IO.Directory]::CreateDirectory($go_src_dir)
}

if(![System.IO.Directory]::Exists($go_github_dir)){
    write-host "Creating github Directory - $go_github_dir"
    [System.IO.Directory]::CreateDirectory($go_github_dir)
    write-host "Make sure you set the env variables as follow:"
    write-host "*User Variable:"
    write-host "================"
    write-host "Add a new variable call GOPATH with value $go_code_dir"
    write-host "In your PATH existing variable, add a new entry ['$GOPATH']"
    write-host ""
    write-host "*System Variable"
    write-host "================"
    write-host "In your PATH add the root bin folder [C:\Go\bin]"

}


#--------------------------------------------------------------------------------------------
function repos { set-location "C:\Users\$env:Username\source\repos" }
function home { set-location $env:HOMEPATH }
function doc { set-location "C:\Users\$env:UserName\Documents" }
function github { set-location "C:\Users\$env:Username\source\repos\github.com" }
function psroot { set-location $PSScriptRoot}
function snippets {set-location "$env:APPDATA\Code\User\snippets"}
function gocode {set-location $go_code_dir}
function gosrc {set-location $go_src_dir}
function gogit {set-location $go_github_dir}

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