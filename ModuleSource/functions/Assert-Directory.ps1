<#
.SYNOPSIS
    Author: Aaron Reeves
    Version: 1.1
    Date: October, 2024
.DESCRIPTION
    Check if a folder exists, and create it if it doesn't. Default behavior with no parameters will print success to host and return a pscustomobject containing a System.Collections.Generic.List[System.IO.DirectoryInfo] table of directories created successfully
.EXAMPLE
    Assert-Directory -path 'c:\test\path'
.EXAMPLE
    (Split-Path $profile) + "\modules" | Assert-Directory
.PARAMETER returnFails
    Will send fails to host instead of successes
#>
function Assert-Directory {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]

    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline)]
        [ValidateScript({
            if ([string]::IsNullOrEmpty($_)) {
                $false  # Return false for null or empty strings
            } else {
                $_.IndexOfAny((Test-Path -IsValid))
            }
        }, ErrorMessage = "The input is either empty or contains invalid path characters.")]
        [string[]]$pathinput,
        [switch]$returnFails
    )

    begin {
        # successful directories
        $sdir = [System.Collections.Hashtable]::new()
        # failed directories
        $fdir = [System.Collections.Hashtable]::new()
    }
    
    process {
        foreach ($path in $pathinput) {
            if (-not [System.IO.Directory]::Exists($path)) {
                Write-PSFMessage -Level Verbose -Message "Directory not found: $path"
                try {
                    Write-PSFMessage -Level Verbose -Message "Creating directory: $path"
                    [System.IO.Directory]::CreateDirectory("$path")
                    Write-PSFMessage -Level Verbose -Message "Directory created! $path"
                    $sdir.Add("$path", 'Created')
                }
                catch {
                    Write-PSFMessage -Level Error -Message "Failed to create directory at $path" -ErrorRecord %_
                    $fdir.Add("$path", 'FAILED')
                    return $null
                }
            } else {
                Write-PSFMessage -Level Verbose -Message "Directory already exists! $path"
                $sdir.Add("$path", 'Existed')
            }
        }
    }

    end {

        if ($returnFails) {
            Write-PSFMessage -Level Verbose -Message "Parameter returnFails detected, returning fails instead of successes"
            $fdir | Format-List | Out-String | Write-Verbose
            $sdir | Format-List | Out-String | Write-Verbose
            return $fdir

        
        } else {
            $fdir | Format-List | Out-String | Write-Verbose
            $sdir | Format-List | Out-String | Write-Verbose
            return $sdir
        }
    
    }

}

