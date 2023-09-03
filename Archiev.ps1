$SourceLogs = "enter path" ##### enter the source path ###
$DestLogs = "enter path"     ###### enter the destenation path###
$Days = "90"               ###### enter the  minimum age file ###
$FPSfiles = Get-ChildItem -Path $SourceLogs\* -Include FPS*.txt
foreach ($file in $FPSfiles)
{
$filedate = $file.CreationTime | Get-Date
$Zipname = $file.CreationTime | Get-Date -Format "yyyy-MM"
$year =  $file.CreationTime | Get-Date -Format "yyyy"
$CurrentDate = Get-Date
$DifferenceDate = (New-TimeSpan -Start $filedate -End $CurrentDate).Days
if ($DifferenceDate -gt $Days )
{
if (Test-Path -Path "$DestLogs\$year")
	{
Compress-Archive -Path "$file"-DestinationPath "$DestLogs\$year\$Zipname.zip" -Update
Remove-Item -Path "$file"
}
else {
New-Item -Path "$DestLogs" -Name "$year" -ItemType Directory
Compress-Archive -Path "$file"-DestinationPath "$DestLogs\$year\$Zipname.zip" -Update
Remove-Item -Path "$file"
}

}
}

