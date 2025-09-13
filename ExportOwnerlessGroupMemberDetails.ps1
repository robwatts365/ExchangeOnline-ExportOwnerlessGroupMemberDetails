<# 
Export Microsoft 365 Ownerless Groups Members
    Version: v1.0
    Date: 09/05/2023
    Author: Rob Watts https://github.com/robwatts365
    Description: This script connects to Exchange Online, finds all ownerless groups in the tenant and exports all members of those groups to a CSV file.
    Prerequisites: ExchangeOnlineManagement PowerShell Module
#>

# Get Date information
#$Date = $(Get-Date).ToString("yyyy-MM-dd")

#Import Exchange Online Module
Import-Module ExchangeOnlineManagement
Write-Host "Importing Exchange Online PowerShell Module..."

# Connects to Exchange Online
Write-Host "Connecting to Exchange Online... Look out for the pop out window."
Connect-ExchangeOnline

# Enable File Saver
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

# File Saver  (Set File Path - Open File Browser)
Write-Host "Please select the save location."
$SaveChooser = New-Object -Typename System.Windows.Forms.SaveFileDialog
$SaveChooser.initialDirectory = $initialDirectory
$SaveChooser.filter = "All files (*.csv)| *.csv"
$SaveChooser.ShowDialog() | Out-Null
$SaveFile = $SaveChooser.filename

# Gets all ownerless groups in the tenant, saves the Group Name and Group Primary SMTP address for later
Get-UnifiedGroup | Where-Object {-Not $_.ManagedBy} | foreach-Object {
    $GroupName=$_.DisplayName
    $GroupPrimarySMTP=$_.PrimarySmtpAddress

#For Each Group, it gets each member and saves user data (Name and UPN) to export
Get-UnifiedGroupLinks -Identity $GroupPrimarySMTP -LinkType Member | ForEach-Object {
        $Row = "" | Select-Object GroupName,GroupPrimarySMTP,UserUPN,UserName
        $row.GroupName=$GroupName
        $row.GroupPrimarySMTP=$GroupPrimarySMTP
        $Row.UserName=$_.DisplayName
        $Row.UserUPN=$_.WindowsLiveID
        $data =@($data)
        $data += $row 
        
    }
}

#Collates all data and saves in a CSV file. 
$data | Export-CSV "$SaveFile" -NoTypeInformation -ErrorAction SilentlyContinue

Write-Host "Done. Your export is saved to $SaveFile."