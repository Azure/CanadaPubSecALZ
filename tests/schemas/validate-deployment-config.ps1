param (
    [Parameter(Mandatory=$true)] $TestFolder,
    [Parameter(Mandatory=$true)] $FileFilter,
    [Parameter(Mandatory=$true)] $SchemaFile
)

Write-Host "Test Folder: $TestFolder"
Write-Host "File Filter: $FileFilter"
Write-Host "Schema File: $SchemaFile"

Get-ChildItem -Recurse -Filter $FileFilter -Path $TestFolder | ForEach-Object {
    Write-Host "Validating: $_"
    Get-Content -Raw $_ | Test-Json -SchemaFile $SchemaFile
}