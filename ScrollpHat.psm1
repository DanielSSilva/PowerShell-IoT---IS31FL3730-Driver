# Implement your module commands in this script.
function Select-ScrollpHat {
        [int]$DeviceAddress = 0x60
        ######### Configuration Register and Value #########
        [int]$ConfigurationRegisterAddress = 0x00
        [int]$ConfigurationRegisterValue = 0x1B
        $Script:Device = Get-I2CDevice -Id $DeviceAddress -FriendlyName phat
        Set-I2CRegister -Device $Device -Register $ConfigurationRegisterAddress -Data $ConfigurationRegisterValue
        $Script:Device
}

function Set-Brightness{
    [CmdletBinding()]
        param (
            [ValidateSet('Low', 'Medium', 'High')]
            [string]$Intensity
        )
        [int]$LightningEffectRegisterAddress = 0x0D
        $IntensityMap = @{
            Low = [convert]::toint32('0001001',2)
            Medium = [convert]::toint32('0000000',2)
            High = [convert]::toint32('0000111',2)
        }
    Set-I2CRegister -Device $Script:Device -Register $LightningEffectRegisterAddress -Data $IntensityMap[$Intensity]
}

function Write-Char {
    [CmdletBinding()]
    param (
        [char]$character
    )
    #Until the dictionary is complete, this method will write the letter A on the 1st position, just for debug
    #Get-NextAvailableRegister
    [int[]]$Matrix1DataRegisterAddress = 0x01 ..0x03
    [int[]]$values = 0x3E, 0x05, 0x3E
    Set-I2CRegister -Device $Script:Device -Register $Register -Data $Value #Write the value
    Update-Registers
}

function Update-Registers{
    [int]$UpdateRegisterAddress = 0x0C
    [int]$UpdateValue = 0xFF # for what I understood, it can be any value " A write operation of any 8-bit value to the Update Column Register is required to update the Data Registers"
    Set-I2CRegister -Device $Script:Device -Register $UpdateRegisterAddress -Data $UpdateValue
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
