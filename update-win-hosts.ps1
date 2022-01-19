param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

'running with full privileges'
$hostsFilePath="$env:windir\system32\drivers\etc\hosts"
$currentDir=$PSScriptRoot
$vhostsFile="$($currentdir)\vhosts.txt"
echo $currentDir

$vhosts=Get-Content -Path $vhostsFile
foreach($line in $vhosts){
	#echo $line
}
$ipv4 = "127.0.0.1"
$ipv6 = "::1"
$currentHostsIpv4=New-Object System.Collections.Generic.List[System.Object]
$currentHostsIpv6=New-Object System.Collections.Generic.List[System.Object]
$winHosts = Get-Content -Path $hostsFilePath
foreach($line in $winHosts){
	$hosts = $line.split(" ")	
	if($hosts[0] -eq $ipv4){
		foreach($hostName in $hosts){
			if($hostName -eq $ipv4){
				continue
			}
			$currentHostsIpv4.Add($hostName)
		}
	}
	if($hosts[0] -eq $ipv6){
		foreach($hostName in $hosts){
			if($hostName -eq $ipv6){
				continue
			}
			$currentHostsIpv6.Add($hostName)
		}
	}
}
foreach($hostName in $vhosts){
	if($hostName -eq  ""){ continue }
	if($currentHostsIpv4 -contains $hostName){		
	}else{		
		$winHosts += "127.0.0.1 $($hostName)`r`n"
	}
	if($currentHostsIpv6 -contains $hostName){		
	}else{		
		$winHosts += "::1 $($hostName)`r`n"

	}
}
$ipv4Hosts = "127.0.0.1 $($currentHostsIpv4 -Join ' ')"
$ipv6Hosts = "::1 $($currentHostsIpv6 -Join ' ')"
echo "Updating system hosts file"
$winHosts
$winHosts | Out-File $hostsFilePath -enc ASCII

