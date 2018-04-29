# Implement your module commands in this script.

New-Variable -Name "TotalRegisters" -Value 11 -Option Constant -Scope Script
New-Variable -Name "CurrentRegisterValues" -Value @() -Scope Script

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
            [ValidateSet('Lowest','Low', 'Medium', 'High', 'Highest')]
            [string]$Intensity
        )

        if($Intensity -eq 'Highest')
        {
            Write-Warning "This brightness setting causes some weird noise on my phat. I assume that's using too much energy. Use at your own risk!"
        }


        [int]$LightningEffectRegisterAddress = 0x0D
        $IntensityMap = @{
            Lowest = [convert]::toint32('1000',2)
            Low = [convert]::toint32('1001',2)
            Medium = [convert]::toint32('1110',2)
            High = [convert]::toint32('0001',2)
            Highest = [convert]::toint32('0111',2)
        }
    Set-I2CRegister -Device $Script:Device -Register $LightningEffectRegisterAddress -Data $IntensityMap[$Intensity]
    Update-Registers
}

function Write-String {
    param(
        [string]$text,
        [System.Boolean]$forever = $true
    )
    Set-LedsOff
    do
    {
        for($i =0; $i -lt $text.Length ; ++$i)
        {
            Write-Char $text[$i]
                #After Writing the char, make sure to leave a space.

            if($Script:CurrentRegisterValues.Count -lt $Script:TotalRegisters){ #We can still set an white column
                $Script:CurrentRegisterValues += 0
                Set-I2CRegister -Device $Script:Device -Register $Script:CurrentRegisterValues.Count -Data 0
            }
            Update-Registers
            Start-Sleep -Milliseconds 10
        }
    }while($forever)
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
    $totalRegistersRequired = $Script:CurrentRegisterValues.Count + $bitsArray.Count

    $registers = ($Script:CurrentRegisterValues.Count+1) .. $totalRegistersRequired

    if($totalRegistersRequired -gt $Script:TotalRegisters ) # this means that we will need to start shifting
    {
        $i = 0
        $wroteWhiteSpace = $false
        while($i -lt $bitsArray.Count)
        {
            #send the first value out.
            $null, $Script:CurrentRegisterValues = $Script:CurrentRegisterValues

            #SHIFT!
            for($j = 1 ; $j -le 10; ++$j) #10 because we will leave the 11 to the new value
            {
                Set-I2CRegister -Device $Script:Device -Register $j -Data $Script:CurrentRegisterValues[$j-1]
            }

            #start by writing a white column
            if($wroteWhiteSpace -eq $false)
            {
                Set-I2CRegister -Device $Script:Device -Register 0xB -Data 0
                $Script:CurrentRegisterValues+= 0
                Update-Registers
                $wroteWhiteSpace = $true
                continue
            }

            Set-I2CRegister -Device $Script:Device -Register 0xB -Data $bitsArray[$i]
            $Script:CurrentRegisterValues += $bitsArray[$i++]
            Update-Registers
            #Start-Sleep -Milliseconds 200
        }
        return
    }
    #if we get here, this is one of the first letters
    $i = 0
    foreach($register in $registers)
    {
        Set-I2CRegister -Device $Script:Device -Register $register -Data $bitsArray[$i]
        $Script:CurrentRegisterValues += $bitsArray[$i++]
    }
}

function Update-Registers{
    [int]$UpdateRegisterAddress = 0x0C
    [int]$UpdateValue = 0xFF # for what I understood, it can be any value " A write operation of any 8-bit value to the Update Column Register is required to update the Data Registers"
    Set-I2CRegister -Device $Script:Device -Register $UpdateRegisterAddress -Data $UpdateValue
}

function Set-LedsOff {
    foreach ($register in @(1 .. $Script:TotalRegisters)) {
        Set-I2CRegister -Device $Script:Device -Register $register -Data 0x0
    }
    $Script:CurrentRegisterValues = @()
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

    $availableRegisters = $Script:MatrixRegisters | Where-Object {$_.InUse -eq $false}

    $requestedRegisters = $availableRegisters | Select-Object -First $numberOfRequiredRegisters

    return [PSCustomObject]@{
        RequestedRegisters = $requestedRegisters
        TotalAvailable = $availableRegisters.Count
    }

}

Select-ScrollpHat

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
