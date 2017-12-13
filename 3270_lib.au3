#include-once

#cs
	Libraries for controlling an X3270 or WC3270 instance
	Author : Worlor (https://github.com/Worlor/)
	For issues or pull request : https://github.com/Worlor/AutoIt-3270

	3270 actions docs : http://x3270.bgp.nu/wc3270-man.html#Actions
#ce

Local Const $__e_320 = "3270 Emulator not initialized, use Init3270 function before use"
Local Const $__e_321 = "3270 Emulator not found"
Local Const $__e_322 = "Unable to open 3270 Emulator"
Local Const $__e_323 = "3270 Emulator already open"
Local Const $__e_324 = "3270 Emulator not initialized, call init3270 function before"
Local Const $__e_325 = "3270 Emulator already closed"
Local Const $__e_326 = "Unable to close 3270 Emulator"
Local Const $__e_327 = "Unable to get 3270 Emulator Process ID"
Local Const $__e_328 = "3270 Emulator closed"

Local $__s_Url3270 = "http://localhost:3270/3270/rest/text/"
Local $__s_CheminX3270 = ""
Local $__i_Pid = -1
Local $__b_isInit = False
Local $__s_Title3270 = ""
Local $__i_winMode = @SW_MAXIMIZE

; Init

Func Init3270($sCheminX3270, $sHote3270, $sCharset = "us-intl", $iWinMode = @SW_MAXIMIZE, $bDemandeEtat = False, $iPortApi = 3270)
	If Not (FileExists($sCheminX3270)) Then Return SetError(321, 0, $__e_321)
	$__s_CheminX3270 = $sCheminX3270 & " -httpd " & $iPortApi & " " & $sHote3270 & " -charset " & $sCharset

	If ($iWinMode <> @SW_MAXIMIZE And $iWinMode <> @SW_MINIMIZE And $iWinMode <> @SW_HIDE) Then $iWinMode = @SW_MAXIMIZE
	$__i_winMode = $iWinMode

	$__s_Title3270 = $sHote3270 & " - wc3270"
	If ($iPortApi <> 3270 Or $bDemandeEtat <> False) Then
		Local $sUrlEndpoint = "text/"
		If ($bDemandeEtat) Then $sUrlEndpoint = "stext/"
		$__s_Url3270 = "http://localhost:" & $iPortApi & "/3270/rest/" & $sUrlEndpoint
	EndIf
	$__b_isInit = True
	Local $sRetVal = Open3270()
	If (@error) Then Return SetError(@error, @extended, $sRetVal)
	Return SetError(0, 0, 0)
EndFunc   ;==>Init3270

; Emulator management

Func Open3270()
	If Not (__isInit()) Then Return SetError(324, 0, $__e_324)
	If ($__i_Pid <> -1 Or WinExists($__s_Title3270)) Then Return SetError(323, 0, $__e_323)

	$__i_Pid = Run($__s_CheminX3270, "", $__i_winMode)
	Local $timeout = WinWait($__s_Title3270, "", 10)
	If (@error Or $timeout = 0) Then Return SetError(322, 0, $__e_322)

	Return SetError(0, 0, 0)
EndFunc   ;==>Open3270

Func Close3270()
	If Not (__isInit()) Then Return SetError(324, 0, $__e_324)
	If ($__i_Pid == -1 Or ProcessExists($__i_Pid) == 0) Then ;Checking if an emulator is open
		If (WinExists($__s_Title3270)) Then
			Local $iPid = WinGetProcess($__s_Title3270)
			If (@error Or $iPid == -1) Then Return SetError(327, @extended, $__e_327)
			$__i_Pid = $iPid
		Else
			Return SetError(325, 0, $__e_325)
		EndIf
	EndIf

	ProcessClose($__i_Pid)
	If (ProcessWaitClose($__i_Pid, 10) == 1) Then
		$__i_Pid = -1
		Return SetError(0, 0, 0)
	EndIf
	If (@error) Then Return SetError(326, @extended, $__e_326)
	Return SetError(@error, @extended, "")
EndFunc   ;==>Close3270

; Actions functions

Func zMoveCursor($iRow, $iCol)
	If (__check3270() <> 0) Then Return SetError(@error, @extended, __check3270())
	Local $sRet = __call3270("MoveCursor(" & $iRow & "," & $iCol & ")")
	If (@error) Then Return SetError(@error, @extended, $sRet)
	Return SetError(0, 0, $sRet)
EndFunc   ;==>zMoveCursor

Func zPutString($sStr)
	If (__check3270() <> 0) Then Return SetError(@error, @extended, __check3270())
	Local $sRet = __call3270("String(""" & __zURIEncode($sStr) & """)")
	If (@error) Then Return SetError(@error, @extended, $sRet)
	Return SetError(0, 0, $sRet)
EndFunc   ;==>zPutString

Func zGetStringPos($iX, $iY, $iLen)
	If (__check3270() <> 0) Then Return SetError(@error, @extended, __check3270())

	Local $sRet = __call3270("ascii(" & $iX & "," & $iY & "," & $iLen & ")")
	If (@error) Then Return SetError(@error, @extended, $sRet)
	Return SetError(0, 0, $sRet)
EndFunc   ;==>zGetStringPos

Func zGetStringBlock($iXstart, $iYstart, $iXend, $iYend)
	If (__check3270() <> 0) Then Return SetError(@error, @extended, __check3270())
	Local $sRet = __call3270("ascii(" & $iXstart & "," & $iYstart & "," & ($iXend - $iXstart) & "," & ($iYend - $iYstart) & ")")
	If (@error) Then Return SetError(@error, @extended, $sRet)
	Return SetError(0, 0, $sRet)
EndFunc   ;==>zGetStringBlock

Func zIsStringInScreenPos($sCheck, $iX, $iY, $iLen)
	If (__check3270() <> 0) Then Return SetError(@error, @extended, __check3270())

	Local $sRet = zGetStringPos($iX, $iY, $iLen)
	If (StringInStr($sRet, $sCheck) <> 0) Then
		Return SetError(0, 0, True)
	EndIf
	Return SetError(0, 0, False)
EndFunc   ;==>zIsStringInScreenPos

Func zGetScreen()
	If (__check3270() <> 0) Then Return SetError(@error, @extended, __check3270())

	$sRet = __call3270('ascii')
	If (@error) Then Return SetError(@error, @extended, $sRet)

	Return $sRet
EndFunc   ;==>zGetScreen

Func zIsStringInScreen($sCheck)
	If (__check3270() <> 0) Then Return SetError(@error, @extended, __check3270())

	$sRet = __call3270('ascii')
	If (@error) Then Return SetError(@error, @extended, $sRet)

	If (StringInStr($sRet, $sCheck) <> 0) Then
		Return SetError(0, 0, True)
	EndIf
	Return SetError(0, 0, False)
EndFunc   ;==>zIsStringInScreen

Func zEnter()
	If (__check3270() <> 0) Then Return SetError(@error, @extended, __check3270())
	Local $vRetour = __call3270("Enter()")
	If (@error) Then Return SetError(@error, @extended, $vRetour)
	Return SetError(0, 0, $vRetour)
EndFunc   ;==>zEnter

Func zTab()
	If (__check3270() <> 0) Then Return SetError(@error, @extended, __check3270())
	Local $vRetour = __call3270("String(%5Ct)")
	If (@error) Then Return SetError(@error, @extended, $vRetour)
	Return SetError(0, 0, $vRetour)
EndFunc   ;==>zTab

Func zPF($iF)
	If (__check3270() <> 0) Then Return SetError(@error, @extended, __check3270())
	Local $vRetour = __call3270("Pf(" & $iF & ")")
	If (@error) Then Return SetError(@error, @extended, $vRetour)
	Return SetError(0, 0, $vRetour)
EndFunc   ;==>zPF

Func zClear()
	If (__check3270() <> 0) Then Return SetError(@error, @extended, __check3270())
	Local $vRetour = __call3270("String(%5Cf)")
	If (@error) Then Return SetError(@error, @extended, $vRetour)
	Return SetError(0, 0, $vRetour)
EndFunc   ;==>zClear

Func zNewLine() ;Move cursor to the first field on next line
	If (__check3270() <> 0) Then Return SetError(@error, @extended, __check3270())
	Local $vRetour = __call3270("NewLine()")
	If (@error) Then Return SetError(@error, @extended, $vRetour)
	Return SetError(0, 0, $vRetour)
EndFunc   ;==>zNewLine

Func zDeleteField() ;Delete the entire field
	If (__check3270() <> 0) Then Return SetError(@error, @extended, __check3270())
	Local $vRetour = __call3270("DeleteField()")
	If (@error) Then Return SetError(@error, @extended, $vRetour)
	Return SetError(0, 0, $vRetour)
EndFunc   ;==>zDeleteField

Func zGetCursorPosition() ; Return the cursor position with an array ; index 0 = X ; index 1 = Y
	If (__check3270() <> 0) Then Return SetError(@error, @extended, __check3270())
	Local $vRetour = __call3270("Query()")
	If (@error) Then Return SetError(@error, @extended, $vRetour)
	$vRetour = StringRegExp($vRetour, ".*Cursor:\s+(\d+)\s+(\d+)", 1)
	If (@error) Then Return SetError(@error, @extended, $vRetour)
	Return SetError(0, 0, $vRetour)
EndFunc   ;==>zGetCursorPosition

Func zHome() ;Return the cursor to the main field
	If (__check3270() <> 0) Then Return SetError(@error, @extended, __check3270())
	Local $vRetour = __call3270("Home()")
	If (@error) Then Return SetError(@error, @extended, $vRetour)
	Return SetError(0, 0, $vRetour)
EndFunc   ;==>zHome

Func zPrint($sPrinterName) ;Print screen text on printer
	If (__check3270() <> 0) Then Return SetError(@error, @extended, __check3270())
	If ($sPrinterName) Then $sPrinterName = "," & $sPrinterName
	Local $vRetour = __call3270("PrintText(wordpad, nodialog" & $sPrinterName & ")")
	If (@error) Then Return SetError(@error, @extended, $vRetour)
	Return SetError(0, 0, $vRetour)
EndFunc   ;==>zPrint

; Local functions

Func __call3270($sCommande)
	Local $vRetour = __HttpGet($__s_Url3270 & $sCommande)
	;sleep(750)
	If (@error) Then Return SetError(@error, @extended, $vRetour)
	Return SetError(0, 0, $vRetour)
EndFunc   ;==>__call3270

Func __isInit()
	Return $__b_isInit
EndFunc   ;==>__isInit

Func __isOpen()
	If ($__i_Pid == -1 Or ProcessExists($__i_Pid) == 0) Then Return False
	Return True
EndFunc   ;==>__isOpen

Func __check3270()
	If Not (__isInit()) Then Return SetError(324, 0, $__e_324)
	If Not (__isOpen()) Then Return SetError(328, 0, $__e_328)
	Return SetError(0, 0, 0)
EndFunc   ;==>__check3270

Func __HttpGet($sURL, $sData = "")
	If($sData <> "") Then
		$sData = "?" & $sData
	EndIf
	Local $oHTTP = ObjCreate("Microsoft.XMLHTTP")
	Local $sRequest = $sURL & $sData
	$oHTTP.Open("GET", $sRequest, False)
	If (@error) Then Return SetError(1, 0, "Error with request : " & $sRequest)

	$oHTTP.withCredentials = True
	$oHTTP.send()

	If($oHTTP.status <> 200) Then Return SetError(3, $oHTTP.status, _
		"Error with request : " & $sRequest & " - HTTP Code : " & $oHttp.status & " " & _
		$oHttp.statusText & @CRLF )
	ConsoleWrite($oHTTP.status)

	If (@error) Then Return SetError(2, 0, "Error with request : " & $sRequest)

	Return SetError(0, 0, $oHTTP.responseText)
EndFunc   ;==>__HttpGet

Func __zURIEncode($sData)
    Local $aData = StringSplit(BinaryToString(StringToBinary($sData,4),1),"")
    Local $nChar
    $sData=""
    For $i = 1 To $aData[0]
        $nChar = Asc($aData[$i])
        Switch $nChar
            Case 45, 46, 48 To 57, 65 To 90, 95, 97 To 122, 126
                $sData &= $aData[$i]
            Case Else
                $sData &= "%" & Hex($nChar,2)
        EndSwitch
    Next
    Return $sData
EndFunc