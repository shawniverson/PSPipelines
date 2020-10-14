# PipelineAnalyze.ps1

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
if (!(Get-Module PSScriptAnalyzer -ErrorAction Ignore))
{
    if (!(Import-Module PSScriptAnalyzer -Force -ErrorAction Ignore))
    {
        Install-Module -Name 'PSScriptAnalyzer' -Repository 'PSGallery' -Force
        Import-Module PSScriptAnalyzer -Force
    }
}

$settings =
@{
    Rules =
    @{
        PSUseCompatibleSyntax =
        @{
            Enable = $true
            TargetVersions = @('5.1')
        }
    }
}

$errorFlag = 0

function CheckScripts($scripts) {
    ForEach ($script in $scripts)
    {
        $diagnostics = Invoke-ScriptAnalyzer -Path $script.FullName -Settings $settings -ErrorAction SilentlyContinue
        $errors = $diagnostics | Where-Object Severity -like "*error*"
        $warnings = $diagnostics | Where-Object Severity -like "*warning*"
        if ( $errors )
        {
            Write-Output "##vso[task.logissue type=error; sourcepath=${script}] Failed during analysis"
            Write-Output $errors
            $script:errorFlag = 1
        } elseif ( $warnings )
        {
            Write-Output "##vso[task.logissue type=warning; sourcepath=${script}] Warning during analysis"
            Write-Output $warnings
        } else
        {
            Write-Output "${script}: Passed"
        }
    }
}

Write-Output ""
Write-Output ""

$powerShellScripts = Get-ChildItem -Path $PSScriptRoot -Include '*.psm1' -Recurse
CheckScripts($powerShellScripts)

$powerShellScripts = Get-ChildItem -Path $PSScriptRoot -Include '*.ps1' -Recurse
CheckScripts($powerShellScripts)

exit $errorFlag