if (!(Test-Path Variable:PSScriptRoot)) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }
$path = join-path "$psscriptroot" "..\apps\aria2\current\aria2c.exe"
if($myinvocation.expectingInput) { $input | & $path  @args } else { & $path  @args }
