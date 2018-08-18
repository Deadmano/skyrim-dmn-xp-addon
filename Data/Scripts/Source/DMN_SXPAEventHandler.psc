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

GlobalVariable Property DMN_SXPADebug Auto
{Set to the debug global variable.}
GlobalVariable Property DMN_SXPAExperiencePoints Auto
GlobalVariable Property DMN_SXPAExperienceMin Auto
GlobalVariable Property DMN_SXPAExperienceMax Auto

; The following 4 variables hold the used
; (true)/unused (false) state of the skill slots.
Bool Property bTaggedSkillSlot01Used Auto Conditional
Bool Property bTaggedSkillSlot02Used Auto Conditional
Bool Property bTaggedSkillSlot03Used Auto Conditional
Bool Property bTaggedSkillSlot04Used Auto Conditional
; The skill cost formula being used. 1 = exponential, 0 = linear.
Bool Property bUseExponentialSkillCost Auto Conditional
; The XP gain formula being used. 1 = exponential, 0 = linear.
Bool Property bUseExponentialXPGain Auto Conditional
; The type of configurator being used. 1 = spell, 0 = book.
Int Property iConfiguratorType Auto Conditional
; When on, monitoring becomes passive (event based). 1 = on, 0 = off.
Int Property iPassiveMonitoring Auto Conditional
; The following 4 variables hold the skill name
; index from 1 (Archery) to 18 (Speech).
Int Property iTaggedSkillSlot01 Auto Conditional
Int Property iTaggedSkillSlot02 Auto Conditional
Int Property iTaggedSkillSlot03 Auto Conditional
Int Property iTaggedSkillSlot04 Auto Conditional
Bool[] Property bXPActivityState Auto
{Affects whether or not the XP activity will be tracked and give XP or not.}
Float[] Property fSkillMultiplier Auto
{The list of skill multipliers that affect the XP cost per skill level.}
Float[] Property fTaggedSkillsPriority Auto
{The list of priorities for player-tagged skills for automatic XP spending.}
Float[] Property fXPMultiplier Auto
{The list of XP multipliers that affect the XP given per stat progression.}
Int[] Property iModCompatibility Auto
{The list that handles the state of mod compatability and support.}
Int[] Property iSkillXP Auto
{The list of converted XP values for each stat.}
Int[] Property iSkillXPSpent Auto
{The list of total generic XP spent on each skill.}
Int[] Property iSkillXPSpentEffective Auto
{The list of total effective skill XP spent on each skill.}
Int[] Property iTrackedStatCount Auto
{The list of all player stat values that we are tracking.}
String[] Property sSkillName Auto
{The list of all player skills that we are able to spend XP on improving.}
String[] Property sStatName Auto
{The list of all player stat names that we are tracking.}
String[] Property sNotificationMessage Auto
{The list of notification messages shown to the player when a stat is updated.}
String[] Property sTaggedSkills Auto Conditional
{The list of skills the player has tagged for automatic XP spending.}

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
		If (sStatName == sStatName[iIndex] && iStatValue > iTrackedStatCount[iIndex])
			iTrackedStatCount[iIndex] = iStatValue
			If (checkPlayerStats(DMN_SXPADebug, bXPActivityState, iTrackedStatCount, sStatName))
				updatePlayerStats(DMN_SXPADebug, DMN_SXPAExperienceMin, DMN_SXPAExperienceMax, DMN_SXPAExperiencePoints, bXPActivityState, fXPMultiplier, iTrackedStatCount, sStatName, sNotificationMessage, bUseExponentialXPGain)
			EndIf
		EndIf
		iIndex += 1
	EndWhile
EndEvent
