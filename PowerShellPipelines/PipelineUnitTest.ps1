# Verify NuGet and PSGallery presence
if(!(Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction Ignore))
{
    Install-PackageProvider -Name NuGet -Force
}
    
if (!(Get-PSRepository -Name PSGallery -ErrorAction Ignore))
{
    Register-PSRepository -Name PSGallery -SourceLocation https://www.powershellgallery.com/api/v2/ -InstallationPolicy Trusted -PackageManagementProvider NuGet
}

# Verify presence of PSScriptAnalyzer
if (!(Get-Module Pester -ErrorAction Ignore))
{
    if (!(Import-Module Pester -Force -ErrorAction Ignore))
    {
        Install-Module -Name 'Pester' -Repository 'PSGallery' -Force
        Import-Module Pester -Force
    }
}

$powershellTests = Get-ChildItem -Path $PSScriptRoot -Include 'Tests' -Recurse 

foreach ($testPath in $powershellTests)
{
    $PesterResults = Invoke-Pester -Script (Join-Path -Path $testPath.FullName -ChildPath '*.ps1') -CodeCoverage (Join-Path -Path $testPath.FullName -ChildPath '..' -AdditionalChildPath '*.psm1') -OutputFile (Join-Path -Path $testPath.FullName -ChildPath '..' -AdditionalChildPath 'UnitTest.xml') -OutputFormat NUnitXml -PassThru

    if ($PesterResults.FailedCount)
    {
        $errorMessage = "Unit Test Failed: $($PesterResults.FailedCount) tests failed out of $($PesterResults.TotalCount) total units tested."
        Write-Output "##vso[task.logissue type=error]$errorMessage"
    }
}

