#neuters Responder by disabling SMBv1, forcing SMB signing, disabling LLMNR and disabling NTB-NS
#enter a list of hostnames or IP addresses where you want the script to run (the script will also run locally)
#example:
#./ignorer.ps1 '192.168.1.2','192.168.1.3'

param([String[]]$hosts)

#enable remoting
winrm quickconfig
Enable-PSRemoting -Force

#trust all hosts
$th=Get-Item wsman:\localhost\client\trustedhosts
try{
	Set-Item wsman:\localhost\client\trustedhosts *
	Restart-Service WinRM

	#provide an Administrator credential that will work on all remote hosts
	$cred=Get-Credential

	$scripts='Get-SmbClientConfiguration',#show current smb client config
			 'Get-SmbServerConfiguration',#show current smb server config
			 'Set-SmbClientConfiguration -EnableInsecureGuestLogons $false -EnableSecuritySignature $true -RequireSecuritySignature $true',#disable guest login and force signing
			 'Set-SmbServerConfiguration -EnableSMB1Protocol $false -EnableSecuritySignature $true -RequireSecuritySignature $true',#disable guest login and force signing
			 'REG ADD "HKLM\Software\policies\Microsoft\Windows NT\DNSClient" /f',
			 'REG ADD "HKLM\Software\policies\Microsoft\Windows NT\DNSClient" /v "EnableMulticast" /t REG_DWORD /d "0" /f',#disable LLMNR
			 '(Get-WmiObject win32_networkadapterconfiguration).ForEach({$_.SetTcpIpNetbios(2)})'#disable NetBios (NTB-NS)
			 
	#run on remote machines
	foreach($machine in $machines){
	 try{
	  foreach($script in $scripts){
	   $sb = [Scriptblock]::Create($script)
	   $sb
	   Invoke-Command -ComputerName $machine -Credential $cred -ScriptBlock $sb
	  }
	 }
	 catch{}
	}

	#run locally
	foreach($script in $scripts){
	 try{
	  $sb = [Scriptblock]::Create($script)
	  $sb
	  Invoke-Command -ScriptBlock $sb
	 }
	 catch{}
	}
}
finally{
	#reset TrustedHosts back to original value
	Set-Item wsman:\localhost\client\trustedhosts $th.Value
	Get-Item wsman:\localhost\client\trustedhosts
}