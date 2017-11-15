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

ScriptName DMN_SXPAEventHandlerData Extends Quest

{Skyrim XP Addon - Event Handler Helper script by Deadmano.
}

Import Debug
Import Game
Import Utility
Import DMN_DeadmaniacFunctionsSXPA
Import DMN_SXPAFunctions

DMN_SXPAEventHandler Property DMN_SXPAEH Auto

;GlobalVariable Property DMN_SXPAExperiencePoints Auto
;GlobalVariable Property DMN_SXPAExperienceMin Auto
;GlobalVariable Property DMN_SXPAExperienceMax Auto

Quest Property DMN_SXPAEventHandlerHelper Auto
{The Event Handler Helper quest. Auto-Fill.}

; The list of XP modifiers that affect the XP given per stat progression.
Float[] Property fXPModifier Auto Hidden
; The list of skill modifiers that affect the XP cost per skill level.
Float[] Property fSkillModifier Auto Hidden
; The list of converted XP values for each stat.
Int[] Property iSkillXP Auto Hidden
; The list of total generic XP spent on each skill.
Int[] Property iSkillXPSpent Auto Hidden
; The list of total effective skill XP spent on each skill.
Int[] Property iSkillXPSpentEffective Auto Hidden
; When on, monitoring becomes passive (event based). 1 = on, 0 = off.
Int Property iPassiveMonitoring Auto Hidden

Function updateEventHandlerData()
; This function first backs up relevant Event Handler user data, stops and
; starts the Event Handler quest to be made aware of newly added variables/properties
; and then restores the user data thus ensuring SXPA data/settings are preserved.
	copyEventHandlerData()
	restoreEventHandlerData()
EndFunction

Function copyEventHandlerData()
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog("\n")
	DMN_SXPALog("[Started copyEventHandlerData Function]\n")
	String sError = "Skyrim XP Addon \n\nERROR! SXPA could not complete user data migration. Please report this on the SXPA page."
	Int iInfiniteLoopBreak = 0
	DMN_SXPALog("Checking to see if the Event Handler Helper Quest is running...")
	If (Self.IsRunning())
		DMN_SXPALog("Quest Is Running!")
	Else
		DMN_SXPALog("Quest Is Not Running! Attempting to start it now...")
	EndIf
	While (!Self.IsRunning() && iInfiniteLoopBreak < 100)
	; Wait at most 10 seconds for the quest to start.
		iInfiniteLoopBreak += 1
		Wait(0.1)
	; Try to start the quest every 100 milliseconds.
		Self.Start()
	EndWhile
	If (!Self.IsRunning())
		MessageBox(sError)
		DMN_SXPALog("ERROR: (Stage: 1/2) The SXPA Event Handler Helper quest could not be started, after 10 seconds of trying.")
	Else
		DMN_SXPALog("Started the SXPA Event Handler Helper quest after " + iInfiniteLoopBreak + " tries (" + (iInfiniteLoopBreak * 0.1) + " seconds).")
		iInfiniteLoopBreak = 0
		DMN_SXPALog("Checking to see if the Event Handler Quest is running...")
		If (DMN_SXPAEH.IsRunning())
			DMN_SXPALog("Quest Is Running!")
		Else
			DMN_SXPALog("Quest Is Not Running! Attempting to start it now...")
		EndIf
		While (!DMN_SXPAEH.IsRunning() && iInfiniteLoopBreak < 100)
		; Wait at most 10 seconds for the quest to start.
			iInfiniteLoopBreak += 1
			Wait(0.1)
		; Try to start the quest every 100 milliseconds.
			DMN_SXPAEH.Start()
		EndWhile
		If (!DMN_SXPAEH.IsRunning())
			MessageBox(sError)
			DMN_SXPALog("ERROR: (Stage: 2/2) The SXPA Event Handler quest could not be started, after 10 seconds of trying.")
			DMN_SXPALog("ERROR: Failed array copy process.")
		Else
			DMN_SXPALog("Started the SXPA Event Handler quest after " + iInfiniteLoopBreak + " tries (" + (iInfiniteLoopBreak * 0.1) + " seconds).")
			iInfiniteLoopBreak = 0
			DMN_SXPALog("Beginning array copy process from the Event Handler quest to Event Handler Helper quest.")
			fXPModifier = New Float[128]
			fXPModifier = DMN_SXPAEH.fXPModifier
			DMN_SXPALog("Copying fXPModifier array now...")
			If (fXPModifier)
				DMN_SXPALog("Copied fXPModifier.")
				DMN_SXPALog("fXPModifier array: " + fXPModifier)
			Else
				DMN_SXPALog("WARNING: fXPModifier is empty!")
				DMN_SXPALog("fXPModifier array: " + fXPModifier)
			EndIf
			fSkillModifier = New Float[128]
			fSkillModifier = DMN_SXPAEH.fSkillModifier
			DMN_SXPALog("Copying fSkillModifier array now...")
			If (fSkillModifier)
				DMN_SXPALog("Copied fSkillModifier.")
				DMN_SXPALog("fSkillModifier array: " + fSkillModifier)
			Else
				DMN_SXPALog("WARNING: fSkillModifier is empty!")
				DMN_SXPALog("fSkillModifier array: " + fSkillModifier)
			EndIf
			iSkillXP = New Int[128]
			iSkillXP = DMN_SXPAEH.iSkillXP
			DMN_SXPALog("Copying iSkillXP array now...")
			If (iSkillXP)
				DMN_SXPALog("Copied iSkillXP.")
				DMN_SXPALog("iSkillXP array: " + iSkillXP)
			Else
				DMN_SXPALog("WARNING: iSkillXP is empty!")
				DMN_SXPALog("iSkillXP array: " + iSkillXP)
			EndIf
			iSkillXPSpent = New Int[128]
			iSkillXPSpent = DMN_SXPAEH.iSkillXPSpent
			DMN_SXPALog("Copying iSkillXPSpent array now...")
			If (iSkillXPSpent)
				DMN_SXPALog("Copied iSkillXPSpent.")
				DMN_SXPALog("iSkillXPSpent array: " + iSkillXPSpent)
			Else
				DMN_SXPALog("WARNING: iSkillXPSpent is empty!")
				DMN_SXPALog("iSkillXPSpent array: " + iSkillXPSpent)
			EndIf
			iSkillXPSpentEffective = New Int[128]
			iSkillXPSpentEffective = DMN_SXPAEH.iSkillXPSpentEffective
			DMN_SXPALog("Copying iSkillXPSpentEffective array now...")
			If (iSkillXPSpentEffective)
				DMN_SXPALog("Copied iSkillXPSpentEffective.")
				DMN_SXPALog("iSkillXPSpentEffective array: " + iSkillXPSpentEffective)
			Else
				DMN_SXPALog("WARNING: iSkillXPSpentEffective is empty!")
				DMN_SXPALog("iSkillXPSpentEffective array: " + iSkillXPSpentEffective)
			EndIf
			DMN_SXPALog("SUCCESS: Completed array copy process.")
			DMN_SXPALog("Copying passive monitoring state...")
			iPassiveMonitoring = DMN_SXPAEH.iPassiveMonitoring
			DMN_SXPALog("Copied passive monitoring state.")
			DMN_SXPALog("SUCCESS: Completed all tasks!")
		EndIf
	EndIf
	fStop = GetCurrentRealTime()
	DMN_SXPALog("copyEventHandlerData() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog("[Ended copyEventHandlerData Function]\n\n")
EndFunction

Function restoreEventHandlerData()
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog("\n")
	DMN_SXPALog("[Started restoreEventHandlerData Function]\n")
	String sError = "Skyrim XP Addon \n\nERROR! SXPA could not complete user data migration. Please report this on the SXPA page."
	Int iInfiniteLoopBreak = 0
	While (DMN_SXPAEH.IsRunning() && iInfiniteLoopBreak < 100)
	; Wait at most 10 seconds for the quest to stop.
		iInfiniteLoopBreak += 1
		Wait(0.1)
; Try to stop the quest every 100 milliseconds.
	DMN_SXPAEH.Stop() ; Stop the Event Handler's quest to wipe its data for migration.
	EndWhile
	If (DMN_SXPAEH.IsRunning())
		MessageBox(sError)
		DMN_SXPALog("ERROR: (Stage: 1/5) The SXPA Event Handler quest could not be stopped, after 10 seconds of trying.")
		DMN_SXPALog("ERROR: Failed array restore process.")
	Else
		DMN_SXPALog("Stopped the SXPA Event Handler quest after " + iInfiniteLoopBreak + " tries (" + (iInfiniteLoopBreak * 0.1) + " seconds).")
		iInfiniteLoopBreak = 0
		While (!DMN_SXPAEH.IsRunning() && iInfiniteLoopBreak < 100)
		; Wait at most 10 seconds for the quest to start.
			iInfiniteLoopBreak += 1
			Wait(0.1)
		; Try to start the quest every 100 milliseconds.
			DMN_SXPAEH.Start() ; Start the Event Handler quest once again to proceed with the data migration.
		EndWhile
		If (!DMN_SXPAEH.IsRunning())
			MessageBox(sError)
			DMN_SXPALog("ERROR: (Stage: 2/5) The SXPA Event Handler quest could not be started, after 10 seconds of trying.")
		Else
			DMN_SXPALog("Beginning array restore process from the Event Handler Helper quest to Event Handler quest.")
			iInfiniteLoopBreak = 0
			Int iIndex = 0
			While (iIndex < fXPModifier.Length)
				DMN_SXPAEH.fXPModifier[iIndex] = fXPModifier[iIndex]
				iIndex += 1
			EndWhile
			DMN_SXPALog("Restoring fXPModifier array now...")
			If (DMN_SXPAEH.fXPModifier)
				DMN_SXPALog("Restored fXPModifier.")
				DMN_SXPALog("fXPModifier array: " + DMN_SXPAEH.fXPModifier)
			Else
				DMN_SXPALog("WARNING: fXPModifier is empty!")
				DMN_SXPALog("fXPModifier array: " + DMN_SXPAEH.fXPModifier)
			EndIf
			iIndex = 0
			While (iIndex < fSkillModifier.Length)
				DMN_SXPAEH.fSkillModifier[iIndex] = fSkillModifier[iIndex]
				iIndex += 1
			EndWhile
			DMN_SXPALog("Restoring fSkillModifier array now...")
			If (DMN_SXPAEH.fSkillModifier)
				DMN_SXPALog("Restored fSkillModifier.")
				DMN_SXPALog("fSkillModifier array: " + DMN_SXPAEH.fSkillModifier)
			Else
				DMN_SXPALog("WARNING: fSkillModifier is empty!")
				DMN_SXPALog("fSkillModifier array: " + DMN_SXPAEH.fSkillModifier)
			EndIf
			iIndex = 0
			While (iIndex < iSkillXP.Length)
				DMN_SXPAEH.iSkillXP[iIndex] = iSkillXP[iIndex]
				iIndex += 1
			EndWhile
			DMN_SXPALog("Restoring iSkillXP array now...")
			If (DMN_SXPAEH.iSkillXP)
				DMN_SXPALog("Restored iSkillXP.")
				DMN_SXPALog("iSkillXP array: " + DMN_SXPAEH.iSkillXP)
			Else
				DMN_SXPALog("WARNING: iSkillXP is empty!")
				DMN_SXPALog("iSkillXP array: " + DMN_SXPAEH.iSkillXP)
			EndIf
			iIndex = 0
			While (iIndex < iSkillXPSpent.Length)
				DMN_SXPAEH.iSkillXPSpent[iIndex] = iSkillXPSpent[iIndex]
				iIndex += 1
			EndWhile
			DMN_SXPALog("Restoring iSkillXPSpent array now...")
			If (DMN_SXPAEH.iSkillXPSpent)
				DMN_SXPALog("Restored iSkillXPSpent.")
				DMN_SXPALog("iSkillXPSpent array: " + DMN_SXPAEH.iSkillXPSpent)
			Else
				DMN_SXPALog("WARNING: iSkillXPSpent is empty!")
				DMN_SXPALog("iSkillXPSpent array: " + DMN_SXPAEH.iSkillXPSpent)
			EndIf
			iIndex = 0
			While (iIndex < iSkillXPSpentEffective.Length)
				DMN_SXPAEH.iSkillXPSpentEffective[iIndex] = iSkillXPSpentEffective[iIndex]
				iIndex += 1
			EndWhile
			DMN_SXPALog("Restoring iSkillXPSpentEffective array now...")
			If (DMN_SXPAEH.iSkillXPSpentEffective)
				DMN_SXPALog("Restored iSkillXPSpentEffective.")
				DMN_SXPALog("iSkillXPSpentEffective array: " + DMN_SXPAEH.iSkillXPSpentEffective)
			Else
				DMN_SXPALog("WARNING: iSkillXPSpentEffective is empty!")
				DMN_SXPALog("iSkillXPSpentEffective array: " + DMN_SXPAEH.iSkillXPSpentEffective)
			EndIf
			iIndex = 0
			DMN_SXPALog("SUCCESS: Completed array restore process.")
			DMN_SXPALog("Restoring passive monitoring state...")
			DMN_SXPAEH.iPassiveMonitoring = iPassiveMonitoring
			DMN_SXPALog("Restored passive monitoring state.")
			While (Self.IsRunning() && iInfiniteLoopBreak < 100)
			; Wait at most 10 seconds for the quest to stop.
				iInfiniteLoopBreak += 1
				Wait(0.1)
			; Try to stop the quest every 100 milliseconds.
				Self.Stop() ; Stop the Event Handler Helper's quest to wipe its data. (Phase 1/3)
			EndWhile
			If (Self.IsRunning())
				MessageBox(sError)
				DMN_SXPALog("ERROR: (Stage: 3/5) The SXPA Event Handler Helper quest could not be stopped, after 10 seconds of trying.")
			Else
				DMN_SXPALog("Stopped the SXPA Event Handler Helper quest after " + iInfiniteLoopBreak + " tries (" + (iInfiniteLoopBreak * 0.1) + " seconds).")
				iInfiniteLoopBreak = 0
				While (!Self.IsRunning() && iInfiniteLoopBreak < 100)
				; Wait at most 10 seconds for the quest to start.
					iInfiniteLoopBreak += 1
					Wait(0.1)
				; Try to start the quest every 100 milliseconds.
					Self.Start() ; Start the Event Handler Helper's quest to complete wiping its data. (Phase 2/3)
				EndWhile
				If (!Self.IsRunning())
					MessageBox(sError)
					DMN_SXPALog("ERROR: (Stage: 4/5) The SXPA Event Handler Helper quest could not be started, after 10 seconds of trying.")
				Else
					DMN_SXPALog("Started the SXPA Event Handler Helper quest after " + iInfiniteLoopBreak + " tries (" + (iInfiniteLoopBreak * 0.1) + " seconds).")
					iInfiniteLoopBreak = 0
					While (Self.IsRunning() && iInfiniteLoopBreak < 100)
					; Wait at most 10 seconds for the quest to stop.
						iInfiniteLoopBreak += 1
						Wait(0.1)
					; Try to stop the quest every 100 milliseconds.
						Self.Stop() ; Stop the Event Handler Helper's quest one last time to save the wiped state. (Phase 3/3)
					EndWhile
					If (Self.IsRunning())
						MessageBox(sError)
						DMN_SXPALog("ERROR: (Stage: 5/5) The SXPA Event Handler Helper quest could not be stopped, after 10 seconds of trying.")
					Else
						DMN_SXPALog("Stopped the SXPA Event Handler Helper quest after " + iInfiniteLoopBreak + " tries (" + (iInfiniteLoopBreak * 0.1) + " seconds).")
						DMN_SXPALog("SUCCESS: Completed all tasks!")
						iInfiniteLoopBreak = 0
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	fStop = GetCurrentRealTime()
	DMN_SXPALog("restoreEventHandlerData() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog("[Ended restoreEventHandlerData Function]\n\n")
EndFunction