$StartLocation = Get-Location
$outputFolder =  "C:\repos\Elysium" 
$proxyFolder = "C:\repos\proxy"
$StartTime = $(get-date)
$testnum = 0

# Guardian Source
$Guardian = "C:\Users\elysium\gocode\src\github.com\aagon00\Guardian"
$GuardianUI = Join-Path -Path $Guardian -ChildPath "fuse"
$GuardianBuild = Join-Path -Path $GuardianUI -ChildPath "build"

# Guardian Output
$GuardianOutputTop = Join-Path -Path $outputFolder -ChildPath "Guardian"
$GuardianOutput = Join-Path -Path $GuardianOutputTop -ChildPath "build" 
$GuardianAsset = Join-Path -Path $GuardianBuild -ChildPath "assets" 
$GuardianStatic = Join-Path -Path $GuardianBuild -ChildPath "static"

# Frozen Trace Web Source
$FrozenTraceWeb = "C:\Users\elysium\gocode\src\github.com\aagon00\FrozenTraceWeb"
$FrozenTraceWebUI = Join-Path -Path $FrozenTraceWeb -ChildPath "Fuse_UI"
$FrozenTraceWebBuild = Join-Path -Path $FrozenTraceWebUI -ChildPath "build"
$FrozenTraceWebAsset = Join-Path -Path $FrozenTraceWebBuild -ChildPath "assets"
$FrozenTraceWebStatic = Join-Path -Path $FrozenTraceWebBuild -ChildPath "static"
$FrozenTraceWebTiles = Join-Path -Path $FrozenTraceWebBuild -ChildPath "tiles"

# Frozen Trace Web Output
$FrozenTraceWebOutput = Join-Path -Path $outputFolder -ChildPath "FrozenTrace"
$FrozenTraceWebBuildOutput = Join-Path $FrozenTraceWebOutput -ChildPath "build"

# Ephemeral Identity Source
$EphemeralIdentity = "C:\Users\elysium\gocode\src\github.com\aagon00\EphemeralIdentity"
$EphemeralIdentityUI = Join-Path -Path $EphemeralIdentity -ChildPath "Fuse_UI"
$EphemeralIdentityBuild = Join-Path -Path $EphemeralIdentityUI -ChildPath "build"
$EphemeralIdentityAsset = Join-Path -Path $EphemeralIdentityBuild -ChildPath "assets"
$EphemeralIdentityStatic = Join-Path -Path $EphemeralIdentityBuild -ChildPath "static"

# Ephemeral Identity Output
$EphemeralIdentityOutput = Join-Path -Path $outputFolder -ChildPath "EphemeralIdentity"
$EphemeralIdentityBuildOutput = Join-Path $EphemeralIdentityOutput -ChildPath "build"
Import-Module 'elysium'
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