Param(
[switch]$Clean,
[switch]$list
)
if (!$Clean -And !$list) {
	echo "Usage: 
	# To Clean the databases
	.\disabled-mailboxes.ps1 -Clean
	
	# To list the disconnected mailboxes
	.\disabled-mailboxes.ps1 -list
	
	# To clean the databases and then list the disconnected mailboxes (Recommended)
	.\disabled-mailboxes.ps1 -Clean -list
	"
	Break
}
$snapinAdded = Get-PSSnapin | Select-String "Microsoft.Exchange.Management.PowerShell.Admin"
if (!$snapinAdded) {
	Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
}


$DBList = Get-MailboxDatabase | Sort

Foreach ($DB in $DBList) {
	$DBName = $DB.Name
	$DBServ = $DB.ServerName
	$DBStor = $DB.StorageGroupName
	$DBFull = "$DBServ\$DBStor\$DBName"
	If ($Clean) {
		echo "Cleaning $DBName..."
		Clean-MailboxDatabase "$DBFull"
	}
	If ($list) {
		If ($ServList) {
			$ServList += $DBServ
		}
		Else {
			$ServList = @()
			$ServList += $DBServ
		}
		
	}
}

If ($list -and $ServList) {
	$ServList = $ServList | Select -Uniq
	Foreach ($serv in $ServList) {
		if ($output) {
			$output += Get-MailboxStatistics -Server $serv | where { $_.DisconnectDate -ne $null } | select DisplayName,DisconnectDate
		}
		else {
			$output = @()
			$output = Get-MailboxStatistics -Server $serv | where { $_.DisconnectDate -ne $null } | select DisplayName,DisconnectDate
		}
	}
	echo $output 
}