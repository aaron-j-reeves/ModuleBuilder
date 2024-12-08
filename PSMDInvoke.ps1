#REQUIRES -Modules PSModuleDevelopment
#REQUIRES -Modules PSFramework

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    $moduleName,
    [Parameter(Mandatory = $false)]
    # Set the fallback output path for the module incase its not defined in psfconfig
    $fallbackOutPath = 'C:\Modules'
)

# Get the output path from the modulename specific psfconfig configuration or use the fallback path
$Path = Get-PSFConfigValue -FullName "${moduleName}.Template.OutPath" -Fallback $fallbackOutPath -Handler { Write-PSFMessage -Level Host -Message "Changed module output directory to $($args[0])" } | Resolve-PSFPath
Write-PSFMessage -Level Verbose -Message "Set module output directory to $Path"

# Set the configuration for the generic psmd template output path
Set-PSFConfig -Module PSModuleDevelopment -Name Template.OutPath -Value $Path -Handler { Write-PSFMessage -Level Host -Message "Changed module output directory to $($args[0])" }
$psmdPath = Get-PSFConfigValue -FullName PSModuleDevelopment.Template.OutPath
Write-PSFMessage -Level Verbose -Message "Set PSModuleDevelopment output directory to $psmdPath"

# Generate file path variables for use later
$moduleDest = Join-PSFPath -Path $Path $moduleName

# Create a new module template
New-PSMDTemplate -ReferencePath '.\ModuleSource\' -TemplateName $moduleName

# Define parameters for invoking the template
$invokeParams = @{
    OutPath     = $Path
    Force       = $true
    Name        = $moduleName
    Description = 'Built by ModuleBuilder'
}

# Check if the module destination directory exists and remove it if it does, prompt user to confirm incase something goes wrong and it tries to delete the parent dir or something
if ([System.IO.Directory]::Exists($moduleDest)) {
    Write-PSFMessage -Level Host -Message "Previous version of $moduleName found at $moduleDest, deleting it"
    Remove-Item -Path $moduleDest -Recurse -Force -Confirm
    if ([System.IO.Directory]::Exists($moduleDest)) {
    Stop-PSFFunction -Message "Failed to delete previous version found at $moduleDest" -EnableException $true
}

# Invoke the template with the specified parameters
Invoke-PSMDTemplate $moduleName -Parameters $invokeParams

# Get the fallback powershell module directory from the environment variable incase its not defined in psfconfig
$moduleDirFB = $env:psmodulepath -split ';' | Select-PSFObject -Index 0 | Resolve-PSFPath

# Get the current user module directory from psfconfig or use the fallback directory
$moduleDir = Get-PSFConfigValue -FullName "${moduleName}.Path.pwshModules.CurrentUser" -Fallback $moduleDirFB | Resolve-PSFPath
$moduleSub = Join-PSFPath -Path $moduleDir $moduleName

# Check if the module already exists in the current user module directory and remove it if it does
if ([System.IO.Directory]::Exists($moduleSub)) {
    Write-PSFMessage -Level Host -Message "Previous version of $moduleName found at $moduleSub, deleting it"
    Remove-Item -Path $moduleSub -Recurse -Force -Confirm
}

# Copy the module from the output destination to the current user module directory
Copy-Item -Path "$moduleDest" -Destination "$moduleDir" -Recurse

# Check if the module was successfully copied and notify the user
if ([System.IO.Directory]::Exists($moduleDest)) {
    Write-PSFMessage -Level Host -Message "$moduleName successfully built at $Path and copied to your CurrentUser powershell module directory $moduleDir You will need to restart your current session before you can import it"
} else {
    Stop-PSFFunction -Message "Failed to copy $moduleName to $moduleDir" -EnableException $true
}

Write-PSFMessage -Level Host -Message "ModuleBuilder run complete. Module should exist at $path and your powershell module directory. Restarting your powershell session."
Write-Host "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")