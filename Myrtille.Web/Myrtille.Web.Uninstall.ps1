[CmdletBinding()]
Param(
	[Parameter(Mandatory=$False)]
	[bool]$DebugMode
)

Set-ExecutionPolicy Bypass -Scope Process

$host.UI.RawUI.WindowTitle = "Myrtille Configuration . . . PLEASE DO NOT CLOSE THIS WINDOW . . ."

try
{
	Import-Module WebAdministration

	# myrtille web application
	if (Get-WebApplication -Site "Default Web Site" -Name "Myrtille")
	{
		Remove-WebApplication -Site "Default Web Site" -Name "Myrtille"
		Write-Output "Removed Myrtille web application"
	}
	else
	{
		Write-Output "Myrtille web application doesn't exists"
	}

	# myrtille application pool
	if (Test-Path "IIS:\AppPools\MyrtilleAppPool")
	{
		Remove-WebAppPool -Name "MyrtilleAppPool"
		Write-Output "Removed Myrtille application pool"
	}
	else
	{
		Write-Output "Myrtille application pool doesn't exists"
	}

	# myrtille self-signed certificate
	$Cert = Get-ChildItem -Path "Cert:\LocalMachine\My" | Where-Object { $_.FriendlyName -eq "Myrtille self-signed certificate" }
	if ($Cert)
	{
		# the https binding (on the default web site) possibly existed before myrtille was installed (using another certificate); only remove the myrtille certificate
		# Remove-Item was introduced in powershell 3.0, using older approach instead
		#$Cert | Remove-Item
		$Store = New-Object System.Security.Cryptography.x509Certificates.x509Store "My", "LocalMachine"
		$Store.Open("ReadWrite")
		$Store.Remove($Cert)
		$Store.Close()
		Write-Output "Removed Myrtille self-signed certificate"
	}
	else
	{
		Write-Output "Myrtille self-signed certificate doesn't exists"
	}

	if ($DebugMode)
	{
		Read-Host "`r`nPress ENTER to continue..."
	}
}
catch
{
	Write-Output $_.Exception.Message

	if ($DebugMode)
	{
		Read-Host "`r`nPress ENTER to continue..."
	}

	exit 1
}