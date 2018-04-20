Import-Module Microsoft.PowerShell.IoT

function Set-RegisterValue {
    param($Device, [int]$Register, [int]$Value)
######### Update register Address and value #########
    [int]$UpdateRegisterAddress = 0x0C
    [int]$UpdateValue = 0xFF # for what I understood, it can be any value " A write operation of any 8-bit value to the Update Column Register is required to update the Data Registers"
    
    Set-I2CRegister -Device $Device -Register $Register -Data $Value #Write the value
    Write-Host "Device: $($Device) - Value: $($Value) - Register: $($Register)"
    Set-I2CRegister -Device $Device -Register $UpdateRegisterAddress -Data $UpdateValue #update the register
}

[int]$DeviceAddress = 0x60

######### Configuration Register and Value #########

[int]$ConfigurationRegisterAddress = 0x00
[int]$ConfigurationRegisterValue = 0x1B

######### Matrix Registers and value #########
[int[]]$Matrix1DataRegisterAddress = 0x01 ..0x0B
[int[]]$values = 0x0,0x0,0x0,0x11,0x08,0x08,0x08,0x11,0x0,0x0,0x0
######### Lightning Effect Register and value #########
[int]$LightningEffectRegisterAddress = 0x0D
[int]$LightningEffectRegisterValue = 0x08
######### Get the device and set the Configuration Register
$Device = Get-I2CDevice -Id $DeviceAddress -FriendlyName phat
Set-I2CRegister -Device $Device -Register $ConfigurationRegisterAddress -Data $ConfigurationRegisterValue

######## Lightning Effect #####
Set-I2CRegister -Device $Device -Register $LightningEffectRegisterAddress -Data $LightningEffectRegisterValue

######### Write the #sadJoey pattern to the Data registers #########

$i = 0
foreach ($register in $Matrix1DataRegisterAddress) {
    Set-RegisterValue -Device $Device -Register $register -Value $values[$i]
    $i++
}