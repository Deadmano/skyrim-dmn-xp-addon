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

ScriptName DMN_SXPAEventHandler Extends Quest Conditional

{Skyrim XP Addon - Event Handler script by Deadmano.
}
;==============================================
; Version: 1.0.0
;===============

Import Debug
Import Game
Import Utility
Import DMN_DeadmaniacFunctions
Import DMN_SXPAFunctions

GlobalVariable Property DMN_SXPAExperiencePoints Auto
GlobalVariable Property DMN_SXPAExperienceMin Auto
GlobalVariable Property DMN_SXPAExperienceMax Auto

Float[] Property iXPModifiers Auto
{The list of XP modifiers that affect the XP given per stat progression.}
String[] Property sSkills Auto
{The list of all player skills that we are able to spend XP on improving.}
String[] Property sStatNames Auto
{The list of all player stat names that we are tracking.}
String[] Property sNotificationMessages Auto
{The list of notification messages shown to the player when a stat is updated.}
GlobalVariable[] Property gStatValues Auto
{The list of all player stat values that we are tracking.}

Int Property iPassiveMonitoring Auto Conditional

Event OnInit()
	startTracking()
EndEvent

Function startTracking()
; Register to start tracking player game stat changes.
; Will not stop tracking unless the quest is stopped
; or if it is manually stopped with stopTracking().
	RegisterForTrackedStatsEvent()
EndFunction

Function stopTracking()
; Unregister all player game stat tracking.
	UnregisterForTrackedStatsEvent()
EndFunction

Int Function getRandomXPValue(Int iIndex)
	Int iMinXP = DMN_SXPAExperienceMin.GetValue() as Int
	Int iMaxXP = DMN_SXPAExperienceMax.GetValue() as Int
	Float fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (iXPModifiers[iIndex])
	Int iRandomXPValue = round(fRandomXPValue)
	Return iRandomXPValue
EndFunction

Function setRandomXPValue(Int iIndex, Int iUpdateCount = 0, Bool bIsUpdate = False)
	DMN_SXPALog("\n")
	DMN_SXPALog("Started setRAndomXPValue Function]")
	If (bIsUpdate || iUpdateCount > 1)
		DMN_SXPALog("An update was queued to assign XP values to existing stats!")
		DMN_SXPALog("Beginning update for: " + sStatNames[iIndex] + " (x" + iUpdateCount + ") now.")
		Int i = 0
		Int j = iUpdateCount
		Int iRandomXP
		While (i < iUpdateCount)
			Int k = getRandomXPValue(iIndex)
			iRandomXP += k
			DMN_SXPALog("Value " + (i+1) + " XP: " + k + ".")
			i += 1
		EndWhile
		Int iNewXP = DMN_SXPAExperiencePoints.GetValue() as Int + iRandomXP
		DMN_SXPALog("Previous XP: " + DMN_SXPAExperiencePoints.GetValue() as Int + ".")
		DMN_SXPAExperiencePoints.SetValue(iNewXP)
		DMN_SXPALog("XP Assigned: " + iRandomXP + ".")
		DMN_SXPALog("Current XP: " + DMN_SXPAExperiencePoints.GetValue() as Int + ".")
		If (bIsUpdate)
			Notification("Skyrim XP Addon: Previously detected \"" + sStatNames[iIndex] + "\" (x" + iUpdateCount + "). +" + iRandomXP + "XP combined!")
		Else
			Notification(sNotificationMessages[iIndex] + " (x" + iUpdateCount + ") +" + iRandomXP + "XP combined!")
		EndIf
	Else
		DMN_SXPALog("Assigning random XP for: " + sStatNames[iIndex] + " now.")
		Int iRandomXP = getRandomXPValue(iIndex)
		Int iNewXP = DMN_SXPAExperiencePoints.GetValue() as Int + iRandomXP
		DMN_SXPALog("Previous XP: " + DMN_SXPAExperiencePoints.GetValue() as Int + ".")
		DMN_SXPAExperiencePoints.SetValue(iNewXP)
		DMN_SXPALog("XP Assigned: " + iRandomXP + ".")
		DMN_SXPALog("Current XP: " + DMN_SXPAExperiencePoints.GetValue() as Int + ".")
		Notification(sNotificationMessages[iIndex] + " +" + iRandomXP + "XP!")
	EndIf
	DMN_SXPALog("[Ended setRAndomXPValue Function]\n")
EndFunction

Event OnTrackedStatsEvent(String sStatName, Int iStatValue)
	Int i = 0
	While (i < sStatNames.Length)
		Int iSavedStatValue = gStatValues[i].GetValue() as Int
		If (sStatName == sStatNames[i] && iStatValue > iSavedStatValue)
			gStatValues[i].SetValue(iStatValue)
			setRandomXPValue(i)
			;updatePlayerStats()
		EndIf
		i += 1
	EndWhile
EndEvent

Bool Function checkPlayerStats()
; Function checks all SXPA tracked stats, and if any differ from SXPA
; stored values then it will return True else it will return False.
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	Int i = 0
	While (i < sStatNames.Length)
		Int iSavedStatValue = gStatValues[i].GetValue() as Int
		Int iStatValue = QueryStat(sStatNames[i])
		If (iStatValue > iSavedStatValue)
			fStop = GetCurrentRealTime()
			DMN_SXPALog("checkPlayerStats() function took " + (fStop - fStart) + " seconds to complete.")
			Return True
		EndIf
		i += 1
	EndWhile
	Return False
EndFunction

Function updatePlayerStats(Bool bUpdateStats = False)
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	Int i = 0
	While (i < sStatNames.Length)
		Int iSavedStatValue = gStatValues[i].GetValue() as Int
		Int iStatValue = QueryStat(sStatNames[i])
		Int j = iStatValue - iSavedStatValue
		If (iStatValue > iSavedStatValue)
			gStatValues[i].SetValue(iStatValue)
			If (bUpdateStats)
				setRandomXPValue(i, j, True)
			ElseIf (j > 1)
				setRandomXPValue(i, j)
			Else
				setRandomXPValue(i)
			EndIf
		; Remove below when releasing final version.
			Notification(sStatNames[i] + " was not part of the OnTrackedStatsEvent Event!")
			DMN_SXPALog(sStatNames[i] + " was not part of the OnTrackedStatsEvent Event!\n")
		EndIf
		i += 1
	EndWhile
	fStop = GetCurrentRealTime()
	DMN_SXPALog("updatePlayerStats() function took " + (fStop - fStart) + " seconds to complete.")
EndFunction
