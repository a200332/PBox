if (!(Test-Path Variable:PSScriptRoot)) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }
$path = join-path "$psscriptroot" "..\apps\7zip\current\7z.exe"
if($myinvocation.expectingInput) { $input | & $path  @args } else { & $path  @args }
