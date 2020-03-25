	<#	
		===========================================================================
		 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
		 Created on:   	3/24/2020 9:07 PM
		 Created by:   	elysium
		 Organization: 	
		 Filename:     	elysium.psm1
		-------------------------------------------------------------------------
		 Module Name: elysium
		===========================================================================
	#>
	
	<#
		.EXTERNALHELP elysium.psm1-Help.xml
	#>
	Function Git-call(){
	    ##git checkout master
	    git fetch | git pull
	    yarn install
	
	    write-host "git done " -ForegroundColor yellow
	}
	
	<#
		.EXTERNALHELP elysium.psm1-Help.xml
	#>
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
	
	<#
		.EXTERNALHELP elysium.psm1-Help.xml
	#>
	Function Yarn-Build(){
	    yarn build -Wait
	}
	
	<#
		.EXTERNALHELP elysium.psm1-Help.xml
	#>
	Function Create-Paths($path)
	{
	  if(![System.IO.Directory]::Exists($path)){
	        write-host "Creating  - $path"
	        [System.IO.Directory]::CreateDirectory($path)
	    }
	}
	
	<#
		.EXTERNALHELP elysium.psm1-Help.xml
	#>
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
	
	