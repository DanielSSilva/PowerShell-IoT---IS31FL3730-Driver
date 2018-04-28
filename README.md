# PowerShell-IoT - IS31FL3730 Driver

This repository has as main objective, replicate the [pimoroni's IS31FL3730 driver](https://github.com/pimoroni/scroll-phat/blob/master/library/scrollphat/IS31FL3730.py) to the PowerShell environment, using [PowerShell-IoT](https://github.com/PowerShell/PowerShell-IoT).

[Here's](http://www.issi.com/WW/pdf/31FL3730.pdf) the chip's datasheet

If you don't have PowerShell installed on your Raspberry, follow [this guide](https://github.com/PowerShell/PowerShell/blob/master/docs/installation/linux.md#raspbian) to do so.

After that, you need to install [PowerShell-IoT Module](https://github.com/PowerShell/PowerShell-IoT#installation)

# What's available so far?
This is still in a really early phase. So far I've been "designing" (if you can call it that way) the alphabet so that later we can send a whole text.

* So far you can only play with setting the brightness `Set-Brightness` (Low, Medium or High)

* Turn the leds off with `Set-LedsOff`

* Write some letters (a string) with `Write-String`. The number of letters actually depend, but it's usually 3 because each letter is using 3 rows. "M" for example uses 5.

After setting the whole alphabet and things to be displayed on the ScrollpHat, will work on a way to scroll the text.


Any suggestion/contribution is really welcome!
