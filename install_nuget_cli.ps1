write-host "`n ## NUGET CLI INSTALLER"
$url = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
$install = $true
$nuget_exe = "$PSScriptRoot\tools\nuget.exe"

if ($install) {

    if(![System.IO.File]::Exists($nuget_exe)){
        write-host "downloading the nuget cli: $nuget_exe"
        $start_time = Get-Date
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($url, $nuget_exe)
        write-Output "nuget cli installer downloaded"
        write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
    }else{
        write-host "nuget.exe already installed"
        write-host "Make sure to add [$PSScriptRoot\tools\] to your env paths"
    }

    # $paths = $env:Path.Split(";");
    # if(!$paths.Contains("$nuget_exe")) {
    #     write-host "adding nuget.exe to env paths...."
    #     #$env:Path = "$nuget_exe";              #(replaces existing path) 
    #     $env:Path += ";$nuget_exe"              # (appends to existing path)
    # }
}

write-host "`n"