# bootstrap.ps1
#Requires -modules Az

# Change to suit your needs
$resourceName = "PSPipelinesRG"
$location = "eastus"
$repoPath = $PSScriptRoot

if (-not (Get-AzContext -ListAvailable)) {
    Write-Error "Not Connected to Azure"
    exit
}

try {
    $rg = New-AzResourceGroup -Name $resourceName -Location $location -Force
    $job = New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile (Join-Path -Path $repoPath -ChildPath "template.json") -TemplateParameterFile (Join-Path -Path $repoPath -ChildPath 'parameters.json') -AsJob
    Write-Output "Deployment executing, please wait..."
    $job | Wait-Job 

    Write-Output ""
    Write-Output "...Deployment finished, result:" $job.State

}
catch {
    Write-Error "Error bootstrapping environment"
    exit
}

exit