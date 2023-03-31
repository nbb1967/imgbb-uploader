#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icons\ibb.ico
#AutoIt3Wrapper_Res_Comment=Created by AutoIt v3.3.16.1
#AutoIt3Wrapper_Res_Description=ImgBB Uploader
#AutoIt3Wrapper_Res_Fileversion=0.9.9.3
#AutoIt3Wrapper_Res_ProductName=ImgBB Uploader
#AutoIt3Wrapper_Res_ProductVersion=0.9.9.3
#AutoIt3Wrapper_Res_CompanyName=NyBumBum
#AutoIt3Wrapper_Res_LegalCopyright=Copyright NyBumBum © 2023. All right reserved.
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_File_Add=localization\en_strings.ini, 6
#AutoIt3Wrapper_Res_File_Add=localization\ru_strings.ini, 6
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPI.au3>
#include <Array.au3>
#include <StringConstants.au3> ; To declare the Constants of StringRegExp
#include <ProgressConstants.au3>


;optimisation of the tray icon (needed for notifications)
Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 1)
TraySetToolTip("ImgBB Uploader")


#Region ;****Localization****
Func GetStringFromResources($iStringID) ;function to extract strings from a String Table
	Local $hInstance = _WinAPI_GetModuleHandle(0)
	If $hInstance = 0 Then
		MsgBox($MB_ICONERROR, "Error", "Failed to get program handle.")
		Exit
	EndIf
	Local $iString = _WinAPI_LoadString($hInstance, $iStringID)
	If @error Then
		MsgBox($MB_ICONERROR, "Error", "Failed to get string from program resources.")
		Exit
	EndIf
	Return $iString
EndFunc   ;==>GetStringFromResources

Global $aiArrayExpiration[24][2] = [[6000, 0], [6001, 300], [6002, 900], [6003, 1800], [6004, 3600], [6005, 10800], [6006, 21600], [6007, 43200], [6008, 86400], [6009, 172800], [6010, 259200], [6011, 345600], [6012, 432000], [6013, 518400], [6014, 604800], [6015, 1209600], [6016, 1814400], [6017, 2419200], [6018, 2592000], [6019, 5184000], [6020, 7776000], [6021, 10368000], [6022, 12960000], [6023, 15552000]]
Global Enum $eFormSettings, $eGroup_APIkey, $eLabel_APIkey1, $eLabel_APIkey2, $eButton_GetAPIkey, $eGroup_Expiration, $eGroup_PostAction, $eCheckbox_Browser, $eCheckbox_Clipboard, $eCheckbox_Notification, $eButton_Cancel, $eButton_Save, $eButton_About
Global $anArrayStringsSettingsDlg[13] = [6048, 6049, 6050, 6051, 6052, 6053, 6054, 6055, 6056, 6057, 6058, 6059, 6060]
Global Enum $eFormAbout, $eLabel_Name, $eLabel_NameText, $eLabel_Version, $eLabel_VersionText, $eLabel_Copiright, $eLabel_CopirightText, $eLabel_Site, $eLabel_SiteText, $eLabel_Support, $eLabel_SupportText, $eLabel_Comment, $eLabel_CommentText
Global $anArrayStringsAboutDlg[13] = [6080, 6081, 6082, 6083, 6084, 6085, 6086, 6087, 6088, 6089, 6090, 6091, 6092]
Global Enum $eAPIkeyCorrectnessError, $eAPIkeyCorrectnessErrorText, $eAPIkeyEmptyError, $eAPIkeyEmptyErrorText, $eCurlError, $eError, $eClientError, $eServerError, $eUnknownErrorText, $eLinkExtractError, $eLinkExtractErrorViewerLink, $eSuccessNotification, $eMediumLinkSizeError, $eMediumLinkSizeErrorTextPart1, $eMediumLinkSizeErrorTextPart2, $eMediumLinkSizeErrorTextPart3, $eMediumLinkSizeErrorTextPart4, $eLinkExtractErrorDirectLink, $eLinkExtractErrorMediumLink, $eLinkExtractErrorThumbLink, $eOpenLinkErrorText, $ePutToClipboardErrorText
Global $anArrayMsg[22] = [6112, 6113, 6114, 6115, 6116, 6117, 6118, 6119, 6120, 6121, 6122, 6123, 6124, 6125, 6126, 6127, 6128, 6129, 6130, 6131, 6132, 6133]
Global Enum $eUpload, $eToImgBB, $eUploadCompletedStart, $eUploadCompleted
Global $asArrayFormProgress[4] = [6144, 6145, 6146, 6147]
Global Enum $eWindowsContextMenu
Global $asArrayWindowsContextMenu[1] = [6256]
Global $asArrayBrowserOptions[2] = [6160, 6161]
Global $asArrayClipboardOptions[11] = [6160, 6161, 6162, 6163, 6164, 6165, 6166, 6167, 6168, 6169, 6170]
#EndRegion ;****Localization****

Global $sAPIkey
Global $nExpiration, $nBrowser, $nBrowserOptions, $nClipboard, $nClipboardOptions, $nNotification
Global $iAPIkeyLength, $iAPIkeyCorrectness
Global Const $sRegexAPIkey = "[0-9a-f]{32}"
Global $sArchitecture



If $CmdLine[0] = 0 Then ;if there are no arguments (direct EXE run)
	GetDataFromRegistry()
	ImgBBUploaderGUI()
	Exit
EndIf
Local $sWindowsPathToImageFile = $CmdLine[1] ;get the path from the argument
Local $sUnixPathToImageFile = StringReplace($sWindowsPathToImageFile, "\", "/")

;FileName
Local Const $sRegexImageFileName = '(?:\\)([^\\]+)$'
Local $sImageFileName = ""
Local $asImageFileName = StringRegExp($sWindowsPathToImageFile, $sRegexImageFileName, $STR_REGEXPARRAYMATCH)
If @error = 0 Then
	$sImageFileName = $asImageFileName[0]
EndIf

GetDataFromRegistry()

;GUI if needed
$iAPIkeyLength = StringLen($sAPIkey)
$iAPIkeyCorrectness = StringRegExp($sAPIkey, $sRegexAPIkey)
If $iAPIkeyLength = 0 Or $iAPIkeyCorrectness = 0 Or $nExpiration > UBound($aiArrayExpiration) - 1 Then
	ImgBBUploaderGUI()
EndIf

;Run curl
Local $sCurlCmd = 'curl' & ' ' & '--progress-bar' & ' ' & '--location' & ' ' & '--ssl-no-revoke' & ' ' & '--request' & ' ' & 'POST' & ' ' & '"' & 'https://api.imgbb.com/1/upload?' & 'expiration=' & $aiArrayExpiration[$nExpiration][1] & '&' & 'key=' & $sAPIkey & '"' & ' ' & '--form' & ' ' & '"' & 'image=@' & $sUnixPathToImageFile & '"'
Local $iPID = Run($sCurlCmd, "", "", BitOR($STDERR_CHILD, $STDOUT_CHILD))


#Region ****Progress, Errors of curl****
Local Const $sRegexProgressPercentage = '([0-9]{1,3}[,|.][0-9])(?:%)$'
Local $iProgressPercentageDetect
Local $asProgressPercentage
Local $nProgressPercentage

Local Const $sRegexCurlError = '(?m)^(curl:\s\([0-9]{1,2}\).*)$'
Local $iCurlErrorDetect
Local $asCurlError
Local $sCurlError

#Region ### START Koda GUI section ### FormProgress.kxf
$idFormProgress = GUICreate(GetStringFromResources($asArrayFormProgress[$eUploadCompletedStart]), 442, 91, -1, -1, BitOR($WS_CAPTION, $WS_SYSMENU))
GUISetIcon(@ScriptFullPath, 99)
GUISetFont(9, 400, 0, "Segoe UI")
$idProgress = GUICtrlCreateProgress(18, 57, 406, 16)
$idLabel_Percent = GUICtrlCreateLabel(GetStringFromResources($asArrayFormProgress[$eUploadCompletedStart]), 18, 29, 405, 24)
GUICtrlSetFont(-1, 11, 400, 0, "Segoe UI")
$idLabel_FileName = GUICtrlCreateLabel(GetStringFromResources($asArrayFormProgress[$eUpload]) & " " & $sImageFileName & " " & GetStringFromResources($asArrayFormProgress[$eToImgBB]), 18, 11, 409, 19)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Local $sStdErr = ""
While 1
	$sStdErr = StderrRead($iPID)
	If @error Then
		ExitLoop
	EndIf
	$nMsg = GUIGetMsg()
	If $nMsg = $GUI_EVENT_CLOSE Then
		Exit
	EndIf
	$iCurlErrorDetect = StringRegExp($sStdErr, $sRegexCurlError)
	If $iCurlErrorDetect = 1 Then
		$asCurlError = StringRegExp($sStdErr, $sRegexCurlError, $STR_REGEXPARRAYMATCH)
		$sCurlError = $asCurlError[0]
		MsgBox($MB_ICONERROR, GetStringFromResources($anArrayMsg[$eCurlError]), $sCurlError)
		Exit
	EndIf
	$iProgressPercentageDetect = StringRegExp($sStdErr, $sRegexProgressPercentage)
	If $iProgressPercentageDetect = 1 Then
		$asProgressPercentage = StringRegExp($sStdErr, $sRegexProgressPercentage, $STR_REGEXPARRAYMATCH)
		$nProgressPercentage = StringReplace($asProgressPercentage[0], ",", ".")
		GUICtrlSetData($idProgress, $nProgressPercentage)
		GUICtrlSetData($idLabel_Percent, GetStringFromResources($asArrayFormProgress[$eUploadCompleted]) & " " & $nProgressPercentage & "%")
		WinSetTitle($idFormProgress, "", GetStringFromResources($asArrayFormProgress[$eUploadCompleted]) & " " & $nProgressPercentage & "%")
	EndIf
	Sleep(20)            ; delay?
WEnd

GUIDelete()
#EndRegion ****Progress, Errors of curl****


Local $sStdOut = ""
While 1
	$sStdOut &= StdoutRead($iPID)
	If @error Then
		ExitLoop
	EndIf
	Sleep(20)            ; delay?
WEnd


#Region ;****Parsing Server Error****
Local Const $sRegexSuccess = '"success":true'
Local Const $sRegexStatusCodeHTTP = '(?:"status_code":)([0-9]{3})'
Local Const $sRegexStatusTextHTTP = '(?:"status_txt":")([^"]+)'
Local Const $sRegexServerMessage = '(?:"message":")([^"]+)'

Local $iSuccessDetect = StringRegExp($sStdOut, $sRegexSuccess)
If Not $iSuccessDetect Then
	Local $nStatusCodeHTTP = 0
	Local $iStatusCodeHTTPDetect = StringRegExp($sStdOut, $sRegexStatusCodeHTTP)
	If $iStatusCodeHTTPDetect = 1 Then
		Local $asStatusCodeHTTP = StringRegExp($sStdOut, $sRegexStatusCodeHTTP, $STR_REGEXPARRAYMATCH)
		$nStatusCodeHTTP = $asStatusCodeHTTP[0]
	EndIf
	Local $sStatusTextHTTP = ""
	Local $iStatusTextHTTPDetect = StringRegExp($sStdOut, $sRegexStatusTextHTTP)
	If $iStatusTextHTTPDetect = 1 Then
		Local $asStatusTextHTTP = StringRegExp($sStdOut, $sRegexStatusTextHTTP, $STR_REGEXPARRAYMATCH)
		$sStatusTextHTTP = $asStatusTextHTTP[0]
	EndIf
	Local $sServerMessage = ""
	Local $iServerMessageDetect = StringRegExp($sStdOut, $sRegexServerMessage)
	If $iServerMessageDetect = 1 Then
		Local $asServerMessage = StringRegExp($sStdOut, $sRegexServerMessage, $STR_REGEXPARRAYMATCH)
		$sServerMessage = $asServerMessage[0]
	EndIf
	If $iStatusCodeHTTPDetect = 0 And $iStatusTextHTTPDetect = 0 And $iServerMessageDetect = 0 Then
		MsgBox($MB_ICONERROR, GetStringFromResources($anArrayMsg[$eError]), GetStringFromResources($anArrayMsg[$eUnknownErrorText]))
		Exit
	Else
		Local $sTitleErrorHTTP = ""
		If $nStatusCodeHTTP >= 400 And $nStatusCodeHTTP < 500 Then
			$sTitleErrorHTTP = GetStringFromResources($anArrayMsg[$eClientError])
		ElseIf $nStatusCodeHTTP >= 500 Then
			$sTitleErrorHTTP = GetStringFromResources($anArrayMsg[$eServerError])
		Else
			$sTitleErrorHTTP = GetStringFromResources($anArrayMsg[$eError])
		EndIf
		MsgBox($MB_ICONERROR, $sTitleErrorHTTP, $nStatusCodeHTTP & ": " & $sStatusTextHTTP & @CRLF & $sServerMessage)
		Exit
	EndIf
EndIf
#EndRegion ;****Parsing Server Error****


#Region	;****Action after upload*****
If $nNotification = 1 Then
	TrayTip($sImageFileName, GetStringFromResources($anArrayMsg[$eSuccessNotification]), 5, 20)
EndIf
If $nBrowser = 1 Then
	Local $nOpenLinkError = ShellExecute(ChoiceLinkForBrowser())
	If $nOpenLinkError = 0 Then
		MsgBox($MB_ICONERROR, GetStringFromResources($anArrayMsg[$eError]), GetStringFromResources($anArrayMsg[$eOpenLinkErrorText]) & " " & GetStringFromResources($asArrayBrowserOptions[$nBrowserOptions]))
	EndIf
EndIf
If $nClipboard = 1 Then
	Local $nPutClipboardError = ClipPut(ChoiseContentForClipboard())
	If $nPutClipboardError = 0 Then
		MsgBox($MB_ICONERROR, GetStringFromResources($anArrayMsg[$eError]), GetStringFromResources($anArrayMsg[$ePutToClipboardErrorText]) & " " & GetStringFromResources($asArrayClipboardOptions[$nClipboardOptions]))
	EndIf
EndIf
If $nNotification = 1 Then
	Sleep(5000)
EndIf
#EndRegion	;****Action after upload*****


Exit


#Region;****Parsing Server Responce****
Func GetViewerLink()
	Local Const $sRegexViewerLink = '(?:"url_viewer":")(https:[^"]+)'
	Local $asViewerLink = StringRegExp($sStdOut, $sRegexViewerLink, $STR_REGEXPARRAYMATCH)
	If @error = 0 Then
		Local $sViewerLink = StringReplace($asViewerLink[0], "\", "")
	Else
		MsgBox($MB_ICONERROR, GetStringFromResources($anArrayMsg[$eLinkExtractError]), GetStringFromResources($anArrayMsg[$eLinkExtractErrorViewerLink]))
		Exit
	EndIf
	Return $sViewerLink
EndFunc   ;==>GetViewerLink


Func GetDirectLink()
	Local Const $sRegexDirectLink = '(?:"image":{[^}]+"url":")(https:[^"]+)'
	Local $asDirectLink = StringRegExp($sStdOut, $sRegexDirectLink, $STR_REGEXPARRAYMATCH)
	If @error = 0 Then
		Local $sDirectLink = StringReplace($asDirectLink[0], "\", "")
	Else
		MsgBox($MB_ICONERROR, GetStringFromResources($anArrayMsg[$eLinkExtractError]), GetStringFromResources($anArrayMsg[$eLinkExtractErrorDirectLink]))
		Exit
	EndIf
	Return $sDirectLink
EndFunc   ;==>GetDirectLink


Func GetMediumLink()
	Local Const $sRegexMediumLink = '(?:"medium":{[^}]+"url":")(https:[^"]+)'
	Local $asMediumLink = StringRegExp($sStdOut, $sRegexMediumLink, $STR_REGEXPARRAYMATCH)
	If @error = 0 Then
		Local $sMediumLink = StringReplace($asMediumLink[0], "\", "")
	Else
		Local Const $sRegexImageWidth = '(?:"width":)([0-9]+)'
		Local $asImageWidth = StringRegExp($sStdOut, $sRegexImageWidth, $STR_REGEXPARRAYMATCH)
		If @error = 0 Then
			Local $nImageWidth = $asImageWidth[0]
			If $nImageWidth <= 640 Then
				MsgBox($MB_ICONWARNING + $MB_TOPMOST, GetStringFromResources($anArrayMsg[$eMediumLinkSizeError]), GetStringFromResources($anArrayMsg[$eMediumLinkSizeErrorTextPart1]) & @CRLF & GetStringFromResources($anArrayMsg[$eMediumLinkSizeErrorTextPart2]) & " " & $nImageWidth & " " & GetStringFromResources($anArrayMsg[$eMediumLinkSizeErrorTextPart3]) & @CRLF & GetStringFromResources($anArrayMsg[$eMediumLinkSizeErrorTextPart4]))
				$sMediumLink = ""
			EndIf
		Else
			MsgBox($MB_ICONERROR, GetStringFromResources($anArrayMsg[$eLinkExtractError]), GetStringFromResources($anArrayMsg[$eLinkExtractErrorMediumLink]))
			Exit
		EndIf
	EndIf
	Return $sMediumLink
EndFunc   ;==>GetMediumLink


Func GetThumbLink()
	Local Const $sRegexThumbLink = '(?:"thumb":{[^}]+"url":")(https:[^}"]+)'
	Local $asThumbLink = StringRegExp($sStdOut, $sRegexThumbLink, $STR_REGEXPARRAYMATCH)
	If @error = 0 Then
		Local $sThumbLink = StringReplace($asThumbLink[0], "\", "")
	Else
		MsgBox($MB_ICONERROR, GetStringFromResources($anArrayMsg[$eLinkExtractError]), GetStringFromResources($anArrayMsg[$eLinkExtractErrorThumbLink]))
		Exit
	EndIf
	Return $sThumbLink
EndFunc   ;==>GetThumbLink


Func GetImageName()
	Local Const $sRegexImageName = '(?:"name":")([^"]+)'
	Local $sImageName = ""
	$asImageName = StringRegExp($sStdOut, $sRegexImageName, $STR_REGEXPARRAYMATCH)
	If @error = 0 Then
		Local $sImageName = $asImageName[0]
	EndIf
	Return $sImageName
EndFunc   ;==>GetImageName
#EndRegion;****Parsing Server Responce****


Func ChoiceLinkForBrowser()
	GetBrowserOptionsFromRegistry()
	Local $sLinkForBrowser
	Switch $nBrowserOptions
		Case 0
			$sLinkForBrowser = GetViewerLink()
		Case 1
			$sLinkForBrowser = GetDirectLink()
	EndSwitch
	Return $sLinkForBrowser
EndFunc   ;==>ChoiceLinkForBrowser


Func ChoiseContentForClipboard()
	GetClipboardOptionsFromRegistry()
	Local $sContentForClipboard
	Local $sMediumLink
	Switch $nClipboardOptions
		Case 0
			$sContentForClipboard = GetViewerLink()
		Case 1
			$sContentForClipboard = GetDirectLink()
		Case 2
			$sContentForClipboard = '<img src="' & GetDirectLink() & '" alt="' & GetImageName() & '" border="0">'
		Case 3
			$sContentForClipboard = '<a href="' & GetViewerLink() & '"><img src="' & GetDirectLink() & '" alt="' & GetImageName() & '" border="0"></a>'
		Case 4
			$sMediumLink = GetMediumLink()
			If $sMediumLink = "" Then
				$sContentForClipboard = GetViewerLink()
			Else
				$sContentForClipboard = '<a href="' & GetViewerLink() & '"><img src="' & $sMediumLink & '" alt="' & GetImageName() & '" border="0"></a>'
			EndIf
		Case 5
			$sContentForClipboard = '<a href="' & GetViewerLink() & '"><img src="' & GetThumbLink() & '" alt="' & GetImageName() & '" border="0"></a>'
		Case 6
			$sContentForClipboard = '[img]' & GetDirectLink() & '[/img]'
		Case 7
			$sContentForClipboard = '[url=' & GetViewerLink() & '][img]' & GetDirectLink() & '[/img][/url]'
		Case 8
			$sMediumLink = GetMediumLink()
			If $sMediumLink = "" Then
				$sContentForClipboard = GetViewerLink()
			Else
				$sContentForClipboard = '[url=' & GetViewerLink() & '][img]' & GetMediumLink() & '[/img][/url]'
			EndIf
		Case 9
			$sContentForClipboard = '[url=' & GetViewerLink() & '][img]' & GetThumbLink() & '[/img][/url]'
		Case 10
			$sContentForClipboard = '![' & GetImageName() & '](' & GetDirectLink() & ' "")'
	EndSwitch
	Return $sContentForClipboard
EndFunc   ;==>ChoiseContentForClipboard

#Region ;****Get Registry****
Func GetBrowserOptionsFromRegistry()
	$sArchitecture = @OSArch
	If $sArchitecture = "X64" Then
		$nBrowserOptions = RegRead("HKCU64\Software\NyBumBum\ImgBB Uploader\1", "OptionsBrowser")
	ElseIf $sArchitecture = "X86" Then
		$nBrowserOptions = RegRead("HKCU\Software\NyBumBum\ImgBB Uploader\1", "OptionsBrowser")
	Else
		MsgBox($MB_ICONINFORMATION, "IA64", "Itanium is not supported")
		Exit
	EndIf
EndFunc   ;==>GetBrowserOptionsFromRegistry


Func GetClipboardOptionsFromRegistry()
	$sArchitecture = @OSArch
	If $sArchitecture = "X64" Then
		$nClipboardOptions = RegRead("HKCU64\Software\NyBumBum\ImgBB Uploader\1", "OptionsClipboard")
	ElseIf $sArchitecture = "X86" Then
		$nClipboardOptions = RegRead("HKCU\Software\NyBumBum\ImgBB Uploader\1", "OptionsClipboard")
	Else
		MsgBox($MB_ICONINFORMATION, "IA64", "Itanium is not supported")
		Exit
	EndIf
EndFunc   ;==>GetClipboardOptionsFromRegistry


Func GetDataFromRegistry()
	$sArchitecture = @OSArch
	If $sArchitecture = "X64" Then
		$sAPIkey = RegRead("HKCU64\Software\NyBumBum\ImgBB Uploader\1", "APIkey")
		$nExpiration = RegRead("HKCU64\Software\NyBumBum\ImgBB Uploader\1", "Expiration")
		$nBrowser = RegRead("HKCU64\Software\NyBumBum\ImgBB Uploader\1", "ActionBrowser")
		$nClipboard = RegRead("HKCU64\Software\NyBumBum\ImgBB Uploader\1", "ActionClipboard")
		$nNotification = RegRead("HKCU64\Software\NyBumBum\ImgBB Uploader\1", "ActionNotification")
	ElseIf $sArchitecture = "X86" Then
		$sAPIkey = RegRead("HKCU\Software\NyBumBum\ImgBB Uploader\1", "APIkey")
		$nExpiration = RegRead("HKCU\Software\NyBumBum\ImgBB Uploader\1", "Expiration")
		$nBrowser = RegRead("HKCU\Software\NyBumBum\ImgBB Uploader\1", "ActionBrowser")
		$nClipboard = RegRead("HKCU\Software\NyBumBum\ImgBB Uploader\1", "ActionClipboard")
		$nNotification = RegRead("HKCU\Software\NyBumBum\ImgBB Uploader\1", "ActionNotification")
	Else
		MsgBox($MB_ICONINFORMATION, "IA64", "Itanium is not supported")
		Exit
	EndIf
EndFunc   ;==>GetDataFromRegistry
#EndRegion ;****Get Registry****


Func ComboboxExpirationFullList()
	Local $sList = ""
	Local $nMaxEntry = UBound($aiArrayExpiration) - 1
	For $i = 0 To $nMaxEntry
		$sList &= GetStringFromResources($aiArrayExpiration[$i][0]) & '|'
	Next
	$sList = StringTrimRight($sList, 1)
	Return $sList
EndFunc   ;==>ComboboxExpirationFullList

Func ComboboxBrowserOptionsFullList()
	Local $sList = ""
	Local $nMaxEntry = UBound($asArrayBrowserOptions) - 1
	For $i = 0 To $nMaxEntry
		$sList &= GetStringFromResources($asArrayBrowserOptions[$i]) & '|'
	Next
	$sList = StringTrimRight($sList, 1)
	Return $sList
EndFunc   ;==>ComboboxBrowserOptionsFullList

Func ComboboxClipboardOptionsFullList()
	Local $sList = ""
	Local $nMaxEntry = UBound($asArrayClipboardOptions) - 1
	For $i = 0 To $nMaxEntry
		$sList &= GetStringFromResources($asArrayClipboardOptions[$i]) & '|'
	Next
	$sList = StringTrimRight($sList, 1)
	Return $sList
EndFunc   ;==>ComboboxClipboardOptionsFullList


Func ImgBBUploaderGUI()
	#Region ### START Koda GUI section ### FormSettings
	$idFormSettings = GUICreate(GetStringFromResources($anArrayStringsSettingsDlg[$eFormSettings]), 389, 513, -1, -1)
	GUISetIcon(@ScriptFullPath, 99)
	GUISetFont(9, 400, 0, "Segoe UI")
	$idLabel_GroupAPIkey = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsSettingsDlg[$eGroup_APIkey]), 27, 18, 324, 21)
	GUICtrlSetFont(-1, 11, 400, 0, "Segoe UI")
	$idLabel_APIkey1 = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsSettingsDlg[$eLabel_APIkey1]), 36, 45, 316, 45)
	$idInput_APIkey = GUICtrlCreateInput("", 36, 140, 316, 23, BitOR($GUI_SS_DEFAULT_INPUT, $ES_RIGHT))                           ; outdated context menu...
	GUICtrlSetLimit(-1, 32)
	$iAPIkeyLength = StringLen($sAPIkey)
	If Not $iAPIkeyLength = 0 Then
		GUICtrlSetData(-1, $sAPIkey)
	EndIf
	$idButton_GetAPIkey = GUICtrlCreateButton(GetStringFromResources($anArrayStringsSettingsDlg[$eButton_GetAPIkey]), 190, 99, 162, 25)
	$idLabel_APIkey2 = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsSettingsDlg[$eLabel_APIkey2]), 36, 121, 59, 19)
	$idLabel_Hr1 = GUICtrlCreateLabel("", 36, 180, 317, 2, $SS_SUNKEN)
	$idLabel_GroupExpiration = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsSettingsDlg[$eGroup_Expiration]), 27, 194, 333, 21)
	GUICtrlSetFont(-1, 11, 400, 0, "Segoe UI")
	$idCombo_Expiration = GUICtrlCreateCombo("", 190, 225, 162, 25, $CBS_DROPDOWNLIST)
	If $nExpiration > UBound($aiArrayExpiration) - 1 Then
		$nExpiration = 0        ;default
	EndIf
	GUICtrlSetData(-1, ComboboxExpirationFullList(), GetStringFromResources($aiArrayExpiration[$nExpiration][0]))
	$idLabel_Hr2 = GUICtrlCreateLabel("", 36, 270, 317, 2, $SS_SUNKEN)
	$idLabel_GroupPostAction = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsSettingsDlg[$eGroup_PostAction]), 27, 284, 331, 21)
	GUICtrlSetFont(-1, 11, 400, 0, "Segoe UI")
	$idCheckbox_Browser = GUICtrlCreateCheckbox(GetStringFromResources($anArrayStringsSettingsDlg[$eCheckbox_Browser]), 36, 319, 91, 19)
	If $nBrowser <> 4 Or $nBrowser = "" Then
		GUICtrlSetState(-1, $GUI_CHECKED)    ;default
	EndIf
	$idCombo_Browser = GUICtrlCreateCombo("", 190, 315, 162, 25, $CBS_DROPDOWNLIST)
	GetBrowserOptionsFromRegistry()
	If $nBrowserOptions > UBound($asArrayBrowserOptions) - 1 Then
		$nBrowserOptions = 0    ;default
	EndIf
	GUICtrlSetData(-1, ComboboxBrowserOptionsFullList(), GetStringFromResources($asArrayBrowserOptions[$nBrowserOptions]))
	If $nBrowser = 4 Then
		GUICtrlSetState(-1, $GUI_DISABLE)
	EndIf
	$idCheckbox_Clipboard = GUICtrlCreateCheckbox(GetStringFromResources($anArrayStringsSettingsDlg[$eCheckbox_Clipboard]), 36, 353, 307, 19)
	If $nClipboard <> 4 Or $nClipboard = "" Then
		GUICtrlSetState(-1, $GUI_CHECKED)    ;default
	EndIf
	$idCombo_Clipboard = GUICtrlCreateCombo("", 36, 378, 316, 25, $CBS_DROPDOWNLIST)
	GetClipboardOptionsFromRegistry()
	If $nClipboardOptions > UBound($asArrayClipboardOptions) - 1 Then
		$nClipboardOptions = 1    ;default
	EndIf
	GUICtrlSetData(-1, ComboboxClipboardOptionsFullList(), GetStringFromResources($asArrayClipboardOptions[$nClipboardOptions]))
	If $nClipboard = 4 Then
		GUICtrlSetState(-1, $GUI_DISABLE)
	EndIf
	$idCheckbox_Notification = GUICtrlCreateCheckbox(GetStringFromResources($anArrayStringsSettingsDlg[$eCheckbox_Notification]), 36, 414, 307, 19)
	If $nNotification = 1 Then
		GUICtrlSetState(-1, $GUI_CHECKED)
	EndIf
	$idLabel_Hr3 = GUICtrlCreateLabel("", 0, 450, 390, 2, $SS_SUNKEN)
	$idButton_Cancel = GUICtrlCreateButton(GetStringFromResources($anArrayStringsSettingsDlg[$eButton_Cancel]), 252, 468, 100, 28)
	$idButton_Save = GUICtrlCreateButton(GetStringFromResources($anArrayStringsSettingsDlg[$eButton_Save]), 144, 468, 100, 28)
	GUICtrlSetState(-1, $GUI_DEFBUTTON)
	If $iAPIkeyLength = 0 Then
		GUICtrlSetState($idInput_APIkey, $GUI_FOCUS)
	Else
		GUICtrlSetState($idButton_Save, $GUI_FOCUS) ;to deselect a APIkey
	EndIf
	$idButton_About = GUICtrlCreateButton(GetStringFromResources($anArrayStringsSettingsDlg[$eButton_About]), 36, 468, 100, 28)
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###

	#Region ### START Koda GUI section ### FormAbout
	$idFormAbout = GUICreate(GetStringFromResources($anArrayStringsAboutDlg[$eFormAbout]), 478, 173, -1, -1, BitOR($WS_CAPTION, $WS_SYSMENU), -1, $idFormSettings)
	GUISetIcon(@ScriptFullPath, 99)
	GUISetFont(9, 400, 0, "Segoe UI")
	$idIcon_iBBLogo = GUICtrlCreateIcon(@ScriptFullPath, 99, 36, 36, 64, 64)
	GUICtrlSetCursor(-1, 0)
	$idLabel_Name = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsAboutDlg[$eLabel_Name]), 108, 33, 118, 16, $SS_RIGHT)
	$idLabel_Version = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsAboutDlg[$eLabel_Version]), 108, 51, 118, 16, $SS_RIGHT)
	$idLabel_Copiright = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsAboutDlg[$eLabel_Copiright]), 108, 69, 118, 16, $SS_RIGHT)
	$idLabel_Site = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsAboutDlg[$eLabel_Site]), 108, 87, 118, 16, $SS_RIGHT)
	$idLabel_Support = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsAboutDlg[$eLabel_Support]), 108, 105, 118, 16, $SS_RIGHT)
	$idLabel_Comment = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsAboutDlg[$eLabel_Comment]), 108, 123, 118, 16, $SS_RIGHT)
	$idLabel_NameText = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsAboutDlg[$eLabel_NameText]), 234, 33, 209, 16)
	$idLabel_VersionText = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsAboutDlg[$eLabel_VersionText]), 234, 51, 209, 16)
	$idLabel_CopirightText = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsAboutDlg[$eLabel_CopirightText]), 234, 69, 209, 16)
	$idLabel_SiteText = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsAboutDlg[$eLabel_SiteText]), 234, 87, 208, 19)
	GUICtrlSetColor(-1, 0x0B6992)
	GUICtrlSetCursor(-1, 0)
	$idLabel_SupportText = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsAboutDlg[$eLabel_SupportText]), 234, 105, 207, 19)
	GUICtrlSetColor(-1, 0x0B6992)
	GUICtrlSetCursor(-1, 0)
	$idLabel_CommentText = GUICtrlCreateLabel(GetStringFromResources($anArrayStringsAboutDlg[$eLabel_CommentText]), 234, 123, 209, 16)
	#EndRegion ### END Koda GUI section ###

	Local $iMemoryCheckbox_Browser
	Local $iMemoryCheckbox_Clipboard

	While 1
		$aMsg = GUIGetMsg(1)
		$nBrowser = GUICtrlRead($idCheckbox_Browser)
		$nClipboard = GUICtrlRead($idCheckbox_Clipboard)
		Select
			Case $nBrowser = 1 And $nBrowser <> $iMemoryCheckbox_Browser
				GUICtrlSetState($idCombo_Browser, $GUI_ENABLE)
			Case $nBrowser = 4 And $nBrowser <> $iMemoryCheckbox_Browser
				GUICtrlSetState($idCombo_Browser, $GUI_DISABLE)
			Case $nClipboard = 1 And $nClipboard <> $iMemoryCheckbox_Clipboard
				GUICtrlSetState($idCombo_Clipboard, $GUI_ENABLE)
			Case $nClipboard = 4 And $nClipboard <> $iMemoryCheckbox_Clipboard
				GUICtrlSetState($idCombo_Clipboard, $GUI_DISABLE)
			Case $aMsg[0] = $idButton_Cancel
				Exit
			Case $aMsg[0] = $GUI_EVENT_CLOSE And $aMsg[1] = $idFormSettings
				Exit
			Case $aMsg[0] = $idButton_GetAPIkey
				ShellExecute("https://api.imgbb.com/")
			Case $aMsg[0] = $idButton_About
				GUISetState(@SW_SHOW, $idFormAbout)
				GUISetState(@SW_DISABLE, $idFormSettings)
			Case $aMsg[0] = $GUI_EVENT_CLOSE And $aMsg[1] = $idFormAbout
				GUISetState(@SW_HIDE, $idFormAbout)
				GUISetState(@SW_ENABLE, $idFormSettings)
				WinActivate($idFormSettings)
				GUICtrlSetState($idButton_Save, $GUI_FOCUS)
			Case $aMsg[0] = $idLabel_SupportText
				ShellExecute("mailto:nybumbum@gmail.com?subject=ImgBB%20Uploader")
			Case $aMsg[0] = $idLabel_SiteText
				ShellExecute("https://github.com/nbb1967/imgbb-uploader")
			Case $aMsg[0] = $idIcon_iBBLogo
				ShellExecute("https://imgbb.com/")
			Case $aMsg[0] = $idButton_Save
				$sAPIkey = GUICtrlRead($idInput_APIkey)
				$iAPIkeyLength = StringLen($sAPIkey)
				$iAPIkeyCorrectness = StringRegExp($sAPIkey, $sRegexAPIkey)
				Select
					Case $iAPIkeyLength = 0
						MsgBox($MB_ICONERROR, GetStringFromResources($anArrayMsg[$eAPIkeyEmptyError]), GetStringFromResources($anArrayMsg[$eAPIkeyEmptyErrorText]))
						ContinueLoop
					Case $iAPIkeyCorrectness = 0
						MsgBox($MB_ICONERROR, GetStringFromResources($anArrayMsg[$eAPIkeyCorrectnessError]), GetStringFromResources($anArrayMsg[$eAPIkeyCorrectnessErrorText]))
						ContinueLoop
				EndSelect
				$nExpiration = GUICtrlSendMsg($idCombo_Expiration, $CB_GETCURSEL, 0, 0)
				$nBrowser = GUICtrlRead($idCheckbox_Browser)
				If $nBrowser = 1 Then
					$nBrowserOptions = GUICtrlSendMsg($idCombo_Browser, $CB_GETCURSEL, 0, 0)
					Switch $sArchitecture
						Case "X64"
							RegWrite("HKCU64\Software\NyBumBum\ImgBB Uploader\1", "OptionsBrowser", "REG_DWORD", $nBrowserOptions)
						Case "X86"
							RegWrite("HKCU\Software\NyBumBum\ImgBB Uploader\1", "OptionsBrowser", "REG_DWORD", $nBrowserOptions)
					EndSwitch
				EndIf
				$nClipboard = GUICtrlRead($idCheckbox_Clipboard)
				If $nClipboard = 1 Then
					$nClipboardOptions = GUICtrlSendMsg($idCombo_Clipboard, $CB_GETCURSEL, 0, 0)
					Switch $sArchitecture
						Case "X64"
							RegWrite("HKCU64\Software\NyBumBum\ImgBB Uploader\1", "OptionsClipboard", "REG_DWORD", $nClipboardOptions)
						Case "X86"
							RegWrite("HKCU\Software\NyBumBum\ImgBB Uploader\1", "OptionsClipboard", "REG_DWORD", $nClipboardOptions)
					EndSwitch
				EndIf
				$nNotification = GUICtrlRead($idCheckbox_Notification)
				Switch $sArchitecture
					Case "X64"
						RegWrite("HKCU64\Software\NyBumBum\ImgBB Uploader\1", "APIkey", "REG_SZ", $sAPIkey)
						RegWrite("HKCU64\Software\NyBumBum\ImgBB Uploader\1", "Expiration", "REG_DWORD", $nExpiration)
						RegWrite("HKCU64\Software\NyBumBum\ImgBB Uploader\1", "ActionBrowser", "REG_DWORD", $nBrowser)
						RegWrite("HKCU64\Software\NyBumBum\ImgBB Uploader\1", "ActionClipboard", "REG_DWORD", $nClipboard)
						RegWrite("HKCU64\Software\NyBumBum\ImgBB Uploader\1", "ActionNotification", "REG_DWORD", $nNotification)
					Case "X86"
						RegWrite("HKCU\Software\NyBumBum\ImgBB Uploader\1", "APIkey", "REG_SZ", $sAPIkey)
						RegWrite("HKCU\Software\NyBumBum\ImgBB Uploader\1", "Expiration", "REG_DWORD", $nExpiration)
						RegWrite("HKCU\Software\NyBumBum\ImgBB Uploader\1", "ActionBrowser", "REG_DWORD", $nBrowser)
						RegWrite("HKCU\Software\NyBumBum\ImgBB Uploader\1", "ActionClipboard", "REG_DWORD", $nClipboard)
						RegWrite("HKCU\Software\NyBumBum\ImgBB Uploader\1", "ActionNotification", "REG_DWORD", $nNotification)
				EndSwitch
				ExitLoop
		EndSelect
		$iMemoryCheckbox_Browser = $nBrowser
		$iMemoryCheckbox_Clipboard = $nClipboard
	WEnd

	GUIDelete()
EndFunc   ;==>ImgBBUploaderGUI
