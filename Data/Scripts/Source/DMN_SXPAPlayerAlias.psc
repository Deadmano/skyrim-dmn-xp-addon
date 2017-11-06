; Copyright (C) 2017 Phillip Stolic
; 
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

ScriptName DMN_SXPAPlayerAlias Extends ReferenceAlias

{Allows the maintenance functions in the Skyrim XP
Addon Config script to run on each save game load.
}

Import Debug
Import Utility

GlobalVariable Property DMN_SXPAActiveMonitoring Auto
 
DMN_SXPAConfig Property DMN_SXPAC Auto
DMN_SXPAEventHandler Property DMN_SXPAEH Auto

Event OnPlayerLoadGame()
	DMN_SXPAC.preMaintenance()
	DMN_SXPAC.Maintenance()
EndEvent

Function waitForStatChange()
; Waits for a single second to action whatever is in
; the OnUpdate() event below. Does not repeat itself. 
  RegisterForSingleUpdate(1.0)
EndFunction

Event OnUpdate()
; The variable that holds the monitor state. 1 = on, 0 = off.
	Bool bContinueMonitoring = DMN_SXPAActiveMonitoring.GetValue() As Int
; If a SXPA tracked player stat was changed,
; then update the SXPA values and reward XP.
	If (DMN_SXPAEH.checkPlayerStats())
		DMN_SXPAEH.updatePlayerStats()
	EndIf
; If monitoring has not been turned off we will register for another OnUpdate()
; cycle for 1 second. This will continue looping until the monitoring variable
; is switched to 0 (off) either by another script, or by player request.
	If (bContinueMonitoring == 1)
		RegisterForSingleUpdate(1.0)
	EndIf
EndEvent

; Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
;Uses: Nirnroots Found.
	; Wait(0.1)
	; If (!akSourceContainer)
	;This item was picked up from the world or added by console.
		; DMN_SXPAEH.checkPlayerStats()
		;Debug.Trace("Player received " + aiItemCount + "x " + akBaseItem + " from the world or via console.")
	  ; Else
	;This item was received from another source such as container/inventory.
		; DMN_SXPAEH.checkPlayerStats()
		;Debug.Trace("Player received " + aiItemCount + "x " + akBaseItem + " from another another source.")
	; EndIf
; EndEvent

; Event OnUpdate()
;Uses: Books Read.
	; Notification("OnUpdate Activated")
	; If (IsInMenuMode())
		; Notification("We are in a menu!")
	;The player is in a menu, such as inventory or book menu.
		; DMN_SXPAEH.checkPlayerStats()
	; Else
	;Nothing interesting happened, so let's wait for another update in 1 second and try again.
		; Notification("Registering for a single update...")
		; RegisterForSingleUpdate(1.0)
	; EndIf
; EndEvent
