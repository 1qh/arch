; Globals
global DesktopCount := 2 ; Windows starts with 2 desktops at boot
global CurrentDesktop := 1 ; Desktop count is 1-indexed (Microsoft numbers them this way)
;
; This function examines the registry to build an accurate list of the current virtual desktops and which one we're currently on.
; Current desktop UUID appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\1\VirtualDesktops
; List of desktops appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
;
mapDesktopsFromRegistry() {
	global DesktopCount
	global CurrentDesktop

	; Get the current desktop UUID. Length should be 32 always, but there's no guarantee this couldn't change in a later Windows release so we check.
	IdLength := 32
	CurrentDesktopId := 0
	SessionId := getSessionId()
	if (SessionId) {
		CurrentDesktopId := RegRead("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%SessionId%\VirtualDesktops", "CurrentVirtualDesktop")
		if (CurrentDesktopId) {
			IdLength := StrLen(CurrentDesktopId)
		}
	}
	; Get a list of the UUIDs for all virtual desktops on the system
	DesktopList := RegRead("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops", "VirtualDesktopIDs")
	if (DesktopList) {
		DesktopListLength := StrLen(DesktopList)
		; Figure out how many virtual desktops there are
		DesktopCount := DesktopListLength / IdLength
	}
	else {
		DesktopCount := 1
	}
	; Parse the REG_DATA string that stores the array of UUID's for virtual desktops in the registry.
	i := 0
	while (CurrentDesktopId and i < DesktopCount) {
		StartPos := (i * IdLength) + 1
		DesktopIter := SubStr(DesktopList, StartPos, IdLength)
		OutputDebug("The iterator is pointing at %DesktopIter% and count is %i%.")
		; Break out if we find a match in the list. If we didn't find anything, keep the
		; old guess and pray we're still correct :-D.
		if (DesktopIter = CurrentDesktopId) {
			CurrentDesktop := i + 1
			OutputDebug("Current desktop number is %CurrentDesktop% with an ID of %DesktopIter%.")
			break
		}
		i++
	}
}
;
; This functions finds out ID of current session.
;
getSessionId() {
	try {
		ProcessId := DllCall("GetCurrentProcessId", "UInt")
	}
	catch {
		OutputDebug("Error getting current process id: %ErrorLevel%")
		return
	}
	try {
		OutputDebug("Current Process Id:" . ProcessId)
		SessionId := DllCall("kernel32.dll\ProcessIdToSessionId", "UInt", ProcessId, "UInt*")
	}
	catch {
		OutputDebug("Error getting session id: %ErrorLevel%")
		return
	}
	OutputDebug("Current Session Id: %SessionId%")
	return SessionId
}
;
; This function switches to the desktop number provided.
;
switchDesktopByNumber(targetDesktop) {
	global CurrentDesktop
	global DesktopCount

	; Re-generate the list of desktops and where we fit in that. We do this because
	; the user may have switched desktops via some other means than the script.
	mapDesktopsFromRegistry()
	; Don't attempt to switch to an invalid desktop
	if (targetDesktop > DesktopCount || targetDesktop < 1) {
		OutputDebug("[invalid] target: %targetDesktop% current: %CurrentDesktop%")
		return
	}
	; Go right until we reach the desktop we want
	while (CurrentDesktop < targetDesktop) {
		Send "^#{Right}"
		CurrentDesktop++
		OutputDebug("[right] target: %targetDesktop% current: %CurrentDesktop%")
	}
	; Go left until we reach the desktop we want
	while (CurrentDesktop > targetDesktop) {
		Send "^#{Left}"
		CurrentDesktop--
		OutputDebug("[left] target: %targetDesktop% current: %CurrentDesktop%")
	}
}
;
; This function creates a new virtual desktop and switches to it
;
switchNextDesktop() {
	global CurrentDesktop
	global DesktopCount

	TargetDesktop := 1
	; Re-generate the list of desktops and where we fit in that. We do this because
	; the user may have switched desktops via some other means than the script.
	mapDesktopsFromRegistry()
	; Don't attempt to switch to an invalid desktop
	TargetDesktop := CurrentDesktop
	if (TargetDesktop < DesktopCount) {
		TargetDesktop++
	}
	else {
		TargetDesktop := 1
	}
	; Go right until we reach the desktop we want
	while (CurrentDesktop < TargetDesktop) {
		Send "^#{Right}"
		CurrentDesktop++
		OutputDebug("[right] target: %TargetDesktop% current: %CurrentDesktop%")
	}
	; Go left until we reach the desktop we want
	while (CurrentDesktop > TargetDesktop) {
		Send "^#{Left}"
		CurrentDesktop--
		OutputDebug("[left] target: %TargetDesktop% current: %CurrentDesktop%")
	}
}
;
; This function creates a new virtual desktop and switches to it
;
createVirtualDesktop() {
	global CurrentDesktop
	global DesktopCount

	Send "#^d"
	DesktopCount++
	CurrentDesktop := DesktopCount
	OutputDebug "[create] desktops: %DesktopCount% current: %CurrentDesktop%"
}
;
; This function deletes the current virtual desktop
;
deleteVirtualDesktop() {
	global CurrentDesktop
	global DesktopCount

	Send "#^{F4}"
	DesktopCount--
	CurrentDesktop--
	OutputDebug("[delete] desktops: %DesktopCount% current: %CurrentDesktop%")
}
; Main
SetKeyDelay 75
mapDesktopsFromRegistry()
OutputDebug("[loading] desktops: %DesktopCount% current: %CurrentDesktop%")

LWin & 1:: switchDesktopByNumber(1)
LWin & 2:: switchDesktopByNumber(2)
LWin & 3:: switchDesktopByNumber(3)
LWin & 4:: switchDesktopByNumber(4)
LWin & 5:: switchDesktopByNumber(5)
LWin & 6:: switchDesktopByNumber(6)
LWin & 7:: switchDesktopByNumber(7)
LWin & 8:: switchDesktopByNumber(8)
LWin & 9:: switchDesktopByNumber(9)

LWin & Enter:: run ("C:\Program Files\Alacritty\alacritty.exe")
LWin & c:: run ("C:\Program Files\Microsoft VS Code\Code.exe")
LWin & b:: run ("C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe")
LWin & g:: run ("C:\Riot Games\League of Legends\LeagueClient.exe")

LWin & q:: Send("!{F4}")
LWin:: Send("!{Space}")

Esc::CapsLock
*CapsLock:: Send "{LControl down}"
*CapsLock up:: {
	Send "{LControl Up}"
	if (A_PriorKey == "CapsLock") {
		if (A_TimeSincePriorHotkey < 1000)
			Suspend "1"
		Send "{Esc}"
		Suspend "0"
	}
}

; F1:: switchNextDesktop()
; CapsLock & 1:: switchDesktopByNumber(1)
; CapsLock & 2:: switchDesktopByNumber(2)
; CapsLock & 3:: switchDesktopByNumber(3)
; CapsLock & 4:: switchDesktopByNumber(4)
; CapsLock & 5:: switchDesktopByNumber(5)
; CapsLock & 6:: switchDesktopByNumber(6)
; CapsLock & 7:: switchDesktopByNumber(7)
; CapsLock & 8:: switchDesktopByNumber(8)
; CapsLock & 9:: switchDesktopByNumber(9)
; CapsLock & n:: switchDesktopByNumber(CurrentDesktop + 1)
; CapsLock & p:: switchDesktopByNumber(CurrentDesktop - 1)
; CapsLock & s:: switchDesktopByNumber(CurrentDesktop + 1)
; CapsLock & a:: switchDesktopByNumber(CurrentDesktop - 1)
