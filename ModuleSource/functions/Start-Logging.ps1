<#
.SYNOPSIS
    Author: Aaron Reeves
    Version: 1.1
    Date: Oct, 2024
.DESCRIPTION
    Uses Set-PSFLoggingProvider to enable the logfile logging provider using the instance and path variables. This will by default log to csv using all of the default logfile headers.
.EXAMPLE
    Start-Logging -Instance "web_cert_create $runID" -Location 'C:\logs\web_cert_create'
.PARAMETER instance
    This parameter defines the name of the resulting log and must end with .csv. if not defined, this will simply be the name of the script + a dynamically generated date + .csv file extension. Make sure if you manually define it that you are not defining it as a static value, as every time your script is ran it will either overwrite the old log or error out because thold log exists. Youll want to have some more of dynamic variable included.
.PARAMETER path
    This parameter defines the path the log is wirtten to as a csv. if not defined, this will default to C:\logs. Make sure you have the permissions to write to this directory. This function will check if the destination path exists and create it.
    #>
    function Start-Logging {
        [CmdletBinding()]
        param(
            [string]$instance,
            [string]$path
        )

        begin {
            
            # Generate file variables
            $script = Get-Execution
            $filename = $script.Command | ForEach-Object { $_ -replace '\.ps1$', '' }
            if (($null -eq $filename)) { $filename = "pwshlog"}
            $date = Get-Date -Format MM-dd-yyyy-HHmmss

            # Generate instance name if not provided
            if (-not $instance) {
                $instance = "$filename-$date"
            }

            # Check if psframework is already loaded
            if ( -not (Get-Module -Name 'psframework' -ListAvailable)) {
                Write-Host "PSFramework not loaded, loading..."
                Import-Module -Name 'psframework' -Verbose
                Write-PSFMessage -Level Host -Message "PSFramework loaded successfully!"
            } else {
                Write-PSFMessage -Level Host -Message "PSFramework was already loaded!"
            }
            # Looks in psfconfigs for log path if not provided and falls back to default
            if (($null -eq $path)) {
                $path = (Get-PSFConfigValue -FullName 'PSFramework.Logging.LogFile.FilePath' -Fallback C:\Logs\$filename)
            }
            
            # Ensure the directory is the right syntax
            if ( Test-Path -Path $path -IsValid ) {
                Write-PSFMessage -Level Verbose -Message "Valid directory $path"
            } else {
                Write-PSFMessage -Level Error -Message "Invalid directory syntax $path"
                return $null
            }
            
            # checks if the path exists and makes it if it isnt
            if (Test-Path -Path $path) {
                Write-PSFMessage -Level Verbose -Message "Directory not found: $path"
                try {
                    Write-PSFMessage -Level Verbose -Message "Creating directory: $path"
                    New-Item -Path $path -ItemType Directory
                    Write-PSFMessage -Level Verbose -Message "Directory created! $path"
                }
                catch {
                    Write-PSFMessage -Level Error -Message "Failed to create directory at $path"
                    return $null
                }
            }
            # Ensure $path ends with a backslash if necessary
            if (-not $path.EndsWith("\")) {
                $path = "$path\"
            }
            
            # Combine the path and instance (filename) and add .csv extension to form the full file path
            $logFilePath = Join-Path -Path $path -ChildPath "$instance.csv"

            # Define the logfile headers so that we can add DataCompact
            $Headers = (Get-PSFConfigValue -FullName 'PSFramework.Logging.LogFile.Headers' -Fallback 'ComputerName', 'File', 'FunctionName', 'Level', 'Line', 'Message', 'ModuleName', 'Runspace', 'Tags', 'TargetObject', 'Timestamp', 'Type', 'Username', 'DataCompact')
            
            # Set up parameters for logging
            $paramSetPSFLoggingProvider = @{
                Name         = 'logfile'
                InstanceName = $instance
                FilePath     = $logFilePath
                headers      = $Headers
                Enabled      = $true
            }
        }
        
        process {
            try {
                Set-PSFLoggingProvider @paramSetPSFLoggingProvider
            }
            catch {
                Write-PSFMessage -Level Error -Message "Failed to start the logging provider" -ErrorRecord $_
                return $null
            }
        }
        
        end {
            # Return the logging provider instance for verification
            $logInstance = Get-PSFLoggingProviderInstance
            Write-PSFMessage -Level Host -Message "PSFramework Logging Enabled!"
            return $logInstance
        }
    }
