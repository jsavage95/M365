
    
function Initialize-AzureADSync {
    param(
        [parameter(Mandatory, Position = 0, HelpMessage="Enter credentials with access to the AzureAD Connector Servers")]
        [System.Management.Automation.PSCredential]$AdminCredential,

        [parameter(Mandatory = $false, position = 1 )]
        [system.string]$AzureADConnectorServer = "AZURE AD CONNECT SERVER",

        [parameter(Mandatory = $false, position = 2 )]
        [ValidateSet("Delta","Initial")]
        [system.string]$SyncType = "Delta"
    )

    Try {
        Invoke-Command -ComputerName $AzureADConnectorServer -Credential $AdminCredential -ScriptBlock {
            Try{
                Start-ADSyncSyncCycle -PolicyType $SyncType -ErrorAction Stop
            }
            Catch{
                $error[0].exception.message
                Write-error "Could not run AzureAD Sync."
                break
            }
        } -ErrorAction Stop
    }
    Catch {
        $error[0].exception.message
        break
    }

    do {
        Write-Host "AzureAD Sync in progress..." -ForegroundColor Yellow

        Start-sleep -Seconds 3

    } while (
        #Check SyncCycleinProgress boolean. If true, continue loop, if False, sync is complete and exit loop.
        Invoke-Command -ComputerName $AzureADConnectorServer -Credential $AdminCredential -ScriptBlock {
            Get-ADSyncScheduler | Select-Object -ExpandProperty SyncCycleinProgress
        }
    )
    Write-host "Azure AD Sync Complete!" -ForegroundColor Green
}