<#
.SYNOPSIS
    Author: Aaron Reeves
    Version: 1.0
    Date: Nov, 2024
.DESCRIPTION
    This function copies a file from the local computer to a remote computer using PowerShell remoting. The function creates a new PowerShell session to the remote computer, copies the file, and then closes the session.
.EXAMPLE
    copy-filePSSession -LocalFilePath 'C:\temp\file.txt' -RemoteComputer 'Server01'
    This example copies the file 'file.txt' from the local computer to the remote computer 'Server01' in the default directory 'c:\temp'.
.EXAMPLE
    copy-filePSSession -LocalFilePath 'C:\temp\file.txt' -RemoteDirectoryPath 'c:\data' -RemoteComputer 'Server01'
    This example copies the file 'file.txt' from the local computer to the remote computer 'Server01' in the directory 'c:\data'.
#>
function copy-filePSSession {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$LocalFilePath,
    
        [Parameter(Mandatory=$false)]
        [string]$RemoteDirectoryPath = 'c:\temp',
    
        [Parameter(Mandatory=$true)]
        [string]$RemoteComputer
    )
    
    begin {
        # Check if the local file exists
        if (-not (Test-Path $LocalFilePath)) { Stop-PSFFunction -Message "The local file does not exist. Please check the path and try again." -EnableException $true }
        
        # Check if the remote computer is reachable
        if (-not (Test-Connection -ComputerName $RemoteComputer -Count 1 -Quiet)) { Stop-PSFFunction -Message "The remote computer is not reachable. Please check the computer name and try again." -EnableException $true }
    }
    
    process {

        # Create a new PowerShell session to the remote computer
        $session = New-PSSession -ComputerName $RemoteComputer
        
        #attempt to fix file attributes caused by onedrive that break pssession file copies
        $attributes = get-item $LocalFilePath | Select-Object -ExpandProperty Attributes
        if ($attributes -eq '5248544'){
            attrib.exe $LocalFilePath +P
            attrib.exe $LocalFilePath -P
            $attribResult = get-item $LocalFilePath | Select-Object -ExpandProperty Attributes
            if ($attribResult -eq '5248544'){
            Stop-PSFFunction -Message "couldnt fix the attribute. " -EnableException $true
            }
        } elseif ($attributes -eq '525344'){
            attrib.exe $LocalFilePath -P
            $attribResult = get-item $LocalFilePath | Select-Object -ExpandProperty Attributes
            if ($attribResult -eq '525344'){
            Stop-PSFFunction -Message "couldnt fix the attribute. " -EnableException $true
            }
        }
        
        try {
            # Attempt to copy the local file to the remote directory
            Copy-Item -Path $LocalFilePath -Destination $RemoteDirectoryPath -ToSession $session -ErrorAction Stop
        }

        catch {
            Write-Error "Failed to copy the file. The remote directory may not exist or you may not have sufficient permissions. Full error: $_ "
        }
        
    }
    
    end {
        # Close the remote session
        if ($session) { Remove-PSSession -Session $session }
    }
}

