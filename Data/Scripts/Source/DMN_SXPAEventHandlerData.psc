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

Quest Property DMN_SXPAEventHandlerHelper Auto
{The Event Handler Helper quest. Auto-Fill.}

; The following 4 variables hold the used
; (true)/unused (false) state of the skill slots.
Bool Property bTaggedSkillSlot01Used Auto Hidden
Bool Property bTaggedSkillSlot02Used Auto Hidden
Bool Property bTaggedSkillSlot03Used Auto Hidden
Bool Property bTaggedSkillSlot04Used Auto Hidden
; The type of configurator being used. 1 = spell, 0 = book.
Int Property iConfiguratorType Auto Hidden
; When on, monitoring becomes passive (event based). 1 = on, 0 = off.
Int Property iPassiveMonitoring Auto Hidden
; The following 4 variables hold the skill name
; index from 1 (Archery) to 18 (Speech).
Int Property iTaggedSkillSlot01 Auto Hidden
Int Property iTaggedSkillSlot02 Auto Hidden
Int Property iTaggedSkillSlot03 Auto Hidden
Int Property iTaggedSkillSlot04 Auto Hidden
; Affects whether or not the XP activity will be tracked and give XP or not.
Bool[] Property bXPActivityState Auto Hidden
; The list of skill multipliers that affect the XP cost per skill level.
Float[] Property fSkillMultiplier Auto Hidden
; The list of priorities for player-tagged skills for automatic XP spending.
Float[] Property fTaggedSkillsPriority Auto Hidden
; The list of XP multipliers that affect the XP given per stat progression.
Float[] Property fXPMultiplier Auto Hidden
; The list of converted XP values for each stat.
Int[] Property iModCompatibility Auto Hidden
; The list that handles the state of mod compatability and support.
Int[] Property iSkillXP Auto Hidden
; The list of total generic XP spent on each skill.
Int[] Property iSkillXPSpent Auto Hidden
; The list of total effective skill XP spent on each skill.
Int[] Property iSkillXPSpentEffective Auto Hidden
; The list of all player stat values that we are tracking.
Int[] Property iTrackedStatCount Auto Hidden
; The list of skills the player has tagged for automatic XP spending.
String[] Property sTaggedSkills Auto Hidden

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
	DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "[Started copyEventHandlerData Function]\n")
	String sError = "Skyrim XP Addon \n\nERROR! SXPA could not complete user data migration. Please report this on the SXPA page."
	Int iInfiniteLoopBreak = 0
	DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Checking to see if the Event Handler Helper Quest is running...")
	If (Self.IsRunning())
		DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Quest Is Running!")
	Else
		DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Quest Is Not Running! Attempting to start it now...")
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
		DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "ERROR: (Stage: 1/2) The SXPA Event Handler Helper quest could not be started, after 10 seconds of trying.")
	Else
		DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Started the SXPA Event Handler Helper quest after " + iInfiniteLoopBreak + " tries (" + (iInfiniteLoopBreak * 0.1) + " seconds).")
		iInfiniteLoopBreak = 0
		DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Checking to see if the Event Handler Quest is running...")
		If (DMN_SXPAEH.IsRunning())
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Quest Is Running!")
		Else
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Quest Is Not Running! Attempting to start it now...")
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
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "ERROR: (Stage: 2/2) The SXPA Event Handler quest could not be started, after 10 seconds of trying.")
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "ERROR: Failed array copy process.")
		Else
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Started the SXPA Event Handler quest after " + iInfiniteLoopBreak + " tries (" + (iInfiniteLoopBreak * 0.1) + " seconds).")
			iInfiniteLoopBreak = 0
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Beginning array copy process from the Event Handler quest to Event Handler Helper quest.")
			bXPActivityState = New Bool[128]
			bXPActivityState = DMN_SXPAEH.bXPActivityState
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copying bXPActivityState array now...")
			If (bXPActivityState)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copied bXPActivityState.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "bXPActivityState array: " + bXPActivityState)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: bXPActivityState is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "bXPActivityState array: " + bXPActivityState)
			EndIf
			fSkillMultiplier = New Float[128]
			fSkillMultiplier = DMN_SXPAEH.fSkillMultiplier
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copying fSkillMultiplier array now...")
			If (fSkillMultiplier)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copied fSkillMultiplier.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "fSkillMultiplier array: " + fSkillMultiplier)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: fSkillMultiplier is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "fSkillMultiplier array: " + fSkillMultiplier)
			EndIf
			fTaggedSkillsPriority = New Float[128]
			fTaggedSkillsPriority = DMN_SXPAEH.fTaggedSkillsPriority
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copying fTaggedSkillsPriority array now...")
			If (fTaggedSkillsPriority)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copied fTaggedSkillsPriority.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "fTaggedSkillsPriority array: " + fTaggedSkillsPriority)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: fTaggedSkillsPriority is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "fTaggedSkillsPriority array: " + fTaggedSkillsPriority)
			EndIf
			fXPMultiplier = New Float[128]
			fXPMultiplier = DMN_SXPAEH.fXPMultiplier
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copying fXPMultiplier array now...")
			If (fXPMultiplier)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copied fXPMultiplier.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "fXPMultiplier array: " + fXPMultiplier)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: fXPMultiplier is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "fXPMultiplier array: " + fXPMultiplier)
			EndIf
			iModCompatibility = New Int[128]
			iModCompatibility = DMN_SXPAEH.iModCompatibility
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copying iModCompatibility array now...")
			If (iModCompatibility)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copied iModCompatibility.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iModCompatibility array: " + iModCompatibility)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: iModCompatibility is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iModCompatibility array: " + iModCompatibility)
			EndIf
			iSkillXP = New Int[128]
			iSkillXP = DMN_SXPAEH.iSkillXP
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copying iSkillXP array now...")
			If (iSkillXP)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copied iSkillXP.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iSkillXP array: " + iSkillXP)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: iSkillXP is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iSkillXP array: " + iSkillXP)
			EndIf
			iSkillXPSpent = New Int[128]
			iSkillXPSpent = DMN_SXPAEH.iSkillXPSpent
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copying iSkillXPSpent array now...")
			If (iSkillXPSpent)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copied iSkillXPSpent.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iSkillXPSpent array: " + iSkillXPSpent)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: iSkillXPSpent is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iSkillXPSpent array: " + iSkillXPSpent)
			EndIf
			iSkillXPSpentEffective = New Int[128]
			iSkillXPSpentEffective = DMN_SXPAEH.iSkillXPSpentEffective
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copying iSkillXPSpentEffective array now...")
			If (iSkillXPSpentEffective)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copied iSkillXPSpentEffective.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iSkillXPSpentEffective array: " + iSkillXPSpentEffective)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: iSkillXPSpentEffective is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iSkillXPSpentEffective array: " + iSkillXPSpentEffective)
			EndIf
			iTrackedStatCount = New Int[128]
			iTrackedStatCount = DMN_SXPAEH.iTrackedStatCount
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copying iTrackedStatCount array now...")
			If (iTrackedStatCount)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copied iTrackedStatCount.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iTrackedStatCount array: " + iTrackedStatCount)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: iTrackedStatCount is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iTrackedStatCount array: " + iTrackedStatCount)
			EndIf
			sTaggedSkills = New String[128]
			sTaggedSkills = DMN_SXPAEH.sTaggedSkills
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copying sTaggedSkills array now...")
			If (sTaggedSkills)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copied sTaggedSkills.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "sTaggedSkills array: " + sTaggedSkills)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: sTaggedSkills is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "sTaggedSkills array: " + sTaggedSkills)
			EndIf
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "SUCCESS: Completed array copy process.")
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copying configurator type...")
			iConfiguratorType = DMN_SXPAEH.iConfiguratorType
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copied configurator type.")
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copying passive monitoring state...")
			iPassiveMonitoring = DMN_SXPAEH.iPassiveMonitoring
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copied passive monitoring state.")
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copying tagged skill slots...")
			iTaggedSkillSlot01 = DMN_SXPAEH.iTaggedSkillSlot01
			iTaggedSkillSlot02 = DMN_SXPAEH.iTaggedSkillSlot02
			iTaggedSkillSlot03 = DMN_SXPAEH.iTaggedSkillSlot03
			iTaggedSkillSlot04 = DMN_SXPAEH.iTaggedSkillSlot04
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copied tagged skill slots.")
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copying tagged skill slots used states...")
			bTaggedSkillSlot01Used = DMN_SXPAEH.bTaggedSkillSlot01Used
			bTaggedSkillSlot02Used = DMN_SXPAEH.bTaggedSkillSlot02Used
			bTaggedSkillSlot03Used = DMN_SXPAEH.bTaggedSkillSlot03Used
			bTaggedSkillSlot04Used = DMN_SXPAEH.bTaggedSkillSlot04Used
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Copied tagged skill slots used states.")
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "SUCCESS: Completed all tasks!")
		EndIf
	EndIf
	fStop = GetCurrentRealTime()
	DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "copyEventHandlerData() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "[Ended copyEventHandlerData Function]\n\n")
EndFunction

Function restoreEventHandlerData()
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "[Started restoreEventHandlerData Function]\n")
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
		DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "ERROR: (Stage: 1/5) The SXPA Event Handler quest could not be stopped, after 10 seconds of trying.")
		DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "ERROR: Failed array restore process.")
	Else
		DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Stopped the SXPA Event Handler quest after " + iInfiniteLoopBreak + " tries (" + (iInfiniteLoopBreak * 0.1) + " seconds).")
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
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "ERROR: (Stage: 2/5) The SXPA Event Handler quest could not be started, after 10 seconds of trying.")
		Else
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Beginning array restore process from the Event Handler Helper quest to Event Handler quest.")
			iInfiniteLoopBreak = 0
			Int iIndex = 0
			While (iIndex < bXPActivityState.Length)
				DMN_SXPAEH.bXPActivityState[iIndex] = bXPActivityState[iIndex]
				iIndex += 1
			EndWhile
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restoring bXPActivityState array now...")
			If (DMN_SXPAEH.bXPActivityState)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restored bXPActivityState.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "bXPActivityState array: " + DMN_SXPAEH.bXPActivityState)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: bXPActivityState is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "bXPActivityState array: " + DMN_SXPAEH.bXPActivityState)
			EndIf
			iIndex = 0
			While (iIndex < fSkillMultiplier.Length)
				DMN_SXPAEH.fSkillMultiplier[iIndex] = fSkillMultiplier[iIndex]
				iIndex += 1
			EndWhile
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restoring fSkillMultiplier array now...")
			If (DMN_SXPAEH.fSkillMultiplier)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restored fSkillMultiplier.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "fSkillMultiplier array: " + DMN_SXPAEH.fSkillMultiplier)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: fSkillMultiplier is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "fSkillMultiplier array: " + DMN_SXPAEH.fSkillMultiplier)
			EndIf
			iIndex = 0
			While (iIndex < fTaggedSkillsPriority.Length)
				DMN_SXPAEH.fTaggedSkillsPriority[iIndex] = fTaggedSkillsPriority[iIndex]
				iIndex += 1
			EndWhile
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restoring fTaggedSkillsPriority array now...")
			If (DMN_SXPAEH.fTaggedSkillsPriority)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restored fTaggedSkillsPriority.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "fTaggedSkillsPriority array: " + DMN_SXPAEH.fTaggedSkillsPriority)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: fTaggedSkillsPriority is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "fTaggedSkillsPriority array: " + DMN_SXPAEH.fTaggedSkillsPriority)
			EndIf
			iIndex = 0
			While (iIndex < fXPMultiplier.Length)
				DMN_SXPAEH.fXPMultiplier[iIndex] = fXPMultiplier[iIndex]
				iIndex += 1
			EndWhile
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restoring fXPMultiplier array now...")
			If (DMN_SXPAEH.fXPMultiplier)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restored fXPMultiplier.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "fXPMultiplier array: " + DMN_SXPAEH.fXPMultiplier)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: fXPMultiplier is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "fXPMultiplier array: " + DMN_SXPAEH.fXPMultiplier)
			EndIf
			iIndex = 0
			While (iIndex < iModCompatibility.Length)
				DMN_SXPAEH.iModCompatibility[iIndex] = iModCompatibility[iIndex]
				iIndex += 1
			EndWhile
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restoring iModCompatibility array now...")
			If (DMN_SXPAEH.iModCompatibility)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restored iModCompatibility.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iModCompatibility array: " + DMN_SXPAEH.iModCompatibility)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: iModCompatibility is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iModCompatibility array: " + DMN_SXPAEH.iModCompatibility)
			EndIf
			iIndex = 0
			While (iIndex < iSkillXP.Length)
				DMN_SXPAEH.iSkillXP[iIndex] = iSkillXP[iIndex]
				iIndex += 1
			EndWhile
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restoring iSkillXP array now...")
			If (DMN_SXPAEH.iSkillXP)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restored iSkillXP.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iSkillXP array: " + DMN_SXPAEH.iSkillXP)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: iSkillXP is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iSkillXP array: " + DMN_SXPAEH.iSkillXP)
			EndIf
			iIndex = 0
			While (iIndex < iSkillXPSpent.Length)
				DMN_SXPAEH.iSkillXPSpent[iIndex] = iSkillXPSpent[iIndex]
				iIndex += 1
			EndWhile
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restoring iSkillXPSpent array now...")
			If (DMN_SXPAEH.iSkillXPSpent)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restored iSkillXPSpent.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iSkillXPSpent array: " + DMN_SXPAEH.iSkillXPSpent)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: iSkillXPSpent is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iSkillXPSpent array: " + DMN_SXPAEH.iSkillXPSpent)
			EndIf
			iIndex = 0
			While (iIndex < iSkillXPSpentEffective.Length)
				DMN_SXPAEH.iSkillXPSpentEffective[iIndex] = iSkillXPSpentEffective[iIndex]
				iIndex += 1
			EndWhile
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restoring iSkillXPSpentEffective array now...")
			If (DMN_SXPAEH.iSkillXPSpentEffective)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restored iSkillXPSpentEffective.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iSkillXPSpentEffective array: " + DMN_SXPAEH.iSkillXPSpentEffective)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: iSkillXPSpentEffective is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iSkillXPSpentEffective array: " + DMN_SXPAEH.iSkillXPSpentEffective)
			EndIf
			iIndex = 0
			While (iIndex < iTrackedStatCount.Length)
				DMN_SXPAEH.iTrackedStatCount[iIndex] = iTrackedStatCount[iIndex]
				iIndex += 1
			EndWhile
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restoring iTrackedStatCount array now...")
			If (DMN_SXPAEH.iTrackedStatCount)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restored iTrackedStatCount.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iTrackedStatCount array: " + DMN_SXPAEH.iTrackedStatCount)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: iTrackedStatCount is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "iTrackedStatCount array: " + DMN_SXPAEH.iTrackedStatCount)
			EndIf
			iIndex = 0
			While (iIndex < sTaggedSkills.Length)
				DMN_SXPAEH.sTaggedSkills[iIndex] = sTaggedSkills[iIndex]
				iIndex += 1
			EndWhile
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restoring sTaggedSkills array now...")
			If (DMN_SXPAEH.sTaggedSkills)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restored sTaggedSkills.")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "sTaggedSkills array: " + DMN_SXPAEH.sTaggedSkills)
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "WARNING: sTaggedSkills is empty!")
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "sTaggedSkills array: " + DMN_SXPAEH.sTaggedSkills)
			EndIf
			iIndex = 0
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "SUCCESS: Completed array restore process.")
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restoring configurator type...")
			DMN_SXPAEH.iConfiguratorType = iConfiguratorType
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restored configurator type.")
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restoring passive monitoring state...")
			DMN_SXPAEH.iPassiveMonitoring = iPassiveMonitoring
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restored passive monitoring state.")
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restoring tagged skill slots...")
			DMN_SXPAEH.iTaggedSkillSlot01 = iTaggedSkillSlot01
			DMN_SXPAEH.iTaggedSkillSlot02 = iTaggedSkillSlot02
			DMN_SXPAEH.iTaggedSkillSlot03 = iTaggedSkillSlot03
			DMN_SXPAEH.iTaggedSkillSlot04 = iTaggedSkillSlot04
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restored tagged skill slots.")
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restoring tagged skill slots used states...")
			DMN_SXPAEH.bTaggedSkillSlot01Used = bTaggedSkillSlot01Used
			DMN_SXPAEH.bTaggedSkillSlot02Used = bTaggedSkillSlot02Used
			DMN_SXPAEH.bTaggedSkillSlot03Used = bTaggedSkillSlot03Used
			DMN_SXPAEH.bTaggedSkillSlot04Used = bTaggedSkillSlot04Used
			DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Restored tagged skill slots used states.")
			While (Self.IsRunning() && iInfiniteLoopBreak < 100)
			; Wait at most 10 seconds for the quest to stop.
				iInfiniteLoopBreak += 1
				Wait(0.1)
			; Try to stop the quest every 100 milliseconds.
				Self.Stop() ; Stop the Event Handler Helper's quest to wipe its data. (Phase 1/3)
			EndWhile
			If (Self.IsRunning())
				MessageBox(sError)
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "ERROR: (Stage: 3/5) The SXPA Event Handler Helper quest could not be stopped, after 10 seconds of trying.")
			Else
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Stopped the SXPA Event Handler Helper quest after " + iInfiniteLoopBreak + " tries (" + (iInfiniteLoopBreak * 0.1) + " seconds).")
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
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "ERROR: (Stage: 4/5) The SXPA Event Handler Helper quest could not be started, after 10 seconds of trying.")
				Else
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Started the SXPA Event Handler Helper quest after " + iInfiniteLoopBreak + " tries (" + (iInfiniteLoopBreak * 0.1) + " seconds).")
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
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "ERROR: (Stage: 5/5) The SXPA Event Handler Helper quest could not be stopped, after 10 seconds of trying.")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Stopped the SXPA Event Handler Helper quest after " + iInfiniteLoopBreak + " tries (" + (iInfiniteLoopBreak * 0.1) + " seconds).")
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "SUCCESS: Completed all tasks!")
						iInfiniteLoopBreak = 0
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	fStop = GetCurrentRealTime()
	DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "restoreEventHandlerData() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "[Ended restoreEventHandlerData Function]\n\n")
EndFunction
