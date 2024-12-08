<#
.SYNOPSIS
    Author: Aaron Reeves
    Version: 1.0
    Date: Nov, 2024
.DESCRIPTION
    This function gets the current execution context of the script.
    It returns the current callstack and the location of the script.
.EXAMPLE
    Get-Execution
    This example returns the current execution context of the script.
.NOTES
    This function uses the `Get-PSCallStack` cmdlet to get the current callstack.
#>
function Get-Execution {

    $CallStack = Get-PSCallStack | Select-Object -Property *

    if (
        ($null -ne $CallStack.Count) -or
        (
        ($CallStack.Command -ne '<ScriptBlock>') -and
        ($CallStack.Location -ne '<No file>') -and
        ($Null -ne $CallStack.ScriptName)
        )
    ) {
        if ($CallStack.Count -eq 1) {

            $Output = $CallStack[0]
            $Output | Add-Member -MemberType NoteProperty -Name ScriptLocation -Value $((Split-Path $_.ScriptName)[0]) -PassThru

        } else {

            $Output = $CallStack[($CallStack.Count – 1)]
            $Output | Add-Member -MemberType NoteProperty -Name ScriptLocation -Value $((Split-Path $Output.ScriptName)[0]) -PassThru -ErrorAction SilentlyContinue

        }
    } else {

        Write-Error -Message 'No callstack detected' -Category 'InvalidData'

    }
}