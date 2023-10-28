#requires -Module MSOnline

<#  
    .NOTES
    ===========================================================================
     Created with:  SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.173
     Created on:    21/12/20 5:09 PM
     Created by:    jsavage
     Organization:  
     Filename:      
    ===========================================================================
    .DESCRIPTION
        Shows a list of Office 365 license types and their available units.
#>


Function Get-OfficeLicenseCount {

    # Connect to Office 365
    try
    {
        if (!(Get-MSOlCompanyInformation -erroraction SilentlyContinue))
        {
            Write-Verbose "Not connected to MSOnline Service.  Connecting..."
            if ($credential)
            {
                #connect using securely stored credentials in PS profile
                Connect-MsolService -credential $credential
            }
            else
            {
                #prompt for microsoft credentials
                Connect-MsolService
            }
        }
    }
    catch
    {
        throw 'Failed to connect to the MSOnline Service'
    }

    $licenses = Get-MsolAccountSku

    $licenses | Add-Member -MemberType NoteProperty -Name AvailableUnits -Value ""
    
    foreach ($option in $licenses)
    {
        $option.AvailableUnits += $option.activeunits - $option.consumedunits
        $option.accountskuid = $option.accountskuid.split(":")[1]

    }
    
    $licenses | select @{ Name = 'Licence Type'; Expression = {$_.AccountSkuId }}, AvailableUnits, ActiveUnits, ConsumedUnits
    


}
