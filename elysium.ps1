$StartLocation = Get-Location
$Guardian = "C:\Users\elysium\gocode\src\github.com\aagon00\Guardian"
$FrozenTraceWeb = "C:\Users\elysium\gocode\src\github.com\aagon00\FrozenTraceWeb"
$EphemeralIdentity = "C:\Users\elysium\gocode\src\github.com\aagon00\EphemeralIdentity"
$outputFolder =  "C:\repos\Elysium" 
$proxyFolder = "C:\repos\proxy"
$StartTime = $(get-date)

Function Git-call(){
    ##git checkout master
    git fetch | git pull
    yarn install

    write-host "git done " -ForegroundColor yellow
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

Function Create-Paths($path)
{
  if(![System.IO.Directory]::Exists($path)){
        write-host "Creating  - $path"
        [System.IO.Directory]::CreateDirectory($path)
    }
}

function StopProcessByName($processName) {
    if ($processName) {
        Try {
            get-process $processName -errorAction SilentlyContinue  | select -expand id | ForEach-Object -Begin {
                Clear-Host
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


##--Kill existing Process---
StopProcessByName("guardian")
StopProcessByName("authv2")
StopProcessByName("SpartanGateway")
StopProcessByName("frozentrace")
StopProcessByName("frozentraceserver")
StopProcessByName("ephemeralidentity")
StopProcessByName("ephemeralidentityserver")
Start-Sleep -Milliseconds 500
Exit

##--Starts Automation Here---
write-host "Starting scripts from folder: $StartLocation"
if(![System.IO.Directory]::Exists($Guardian)){
    write-host "check your path please - $Guardian"
}

if(![System.IO.Directory]::Exists($FrozenTraceWeb)){
    write-host "check your path please - $FrozenTraceWeb"
}

if(![System.IO.Directory]::Exists($EphemeralIdentity)){
    write-host "check your path please - $EphemeralIdentity"
}


if(![System.IO.Directory]::Exists($proxyFolder)){
    write-host "check your path please - $proxyFolder"
}


if(![System.IO.Directory]::Exists($outputFolder)){
    Create-Paths -p $outputFolder
}else{
    write-host "deleting Folder - $outputFolder"
    Remove-Item  $outputFolder
}

#################################  Guardian  Start ################################
Set-Location -Path $Guardian

write-host "setup - $Guardian" -ForegroundColor blue    

$GuardianUI = Join-Path -Path $Guardian -ChildPath "fuse"
$GuardianBuild = Join-Path -Path $GuardianUI -ChildPath "build" 

if(![System.IO.Directory]::Exists($GuardianUI)){
    write-host "no Folder - $GuardianUI"
}else{
     Set-Location -Path $GuardianUI
     write-host "UI Folder - $GuardianUI"

     # checkout latest
    Git-call
    #Git-call-miami 

     Yarn-Build
     write-host "build done - $GuardianUI" -ForegroundColor yellow     
}

if(![System.IO.Directory]::Exists($GuardianBuild)){
    write-host "no Folder - $GuardianBuild"
}else{
     Set-Location -Path $GuardianBuild
     write-host "copying build Folder - $GuardianBuild" 

    $GuardianOutputTop = Join-Path -Path $outputFolder -ChildPath "Guardian"
    $GuardianOutput = Join-Path -Path $GuardianOutputTop -ChildPath "build"   

     if(![System.IO.Directory]::Exists($GuardianOutput)){
         Create-Paths -p $GuardianOutput
     }
        $GuardianAsset = Join-Path -Path $GuardianBuild -ChildPath "assets"
         write-host "copying build Folder - $GuardianAsset" 
        Copy-Item $GuardianAsset -Destination $GuardianOutput -recurse

        $GuardianStatic = Join-Path -Path $GuardianBuild -ChildPath "static"
        write-host "copying build Folder - $GuardianAsset" 
        Copy-Item $GuardianStatic -Destination $GuardianOutput -recurse 

        write-host "copying  ico" 
        Copy-Item -path $GuardianBuild\*.ico  -Destination $GuardianOutput 

        write-host "copying  html" 
        Copy-Item -path $GuardianBuild\*.html  -Destination $GuardianOutput 
      
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

}
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
     Git-call

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
         Create-Paths -p $FrozenTraceWebOutput
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
        Create-Paths -p $RootBuild

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
     Git-call
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
         Create-Paths -p $EphemeralIdentityOutput
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
        Create-Paths -p $RootBuild

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


$elapsedTime = $(get-date) - $StartTime
$totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
write-host "elapse time  - $totalTime" 

Set-Location -Path $StartLocation
 