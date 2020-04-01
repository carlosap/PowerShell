#Import-Module 'elysium'
#TODO: need to add a verbose flag to make scripts run faster or slower with more details.
$StartLocation = Get-Location
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

#Frozen Trace Web Source
$FrozenTraceWeb = "C:\Users\elysium\gocode\src\github.com\aagon00\FrozenTraceWeb"
$FrozenTraceWebUI = Join-Path -Path $FrozenTraceWeb -ChildPath "Fuse_UI"
$FrozenTraceWebBuild = Join-Path -Path $FrozenTraceWebUI -ChildPath "build"
$FrozenTraceWebAsset = Join-Path -Path $FrozenTraceWebBuild -ChildPath "assets"
$FrozenTraceWebStatic = Join-Path -Path $FrozenTraceWebBuild -ChildPath "static"
$FrozenTraceWebTiles = Join-Path -Path $FrozenTraceWebBuild -ChildPath "tiles"

#Frozen Trace Web Output
$FrozenTraceWebOutput = Join-Path -Path $outputFolder -ChildPath "FrozenTrace"
$FrozenTraceWebBuildOutput = Join-Path $FrozenTraceWebOutput -ChildPath "build"

#Ephemeral Identity Source
$EphemeralIdentity = "C:\Users\elysium\gocode\src\github.com\aagon00\EphemeralIdentity"
$EphemeralIdentityUI = Join-Path -Path $EphemeralIdentity -ChildPath "Fuse_UI"
$EphemeralIdentityBuild = Join-Path -Path $EphemeralIdentityUI -ChildPath "build"
$EphemeralIdentityAsset = Join-Path -Path $EphemeralIdentityBuild -ChildPath "assets"
$EphemeralIdentityStatic = Join-Path -Path $EphemeralIdentityBuild -ChildPath "static"

#Ephemeral Identity Output
$EphemeralIdentityOutput = Join-Path -Path $outputFolder -ChildPath "EphemeralIdentity"
$EphemeralIdentityBuildOutput = Join-Path $EphemeralIdentityOutput -ChildPath "build"

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
Function Copy-GuardianEnv() {
    try{
        Update-TestTime("Copying Guardian Env  - " + $GuardianOutputTop)
        Copy-Item -path $Guardian\env  -Destination $GuardianOutputTop  -recurse
    }catch{
        Write-Error "Error: Copy-GuardianEnv:" -Verbose
        Complete-Deployment
    }
}


Function Restore-GuardianIngestScripts() {
    try{
        Update-TestTime("Restore and Copying Guardian Ingest Scripts  - " + $GuardianOutputTop)
        $exclude = @('*.go','*.png','*.md','LICENSE','*.txt') 
        Set-Location -Path $Guardian\db\ingest
        go build .\ingest.go
        Copy-Item -path $Guardian\db\ingest  -Destination $GuardianOutputTop\"ingest scripts" -recurse -Exclude $exclude 
        
    }catch{
        Write-Error "Restore-GuardianIngestScripts" -Verbose
        Complete-Deployment
    }
}

Function Restore-GuardianMigrationScripts() {
    try{
        Update-TestTime("Restore and Copying Guardian Migration Scripts  - " + $GuardianOutputTop)
        Set-Location -Path $Guardian\db\migration
        go build .\migration.go 
        Copy-Item -path $Guardian\db\migration  -Destination $GuardianOutputTop\"migration scripts" -recurse  -Exclude $exclude 
        
    }catch{
        Write-Error "Restore-GuardianMigrationScripts" -Verbose
        Complete-Deployment
    }
}
Function Restore-GuardianAuthbossBinaries() {
    try{
        Update-TestTime("Restore and Copying Authboss Scripts  - " + $GuardianOutputTop)
        Set-Location -Path $Guardian\authboss
        go build .\authv2.go
        Copy-Item -path $Guardian\authboss\authv2.exe  -Destination $GuardianOutputTop\authv2.exe 
        
    }catch{
        Write-Error "Restore-GuardianAuthbossBinaries" -Verbose
        Complete-Deployment
    }
}

Function Restore-FronzenTraceWebBinaries() {
    try{
        Update-TestTime("Restore and copying frozentraceweb Scripts  - " + $FrozenTraceWeb)
        Set-Location -Path $FrozenTraceWeb\server
        go build .\server.go .\configs.go .\database.go .\handler.go .\handlerhelper.go .\routes.go
        Copy-Item -path $FrozenTraceWeb\server\server.exe  -Destination $FrozenTraceWebOutput\frozentraceserver.exe
    }catch{
        Write-Error "Restore-Restore-FronzenTraceWebBinaries" -Verbose
        Complete-Deployment
    }
}

Function Restore-GuardianAuthbossTemplates() {
    try{
        Update-TestTime("Restore and Copying Authboss Template  - " + $GuardianOutputTop)
        Set-Location -Path $Guardian\authboss\templates
        Copy-Item -path $Guardian\authboss\templates  -Destination $GuardianOutputTop -Recurse
    }catch{
        Write-Error "Restore-GuardianAuthbossTemplates" -Verbose
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
                Start-Sleep -Milliseconds 100
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
            Start-Sleep -Milliseconds 100
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
    Search-Directory($FrozenTraceWebUI)

    Search-Directory($EphemeralIdentity)
    Search-Directory($EphemeralIdentityUI)

    Search-Directory($proxyFolder)

    Initialize-Directory($outputFolder)
    Initialize-Directory($GuardianOutputTop)
    Initialize-Directory($GuardianOutput)
    Initialize-Directory($GuardianAsset)
    Initialize-Directory($GuardianStatic)
    Initialize-Directory($FrozenTraceWebOutput)
    Initialize-Directory($EphemeralIdentityBuildOutput)

  
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

Function Restore-ProxyServer() {
    try{
        Update-TestTime("Restore Proxy Server - " + $proxyFolder)
        Set-Location -Path $proxyFolder
        write-host "copying proxy guardian" 
        Copy-Item -path $proxyFolder\guardian.exe  -Destination $GuardianOutputTop
        write-host "copying proxy appsettings" 
        Copy-Item -path $proxyFolder\appsettings.json  -Destination $GuardianOutputTop
        write-host "copying proxy run_all" 
        Copy-Item -path $proxyFolder\run_all.exe  -Destination $outputFolder
        write-host "copying proxy data_population_demo.exe" 
        Copy-Item -path $proxyFolder\data_population_demo.exe  -Destination $outputFolder
        write-host "copying proxy data_reset_admin.exe" 
        Copy-Item -path $proxyFolder\data_reset_admin.exe  -Destination $outputFolder
        write-host "copying proxy frozentrace.exe" 
        Copy-Item -path $proxyFolder\frozentrace.exe  -Destination $FrozenTraceWebOutput
        write-host "copying proxy ephemeralidentity.exe" 
        Copy-Item -path $proxyFolder\ephemeralidentity.exe  -Destination $EphemeralIdentityOutput
        # write-host "copying proxy ocelot" 
        # Copy-Item -path $proxyFolder\ocelot.json  -Destination $GuardianOutputTop
    }catch{
        Write-Error "Restore-ProxyServer" -Verbose
        Complete-Deployment
    }
}

Function Copy-FrozenTraceWebAssets() {
    try{
        Update-TestTime("Copying FrozenTraceWeb Assets  - " + $FrozenTraceWebAsset)
        write-host "copying frozen trace web assets to build Folder - $FrozenTraceWebAsset" 
        Set-Location -Path $FrozenTraceWebBuild
        Copy-Item $FrozenTraceWebAsset -Destination $GuardianOutput -Recurse -force  
    }catch{
        Write-Error "Error: Copy-FrozenTraceWebAssets" -Verbose
        Complete-Deployment
    }
}
Function Copy-FrozenTraceWebStatic() {
    try{
        Update-TestTime("Copying FrozenTraceWeb Static  - " + $FrozenTraceWebStatic)
        write-host "copying static Folder - $FrozenTraceWebStatic" 
        Set-Location -Path $FrozenTraceWebBuild
        Copy-Item $FrozenTraceWebStatic -Destination $GuardianOutput -Recurse -force  
    }catch{
        Write-Error "Error: Copy-FrozenTraceWebStatic" -Verbose
        Complete-Deployment
    }
}
Function Copy-FrozenTraceWebMapTiles() {
    try{
        Update-TestTime("Copying FrozenTraceWeb Map Tiles  - " + $FrozenTraceWebTiles)
         write-host "copying map tiles Folder - $FrozenTraceWebTiles" 
        Set-Location -Path $FrozenTraceWebBuild
        Copy-Item $FrozenTraceWebTiles -Destination $GuardianOutput -Recurse -force  
    }catch{
        Write-Error "Error: Copy-FrozenTraceWebMapTiles" -Verbose
        Complete-Deployment
    }
}
Function Copy-FronzenTraceWebIco() {
    try{
        Update-TestTime("Copying FronzenTraceWeb Ico File - " + $FrozenTraceWebBuild)
        Set-Location -Path $FrozenTraceWebBuild
        Initialize-Directory($FrozenTraceWebBuildOutput)
        write-host "copying Folder ico" 
        Copy-Item -path $FrozenTraceWebBuild\*.ico  -Destination $FrozenTraceWebBuildOutput #goes into a new path
    }catch{
        Write-Error "Error: Copy-FronzenTraceWebIco" -Verbose
        Complete-Deployment
    }
}

Function Copy-FronzenTraceWebHtml() {
    try{
        Update-TestTime("Copying FronzenTraceWeb Html Files - " + $FrozenTraceWebBuild)
        Set-Location -Path $FrozenTraceWebBuild
        write-host "copying html files" 
        Copy-Item -path $FrozenTraceWebBuild\*.html  -Destination $FrozenTraceWebBuildOutput 
    }catch{
        Write-Error "Error: Copy-FronzenTraceWebHtml" -Verbose
        Complete-Deployment
    }
}

Function Copy-FronzenTraceWebTemplates() {
    try{
        Update-TestTime("Copying FronzenTraceWeb Templates Files - " + $FrozenTraceWeb + "\server\templates")
        write-host "copying templates" 
        Set-Location -Path $FrozenTraceWeb\server\templates
        Copy-Item -path $FrozenTraceWeb\server\templates  -Destination $FrozenTraceWebOutput -Recurse
    }catch{
        Write-Error "Error: Copy-FronzenTraceWebTemplates" -Verbose
        Complete-Deployment
    }
}
Function Copy-FronzenTraceWebPackages() {
    try{
        Update-TestTime("Copying FronzenTraceWeb Packages Files - " + $FrozenTraceWeb + "\server\Packages")
        write-host "copying packages" 
        Set-Location -Path $FrozenTraceWeb\server\Packages
        Copy-Item -path $FrozenTraceWeb\server\Packages  -Destination $FrozenTraceWebOutput -Recurse
    }catch{
        Write-Error "Error: Copy-FronzenTraceWebPackages" -Verbose
        Complete-Deployment
    }
}

Function Copy-FronzenTraceWebConfigs() {
    try{
        Update-TestTime("Copying FronzenTraceWeb Configs Files - " + $FrozenTraceWeb + "\server\configs")
        write-host "copying configs server" 
        Set-Location -Path $FrozenTraceWeb\server\configs
        Copy-Item -path $FrozenTraceWeb\server\configs -Destination $FrozenTraceWebOutput -Recurse
    }catch{
        Write-Error "Error: Copy-FronzenTraceWebConfigs" -Verbose
        Complete-Deployment
    }
}

# Function Copy-FronzenTraceWebClient() {
#     try{
#         Update-TestTime("Copying FronzenTraceWeb Client API - " + $FrozenTraceWeb + "\server\configs")
#         write-host "copying client api" 
#         Set-Location -Path $proxyFolder
#         Copy-Item -path $proxyFolder\frozentrace.exe  -Destination $FrozenTraceWebOutput
#     }catch{
#         Write-Error "Error: Copy-FronzenTraceWebClient" -Verbose
#         Complete-Deployment
#     }
# }

Function Copy-EphemeralIdentityAssets() {
    try{
        Update-TestTime("Copying EphemeralIdentity Assets  - " + $EphemeralIdentityAsset)
        Set-Location -Path $EphemeralIdentityBuild
        write-host "copying Ephemeral Identity assets to build Folder - $EphemeralIdentityAsset" 
        Copy-Item $EphemeralIdentityAsset -Destination $GuardianOutput -Recurse -force 
    }catch{
        Write-Error "Error: Copy-EphemeralIdentityAssets" -Verbose
        Complete-Deployment
    }
}

Function Copy-EphemeralIdentityStatic() {
    try{
        Update-TestTime("Copying EphemeralIdentity Static  - " + $EphemeralIdentityStatic)
        Set-Location -Path $EphemeralIdentityBuild
        write-host "copying EphemeralIdentity Static Folder - $EphemeralIdentityStatic" 
        Copy-Item $EphemeralIdentityStatic -Destination $GuardianOutput -Recurse -force  
    }catch{
        Write-Error "Error: Copy-EphemeralIdentityStatic" -Verbose
        Complete-Deployment
    }
}

Function Copy-EphemeralIdentityIco() {
    try{
        Update-TestTime("Copying EphemeralIdentity Ico File - " + $EphemeralIdentityBuild)
        Set-Location -Path $EphemeralIdentityBuild
        write-host "copying Ephemeral Identity ico" 
        Copy-Item -path $EphemeralIdentityBuild\*.ico  -Destination $EphemeralIdentityBuildOutput
    }catch{
        Write-Error "Error: Copy-EphemeralIdentityIco" -Verbose
        Complete-Deployment
    }
}
Function Copy-EphemeralIdentityHtml() {
    try{
        Update-TestTime("Copying EphemeralIdentity Html File - " + $EphemeralIdentityBuild)
        Set-Location -Path $EphemeralIdentityBuild
        write-host "copying Ephemeral Identity Html File" 
        Copy-Item -path $EphemeralIdentityBuild\*.html  -Destination $EphemeralIdentityBuildOutput
    }catch{
        Write-Error "Error: Copy-EphemeralIdentityHtml" -Verbose
        Complete-Deployment
    }
}

Function Restore-EphemeralIdentityBinaries() {
    try{
        Update-TestTime("Restore and copying Ephemeral Identity Scripts  - " + $EphemeralIdentity + "\ephemeral_server\server.exe")
        Set-Location -Path $EphemeralIdentity\ephemeral_server
        go build .\server.go
        Copy-Item -path $EphemeralIdentity\ephemeral_server\server.exe  -Destination $EphemeralIdentityOutput\ephemeralidentityserver.exe
    }catch{
        Write-Error "Restore-EphemeralIdentityBinaries" -Verbose
        Complete-Deployment
    }
}

write-host "copying proxy server" 
Set-Location -Path $proxyFolder
Copy-Item -path $proxyFolder\ephemeralidentity.exe  -Destination $EphemeralIdentityOutput

################################# Guardian ###############################
Initialize-Deployment
Install-YarnModules($GuardianUI)
Restore-Yarn($GuardianUI)
Test-YarnBuild($GuardianBuild)
Copy-GuardianAssets
Copy-GuardianStatic
Copy-GuardianWebIco
Copy-GuardianWebHtml
Copy-GuardianEnv
Restore-GuardianIngestScripts
Restore-GuardianMigrationScripts
Restore-GuardianAuthbossBinaries
Restore-GuardianAuthbossTemplates

################################# FrozenTraceWeb ################################
Install-YarnModules($FrozenTraceWebUI)
Restore-Yarn($FrozenTraceWebUI)
Test-YarnBuild($FrozenTraceWebBuild)
Copy-FrozenTraceWebAssets
Copy-FrozenTraceWebStatic
Copy-FrozenTraceWebMapTiles
Copy-FronzenTraceWebIco
Copy-FronzenTraceWebHtml
Copy-FronzenTraceWebTemplates
Copy-FronzenTraceWebTemplates
Copy-FronzenTraceWebPackages
Copy-FronzenTraceWebConfigs
Restore-FronzenTraceWebBinaries

################################# Ephemeral Identity ################################
Install-YarnModules($EphemeralIdentityUI)
Restore-Yarn($EphemeralIdentityUI)
Test-YarnBuild($EphemeralIdentityBuild)
Copy-EphemeralIdentityAssets
Copy-EphemeralIdentityStatic
Copy-EphemeralIdentityIco
Copy-EphemeralIdentityHtml
Restore-EphemeralIdentityBinaries
Restore-ProxyServer
Complete-Deployment

#Git-call-miami 