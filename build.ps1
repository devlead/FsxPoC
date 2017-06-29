Add-Type -AssemblyName System.IO.Compression.FileSystem
Function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Function NugetInstall
{
    param(
        [string]$PackageId,
        [string]$PackageVersion,
        [string]$ToolsPath
    )
    (New-Object System.Net.WebClient).DownloadFile("https://www.nuget.org/api/v2/package/$PackageId/$PackageVersion", "$ToolsPath\$PackageId.zip")
     Unzip "$ToolsPath\$PackageId.zip" "$ToolsPath/$PackageId.$PackageVersion"
     Remove-Item "$ToolsPath\$PackageId.zip"
}

[string] $CakeVersion       = "0.20.0"
[string] $BridgeVersion     = "0.0.4-alpha"
[string] $FSIVersion        = "4.1.17"

[string] $PSScriptRoot      = Split-Path $MyInvocation.MyCommand.Path -Parent
[string] $ToolsPath         = Join-Path $PSScriptRoot "tools"
[string] $CakeCorePath      = Join-Path $ToolsPath "Cake.Core.$CakeVersion/lib/net45/Cake.Core.dll"
[string] $CakeCommonPath    = Join-Path $ToolsPath "Cake.Common.$CakeVersion/lib/net45/Cake.Common.dll"
[string] $CakeBridgePath    = Join-Path $ToolsPath "Cake.Bridge.$BridgeVersion/lib/net45/Cake.Bridge.dll"
[string] $FSIPath           = Join-Path $ToolsPath "FSharp.Compiler.Tools.$FSIVersion/tools/fsi.exe"

if (!(Test-Path $ToolsPath))
{
    New-Item -Path $ToolsPath -Type directory | Out-Null
}

if (!(Test-Path $CakeCorePath))
{
   NugetInstall 'Cake.Core' $CakeVersion $ToolsPath
}

if (!(Test-Path $CakeCommonPath))
{
   NugetInstall 'Cake.Common' $CakeVersion $ToolsPath
}

if (!(Test-Path $CakeBridgePath))
{
   NugetInstall 'Cake.Bridge' $BridgeVersion $ToolsPath
}


if (!(Test-Path $FSIPath))
{
   NugetInstall 'FSharp.Compiler.Tools' $FSIVersion $ToolsPath
}

if (!(test-path $FSIPath)) {
  exit 404
}

&$FSIPath .\build.fsx $args
exit $LASTEXITCODE