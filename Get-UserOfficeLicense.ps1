<#
.NOTES
===========================================================================
 Created with: SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.173
 Created on:   12/12/20 10:14 AM
 Created by:   jsavage
 Organization: 
 Filename:     
===========================================================================
.DESCRIPTION
Shows all licenses a user has assigned to them.
#>

function Get-UserOfficeLicense
{
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [System.String[]]$username,
        [Parameter(Position = 1, Mandatory = $false)]
        [PSCredential]$credential
    )
    
    begin
    {
        
        # Connect to Office 365
        try
        {
            if (!(Get-MSOlCompanyInformation -erroraction SilentlyContinue))
            {
                Write-Verbose "Not connected to MSOnline Service.  Connecting..."
                if ($credential)
                {
                    Connect-MsolService -credential $credential
                }
                else
                {
                    Connect-MsolService
                }
            }
        }
        catch
        {
            Throw 'Failed to connect to the MSOnline Service'
        }
        
        #Create a hash table with easy to read license names
        $FriendlyNameHash = @{
            'COMPANYNAME:VISIOCLIENT'= 'Visio Pro Online'
            'COMPANYNAME:POWER_BI_PRO' = 'Power BI Pro'
            'COMPANYNAME:WINDOWS_STORE'= 'Windows Store for Business'
            'COMPANYNAME:FLOW_FREE'= 'Microsoft Flow Free'
            'COMPANYNAME:POWER_BI_STANDARD' = 'Power-BI Standard (free)'
            'COMPANYNAME:OFFICESUBSCRIPTION' = 'Microsoft 365 Apps for Enterprise'
            'COMPANYNAME:VISIOONLINE_PLAN1' = 'Visio Online Plan 1'
            'COMPANYNAME:PROJECTPROFESSIONAL' = 'Project Professional'
            'COMPANYNAME:TEAMS_EXPLORATORY' = 'Microsoft Teams Exploratory'
        }

    }
    
    Process
    {

        $UserPrincipalName = @()
        foreach ($user in $username)
        {
            try
            {
                # Check the user exists, might not be if a brand new user account
                $UserPrincipalName += Get-ADUser -Identity $user | Select-Object -ExpandProperty UserPrincipalName -ErrorAction Stop
            }
            Catch
            {
                Write-Host "Unable to find '$user' in Active Directory: $_" -ForegroundColor Red
            }
        }
        
        
        
        #Get licenses assigned to mailboxes
        $User = (Get-MsolUser -UserPrincipalName $UserPrincipalName)
        $Licenses = $User.Licenses.AccountSkuId
        $AssignedLicense = ""
        $Count = 0
        
        #Convert license plan to friendly name
        foreach ($License in $Licenses)
        {
            $Count++
            $LicenseItem = $License -Split ":" | Select-Object -Last 1
            $EasyName = $FriendlyNameHash[$LicenseItem]
            if (!($EasyName))
            { $NamePrint = $LicenseItem }
            else
            { $NamePrint = $EasyName }
            $AssignedLicense = $AssignedLicense + $NamePrint
            if ($count -lt $licenses.count)
            {
                $AssignedLicense = $AssignedLicense + ","
            }
        }

    }

}