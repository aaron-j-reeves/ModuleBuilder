# ModuleBuilder

this is a stripped down and sanitized version of something i use at work. it has not been tested and i cant be assed to document it better than what you see here. go read the psframework docs if something is broken.

## psframework
this heavily utilizes many aspects of psframework. ensure you understand how both psframe and psmoduledevelopment work if you run in to any issues

<https://psframework.org/documentation/documents/psmoduledevelopment.html>

<https://psframework.org/documentation/documents/psframework.html>

## how to use
configure the subfolder `ModuleSource` with everything you want to include in your module. internal folder is for stuff you want to run when the module is imported, the function folder is for functions you want exposed and usable as commandlets

navigate to the root directory in powershell and execute `psmdinvoke.ps1` you can also include `-modulename name-of-your-module` or it will prompt you for it. you can also include `-fallbackOutPath <directory path>` to specify the output directory if you dont want to use the psfconfig command below.

DONT try to run this from a different working directory by calling the file path like `& c:\imstupid\cantread\modulebuilder\psmdinvoke.ps1` it probably wont work.

## psfconfigs
you can run the following commands to configure some psfconfigs used by psmdinvoke if you want but it will use generic fall backs if you dont have them defined
- $path is where you want the packaged version of your module to be saved
- $moduleDir is your module install directory where you want the module copied to so you can load it, usually something like documents\powershell\modules
- $nameOfYourModule is the name of your module, all one word. dashes gave me problems.
 
`Set-PSFConfig -Module $nameOfYourModule -Name Template.OutPath -Value $Path -Handler { Write-PSFMessage -Level Host -Message "Changed module output directory to $($args[0])" } -PassThru | Register-PSFConfig`

`Set-PSFConfig -Module $nameOfYourModule -Name Path.pwshModules.CurrentUser -Value $moduleDir -Handler { Write-PSFMessage -Level Host -Message "Changed module output directory to $($args[0])" } -PassThru | Register-PSFConfig`



