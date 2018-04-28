# Implement your module commands in this script.
$registerObjectArray = @();
for([int] $i = 1; $i -le 11<#numberOfRegisters#>; ++$i){
    $registerObjectArray += [PSCustomObject]@{
        Address = $i
        InUse   = $false
    }
}
New-Variable -Name "MatrixRegisters" -Value $registerObjectArray -Scope Script

New-Variable -Name "InitialEmptyColumns" -Value 0x04, 0x08 -Option Constant -Scope Script

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
            [Parameter(Mandatory=$true)]
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
    Update-Registers
}

function Write-String {
    param(
        [string]$text
    )
    for($i =0; $i -lt $text.Length ; ++$i)
    {
        Write-Char $text[$i]
            #After Writing the char, make sure to leave a space.
    $blankSpaceRegister = Get-NextAvailableRegisters 1
    if($blankSpaceRegister -eq $null){ #we have reached the end of the registers....
        return
    }
    Set-I2CRegister -Device $Script:Device -Register $blankSpaceRegister.Address -Data 0
    $blankSpaceRegister.InUse = $true
    }
    Update-Registers
}

function Write-Char {
    param(
        [ValidateLength(1,1)]
        [string]$char
    )
    ##############TEMP#################
    $alphabet = @{
        A = 0x3E, 0x05, 0x3E
        B = 0x1F, 0x15, 0x0A
        C = 0x0E, 0x11, 0x11
        D = 0x1F, 0x11, 0x0E
        E = 0x1F, 0x15, 0x11
        F = 0x1F, 0x05, 0x01
        G = 0x0E, 0x11, 0x1D
        H = 0x1F, 0x04, 0x1F
        I = 0x11, 0x1F, 0x11
        J = 0x09, 0x11, 0x0F
        K = 0x1F, 0x04, 0x1B
        L = 0x1F, 0x10, 0x10
        M = 0x1F, 0x02, 0x04, 0x02, 0x1F
        "!" = 0x17
    }
    ###################################
    #get respective bits from hashtable
    $bitsArray = $alphabet[$char] # this is an array with required data
    $registers = Get-NextAvailableRegisters $bitsArray.Count
    $i = 0
    foreach($register in $registers)
    {
        Set-I2CRegister -Device $Script:Device -Register $register.Address -Data $bitsArray[$i]
        $register.InUse = $true
        ++$i
    }
}

function Update-Registers{
    [int]$UpdateRegisterAddress = 0x0C
    [int]$UpdateValue = 0xFF # for what I understood, it can be any value " A write operation of any 8-bit value to the Update Column Register is required to update the Data Registers"
    Set-I2CRegister -Device $Script:Device -Register $UpdateRegisterAddress -Data $UpdateValue
}

function Set-LedsOff {
    foreach ($register in @($Script:MatrixRegisters | % {$_})) { # this weird sintax flattens the list.
        Set-I2CRegister -Device $Script:Device -Register $register.Address -Data 0x0
        $register.InUse = $false
    }

    Update-Registers
}

function Reset-Registers {
    $resetRegisterAddress = 0xFF
    $resetRegisterValue = 0xF #can be any value
    Set-I2CRegister -Device $Script:Device -Register $resetRegisterAddress -Data $resetRegisterValue
}

function Get-NextAvailableRegisters {
    param(
        [int]$numberOfRequiredRegisters
    )
    $Script:MatrixRegisters | Where-Object {$_.InUse -eq $false} | Select-Object -First $numberOfRequiredRegisters

}

Select-ScrollpHat

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
