Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath "HelloWorld.psm1") -Force

Describe "Hello World Module" {
    Context "Module" {
        It "It should be a powershell module script" {
            (Get-Module HelloWorld).ModuleType | Should -be "Script"
        }

        It "Should export the Write-HelloWorld cmdlet" {
            (Get-Module HelloWorld).ExportedCommands.Values.Name | Should -be "Write-HelloWorld"
        }
        
        It "Should be a powershell module function" {
            (Get-Command Write-HelloWorld).CommandType | Should -be "Function"
        }

        It "Should output Hello World!" {
            Write-HelloWorld | Should -be "Hello World!"
        }
    }
    Context "Manifest" {
        It "Should exist" {
            (Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath 'HelloWorld.psd1') | Should -Exist
        }
    }
}