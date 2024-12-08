<#
This is an example configuration file

By default, it is enough to have a single one of them,
however if you have enough configuration settings to justify having multiple copies of it,
feel totally free to split them into multiple files.
#>

<#
# Example Configuration
Set-PSFConfig -Module 'þnameþ' -Name 'Example.Setting' -Value 10 -Initialize -Validation 'integer' -Handler { } -Description "Example configuration setting. Your module can then use the setting using 'Get-PSFConfigValue'"
#>

Set-PSFConfig -Name psframework.message.info.color -Value 'Yellow' -Validation consolecolor -Handler { Write-PSFMessage -Level Host -Message "Changed psf message color to $($args[0])" } -Initialize
Set-PSFConfig -Name psframework.message.info.color.emphasis -Value 'White' -Validation consolecolor -Handler { Write-PSFMessage -Level Host -Message "Changed psf message emphasis color to $($args[0])" } -Initialize
Set-PSFConfig -Name psframework.message.info.color.subtle -Value 'DarkYellow' -Validation consolecolor -Handler { Write-PSFMessage -Level Host -Message "Changed psf message subtle color to $($args[0])" } -Initialize