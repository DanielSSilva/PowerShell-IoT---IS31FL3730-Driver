Import-Module Microsoft.PowerShell.IoT

[int]$DeviceAddress = 0x60
[int]$ConfigurationRegisterAddress = 0x00
[int]$ConfigurationRegisterValue = 0x1B
# Get the scroll pHat from I2C.
$Device = Get-I2CDevice -Id $DeviceAddress -FriendlyName phat
# Set the configuration register with the respective configuration value
Set-I2CRegister -Device $Device -Register $ConfigurationRegisterAddress -Data $ConfigurationRegisterValue

#Let's Write the A letter. For that, we will need 3 Registers
#Registers: 1 2 3
#             x
#           x   x
#           x x x
#           x   x
#           x   x

$registers = 0x01..0x3
$letterA = 0x1E, 0x05, 0x1E

$index = 0
#Set the value on $letterA array on the correspondent register.
foreach($register in $registers)
{
	Set-I2CRegister -Device $Device -Register $register -Data $letterA[$index]
	++$index
}
#In order to update the registers, we need to write something to the column register, accoding to the datasheet: "A write operation of any 8-bit value to the Update Column Register is required to update the Data Registers"
[int]$UpdateRegisterAddress = 0x0C
[int]$UpdateValue = 0xFF
#After executing this instruction, you should see the A letter on your Scroll pHat :)
Set-I2CRegister -Device $Device -Register $UpdateRegisterAddress -Data $UpdateValue