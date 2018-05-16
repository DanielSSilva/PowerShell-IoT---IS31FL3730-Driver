# PowerShell-IoT - IS31FL3730 Driver

This repository has as main objective, replicate the [pimoroni's IS31FL3730 driver](https://github.com/pimoroni/scroll-phat/blob/master/library/scrollphat/IS31FL3730.py) to the PowerShell environment, using [PowerShell-IoT](https://github.com/PowerShell/PowerShell-IoT).

[Here's](http://www.issi.com/WW/pdf/31FL3730.pdf) the chip's datasheet

If you don't have PowerShell installed on your Raspberry, follow [this guide](https://github.com/PowerShell/PowerShell/blob/master/docs/installation/linux.md#raspbian) to do so.

After that, you need to install [PowerShell-IoT Module](https://github.com/PowerShell/PowerShell-IoT#installation)

# Get Started

It's simple!
```
git clone https://github.com/DanielSSilva/PowerShell-IoT---IS31FL3730-Driver.git
cd ./PowerShell-IoT---IS31FL3730-Driver/
sudo pwsh (if not already on PowerShell)
Import-Module ./ScrollpHat.psm1 -Force
Write-PhatString "HELLO WORLD" -WaitMiliseconds 50 -forever $true
```
# What's available so far?

* Set the LEDs' brightness with `Set-Brightness` (Lowest, Low, Medium, High or Highest)

* Turn the leds off with `Set-LedsOff`

* Write some letters (a string) with `Write-String`. By default, the text is scrolled forever, unless specified otherwise (by passing `$false` as second parameter)

# Example

![](https://i.imgur.com/QSU76lP.gif)


Any suggestion/contribution is really welcome!
