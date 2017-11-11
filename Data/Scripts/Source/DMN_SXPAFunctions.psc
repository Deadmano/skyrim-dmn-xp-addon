; Copyright (C) 2017 Phillip Stolić
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

ScriptName DMN_SXPAFunctions

{A custom collection of functions by Deadmano
to enhance the Skyrim XP Addons mod.}

Import Debug
Import Game
Import Math
Import Utility
Import DMN_DeadmaniacFunctions

String Function DMN_ModLogName() Global
	String logName = "DMN_SkyrimXPAddon"
	Return logName
EndFunction

Function DMN_SXPALog(String traceMessage) Global
	String logName = DMN_ModLogName()
	OpenUserLog(logName)
	TraceUser(logName, traceMessage)
EndFunction

Function giveConfigurator(Book configurator) Global
; Save the amount of configurators the player has in their inventory.
	Actor ref = GetPlayer()
	Int i = ref.GetItemCount(configurator)
	If (i == 0)
; If the player has none, add a single configurator to their inventory, silently.
		ref.AddItem(configurator, 1, True)
	ElseIf (i >= 1)
; Else remove every configurator in the player inventory and add one, silently.
		ref.RemoveItem(configurator, i, True)
		ref.AddItem(configurator, 1, True)
	EndIf
EndFunction

Function spendXP(GlobalVariable gTotalXP, String sSkill, Int iAmount) Global
	Int iCurrentXP = gTotalXP.GetValue() as Int
	If (iCurrentXP >= iAmount)
		AdvanceSkill(sSkill, iAmount)
		Notification("Skyrim XP Addon: Spent " + iAmount + "XP on the " + sSkill + " skill.")
		Int iNewXP = iCurrentXP - iAmount
		gTotalXP.SetValue(iNewXP)
	EndIf
EndFunction

Int Function getRandomXPValue(GlobalVariable gMinXP, GlobalVariable gMaxXP, Float[] fXPModifier, Int iIndex) Global
; Part 1: Getting a random XP value between the min and max XP variables.
	Int iMinXP = gMinXP.GetValue() as Int
	Int iMaxXP = gMaxXP.GetValue() as Int
	Float fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
	Trace("Min XP: " + iMinXP)
	Trace("Max XP: " + iMaxXP)
	Trace("Random XP (Min~Max * Modifier): " + fRandomXPValue)
; Part 2: Getting the total random XP value based on the player level and formula below.
	Int iPlayerLevel = GetPlayer().GetLevel()
	Float fPlayerLevelOffset = iPlayerLevel - 1
	Float fPlayerLevelOffsetSquared = pow(fPlayerLevelOffset, 2.0)
	Float fFinalRandomXPValue = (fPlayerLevelOffsetSquared + 25.00) / 100 * fXPModifier[iIndex] * fRandomXPValue
	Int iRandomXPValue = round(fFinalRandomXPValue)
	; String sPrettyXP = prettyPrintXP(fFinalRandomXPValue)
	; Notification("Skyrim XP Addon: Pretty XP Display - " + sPrettyXP)
	Trace("Player Level: " + iPlayerLevel)
	Trace("Player Level Offset: " + fPlayerLevelOffset)
	Trace("Power Of Value: " + fPlayerLevelOffsetSquared)
	Trace("Final Random XP (Float): " + fFinalRandomXPValue)
	; Trace("Pretty Print XP Value: " + sPrettyXP)
	Trace("Final Random XP (Int): " + iRandomXPValue + "\n\n")
	Return iRandomXPValue
EndFunction

Function setRandomXPValue(GlobalVariable gMinXP, GlobalVariable gMaxXP, GlobalVariable gXP, Float[] fXPModifier, Int iIndex, String[] sStatName, String[] sNotificationMessage, Int iUpdateCount = 0, Bool bIsUpdate = False) Global
	DMN_SXPALog("\n")
	DMN_SXPALog("Started setRAndomXPValue Function]")
	If (bIsUpdate || iUpdateCount > 1)
		DMN_SXPALog("An update was queued to assign XP values to existing stats!")
		DMN_SXPALog("Beginning update for: " + sStatName[iIndex] + " (x" + iUpdateCount + ") now.")
		Int i = 0
		Int j = iUpdateCount
		Int iRandomXP
		While (i < iUpdateCount)
			Int k = getRandomXPValue(gMinXP, gMaxXP, fXPModifier, iIndex)
			iRandomXP += k
			DMN_SXPALog("Value " + (i+1) + " XP: " + k + ".")
			i += 1
		EndWhile
		Int iNewXP = gXP.GetValue() as Int + iRandomXP
		DMN_SXPALog("Previous XP: " + gXP.GetValue() as Int + ".")
		gXP.SetValue(iNewXP)
		DMN_SXPALog("XP Assigned: " + iRandomXP + ".")
		DMN_SXPALog("Current XP: " + gXP.GetValue() as Int + ".")
		If (bIsUpdate)
			Notification("Skyrim XP Addon: Previously detected \"" + sStatName[iIndex] + "\" (x" + iUpdateCount + "). +" + iRandomXP + "XP combined!")
		Else
			Notification(sNotificationMessage[iIndex] + " (x" + iUpdateCount + ") +" + iRandomXP + "XP combined!")
		EndIf
	Else
		DMN_SXPALog("Assigning random XP for: " + sStatName[iIndex] + " now.")
		Int iRandomXP = getRandomXPValue(gMinXP, gMaxXP, fXPModifier, iIndex)
		Int iNewXP = gXP.GetValue() as Int + iRandomXP
		DMN_SXPALog("Previous XP: " + gXP.GetValue() as Int + ".")
		gXP.SetValue(iNewXP)
		DMN_SXPALog("XP Assigned: " + iRandomXP + ".")
		DMN_SXPALog("Current XP: " + gXP.GetValue() as Int + ".")
		Notification(sNotificationMessage[iIndex] + " +" + iRandomXP + "XP!")
	EndIf
	DMN_SXPALog("[Ended setRAndomXPValue Function]\n")
EndFunction

Function updatePlayerStats(GlobalVariable gMinXP, GlobalVariable gMaxXP, GlobalVariable[] gStatValue, GlobalVariable gXP, Float[] fXPModifier, String[] sStatName, String[] sNotificationMessage, Bool bUpdateStats = False) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	Int iIndex = 0
	While (iIndex < sStatName.Length)
		Int iSavedStatValue = gStatValue[iIndex].GetValue() as Int
		Int iStatValue = QueryStat(sStatName[iIndex])
		Int iUpdateCount = iStatValue - iSavedStatValue
		If (iStatValue > iSavedStatValue)
			gStatValue[iIndex].SetValue(iStatValue)
			If (bUpdateStats)
				setRandomXPValue(gMinXP, gMaxXP, gXP, fXPModifier, iIndex, sStatName, sNotificationMessage, iUpdateCount, True)
			ElseIf (iUpdateCount > 1)
				setRandomXPValue(gMinXP, gMaxXP, gXP, fXPModifier, iIndex, sStatName, sNotificationMessage, iUpdateCount)
			Else
				setRandomXPValue(gMinXP, gMaxXP, gXP, fXPModifier, iIndex, sStatName, sNotificationMessage)
			EndIf
		; Remove below when releasing final version.
			Notification(sStatName[iIndex] + " was not part of the OnTrackedStatsEvent Event!")
			DMN_SXPALog(sStatName[iIndex] + " was not part of the OnTrackedStatsEvent Event!\n")
		EndIf
		iIndex += 1
	EndWhile
	fStop = GetCurrentRealTime()
	DMN_SXPALog("updatePlayerStats() function took " + (fStop - fStart) + " seconds to complete.")
EndFunction

Bool Function checkPlayerStats(GlobalVariable[] gStatValue, String[] sStatName) Global
; Function checks all SXPA tracked stats, and if any differ from SXPA
; stored values then it will return True else it will return False.
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	Int iIndex = 0
	While (iIndex < sStatName.Length)
		Int iSavedStatValue = gStatValue[iIndex].GetValue() as Int
		Int iStatValue = QueryStat(sStatName[iIndex])
		If (iStatValue > iSavedStatValue)
			fStop = GetCurrentRealTime()
			DMN_SXPALog("checkPlayerStats() function took " + (fStop - fStart) + " seconds to complete.")
			Return True
		EndIf
		iIndex += 1
	EndWhile
	Return False
EndFunction

String Function prettyPrintXP(Float fXP) Global
	Float fMillionsDivider
	Int iMillions
	Float fThousandsDivider
	Float fThousandsSeparator
	Float fThousands
	Int iThousands
	Float fHundredsSeparator
	Float fHundreds
	Int iHundreds
	String sPrettyXP
	If (fXP < 1000)
		sPrettyXP = fXP
	ElseIf (fXP > 1000 && fXP < 1000000) ; Less Than 1,000,000 ; Example Input: 1563
		fThousandsDivider = fXP / 1000 ; Example Output: 1.563
		iThousands = Floor(fThousandsDivider) ; Example Output: 1
		fHundredsSeparator = fThousandsDivider - iThousands ; Example Output: 0.563
		fHundreds = fHundredsSeparator * 1000 ; Example Output: 563.000
		iHundreds = Floor(fHundreds) ; Example Output: 563
		sPrettyXP = iThousands + "," + iHundreds ; Example Output: 1,563
	ElseIf (fXP < 1000000000) ; Less Than 1,000,000,000 ; Example Input: 6852365
		fMillionsDivider = fXP / 1000000 ; Example Output: 6.852365
		iMillions = Floor(fMillionsDivider) ; Example Output: 6
		fThousandsSeparator = fMillionsDivider - iMillions ; Example Output 0.852365
		fThousands = fThousandsSeparator * 1000 ; Example Output: 852.365
		iThousands = Floor(fThousands) ; Example Output: 852
		fHundredsSeparator = fThousands - iThousands ; Example Output: 0.365
		fHundreds = fHundredsSeparator * 1000 ; Example Output: 365.000
		iHundreds = Floor(fHundreds) ; Example Output: 365
		sPrettyXP = iMillions + "," + iThousands + "," + iHundreds ; Example Output: 6,852,365
	EndIf
	Trace("fXP Value: " + fXP)
	Trace("fMillionsDivider Value: " + fMillionsDivider)
	Trace("fThousandsDivider Value: " + fThousandsDivider)
	Trace("fThousandsSeparator Value: " + fThousandsSeparator)
	Trace("fHundredsSeparator Value: " + fHundredsSeparator)
	Trace("fThousands Value: " + fThousands)
	Trace("fHundreds Value: " + fHundreds)
	Trace("iMillions Value: " + iMillions)
	Trace("iHundreds Value: " + iHundreds)
	Trace("iThousands Value: " + iThousands)
	Trace("sPrettyXP Value: " + sPrettyXP + "\n\n")
	Return sPrettyXP
EndFunction

;  2,147,483,647 max integer size


; 1671064 = 1,671,064
; 1671064 * 

; 1563 / 1000 = 1.563

;(1 - Player Level) ^2 + 25 / 100 * Event Multiplier * Random XP Value


