param (
    [Parameter(Mandatory=$true)] $TestFolder,
    [Parameter(Mandatory=$true)] $SchemaFolder
)

Write-Host "Test Folder: $TestFolder"
Write-Host "Schema Folder: $SchemaFolder"

Get-ChildItem -Directory -Path $TestFolder | Foreach-Object {
    $archetypeName = $_.BaseName

    Write-Host "Archetype: $archetypeName"

    Get-ChildItem -Recurse -Filter '*.json' -Path $archetype | ForEach-Object {
        Write-Host "   Test: $_"
        Get-Content -Raw $_ | Test-Json -SchemaFile "$SchemaFolder/$archetypeName.json"
    }
}