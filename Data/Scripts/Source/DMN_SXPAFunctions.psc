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
Import DMN_DeadmaniacFunctionsSXPA

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
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog("\n")
	DMN_SXPALog("[Started getRandomXPValue Function]")
; Part 1: Getting a random XP value between the min and max XP variables.
	Int iMinXP = gMinXP.GetValue() as Int
	Int iMaxXP = gMaxXP.GetValue() as Int
	Float fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
	DMN_SXPALog("Min XP: " + iMinXP)
	DMN_SXPALog("Max XP: " + iMaxXP)
	DMN_SXPALog("Random XP (Min~Max * Modifier): " + fRandomXPValue)
; Part 2: Getting the total random XP value based on the player level and formula below.
	Int iPlayerLevel = GetPlayer().GetLevel()
	Float fPlayerLevelOffset = iPlayerLevel - 1
	Float fPlayerLevelOffsetSquared = pow(fPlayerLevelOffset, 2.0)
	Float fFinalRandomXPValue = (fPlayerLevelOffsetSquared + 25.00) / 100 * fRandomXPValue
	Int iRandomXPValue = round(fFinalRandomXPValue)
	; String sPrettyXP = prettyPrintXP(fFinalRandomXPValue)
	; Notification("Skyrim XP Addon: Pretty XP Display - " + sPrettyXP)
	DMN_SXPALog("Player Level: " + iPlayerLevel)
	DMN_SXPALog("Player Level Offset: " + fPlayerLevelOffset)
	DMN_SXPALog("Power Of Value: " + fPlayerLevelOffsetSquared)
	DMN_SXPALog("Final Random XP (Float): " + fFinalRandomXPValue)
	; DMN_SXPALog("Pretty Print XP Value: " + sPrettyXP)
	DMN_SXPALog("Final Random XP (Int): " + iRandomXPValue + "\n")
	fStop = GetCurrentRealTime()
	DMN_SXPALog("getRandomXPValue() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog("[Ended getRandomXPValue Function]\n\n")
	Return iRandomXPValue
EndFunction

Function setRandomXPValue(GlobalVariable gMinXP, GlobalVariable gMaxXP, GlobalVariable gXP, Float[] fXPModifier, Int iIndex, String[] sStatName, String[] sNotificationMessage, Int iUpdateCount = 0, Bool bIsUpdate = False) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog("\n")
	DMN_SXPALog("[Started setRandomXPValue Function]\n")
	If (bIsUpdate || iUpdateCount > 1)
		DMN_SXPALog("An update was queued to assign XP values to existing stats!")
		DMN_SXPALog("Beginning update for: " + sStatName[iIndex] + " (x" + iUpdateCount + ") now.")
		Int i = 0
		Int j = iUpdateCount
		Int iRandomXP
		While (i < iUpdateCount)
			Int k = getRandomXPValue(gMinXP, gMaxXP, fXPModifier, iIndex)
			iRandomXP += k
			DMN_SXPALog(sStatName[iIndex] + " " + "(" + (i+1) + "/" + iUpdateCount + ")" + " XP: " + k + ".")
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
	fStop = GetCurrentRealTime()
	DMN_SXPALog("setRandomXPValue() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog("[Ended setRandomXPValue Function]\n\n")
EndFunction

Function rewardExistingXPActivities(GlobalVariable gMinXP, GlobalVariable gMaxXP, GlobalVariable[] gStatValue, GlobalVariable gXP, Float[] fXPModifier, String[] sStatName) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog("\n")
	DMN_SXPALog("[Started rewardExistingXPActivities Function]\n")
; Part 1: Getting the player level, calculating the offset and then squaring it.
	Int iPlayerLevel = GetPlayer().GetLevel()
	Float fPlayerLevelOffset = iPlayerLevel - 1
	Float fPlayerLevelOffsetSquared = pow(fPlayerLevelOffset, 2.0)
	DMN_SXPALog("Player Level: " + iPlayerLevel)
	DMN_SXPALog("Player Level Offset: " + fPlayerLevelOffset)
	DMN_SXPALog("Power Of Value: " + fPlayerLevelOffsetSquared + "\n\n")
; Part 2: Looping through each XP activity and seeing if any of the values are greater than our stored values, if they are, update them.
	DMN_SXPALog("An update was queued to assign XP values to existing stats!\n\n")
	Int iIndex = 0
	While (iIndex < sStatName.Length)
		Int iSavedStatValue = gStatValue[iIndex].GetValue() as Int
		Int iStatValue = QueryStat(sStatName[iIndex])
		Int iUpdateCount = iStatValue - iSavedStatValue
		If (iStatValue > iSavedStatValue)
			gStatValue[iIndex].SetValue(iStatValue)
		; Part 3: Getting a random XP value between the min and max XP variables and multiplying it by the XP activity modifier.
			Int iMinXP = gMinXP.GetValue() as Int
			Int iMaxXP = gMaxXP.GetValue() as Int
			Float fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
			DMN_SXPALog("Beginning update for: " + sStatName[iIndex] + " (x" + iUpdateCount + ") now.")
			DMN_SXPALog("Min XP: " + iMinXP)
			DMN_SXPALog("Max XP: " + iMaxXP)
			DMN_SXPALog("Random XP (Min~Max * Modifier): " + fRandomXPValue)
		; Part 4: Estimating the amount of times the XP activity was performed at previous levels.
			Float fActivityCount10Percent = iUpdateCount * 0.10 ; Example Input: 250 = 250 * 0.15 = 37.5. 15%.
			Float fActivityCount20Percent = iUpdateCount * 0.20 ; Example Input: 250 = 250 * 0.25 = 62.5. 25%.
			Float fActivityCount70Percent = iUpdateCount * 0.70 ; Example Input: 250 = 250 * 0.60 = 150. 60%.
		; Part 5: Calculating the amount of XP earned for the XP activity at the level thresholds.
			Float fRandomXPValueFull = ((fPlayerLevelOffsetSquared) + 25.00) / 100 * fRandomXPValue * fActivityCount10Percent
			Float fRandomXPValueHalf = ((fPlayerLevelOffsetSquared / 4) + 25.00) / 100 * fRandomXPValue * fActivityCount20Percent
			Float fRandomXPValueThird = ((fPlayerLevelOffsetSquared / 9) + 25.00) / 100 * fRandomXPValue * fActivityCount70Percent
			DMN_SXPALog("Amount of " + sStatName[iIndex] + " estimated at level " + iPlayerLevel + ": " + fActivityCount10Percent + ".")
			DMN_SXPALog("Amount of XP gained for " + sStatName[iIndex] + "(x" + iUpdateCount + ")" + " at level " + iPlayerLevel + ": " + fRandomXPValueFull + ".")
			DMN_SXPALog("Amount of " + sStatName[iIndex] + " estimated at level " + iPlayerLevel / 2 + ": " + fActivityCount20Percent + ".")
			DMN_SXPALog("Amount of XP gained for " + sStatName[iIndex] + "(x" + iUpdateCount + ")" + " at level " + iPlayerLevel / 2 + ": " + fRandomXPValueHalf + ".")
			DMN_SXPALog("Amount of " + sStatName[iIndex] + " estimated at level " + iPlayerLevel / 3 + ": " + fActivityCount70Percent + ".")
			DMN_SXPALog("Amount of XP gained for " + sStatName[iIndex] + "(x" + iUpdateCount + ")" + " at level " + iPlayerLevel / 3 + ": " + fRandomXPValueThird + ".")
		; Part 6: Calculating the total amount of XP earned for the XP activity.
			Float fFinalRandomXPValue = fRandomXPValueFull + fRandomXPValueHalf + fRandomXPValueThird
			Int iRandomXPValue = round(fFinalRandomXPValue)
			DMN_SXPALog("Total amount of " + sStatName[iIndex] + ":" + " " + iUpdateCount + ".")
			DMN_SXPALog("Total amount of XP gained for " + sStatName[iIndex] + ":" + " " + iRandomXPValue + ".")
		; Part 6: Adding the total amount of XP earned for the XP activity to the total experience points.
			Int iNewXP = gXP.GetValue() as Int + iRandomXPValue
			DMN_SXPALog("Previous XP: " + gXP.GetValue() as Int + ".")
			gXP.SetValue(iNewXP)
			DMN_SXPALog("XP Assigned: " + iRandomXPValue + ".")
			DMN_SXPALog("Current XP: " + gXP.GetValue() as Int + ".\n\n")
			If (iUpdateCount > 1)
				Notification("Skyrim XP Addon: Previously detected \"" + sStatName[iIndex] + "\" (x" + iUpdateCount + "). +" + iRandomXPValue + "XP combined!")
			Else
				Notification("Skyrim XP Addon: Previously detected \"" + sStatName[iIndex] + "\" (x" + iUpdateCount + "). +" + iRandomXPValue + "XP!")
			EndIf
		EndIf
		iIndex += 1
	EndWhile
	fStop = GetCurrentRealTime()
	DMN_SXPALog("rewardExistingXPActivities() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog("[Ended rewardExistingXPActivities Function]\n\n")
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
