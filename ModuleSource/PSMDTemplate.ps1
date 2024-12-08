@{
	TemplateName = 'TemplateBuilder'
	Version = "1.0.0.0"
	AutoIncrementVersion = $true
	Tags = 'module'
	Author = 'Aaron Reeves'
	Description = 'Basic module scaffold'
	Exclusions = @() # Contains list of files - relative path to root - to ignore when building the template
	Scripts = @{
		guid = {
			[System.Guid]::NewGuid().ToString()
		}
		year = {
			Get-Date -Format "yyyy"
		}
		psfversion = {
			(Get-Module PSFramework).Version.ToString()
		}
		functions = {
			(Get-ChildItem -Path ".\functions", ".\internal\functions" -Recurse -Filter "*.ps1" | ForEach-Object { "'$($_.BaseName)'" }) -join ", "
		}
		files = {
			(Get-ChildItem -Recurse -File | Where-Object { $_.Extension -notin ".ps1", ".psd1", ".md", ".txt" } | ForEach-Object { "'$($_.Name)'" }) -join ", "
		}
	}
}