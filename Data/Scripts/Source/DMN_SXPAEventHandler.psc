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
Import DMN_DeadmaniacFunctionsSXPA
Import DMN_SXPAFunctions

GlobalVariable Property DMN_SXPAExperiencePoints Auto
GlobalVariable Property DMN_SXPAExperienceMin Auto
GlobalVariable Property DMN_SXPAExperienceMax Auto

Float[] Property fXPModifier Auto
{The list of XP modifiers that affect the XP given per stat progression.}
String[] Property sSkill Auto
{The list of all player skills that we are able to spend XP on improving.}
String[] Property sStatName Auto
{The list of all player stat names that we are tracking.}
String[] Property sNotificationMessage Auto
{The list of notification messages shown to the player when a stat is updated.}
GlobalVariable[] Property gStatValue Auto
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

Event OnTrackedStatsEvent(String sStatName, Int iStatValue)
	Int iIndex = 0
	While (iIndex < sStatName.Length)
		Int iSavedStatValue = gStatValue[iIndex].GetValue() as Int
		If (sStatName == sStatName[iIndex] && iStatValue > iSavedStatValue)
			gStatValue[iIndex].SetValue(iStatValue)
			If (checkPlayerStats(gStatValue, sStatName))
				updatePlayerStats(DMN_SXPAExperienceMin, DMN_SXPAExperienceMax, gStatValue, DMN_SXPAExperiencePoints, fXPModifier, sStatName, sNotificationMessage)
			EndIf
		EndIf
		iIndex += 1
	EndWhile
EndEvent
