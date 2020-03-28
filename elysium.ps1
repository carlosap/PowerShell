#Import-Module 'elysium'
#TODO: need to add a verbose flag to make scripts run faster or slower with more details.
$StartLocation = Get-Location
$FrozenTraceWeb = "C:\Users\elysium\gocode\src\github.com\aagon00\FrozenTraceWeb"
$EphemeralIdentity = "C:\Users\elysium\gocode\src\github.com\aagon00\EphemeralIdentity"
$outputFolder =  "C:\repos\Elysium" 
$proxyFolder = "C:\repos\proxy"
$StartTime = $(get-date)
$testnum = 0

#Guardian Source
$Guardian = "C:\Users\elysium\gocode\src\github.com\aagon00\Guardian"
$GuardianUI = Join-Path -Path $Guardian -ChildPath "fuse"
$GuardianBuild = Join-Path -Path $GuardianUI -ChildPath "build"

#Guardian Output
$GuardianOutputTop = Join-Path -Path $outputFolder -ChildPath "Guardian"
$GuardianOutput = Join-Path -Path $GuardianOutputTop -ChildPath "build" 
$GuardianAsset = Join-Path -Path $GuardianBuild -ChildPath "assets" 
$GuardianStatic = Join-Path -Path $GuardianBuild -ChildPath "static"

Function Initialize-Deployment(){
    Reset-TestNumber
    Test-GitVersion
    Stop-ElysiumProcess
    Initialize-DeploymentDirectories
}

Function Install-YarnModules($uipath) {

    if($uipath){
        Update-TestTime("Installing Yarn Modules - " + $uipath)
        Set-Location -Path $uipath
        Test-MasterBranch($uipath)
        Install-Yarn($uipath)
        write-host "git done " -ForegroundColor yellow
    }
}

Function Install-Yarn($uipath) {
    try{
        Update-TestTime("Yarn Install - " + $uipath)
        yarn install
    }catch{
        Write-Error "Error: Install-Yarn:" -Verbose
        Complete-Deployment
    }

}

Function Restore-Yarn($uipath) {
    try{
        Update-TestTime("Yarn Build - " + $uipath)
        Yarn-Build -Wait
    }catch{
        Write-Error "Error: Restore-Yarn:" -Verbose
        Complete-Deployment
    }

}

Function Test-YarnBuild($buildpath) {
    try{
        Update-TestTime("Test Yarn Build - " + $buildpath)
        Search-Directory($buildpath)
    }catch{
        Write-Error "Error: Test-YarnBuild:" -Verbose
        Complete-Deployment
    }
}

Function Copy-GuardianAssets() {
    try{
        Update-TestTime("Copying Assets Folder - " + $GuardianBuild)
        Set-Location -Path $GuardianBuild
        Initialize-Directory($GuardianOutput)
        Copy-Item $GuardianAsset -Destination $GuardianOutput -recurse
    }catch{
        Write-Error "Error: Copy-GuardianAssets:" -Verbose
        Complete-Deployment
    }
}

Function Copy-GuardianStatic() {
    try{
        Update-TestTime("Copying Static Folder - " + $GuardianBuild)
        Set-Location -Path $GuardianBuild
        Copy-Item $GuardianStatic -Destination $GuardianOutput -recurse 
    }catch{
        Write-Error "Error: Copy-GuardianStatic:" -Verbose
        Complete-Deployment
    }
}

Function Copy-GuardianWebIco() {
    try{
        Update-TestTime("Copying Web Ico  - " + $GuardianBuild)
        Set-Location -Path $GuardianBuild
        Copy-Item -path $GuardianBuild\*.ico  -Destination $GuardianOutput 
    }catch{
        Write-Error "Error: Copy-GuardianStatic:" -Verbose
        Complete-Deployment
    }
}

Function Copy-GuardianWebHtml() {
    try{
        Update-TestTime("Copying Web HTML  - " + $GuardianBuild)
        Set-Location -Path $GuardianBuild
        Copy-Item -path $GuardianBuild\*.html  -Destination $GuardianOutput
    }catch{
        Write-Error "Error: Copy-GuardianWebHtml:" -Verbose
        Complete-Deployment
    }
}



Function Test-MasterBranch($uipath) {
    try{
        Update-TestTime("Git Checkout Master Branch - " + $uipath)
        git checkout master
        git fetch | git pull
        write-host "success checkout master and pulled..." -ForegroundColor green
        Start-Sleep -Milliseconds 300
    }catch{
        Write-Error "Error: Test-MasterBranch:" -Verbose
        Complete-Deployment
    }

}

Function Test-GitVersion(){

    Update-TestTime("Check Git Version")
    if (Get-Command git -errorAction SilentlyContinue) {
        $git_current_version = (git --version)
    }
    if ($git_current_version) {
        Write-Verbose "[GIT] $git_current_version detected. Proceeding ..." -Verbose
        Start-Sleep -Milliseconds 1200
    }else{
        Write-Error "Error: Test-GitVersion. make sure git is working in your environment" -Verbose
        Complete-Deployment
    }
}

Function Git-call-miami(){
    git checkout master
    git fetch | git pull
    git checkout miami1
    git fetch | git pull
    git merge master
    git push
    git fetch | git pull
    yarn install
    write-host "git done " -ForegroundColor yellow
}

Function Yarn-Build(){
    yarn build -Wait
}

function Stop-ProcessByName($processName) {
    if ($processName) {
        Try {
            #Clear-Host
            get-process $processName -errorAction SilentlyContinue | select -expand id | ForEach-Object -Begin {
                Write-Verbose "Analysing Process... $processName" -Verbose
                Start-Sleep -Milliseconds 600
            } -Process {
        
                Write-Host "Terminating ID...$_" -Verbose
                Stop-Process -id $_
                Write-Verbose "Sucessfully Terminated Process...$processName" -Verbose
                #$_
            } -End {
                #Write-Verbose "Sucessfully Terminated Process...$processName" -Verbose
            }
        }
        Catch {
            Write-Debug "No $processName Found. No Actions took place" -Verbose
            #Break
        }

    }
}

function Search-Directory($dirpath) {
    if ($dirpath) {
        Try {
            if (![System.IO.Directory]::Exists($dirpath)) {
                Write-Error "directory path does not exist. - $dirpath"
                Complete-Deployment
            } 
            Start-Sleep -Milliseconds 300
            Write-Host "found directory path...$dirpath" -ForegroundColor Green

        }
        Catch {
            Write-Error "Error: Search-Directory:. No Actions took place" -Verbose
        }

    }
}

function Initialize-Directory($dirpath) {
    if ($dirpath) {
        Try {
            if (![System.IO.Directory]::Exists($dirpath)) {
                [System.IO.Directory]::CreateDirectory($dirpath)
                Write-Host "initialized directory...$dirpath" -ForegroundColor Green
                Start-Sleep -Milliseconds 500
            }
            else {
                Write-Host "please wait. we removing files from directory - $dirpath" -ForegroundColor Yellow
                Remove-Item  $dirpath -Recurse -Force
                Start-Sleep -Milliseconds 200
                Initialize-Directory($dirpath)
            }
        }
        Catch {
            Write-Error "Error: Search-Directory:. No Actions took place" -Verbose
        }
    }
}

function Stop-ElysiumProcess() {
    Update-TestTime("Stop Elysium Process")
    Stop-ProcessByName("guardian")
    Stop-ProcessByName("authv2")
    Stop-ProcessByName("SpartanGateway")
    Stop-ProcessByName("frozentrace")
    Stop-ProcessByName("frozentraceserver")
    Stop-ProcessByName("ephemeralidentity")
    Stop-ProcessByName("ephemeralidentityserver")
}

function Initialize-DeploymentDirectories() {
    Update-TestTime("Initialize Deployment Directories")
    Search-Directory($Guardian)
    Search-Directory($GuardianUI)
    Search-Directory($FrozenTraceWeb)
    Search-Directory($EphemeralIdentity)
    Search-Directory($proxyFolder)
    Initialize-Directory($outputFolder)
}

Function Test-IncrementNumber() {

    $global:testnum++
    return $global:testnum
}

Function Reset-TestNumber() {

    $global:testnum = 0
    return $global:testnum
}

Function Update-TestTime($testname){
    $elapsedTime = $(get-date) - $StartTime
    $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
    $elapseMsg = "elapse time  - $totalTime" 

    if($testname){
        Clear-Host  
        $testnum = Test-IncrementNumber
        write-host "=================================================[$elapseMsg]=====================================================" -ForegroundColor blue   
        write-host " [$testnum] $testname" -ForegroundColor blue   
        write-host "===============================================================================================================================" -ForegroundColor blue 
        Start-Sleep -Milliseconds 700
    }else{
        write-host $elapseMsg
    }
}

Function Complete-Deployment(){
    Update-TestTime
    Set-Location -Path $StartLocation
    Exit
}

Initialize-Deployment
Install-YarnModules($GuardianUI)
Restore-Yarn($GuardianUI)
Test-YarnBuild($GuardianBuild)
Copy-GuardianAssets
Copy-GuardianStatic
Copy-GuardianWebIco
Copy-GuardianWebHtml
Complete-Deployment

#Git-call-miami 


        write-host "copying Folder env" 
        Copy-Item -path $Guardian\env  -Destination $GuardianOutputTop  -recurse

        $exclude = @('*.go','*.png','*.md','LICENSE','*.txt') 
        write-host "copying Folder ingest scripts" 
        Set-Location -Path $Guardian\db\ingest
         go build .\ingest.go
         Start-Sleep -Milliseconds 1000
        Copy-Item -path $Guardian\db\ingest  -Destination $GuardianOutputTop\"ingest scripts" -recurse -Exclude $exclude 
        
        write-host "copying Folder migration scripts" 
        Set-Location -Path $Guardian\db\migration
        go build .\migration.go 
        Start-Sleep -Milliseconds 1000
        Copy-Item -path $Guardian\db\migration  -Destination $GuardianOutputTop\"migration scripts" -recurse  -Exclude $exclude 

 
        write-host "copying Folder authboss" 
        Set-Location -Path $Guardian\authboss
        go build .\authv2.go
        Start-Sleep -Milliseconds 1000
        Copy-Item -path $Guardian\authboss\authv2.exe  -Destination $GuardianOutputTop\authv2.exe 

        write-host "copying Folder server" 
        Set-Location -Path $Guardian\authboss\templates
        Copy-Item -path $Guardian\authboss\templates  -Destination $GuardianOutputTop -Recurse
        
        write-host "copying proxy server" 
        Set-Location -Path $proxyFolder
        Copy-Item -path $proxyFolder\guardian.exe  -Destination $GuardianOutputTop

        write-host "copying proxy appsettings" 
        Set-Location -Path $proxyFolder
        Copy-Item -path $proxyFolder\appsettings.json  -Destination $GuardianOutputTop

        write-host "copying proxy run_all" 
        Set-Location -Path $proxyFolder
        Copy-Item -path $proxyFolder\run_all.exe  -Destination $outputFolder

        write-host "copying proxy data_population_demo.exe" 
        Set-Location -Path $proxyFolder
        Copy-Item -path $proxyFolder\data_population_demo.exe  -Destination $outputFolder

        write-host "copying proxy data_reset_admin.exe" 
        Set-Location -Path $proxyFolder
        Copy-Item -path $proxyFolder\data_reset_admin.exe  -Destination $outputFolder

        
        # write-host "copying proxy ocelot" 
        # Set-Location -Path $proxyFolder
        # Copy-Item -path $proxyFolder\ocelot.json  -Destination $GuardianOutputTop

#}
#################################  Guardian  end ################################

#################################  FrozenTraceWeb  Start ################################

Set-Location -Path $FrozenTraceWeb

write-host "setup - $FrozenTraceWeb" -ForegroundColor blue

$FrozenTraceWebUI = Join-Path -Path $FrozenTraceWeb -ChildPath "Fuse_UI"
$FrozenTraceWebBuild = Join-Path -Path $FrozenTraceWebUI -ChildPath "build"

if(![System.IO.Directory]::Exists($FrozenTraceWebUI)){
    write-host "no Folder - $FrozenTraceWebUI"
}else{
     Set-Location -Path $FrozenTraceWebUI
     write-host "UI Folder - $FrozenTraceWebUI"

     # checkout latest
     Install-YarnModules

     Yarn-Build
     write-host "build done - $FrozenTraceWebUI" -ForegroundColor yellow
}

if(![System.IO.Directory]::Exists($FrozenTraceWebBuild)){
    write-host "no Folder - $FrozenTraceWebBuild"
}else{
     Set-Location -Path $FrozenTraceWebBuild
     write-host "copying build Folder - $FrozenTraceWebBuild" 

    $FrozenTraceWebOutput = Join-Path -Path $outputFolder -ChildPath "FrozenTrace"

     if(![System.IO.Directory]::Exists($FrozenTraceWebOutput)){
        Initialize-Directory($FrozenTraceWebOutput)
     }

############# copy to garidan build start ########################

        $FrozenTraceWebAsset = Join-Path -Path $FrozenTraceWebBuild -ChildPath "assets"
         write-host "copying build Folder - $FrozenTraceWebAsset" 
        Copy-Item $FrozenTraceWebAsset -Destination $GuardianOutput -Recurse -force  

         $FrozenTraceWebStatic = Join-Path -Path $FrozenTraceWebBuild -ChildPath "static"
         write-host "copying build Folder - $FrozenTraceWebStatic" 
        Copy-Item $FrozenTraceWebStatic -Destination $GuardianOutput -Recurse -force  
 
        $FrozenTraceWebStatic = Join-Path -Path $FrozenTraceWebBuild -ChildPath "tiles"
         write-host "copying build Folder - $FrozenTraceWebStatic" 
        Copy-Item $FrozenTraceWebStatic -Destination $GuardianOutput -Recurse -force  


############# copy to garidan build end  ########################
 
        $RootBuild = Join-Path $FrozenTraceWebOutput -ChildPath "build"
        Initialize-Directory($RootBuild)

        write-host "copying Folder ico" 
        Copy-Item -path $FrozenTraceWebBuild\*.ico  -Destination $RootBuild 

        write-host "copying Folder html" 
        Copy-Item -path $FrozenTraceWebBuild\*.html  -Destination $RootBuild  

        write-host "copying Folder server" 
        Set-Location -Path $FrozenTraceWeb\server
        go build .\server.go .\configs.go .\database.go .\handler.go .\handlerhelper.go .\routes.go
        Start-Sleep -Milliseconds 1000
        Copy-Item -path $FrozenTraceWeb\server\server.exe  -Destination $FrozenTraceWebOutput\frozentraceserver.exe 
    
        write-host "copying Folder server" 
        Set-Location -Path $FrozenTraceWeb\server\templates
        Copy-Item -path $FrozenTraceWeb\server\templates  -Destination $FrozenTraceWebOutput -Recurse

        write-host "copying Folder server" 
        Set-Location -Path $FrozenTraceWeb\server\Packages
        Copy-Item -path $FrozenTraceWeb\server\Packages  -Destination $FrozenTraceWebOutput -Recurse

        write-host "copying Folder server" 
        Set-Location -Path $FrozenTraceWeb\server\configs
        Copy-Item -path $FrozenTraceWeb\server\configs -Destination $FrozenTraceWebOutput -Recurse


        write-host "copying proxy server" 
        Set-Location -Path $proxyFolder
        Copy-Item -path $proxyFolder\frozentrace.exe  -Destination $FrozenTraceWebOutput
}

#################################  FrozenTraceWeb  end ################################

#################################  EphemeralIdentity  Start ################################

Set-Location -Path $EphemeralIdentity

write-host "setup - $EphemeralIdentity" -ForegroundColor blue

$EphemeralIdentityUI = Join-Path -Path $EphemeralIdentity -ChildPath "Fuse_UI"
$EphemeralIdentityBuild = Join-Path -Path $EphemeralIdentityUI -ChildPath "build"

if(![System.IO.Directory]::Exists($EphemeralIdentityUI)){
    write-host "no Folder - $EphemeralIdentityUI"
}else{
     Set-Location -Path $EphemeralIdentityUI
     write-host "UI Folder - $EphemeralIdentityUI"

     # checkout latest
     Install-YarnModules
     #Git-call-miami 
     
     Yarn-Build
     write-host "build done - $EphemeralIdentityUI" -ForegroundColor yellow
}

if(![System.IO.Directory]::Exists($EphemeralIdentityBuild)){
    write-host "no Folder - $EphemeralIdentityBuild"
}else{
     Set-Location -Path $EphemeralIdentityBuild
     write-host "copying build Folder - $EphemeralIdentityBuild" 

    $EphemeralIdentityOutput = Join-Path -Path $outputFolder -ChildPath "EphemeralIdentity"

     if(![System.IO.Directory]::Exists($EphemeralIdentityOutput)){
        Initialize-Directory($EphemeralIdentityOutput)
     }

############# copy to garidan build start ########################
        $EphemeralIdentityAsset = Join-Path -Path $EphemeralIdentityBuild -ChildPath "assets"
         write-host "copying build Folder - $EphemeralIdentityAsset" 
        Copy-Item $EphemeralIdentityAsset -Destination $GuardianOutput -Recurse -force  

         $EphemeralIdentityStatic = Join-Path -Path $EphemeralIdentityBuild -ChildPath "static"
         write-host "copying build Folder - $EphemeralIdentityStatic" 
        Copy-Item $EphemeralIdentityStatic -Destination $GuardianOutput -Recurse -force  
############# copy to garidan build end  ########################
 
        $RootBuild = Join-Path $EphemeralIdentityOutput -ChildPath "build"
        Initialize-Directory($RootBuild)

        write-host "copying Folder ico" 
        Copy-Item -path $EphemeralIdentityBuild\*.ico  -Destination $RootBuild 

        write-host "copying Folder html" 
        Copy-Item -path $EphemeralIdentityBuild\*.html  -Destination $RootBuild  

        write-host "copying Folder server" 
        Set-Location -Path $EphemeralIdentity\ephemeral_server
        go build .\server.go 
        Start-Sleep -Milliseconds 2000
        Copy-Item -path $EphemeralIdentity\ephemeral_server\server.exe  -Destination $EphemeralIdentityOutput\ephemeralidentityserver.exe 

        write-host "copying File Folder server" 
        Set-Location -Path $EphemeralIdentity\ephemeral_server
        go build .\server.go 
        Start-Sleep -Milliseconds 2000
        Copy-Item -path $EphemeralIdentity\ephemeral_server\files  -Destination $EphemeralIdentityOutput -Recurse

        write-host "copying proxy server" 
        Set-Location -Path $proxyFolder
        Copy-Item -path $proxyFolder\ephemeralidentity.exe  -Destination $EphemeralIdentityOutput

}
#################################  EphemeralIdentity  end ################################



 