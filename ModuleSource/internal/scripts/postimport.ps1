# Place all code that should be run after functions are imported here
# EXAMPLE
# -----------------
# Install chocolatey
# . Import-ModuleFile -Path "$ModuleRoot\internal\scripts\postimport\post-choco.ps1"

# Load Configurations
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\configurations\*.ps1" -ErrorAction Ignore)) {
	. Import-ModuleFile -Path $file.FullName
}