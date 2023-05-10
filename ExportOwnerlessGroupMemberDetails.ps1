<# 
Export Microsoft 365 Ownerless Groups Members
    Version: v1.0
    Date: 09/05/2023
    Author: Rob Watts - Senior Cloud Solution Architect - Microsoft
    

DISCLAIMER
   THIS CODE IS SAMPLE CODE. THESE SAMPLES ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
   MICROSOFT FURTHER DISCLAIMS ALL IMPLIED WARRANTIES INCLUDING WITHOUT LIMITATION ANY IMPLIED WARRANTIES
   OF MERCHANTABILITY OR OF FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK ARISING OUT OF THE USE OR
   PERFORMANCE OF THE SAMPLES REMAINS WITH YOU. IN NO EVENT SHALL MICROSOFT OR ITS SUPPLIERS BE LIABLE FOR
   ANY DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS PROFITS, BUSINESS
   INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR
   INABILITY TO USE THE SAMPLES, EVEN IF MICROSOFT HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
   BECAUSE SOME STATES DO NOT ALLOW THE EXCLUSION OR LIMITATION OF LIABILITY FOR CONSEQUENTIAL OR
   INCIDENTAL DAMAGES, THE ABOVE LIMITATION MAY NOT APPLY TO YOU.
#>

# Pop out disclaimer
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

[Windows.Forms.MessageBox]::Show("
THIS CODE IS SAMPLE CODE. 

THESE SAMPLES ARE PROVIDED 'AS IS' WITHOUT WARRANTY OF ANY KIND.

MICROSOFT FURTHER DISCLAIMS ALL IMPLIED WARRANTIES INCLUDING WITHOUT LIMITATION ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR OF FITNESS FOR A PARTICULAR PURPOSE. 

THE ENTIRE RISK ARISING OUT OF THE USE OR PERFORMANCE OF THE SAMPLES REMAINS WITH YOU.

IN NO EVENT SHALL MICROSOFT OR ITS SUPPLIERS BE LIABLE FOR ANY DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS PROFITS, BUSINESS INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR INABILITY TO USE THE SAMPLES, EVEN IF MICROSOFT HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

BECAUSE SOME STATES DO NOT ALLOW THE EXCLUSION OR LIMITATION OF LIABILITY FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES, THE ABOVE LIMITATION MAY NOT APPLY TO YOU.", "***DISCLAIMER***", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Warning)

# Get Date information
$Date = $(Get-Date).ToString("yyyy-MM-dd")

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

# Gets all teams in the tenant, saves the Team Name and Group ID for later
Get-UnifiedGroup | Where-Object {-Not $_.ManagedBy} | foreach-Object {
    $GroupName=$_.DisplayName
    $GroupPrimarySMTP=$_.PrimarySmtpAddress

#For Each Team, it gets each member and saves user data (Name, UPN, Role (Owner/Member)) to export
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