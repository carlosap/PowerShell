Import-Module posh-git

# kubectl aliases : Credits to https://github.com/shanoor/kubectl-aliases-powershell
'. $Home\Documents\WindowsPowerShell\kubectl_aliases.ps1' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append

# Welcome message
#Using Windows Terminal
#1- Make sure you start a powershell session as admin (right-click and select administrator)
#2- run "Set-ExecutionPolicy Unrestricted" and select "A" to all
#2- Make sure you create a profile.ps1 in your WindowsPowerShell (C:\Users\caper\Documents\WindowsPowerShell)
"You are now entering PowerShell : " + $env:Username

$github_repo = "C:\Users\$env:Username\source\repos\github.com"
$tools_dir = "$PSScriptRoot\tools\"
$go_workplace = "C:\Users\$env:Username\gocode\src\github.com"
$go_source = "C:\Users\$env:Username\gocode\src\"
$go_github = "C:\Users\$env:Username\gocode\src\github.com"

#-------------------------------------Directories-----------------------------------------------------
#Repos folder  

if(![System.IO.Directory]::Exists($github_repo)){
    write-host "Creating Github Repo - $github_repo"
    [System.IO.Directory]::CreateDirectory($github_repo)
}


#Tools directory

if(![System.IO.Directory]::Exists($tools_dir)){
    write-host "Creating Tools Directory - $tools_dir"
    [System.IO.Directory]::CreateDirectory($tools_dir)
}
#----------------------------------------GOLang-------------------------------------------------------
#Golang workplace directory - go env GOPATH

if(![System.IO.Directory]::Exists($go_workplace)){
    write-host "Creating Go Work Place Folder - $go_workplace"
    [System.IO.Directory]::CreateDirectory($go_workplace)
}

#Golang Source directory - this is where all go source code is going to go
if(![System.IO.Directory]::Exists($go_source)){
    write-host "Creating Go Source (src) Folder - $go_source"
    [System.IO.Directory]::CreateDirectory($go_source)
}

#Golang Github.com directory - this is where all your github.com repos
if(![System.IO.Directory]::Exists($go_github)){
    write-host "Creating Go Github Folder - $go_github"
    [System.IO.Directory]::CreateDirectory($go_github)
}

#--------------------------------------------------------------------------------------------
function gocode { set-location "C:\Users\$env:Username\gocode" }
function gosrc { set-location "C:\Users\$env:Username\gocode\src" }
function gogithub { set-location "C:\Users\$env:Username\gocode\src\github.com" }

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


#----------------------------------------Aliases---------------------------------------------
function repos { set-location "C:\Users\$env:Username\source\repos" }
function home { set-location $env:HOMEPATH }
function doc { set-location "C:\Users\$env:UserName\Documents" }
function github { set-location "C:\Users\$env:Username\source\repos\github.com" }
function psroot { set-location $PSScriptRoot}
function snippets {set-location "$env:APPDATA\Code\User\snippets"}
function gocode {set-location $go_code_dir}
function gosrc {set-location $go_src_dir}
function gogit {set-location $go_github_dir}

#------project related------
function elysium {set-location "$go_github_dir\aagon00"}

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

#--------------------------------File Helpers Functions-----------------------------------
function size($file) {
   if($file) {
    $size = Format-FileSize((Get-Item $file).length)
    Write-Host("$file        size: $size")
   }
 }
 
 Function Format-FileSize() {
    Param ([int]$size)
    If ($size -gt 1TB) {[string]::Format("{0:0.00} TB", $size / 1TB)}
    ElseIf ($size -gt 1GB) {[string]::Format("{0:0.00} GB", $size / 1GB)}
    ElseIf ($size -gt 1MB) {[string]::Format("{0:0.00} MB", $size / 1MB)}
    ElseIf ($size -gt 1KB) {[string]::Format("{0:0.00} kB", $size / 1KB)}
    ElseIf ($size -gt 0) {[string]::Format("{0:0.00} B", $size)}
    Else {""}
}
