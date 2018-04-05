#Created to Pull Version and Proccessors info from SQL servers. 
#Creation date : 4-4-2018
#Creator: Alix N Hoover

Import-Module ActiveDirectory

$searchbase1 = "OU=servers,DC=x,DC=x"
#$searchbase2 = "OU=servers, DC=x,DC=x"
#$searchbase3 = "OU=servers, DC=x,DC=x"
$DOMAIN1 = "DC"
#$DOMAIN2 = "DC2"
#$DOMAIN3 = "DC3"

$HTMLFile = “C:\temp\SQL_Info.htm”

#Email Info
$MailServer = "mailserver"
$recip = "me@x.x"
$sender = "Powershell@x.x"
$subject = "SQL Version Information"


#Populate Server Array
$servers =@()
#$servers = get-adcomputer -server $DOMAIN1 -searchbase $searchbase1 -filter * | ForEach-Object {$_.Name}
#$servers +=get-adcomputer -server $DOMAIN2 -searchbase $searchbase2 -filter * | ForEach-Object {$_.Name}
#$servers +=get-adcomputer -server $DOMAIN3 -searchbase $searchbase3 -filter * | ForEach-Object {$_.Name}

#Manual Server Array
$servers +=("Server1","Server2","Server3\Instance","Server4\Instance")


$totalProcessors =0
$totalExpressProcessors=0

$HTMLinfo = “<HTML><BODY><Table border=1 cellpadding=0 cellspacing=0 width=80%>
<TR BGCOLOR='LIGHTBLUE'>
<TH><B>Server</B></TH>
<TH><B>Instance</B></TH>
<TH><B>Edition</B></TH>
<TH><B>OS</B></TH>
<TH><B>Platform</B></TH>
<TH><B>Version</B></TH>
<TH><B>Memory (MB)</B></TH>
<TH><B>Processors</B></TH>
</TR>”

$HTMLExpress = "<TR><TD colspan=8 ></td></tr>
<TR BGCOLOR='LIGHTBLUE'>
<TH><B>Server</B></TH>
<TH><B>Instance</B></TH>
<TH><B>Edition</B></TH>
<TH><B>OS</B></TH>
<TH><B>Platform</B></TH>
<TH><B>Version</B></TH>
<TH><B>Memory (MB)</B></TH>
<TH><B>Processors</B></TH>
</TR>”

[System.Reflection.Assembly]::LoadWithPartialName(‘Microsoft.SqlServer.SMO’) | out-null
ForEach ($ServerName in $servers)
{
$SQLServer = New-Object (‘Microsoft.SqlServer.Management.Smo.Server’) $ServerName

if ($SQLServer.domaininstancename)
{
if ($SQLServer.Edition -like "*Express*" -OR $SQLServer.Edition -like "*Developer*")
{ 
$HTMLExpress += “
<TD>$($SQLServer.NetName)</TD>
<TD>$($SQLServer.DomainInstanceName)</TD>
<TD>$($SQLServer.Edition)</TD>
<TD>$($SQLServer.OSVersion)</TD>
<TD>$($SQLServer.Platform)</TD>
<TD>$($SQLServer.Version)</TD>
<TD>$($SQLServer.PhysicalMemory)</TD>
<TD>$($SQLServer.Processors)</TD></TR>”

$totalExpressProcessors += $SQLServer.Processors
}#Close IF Express

Else {
$HTMLinfo += “
<TD>$($SQLServer.NetName)</TD>
<TD>$($SQLServer.DomainInstanceName)</TD>
<TD>$($SQLServer.Edition)</TD>
<TD>$($SQLServer.OSVersion)</TD>
<TD>$($SQLServer.Platform)</TD>
<TD>$($SQLServer.Version)</TD>
<TD>$($SQLServer.PhysicalMemory)</TD>
<TD>$($SQLServer.Processors)</TD></TR>”

$totalProcessors += $SQLServer.Processors
}#Close Else Express
}#Close IF Domain Instance 



} #Close For Each Servername in Servers

$HTMLinfo += “<TR>
<TD></TD>
<TD></TD>
<TD></TD>
<TD></TD>
<TD></TD>
<TD></TD>
<TD BGCOLOR='YELLOW'>Total</TD>
<TD BGCOLOR='YELLOW'>$($totalProcessors)</TD></TR>"

$HTMLExpress += “<TR>
<TD></TD>
<TD></TD>
<TD></TD>
<TD></TD>
<TD></TD>
<TD></TD>
<TD BGCOLOR='lightgreen'>Total</TD>
<TD BGCOLOR='lightgreen'>$($totalExpressProcessors)</TD>
</TR></Table></BODY></HTML>”

$HTMLinfo +=$HTMLExpress


$HTMLinfo | Out-File $HTMLFile
$Body2 = $HTMLinfo
Send-MailMessage -From $sender -To $recip -Subject $subject -Body ( $Body2 | out-string ) -BodyAsHtml -SmtpServer $MailServer   
