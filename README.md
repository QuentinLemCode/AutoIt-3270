# AutoIt 3270 Library

## Usage 

* Download X3270 [here](http://x3270.bgp.nu/)
* Import the file in your script

```` autoit
#include "3270_lib.au3"
````

* Call function Init3270()
* Call function Open3270()

... and do your stuff !


## Functions

```` autoit
Init3270($sCheminX3270, $sHote3270, $sCharset = "us-intl", $iWinMode = @SW_MAXIMIZE, $bDemandeEtat = False, $iPortApi = 3270)
````

Initialize the lib, parameters :

* Full path the X3270 executable
* 3270 host
* Charset to use (see X3270 doc)
* Window mode
* Get or not some information from emulator when calling a function
* Port for communicating with the emulator (change if already used on your computer)

```` autoit
Open3270()
````

Open the Emulator

```` autoit
Close3270()
````

Close emulator

```` autoit
zMoveCursor($iRow, $iCol)
````

Move cursor

```` autoit
zPutString($sStr)
````

Set string under cursor

```` autoit
zGetStringPos($iX, $iY, $iLen)
````

Get the string at position X and Y with length Len

```` autoit
zGetStringBlock($iXstart, $iYstart, $iXend, $iYend)
````

Get all the character in the block

```` autoit
zGetScreen()
````

Get the entire screen

```` autoit
zIsStringInScreenPos($sCheck, $iX, $iY, $iLen)
````

Return true if the string Check is present in the string of length Len at position X and Y

```` autoit
zIsStringInScreen($sCheck)
````

Return true if the string Check is present in the screen

```` autoit
zEnter()
````

Press Enter

```` autoit
zTab()
````

Press Tab

```` autoit
zPf($iF)
````

Press F button with the number passed in parameter

Example : zPf(4) -> Press F4 key

```` autoit
zClear()
````

Call clear

```` autoit
zNewLine()
````

Move cursor to the first field on next line

```` autoit
zDeleteField()
````

Delete the entire field

```` autoit
zGetCursorPosition()
````

Return the cursor position with an array ; index 0 = X ; index 1 = Y

```` autoit
zHome()
````

Return the cursor to the main field

```` autoit
zPrint($sPrinterName)
````

Print screen text on printer

## Errors

Every function will set the @error to <> 0 if there are an error.

```` autoit
$__e_320 = "3270 Emulator not initialized, use Init3270 function before use"
$__e_321 = "3270 Emulator not found"
$__e_322 = "Unable to open 3270 Emulator"
$__e_323 = "3270 Emulator already open"
$__e_324 = "3270 Emulator not initialized, call init3270 function before"
$__e_325 = "3270 Emulator already closed"
$__e_326 = "Unable to close 3270 Emulator"
$__e_327 = "Unable to get 3270 Emulator Process ID"
$__e_328 = "3270 Emulator closed"
````