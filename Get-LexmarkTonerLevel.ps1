# Verified working for Lexmark MX710 line and MS410 line models.
$PrinterIP = Read-Host "Please type the printer's IP address"
$PrinterDetails = (Invoke-WebRequest "http://$PrinterIP/cgi-bin/dynamic/topbar.html").RawContent.Split("`n")
$PrinterName = (($PrinterDetails -like "*location*") -replace ".*Location: " -replace "<.*")
$PrinterModel = (($PrinterDetails -like "*prodname*") -replace ".*top_prodname`">" -replace "<.*")

$PercentToner = [int]$(((((Invoke-WebRequest "http://$PrinterIP/cgi-bin/dynamic/printer/PrinterStatus.html").RawContent).Split("`n")) -like "*~*") -replace ".*~" -replace "%.*")
"$PrinterName has $PercentToner% toner remaining."

if (($PercentToner) -is [int]) { # You could also use (($PercentToner).GetType() -eq [int]) here.
	while ($PercentToner -gt 1) {
		Start-Sleep 180 # 3 minutes
		$PercentToner = [int]$(((((Invoke-WebRequest "http://$PrinterIP/cgi-bin/dynamic/printer/PrinterStatus.html").RawContent).Split("`n")) -like "*~*") -replace ".*~" -replace "%.*")
		"$PrinterName has $PercentToner% toner remaining. Waiting to alert at 1%."
	}
	# Set up your notification of choice here, such as Send-MailMessage using "$PrinterName toner cartridge empty." or "$PrinterName toner cartridge has less than 1% remaining. Model $PrinterModel. Please replace."
}
else {
	"Couldn't get ramaining toner amount... please review."
	Read-Host "Press any key to exit"
}
# This can be adapted to other printers, as long as the printer status page is directly web accessible, but the regex may need to change.