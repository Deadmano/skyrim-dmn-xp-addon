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

Function DMN_SXPALog(GlobalVariable gDebug, String traceMessage) Global
	If (gDebug.GetValue() == 1)
		String logName = DMN_ModLogName()
		OpenUserLog(logName)
		TraceUser(logName, traceMessage)
	EndIf
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

Function spendXP(GlobalVariable gDebug, GlobalVariable gTotalXP, Float[] fSkillModifier, Int[] iSkillXP, Int[] iSkillXPSpent, Int[] iSkillXPSpentEffective, String[] sSkillName, String sSkill, Int iAmount) Global
	DMN_SXPALog(gDebug, "[Started spendXP Function]")
	Int iCurrentXP = gTotalXP.GetValue() as Int
	Float fSkillLevel = GetPlayer().GetActorValue(sSkill)
	Float fSkillLevelOffsetPOW = pow(fSkillLevel, 1.95)
	Int iSkillImproveOffset
; Map out skill names to match with the stored sSkillName array values so that the
; iIndex variable will correctly find a match and provide an index to go on.
	If (sSkill == "Alchemy")
		iSkillImproveOffset = 65
	ElseIf (sSkill == "Enchanting")
		iSkillImproveOffset = 170
	ElseIf (sSkill == "HeavyArmor")
		sSkill = "Heavy Armor"
	ElseIf (sSkill == "LightArmor")
		sSkill = "Light Armor"
	ElseIf (sSkill == "Lockpicking")
		iSkillImproveOffset = 300
	ElseIf (sSkill == "Marksman")
		sSkill = "Archery"
	ElseIf (sSkill == "OneHanded")
		sSkill = "One-Handed"
	ElseIf (sSkill == "Pickpocket")
		iSkillImproveOffset = 250
	ElseIf (sSkill == "Smithing")
		iSkillImproveOffset = 300
	ElseIf (sSkill == "Sneak")
		iSkillImproveOffset = 120
	ElseIf (sSkill == "Speechcraft")
		sSkill = "Speech"
	ElseIf (sSkill == "TwoHanded")
		sSkill = "Two-Handed"
	EndIf
	Int iIndex = sSkillName.Find(sSkill) as Int
	Float fEffectiveXP = (iAmount * fSkillModifier[iIndex]) / 2
	Int iEffectiveXP = round(fEffectiveXP)
		;Float fSkillCost = fSkillModifier[iIndex] * 2 * fSkillLevelOffsetPOW + iSkillImproveOffset
		Float fSkillCost = fSkillModifier[iIndex] * fSkillLevelOffsetPOW + iSkillImproveOffset
		Int iSkillCost = round(fSkillCost)
		iSkillXP[iIndex] = iSkillXP[iIndex] + iEffectiveXP
		iSkillXPSpent[iIndex] = iSkillXPSpent[iIndex] + iAmount
		iSkillXPSpentEffective[iIndex] = iSkillXPSpentEffective[iIndex] + iEffectiveXP
	If (iSkillXP[iIndex] >= iSkillCost)
			iSkillXP[iIndex] = iSkillXP[iIndex] - iSkillCost
	; Revert the earlier skill name changes so that specific skill names with spaces
	; correctly parse into the engine for levelling purposes.
		If (sSkill == "Light Armor")
			sSkill = "LightArmor"
		ElseIf (sSkill == "Heavy Armor")
			sSkill = "HeavyArmor"
		ElseIf (sSkill == "Archery")
			sSkill = "Marksman"
		ElseIf (sSkill == "One-Handed")
			sSkill = "OneHanded"
		ElseIf (sSkill == "Speech")
			sSkill = "Speechcraft"
		ElseIf (sSkill == "Two-Handed")
			sSkill = "TwoHanded"
		EndIf
	; Add +1 to the skill level the player chose to spend XP on, provided they have enough XP.
		IncrementSkillBy(sSkill, 1)
		Notification("Skyrim XP Addon: " + sSkill + " reached enough experience points to level up! (" + (fSkillLevel) + " > " + (fSkillLevel + 1) + ")")
	EndIf
		Notification("Skyrim XP Addon: Converted " + iAmount + " generic XP to " + sSkill + " specific XP. (" + iEffectiveXP + "XP)")
		DMN_SXPALog(gDebug, "Chosen Skill: " + sSkill)
		DMN_SXPALog(gDebug, "Skill Index: " + iIndex)
		DMN_SXPALog(gDebug, "Skill Level: " + fSkillLevel)
		DMN_SXPALog(gDebug, "Current Generic XP: " + iCurrentXP)
		DMN_SXPALog(gDebug, "Generic XP Invested: " + iAmount)
		DMN_SXPALog(gDebug, "Skill Modifier: " + fSkillModifier[iIndex])
		DMN_SXPALog(gDebug, "Converted To Skill-Specific XP: " + iEffectiveXP)
		DMN_SXPALog(gDebug, "XP Cost To Level " + (fSkillLevel+1) + ": " + fSkillCost)
		DMN_SXPALog(gDebug, "Remaining XP To Level " + (fSkillLevel+1) + ": " + (fSkillCost - iSkillXP[iIndex]))
		Int iNewXP = iCurrentXP - iAmount
		gTotalXP.SetValue(iNewXP)
		DMN_SXPALog(gDebug, "New Generic XP: " + iNewXP)
		DMN_SXPALog(gDebug, "[Ended spendXP Function]\n\n")
EndFunction

Int Function getRandomXPValue(GlobalVariable gDebug, GlobalVariable gMinXP, GlobalVariable gMaxXP, Float[] fXPModifier, Int iIndex) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started getRandomXPValue Function]")
; Part 1: Getting a random XP value between the min and max XP variables.
	Int iMinXP = gMinXP.GetValue() as Int
	Int iMaxXP = gMaxXP.GetValue() as Int
	Float fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
	DMN_SXPALog(gDebug, "Min XP: " + iMinXP)
	DMN_SXPALog(gDebug, "Max XP: " + iMaxXP)
	DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
; Part 2: Getting the total random XP value based on the player level and formula below.
	Int iPlayerLevel = GetPlayer().GetLevel()
	Float fPlayerLevelOffset = iPlayerLevel - 1
	Float fPlayerLevelOffsetSquared = pow(fPlayerLevelOffset, 2.0)
	Float fFinalRandomXPValue = (fPlayerLevelOffsetSquared + 25.00) / 100 * fRandomXPValue
	Int iRandomXPValue = round(fFinalRandomXPValue)
	; String sPrettyXP = prettyPrintXP(fFinalRandomXPValue)
	; Notification("Skyrim XP Addon: Pretty XP Display - " + sPrettyXP)
	DMN_SXPALog(gDebug, "Player Level: " + iPlayerLevel)
	DMN_SXPALog(gDebug, "Player Level Offset: " + fPlayerLevelOffset)
	DMN_SXPALog(gDebug, "Power Of Value: " + fPlayerLevelOffsetSquared)
	DMN_SXPALog(gDebug, "Final Random XP (Float): " + fFinalRandomXPValue)
	; DMN_SXPALog(gDebug, "Pretty Print XP Value: " + sPrettyXP)
	DMN_SXPALog(gDebug, "Final Random XP (Int): " + iRandomXPValue + "\n")
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "getRandomXPValue() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended getRandomXPValue Function]")
	Return iRandomXPValue
EndFunction

Function setRandomXPValue(GlobalVariable gDebug, GlobalVariable gMinXP, GlobalVariable gMaxXP, GlobalVariable gXP, Float[] fXPModifier, Int iIndex, String[] sStatName, String[] sNotificationMessage, Int iUpdateCount = 0, Bool bIsUpdate = False) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started setRandomXPValue Function]")
	If (bIsUpdate || iUpdateCount > 1)
		If (iUpdateCount > 500)
			Notification("Skyrim XP Addon: Allocating XP for existing " + sStatName[iIndex] + " (x" + iUpdateCount + ") now. This will be a while...")
		ElseIf (iUpdateCount > 50)
			Notification("Skyrim XP Addon: Allocating XP for existing " + sStatName[iIndex] + " (x" + iUpdateCount + ") now. This may take a while...")
		ElseIf (iUpdateCount > 10)
			Notification("Skyrim XP Addon: Allocating XP for existing " + sStatName[iIndex] + " (x" + iUpdateCount + ") now.")
		EndIf
		DMN_SXPALog(gDebug, "An update was queued to assign XP values to existing stats!")
		DMN_SXPALog(gDebug, "Beginning update for: " + sStatName[iIndex] + " (x" + iUpdateCount + ") now.")
		Float fFunctionRunDuration
		Int i = 0
		Int j = iUpdateCount
		Int iFunctionRuns
		Int iRandomXP
		While (i < iUpdateCount)
			Float fRunStart = GetCurrentRealTime()
			Int k = getRandomXPValue(gDebug, gMinXP, gMaxXP, fXPModifier, iIndex)
			iRandomXP += k
			DMN_SXPALog(gDebug, sStatName[iIndex] + " " + "(" + (i+1) + "/" + iUpdateCount + ")" + " XP: " + k + ".")
			i += 1
			Float fRunStop = GetCurrentRealTime()
			fFunctionRunDuration = fFunctionRunDuration + (fRunStop - fRunStart)
			iFunctionRuns += 1
			If (iFunctionRuns == 10)
				Float fAverageFunctionRunDuration = fFunctionRunDuration / 10
				estimateScriptDuration(gDebug, fAverageFunctionRunDuration, iUpdateCount)
			EndIf
		EndWhile
		Int iNewXP = gXP.GetValue() as Int + iRandomXP
		DMN_SXPALog(gDebug, "Previous XP: " + gXP.GetValue() as Int + ".")
		gXP.SetValue(iNewXP)
		DMN_SXPALog(gDebug, "XP Assigned: " + iRandomXP + ".")
		DMN_SXPALog(gDebug, "Current XP: " + gXP.GetValue() as Int + ".")
		If (bIsUpdate)
			Notification("Skyrim XP Addon: Previously detected \"" + sStatName[iIndex] + "\" (x" + iUpdateCount + "). +" + iRandomXP + "XP combined!")
		Else
			Notification(sNotificationMessage[iIndex] + " (x" + iUpdateCount + ") +" + iRandomXP + "XP combined!")
		EndIf
	Else
		DMN_SXPALog(gDebug, "Assigning random XP for: " + sStatName[iIndex] + " now.")
		Int iRandomXP = getRandomXPValue(gDebug, gMinXP, gMaxXP, fXPModifier, iIndex)
		Int iNewXP = gXP.GetValue() as Int + iRandomXP
		DMN_SXPALog(gDebug, "Previous XP: " + gXP.GetValue() as Int + ".")
		gXP.SetValue(iNewXP)
		DMN_SXPALog(gDebug, "XP Assigned: " + iRandomXP + ".")
		DMN_SXPALog(gDebug, "Current XP: " + gXP.GetValue() as Int + ".")
		Notification(sNotificationMessage[iIndex] + " +" + iRandomXP + "XP!")
	EndIf
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "setRandomXPValue() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended setRandomXPValue Function]\n\n")
EndFunction

Function rewardExistingXPActivities(GlobalVariable gDebug, GlobalVariable gMinXP, GlobalVariable gMaxXP, GlobalVariable gXP, Bool[] bXPActivityState, Float[] fXPModifier, Int[] iTrackedStatCount, String[] sStatName) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started rewardExistingXPActivities Function]")
; Part 1: Getting a random XP value between the min and max XP variables and multiplying it by the XP activity modifier.
	Int iMinXP = gMinXP.GetValue() as Int
	Int iMaxXP = gMaxXP.GetValue() as Int
	Float fRandomXPValue
	DMN_SXPALog(gDebug, "Min XP: " + iMinXP)
	DMN_SXPALog(gDebug, "Max XP: " + iMaxXP)
; Part 2: Getting the player level, calculating the offset and then squaring it.
	Int iPlayerLevel = GetPlayer().GetLevel()
	Float fPlayerLevelOffset = iPlayerLevel - 1
	Float fPlayerLevelOffsetSquared = pow(fPlayerLevelOffset, 2.0)
	DMN_SXPALog(gDebug, "Player Level: " + iPlayerLevel)
	DMN_SXPALog(gDebug, "Player Level Offset: " + fPlayerLevelOffset)
	DMN_SXPALog(gDebug, "Power Of Value: " + fPlayerLevelOffsetSquared + "\n\n")
; Part 3: Looping through each XP activity and seeing if any of the values are greater than our stored values, if they are, update them.
	DMN_SXPALog(gDebug, "An update was queued to assign XP values to existing stats!\n\n")
	Int iIndex = 0
	Int iTotalXPAllocated
	Int iTotalUpdateCount
	While (iIndex < sStatName.Length)
		Float fRandomXPValueFull
		Float fRandomXPValueHalf
		Float fRandomXPValueThird
		Float fRandomXPValueFourth
		Float fRandomXPValueFifth
		Float fRandomXPValueSixth
		Float fRandomXPValueFullTotal
		Float fRandomXPValueHalfTotal
		Float fRandomXPValueThirdTotal
		Float fRandomXPValueFourthTotal
		Float fRandomXPValueFifthTotal
		Float fRandomXPValueSixthTotal
		Int i = 0
		If (bXPActivityState[iIndex])
			Int iStatValue = QueryStat(sStatName[iIndex])
			Int iUpdateCount = iStatValue - iTrackedStatCount[iIndex]
			If (iStatValue > iTrackedStatCount[iIndex])
				iTrackedStatCount[iIndex] = iStatValue
				DMN_SXPALog(gDebug, "Beginning update for: " + sStatName[iIndex] + " (x" + iUpdateCount + ") now.")
			; Part 4: Estimating the amount of times the XP activity was performed at previous levels.
				Float fActivityCount1Percent = iUpdateCount * 0.01 ; Example Input: 250 = 250 * 0.01 = 2.5. 1%.
				Float fActivityCount4Percent = iUpdateCount * 0.04 ; Example Input: 250 = 250 * 0.04 = 10. 4%.
				Float fActivityCount5Percent = iUpdateCount * 0.05 ; Example Input: 250 = 250 * 0.05 = 12.5. 5%.
				Float fActivityCount10Percent = iUpdateCount * 0.10 ; Example Input: 250 = 250 * 0.10 = 25. 10%.
				Float fActivityCount15Percent = iUpdateCount * 0.15 ; Example Input: 250 = 250 * 0.15 = 37.5. 15%.
				Float fActivityCount65Percent = iUpdateCount * 0.65 ; Example Input: 250 = 250 * 0.65 = 162.5. 65%.
			; Part 5: Calculating the amount of XP earned for the XP activity at the level thresholds.
				Int iActivityCount1Percent = Floor(fActivityCount1Percent)
				Int iActivityCount4Percent = Floor(fActivityCount4Percent)
				Int iActivityCount5Percent = Floor(fActivityCount5Percent)
				Int iActivityCount10Percent = Floor(fActivityCount10Percent)
				Int iActivityCount15Percent = Floor(fActivityCount15Percent)
				Int iActivityCount65Percent = Floor(fActivityCount65Percent)
				Float fActivityCount1PercentRemainder = fActivityCount1Percent - iActivityCount1Percent
				Float fActivityCount4PercentRemainder = fActivityCount4Percent - iActivityCount4Percent
				Float fActivityCount5PercentRemainder = fActivityCount5Percent - iActivityCount5Percent
				Float fActivityCount10PercentRemainder = fActivityCount10Percent - iActivityCount10Percent
				Float fActivityCount15PercentRemainder = fActivityCount15Percent - iActivityCount15Percent
				Float fActivityCount65PercentRemainder = fActivityCount65Percent - iActivityCount65Percent
			;-------------------
			; fRandomXPValueFull
			;-------------------
				DMN_SXPALog(gDebug, "Amount of " + sStatName[iIndex] + " estimated at level " + iPlayerLevel + ": " + fActivityCount1Percent + ".")
				If (iActivityCount1Percent < 1)
					fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
					DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
					Float k = ((fPlayerLevelOffsetSquared) + 25.00) / 100 * fRandomXPValue * fActivityCount1Percent ; Squared.
					fRandomXPValueFull += k
					DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount1Percent + "/" + fActivityCount1Percent + ") XP: " + k + ".")
					k = 0
				Else
					While (i < iActivityCount1Percent)
						fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
						DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
						Float k = ((fPlayerLevelOffsetSquared) + 25.00) / 100 * fRandomXPValue ; Squared.
						fRandomXPValueFull += k
						DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + (i+1) + "/" + iActivityCount1Percent + ") XP: " + k + ".")
						k = 0
						i += 1
					EndWhile
					fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
					DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
					Float k = ((fPlayerLevelOffsetSquared) + 25.00) / 100 * fRandomXPValue * fActivityCount1PercentRemainder ; Squared.
					fRandomXPValueFull += k
					DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount1PercentRemainder + "/" + fActivityCount1PercentRemainder + ") XP: " + k + ".")
					k = 0
					i = 0
				EndIf
				DMN_SXPALog(gDebug, "Total amount of XP gained for " + sStatName[iIndex] + " at level " +  iPlayerLevel + ": " + fRandomXPValueFull + ".\n\n")
				fRandomXPValueFullTotal += fRandomXPValueFull
				fRandomXPValueFull = 0
			;-------------------
			; fRandomXPValueHalf
			;-------------------
				DMN_SXPALog(gDebug, "Amount of " + sStatName[iIndex] + " estimated at level " + iPlayerLevel / 2 + ": " + fActivityCount4Percent + ".")
				If (iActivityCount4Percent < 1)
					fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
					DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
					Float k = ((fPlayerLevelOffsetSquared /4) + 25.00) / 100 * fRandomXPValue * fActivityCount4Percent ; 2 Squared.
					fRandomXPValueHalf += k
					DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount4Percent + "/" + fActivityCount4Percent + ") XP: " + k + ".")
					k = 0
				Else
					While (i < iActivityCount4Percent)
						fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
						DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
						Float k = ((fPlayerLevelOffsetSquared / 4) + 25.00) / 100 * fRandomXPValue ; 2 Squared.
						fRandomXPValueHalf += k
						DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + (i+1) + "/" + iActivityCount4Percent + ") XP: " + k + ".")
						k = 0
						i += 1
					EndWhile
					fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
					DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
					Float k = ((fPlayerLevelOffsetSquared / 4) + 25.00) / 100 * fRandomXPValue * fActivityCount4PercentRemainder ; 2 Squared.
					fRandomXPValueHalf += k
					DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount4PercentRemainder + "/" + fActivityCount4PercentRemainder + ") XP: " + k + ".")
					k = 0
					i = 0
				EndIf
				DMN_SXPALog(gDebug, "Total amount of XP gained for " + sStatName[iIndex] + " at level " +  iPlayerLevel / 2 + ": " + fRandomXPValueHalf + ".\n\n")
				fRandomXPValueHalfTotal += fRandomXPValueHalf
				fRandomXPValueHalf = 0
			;--------------------
			; fRandomXPValueThird
			;--------------------
				DMN_SXPALog(gDebug, "Amount of " + sStatName[iIndex] + " estimated at level " + iPlayerLevel / 3 + ": " + fActivityCount5Percent + ".")
				If (iActivityCount5Percent < 1)
					fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
					DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
					Float k = ((fPlayerLevelOffsetSquared / 9) + 25.00) / 100 * fRandomXPValue * fActivityCount5Percent ; 3 Squared.
					fRandomXPValueThird += k
					DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount5Percent + "/" + fActivityCount5Percent + ") XP: " + k + ".")
					k = 0
				Else
					While (i < iActivityCount5Percent)
						fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
						DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
						Float k = ((fPlayerLevelOffsetSquared / 9) + 25.00) / 100 * fRandomXPValue ; 3 Squared.
						fRandomXPValueThird += k
						DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + (i+1) + "/" + iActivityCount5Percent + ") XP: " + k + ".")
						k = 0
						i += 1
					EndWhile
					fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
					DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
					Float k = ((fPlayerLevelOffsetSquared / 9) + 25.00) / 100 * fRandomXPValue * fActivityCount5PercentRemainder ; 3 Squared.
					fRandomXPValueThird += k
					DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount5PercentRemainder + "/" + fActivityCount5PercentRemainder + ") XP: " + k + ".")
					k = 0
					i = 0
				EndIf
				DMN_SXPALog(gDebug, "Total amount of XP gained for " + sStatName[iIndex] + " at level " +  iPlayerLevel / 3 + ": " + fRandomXPValueThird + ".\n\n")
				fRandomXPValueThirdTotal += fRandomXPValueThird
				fRandomXPValueThird = 0
			;---------------------
			; fRandomXPValueFourth
			;---------------------
				DMN_SXPALog(gDebug, "Amount of " + sStatName[iIndex] + " estimated at level " + iPlayerLevel / 4 + ": " + fActivityCount10Percent + ".")
				If (iActivityCount10Percent < 1)
					fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
					DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
					Float k = ((fPlayerLevelOffsetSquared / 16) + 25.00) / 100 * fRandomXPValue * fActivityCount10Percent ; 4 Squared.
					fRandomXPValueFourth += k
					DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount10Percent + "/" + fActivityCount10Percent + ") XP: " + k + ".")
					k = 0
				Else
					While (i < iActivityCount10Percent)
						fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
						DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
						Float k = ((fPlayerLevelOffsetSquared / 16) + 25.00) / 100 * fRandomXPValue ; 4 Squared.
						fRandomXPValueFourth += k
						DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + (i+1) + "/" + iActivityCount10Percent + ") XP: " + k + ".")
						k = 0
						i += 1
					EndWhile
					fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
					DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
					Float k = ((fPlayerLevelOffsetSquared / 16) + 25.00) / 100 * fRandomXPValue * fActivityCount10PercentRemainder ; 4 Squared.
					fRandomXPValueFourth += k
					DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount10PercentRemainder + "/" + fActivityCount10PercentRemainder + ") XP: " + k + ".")
					k = 0
					i = 0
				EndIf
				DMN_SXPALog(gDebug, "Total amount of XP gained for " + sStatName[iIndex] + " at level " +  iPlayerLevel / 4 + ": " + fRandomXPValueFourth + ".\n\n")
				fRandomXPValueFourthTotal += fRandomXPValueFourth
				fRandomXPValueFourth = 0
			;--------------------
			; fRandomXPValueFifth
			;--------------------
				DMN_SXPALog(gDebug, "Amount of " + sStatName[iIndex] + " estimated at level " + iPlayerLevel / 5 + ": " + fActivityCount15Percent + ".")
				If (iActivityCount15Percent < 1)
					fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
					DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
					Float k = ((fPlayerLevelOffsetSquared / 25) + 25.00) / 100 * fRandomXPValue * fActivityCount15Percent ; 5 Squared.
					fRandomXPValueFifth += k
					DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount15Percent + "/" + fActivityCount15Percent + ") XP: " + k + ".")
					k = 0
				Else
					While (i < iActivityCount15Percent)
						fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
						DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
						Float k = ((fPlayerLevelOffsetSquared / 25) + 25.00) / 100 * fRandomXPValue ; 5 Squared.
						fRandomXPValueFifth += k
						DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + (i+1) + "/" + iActivityCount15Percent + ") XP: " + k + ".")
						k = 0
						i += 1
					EndWhile
					fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
					DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
					Float k = ((fPlayerLevelOffsetSquared / 25) + 25.00) / 100 * fRandomXPValue * fActivityCount15PercentRemainder ; 5 Squared.
					fRandomXPValueFifth += k
					DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount15PercentRemainder + "/" + fActivityCount15PercentRemainder + ") XP: " + k + ".")
					k = 0
					i = 0
				EndIf
				DMN_SXPALog(gDebug, "Total amount of XP gained for " + sStatName[iIndex] + " at level " +  iPlayerLevel / 5 + ": " + fRandomXPValueFifth + ".\n\n")
				fRandomXPValueFifthTotal += fRandomXPValueFifth
				fRandomXPValueFifth = 0
			;--------------------
			; fRandomXPValueSixth
			;--------------------
				DMN_SXPALog(gDebug, "Amount of " + sStatName[iIndex] + " estimated at level " + iPlayerLevel / 6 + ": " + fActivityCount65Percent + ".")
				If (iActivityCount65Percent < 1)
					fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
					DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
					Float k = ((fPlayerLevelOffsetSquared / 36) + 25.00) / 100 * fRandomXPValue * fActivityCount65Percent ; 6 Squared.
					fRandomXPValueSixth += k
					DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount65Percent + "/" + fActivityCount65Percent + ") XP: " + k + ".")
					k = 0
				Else
					While (i < iActivityCount65Percent)
						fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
						DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
						Float k = ((fPlayerLevelOffsetSquared / 36) + 25.00) / 100 * fRandomXPValue ; 6 Squared.
						fRandomXPValueSixth += k
						DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + (i+1) + "/" + iActivityCount65Percent + ") XP: " + k + ".")
						k = 0
						i += 1
					EndWhile
					fRandomXPValue = (RandomInt(iMinXP, iMaxXP)) * (fXPModifier[iIndex])
					DMN_SXPALog(gDebug, "Random XP (Min~Max * Modifier): " + fRandomXPValue)
					Float k = ((fPlayerLevelOffsetSquared / 36) + 25.00) / 100 * fRandomXPValue * fActivityCount65PercentRemainder ; 6 Squared.
					fRandomXPValueSixth += k
					DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount65PercentRemainder + "/" + fActivityCount65PercentRemainder + ") XP: " + k + ".")
					k = 0
					i = 0
				EndIf
				DMN_SXPALog(gDebug, "Total amount of XP gained for " + sStatName[iIndex] + " at level " +  iPlayerLevel / 6 + ": " + fRandomXPValueSixth + ".\n\n")
				fRandomXPValueSixthTotal += fRandomXPValueSixth
				fRandomXPValueSixth = 0
			; Part 6: Calculating the total amount of XP earned for the XP activity.
				Float fFinalRandomXPValue = fRandomXPValueFullTotal + fRandomXPValueHalfTotal + fRandomXPValueThirdTotal + fRandomXPValueFourthTotal + fRandomXPValueFifthTotal + fRandomXPValueSixthTotal
				Int iRandomXPValue = round(fFinalRandomXPValue)
				DMN_SXPALog(gDebug, "Total amount of " + sStatName[iIndex] + ":" + " " + iUpdateCount + ".")
				DMN_SXPALog(gDebug, "Total amount of XP gained for " + sStatName[iIndex] + ":" + " " + iRandomXPValue + ".")
			; Part 7: Adding the total amount of XP earned for the XP activity to the total experience points.
				Int iNewXP = gXP.GetValue() as Int + iRandomXPValue
				DMN_SXPALog(gDebug, "Previous XP: " + gXP.GetValue() as Int + ".")
				gXP.SetValue(iNewXP)
				DMN_SXPALog(gDebug, "XP Assigned: " + iRandomXPValue + ".")
				DMN_SXPALog(gDebug, "Current XP: " + gXP.GetValue() as Int + ".")
				DMN_SXPALog(gDebug, "Completed update for: " + sStatName[iIndex] + ".\n\n")
				If (iUpdateCount > 1)
					debugNotification(gDebug, "Skyrim XP Addon DEBUG: Previously detected \"" + sStatName[iIndex] + "\" (x" + iUpdateCount + "). +" + iRandomXPValue + "XP combined!")
				Else
					debugNotification(gDebug, "Skyrim XP Addon DEBUG: Previously detected \"" + sStatName[iIndex] + "\" (x" + iUpdateCount + "). +" + iRandomXPValue + "XP!")
				EndIf
				iTotalXPAllocated += iRandomXPValue
				iTotalUpdateCount += iUpdateCount
				fRandomXPValueFullTotal = 0
				fRandomXPValueHalfTotal = 0
				fRandomXPValueThirdTotal = 0
				fRandomXPValueFourthTotal = 0
				fRandomXPValueFifthTotal = 0
				fRandomXPValueSixthTotal = 0
				fFinalRandomXPValue = 0
				iRandomXPValue = 0
			EndIf
		EndIf
		iIndex += 1
	EndWhile
; Show a notification that combines all previously earned XP and activity count totals and displays it to the player.
	If (iTotalXPAllocated > 0 && iTotalUpdateCount > 1)
		Notification("Skyrim XP Addon: Gained " + iTotalXPAllocated + " XP across " + iTotalUpdateCount + " tracked activity events.")
	ElseIf (iTotalXPAllocated > 0 && iTotalUpdateCount > 0)
		Notification("Skyrim XP Addon: Gained " + iTotalXPAllocated + " XP across " + iTotalUpdateCount + " tracked activity event.")
	EndIf
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "rewardExistingXPActivities() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended rewardExistingXPActivities Function]\n\n")
EndFunction

Function resetStatValues(GlobalVariable gDebug, Int[] iTrackedStatCount, String[] sStatName) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started resetStatValues Function]")
	Int iIndex = 0
	While (iIndex < iTrackedStatCount.Length)
	; Set the tracked XP activity value to 0 if it isn't already 0.
		If (iTrackedStatCount[iIndex] > 0)
			DMN_SXPALog(gDebug, sStatName[iIndex] + ": " + iTrackedStatCount[iIndex] + ".")
			iTrackedStatCount[iIndex] = 0
			DMN_SXPALog(gDebug, "Set " + sStatName[iIndex] + " to " + iTrackedStatCount[iIndex] + ".")
		EndIf
		iIndex += 1
	EndWhile
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "resetStatValues() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended resetStatValues Function]\n\n")
EndFunction

Function updatePlayerStats(GlobalVariable gDebug, GlobalVariable gMinXP, GlobalVariable gMaxXP, GlobalVariable gXP, Bool[] bXPActivityState, Float[] fXPModifier, Int[] iTrackedStatCount, String[] sStatName, String[] sNotificationMessage, Bool bUpdateStats = False) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started updatePlayerStats Function]\n")
	Int iIndex = 0
	While (iIndex < sStatName.Length)
		If (bXPActivityState[iIndex])
			Int iStatValue = QueryStat(sStatName[iIndex])
			Int iUpdateCount = iStatValue - iTrackedStatCount[iIndex]
			If (iStatValue > iTrackedStatCount[iIndex])
				iTrackedStatCount[iIndex] = iStatValue
				If (bUpdateStats)
					setRandomXPValue(gDebug, gMinXP, gMaxXP, gXP, fXPModifier, iIndex, sStatName, sNotificationMessage, iUpdateCount, True)
				ElseIf (iUpdateCount > 1)
					setRandomXPValue(gDebug, gMinXP, gMaxXP, gXP, fXPModifier, iIndex, sStatName, sNotificationMessage, iUpdateCount)
				Else
					setRandomXPValue(gDebug, gMinXP, gMaxXP, gXP, fXPModifier, iIndex, sStatName, sNotificationMessage)
				EndIf
				DMN_SXPALog(gDebug, sStatName[iIndex] + " was not part of the OnTrackedStatsEvent Event!\n\n")
			EndIf
		EndIf
		iIndex += 1
	EndWhile
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "updatePlayerStats() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended updatePlayerStats Function]\n\n")
EndFunction

Function updatePlayerStatsCount(GlobalVariable gDebug, Bool[] bXPActivityState, Int iIndexStart, Int iIndexEnd, Int[] iTrackedStatCount, String[] sStatName) Global
; Function that takes the starting and ending positions of an array
; and sets each value to the corresponding tracked stat count.
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started updatePlayerStatsCount Function]")
	Int iIndex = iIndexStart
	DMN_SXPALog(gDebug, "Starting array position: " + iIndex + ".")
	DMN_SXPALog(gDebug, "Ending array position: " + iIndexEnd + ".")
	While (iIndex <= iIndexEnd)
		If (bXPActivityState[iIndex])
			Int iStatValue = QueryStat(sStatName[iIndex])
			DMN_SXPALog(gDebug, sStatName[iIndex] + " previous count: " + iTrackedStatCount[iIndex]  + ".")
			If (iStatValue > iTrackedStatCount[iIndex])
				iTrackedStatCount[iIndex] = iStatValue
			EndIf
			DMN_SXPALog(gDebug, sStatName[iIndex] + " new count: " + iTrackedStatCount[iIndex]  + ".")
		EndIf
		iIndex += 1
	EndWhile
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "updatePlayerStatsCount() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended updatePlayerStatsCount Function]\n\n")
EndFunction

Function estimateScriptDuration(GlobalVariable gDebug, Float fAverageFunctionRunDuration, Int iUpdateCount) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started estimateScriptDuration Function]")
; Function to try to estimate the time another function may take to complete.
	DMN_SXPALog(gDebug, "Average Function Run Duration: " + fAverageFunctionRunDuration)
	DMN_SXPALog(gDebug, "Update Count: " + iUpdateCount)
	; The expected function run duration, as a float in seconds, plus 10 milliseconds times
	; the update count. The added 10 milliseconds * update count is to help with deviation
	; in the function run duration due to the low number of iterations performed.
	Float fFunctionDuration = fAverageFunctionRunDuration * iUpdateCount - fAverageFunctionRunDuration + (0.01 * iUpdateCount)
	DMN_SXPALog(gDebug, "Estimated Function Run Duration: " + fFunctionDuration)
	Int iFunctionDurationMinutes = Floor(fFunctionDuration / 60)
	DMN_SXPALog(gDebug, "Minutes: " + iFunctionDurationMinutes)
	Int iFunctionDurationSeconds = round(fFunctionDuration - iFunctionDurationMinutes * 60)
	DMN_SXPALog(gDebug, "Seconds: " + iFunctionDurationSeconds)
	If (iFunctionDurationMinutes > 1)
		Notification("Skyrim XP Addon: Estimated time to completion: " + iFunctionDurationMinutes + " minutes and " + iFunctionDurationSeconds + " seconds.")
	ElseIf (iFunctionDurationMinutes == 1)
		Notification("Skyrim XP Addon: Estimated time to completion: " + iFunctionDurationMinutes + " minute and " + iFunctionDurationSeconds + " seconds.")
	ElseIf (iFunctionDurationMinutes < 1)
		Notification("Skyrim XP Addon: Estimated time to completion: " + iFunctionDurationSeconds + " seconds.")
	EndIf
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "estimateScriptDuration() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended estimateScriptDuration Function]\n\n")
EndFunction

Bool Function checkPlayerStats(GlobalVariable gDebug, Bool[] bXPActivityState, Int[] iTrackedStatCount, String[] sStatName) Global
; Function checks all SXPA tracked stats, and if any differ from SXPA
; stored values then it will return True else it will return False.
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	Int iIndex = 0
	While (iIndex < sStatName.Length)
		If (bXPActivityState[iIndex])
			Int iStatValue = QueryStat(sStatName[iIndex])
			If (iStatValue > iTrackedStatCount[iIndex])
				fStop = GetCurrentRealTime()
				DMN_SXPALog(gDebug, "checkPlayerStats() function took " + (fStop - fStart) + " seconds to complete.\n\n")
				Return True
			EndIf
		EndIf
		iIndex += 1
	EndWhile
	Return False
EndFunction

Function resetArrayDataInt(GlobalVariable gDebug, Int[] iArray) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started resetArrayDataInt Function]")
	DMN_SXPALog(gDebug, "Previous full array value: " + iArray + ".")
	Int iArrayLength = iArray.Length
	Int iIndex = 0
	While (iIndex < iArrayLength)
	DMN_SXPALog(gDebug, "Array index " + iIndex + " previous value: " + iArray[iIndex] + ".")
		iArray[iIndex] = 0
	DMN_SXPALog(gDebug, "Array index " + iIndex + " new value: " + iArray[iIndex] + ".")
		iIndex += 1
	EndWhile
	DMN_SXPALog(gDebug, "New full array value: " + iArray + ".")
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "resetArrayDataInt() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended resetArrayDataInt Function]\n\n")
EndFunction

Function resetSXPAProgress(GlobalVariable gDebug, GlobalVariable gMonitoring, GlobalVariable gMinXP, GlobalVariable gMaxXP, GlobalVariable gXP, Bool[] bXPActivityState, Float[] fXPModifier, Int[] iSkillXP, Int[] iSkillXPSpent, Int[] iSkillXPSpentEffective, Int[] iTrackedStatCount, String[] sSkillName, String[] sStatName) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started resetSXPAProgress Function]")
; Temporarily disable active monitoring if it is on whilst we reset and update player progress.
	Int DMN_SXPAActiveMonitoringState = gMonitoring.GetValue() As Int
	Bool bActiveMonitoringEnabled
	If (DMN_SXPAActiveMonitoringState == 1)
		bActiveMonitoringEnabled = True
		DMN_SXPALog(gDebug, "Reset SXPA Progress: Disabling XP activity active tracking temporarily...")
		gMonitoring.SetValue(0)
		If (gMonitoring.GetValue() == 0)
			DMN_SXPALog(gDebug, "Reset SXPA Progress: XP activity active tracking was disabled.\n\n")
		Else
			DMN_SXPALog(gDebug, "Reset SXPA Progress: WARNING: XP activity active tracking was NOT disabled!\n\n")
		EndIf
	EndIf
; Wipe the amount of stored SXPA skill XP.
	resetArrayDataInt(gDebug, iSkillXP)
; Wipe the amount of generic SXPA XP spent on skills.
	resetArrayDataInt(gDebug, iSkillXPSpent)
; Wipe the amount of effective (converted) skill-specific XP spent.
	resetArrayDataInt(gDebug, iSkillXPSpentEffective)
; Wipe the count of each tracked XP activity completed.
	resetArrayDataInt(gDebug, iTrackedStatCount)
; Wipe the total SXPA experience points gained.
	gXP.SetValue(0)
; Update all previously completed XP activities to properly scale and balance to the player level and an average thereof.
	rewardExistingXPActivities(gDebug, gMinXP, gMaxXP, gXP, bXPActivityState, fXPModifier, iTrackedStatCount, sStatName)
; Once we've completed the update we can re-enable active monitoring, if it was enabled to begin with.
	If (bActiveMonitoringEnabled)
		bActiveMonitoringEnabled = None
		DMN_SXPALog(gDebug, "Reset SXPA Progress: Re-enabling XP activity active tracking.")
		gMonitoring.SetValue(1)
		If (gMonitoring.GetValue() == 1)
			DMN_SXPALog(gDebug, "Reset SXPA Progress: XP activity active tracking was enabled.\n\n")
		Else
			DMN_SXPALog(gDebug, "Reset SXPA Progress: WARNING: XP activity active tracking was NOT enabled!\n\n")
		EndIf
	EndIf
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "resetSXPAProgress() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended resetSXPAProgress Function]\n\n")
EndFunction

Function setSXPADefaults(GlobalVariable gDebug, GlobalVariable gMonitoring, GlobalVariable gMinXP, GlobalVariable gMaxXP, Bool[] bXPActivityState, Float[] fSkillModifier, Float[] fXPModifier, Int iPassiveMonitoring) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started setSXPADefaults Function]")
; Set the Skill Modifiers to default values.
	setSkillModifierDefaults(gDebug, fSkillModifier)
; Set the XP Activity states to default.
	setXPActivityStateDefaults(gDebug, bXPActivityState)
; Set the XP Modifiers to default values.
	setXPModifierDefaults(gDebug, fXPModifier)
; Set the minimum XP reward to default.
	gMinXP.SetValue(250) 
; Set the maximum XP reward to default.
	gMaxXP.SetValue(1000)
; Disable passive monitoring.
	iPassiveMonitoring = 0
; Enable active (always-on) monitoring.
	gMonitoring.SetValue(1)
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "setSXPADefaults() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended setSXPADefaults Function]\n\n")
EndFunction

Bool Function getXPActivityState(GlobalVariable gDebug, Bool[] bXPActivityState, Int iXPActivityIndex, String[] sStatName) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started getXPActivityState Function]")
	Bool bState = bXPActivityState[iXPActivityIndex]
	DMN_SXPALog(gDebug, sStatName[iXPActivityIndex] + " XP gain is set to " + bState + ".")
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "getXPActivityState() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended getXPActivityState Function]\n\n")
	Return bState
EndFunction

Function setXPActivityState(GlobalVariable gDebug, Bool[] bXPActivityState, Int iXPActivityIndex, Bool bEnabled, String[] sStatName) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started setXPActivityState Function]")
	bXPActivityState[iXPActivityIndex] = bEnabled
	DMN_SXPALog(gDebug, "Set " + sStatName[iXPActivityIndex] + " XP gain to " + bEnabled + ".")
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "setXPActivityState() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended setXPActivityState Function]\n\n")
EndFunction

Int Function getXPActivityIndex(String sXPActivityName, String[] sStatName) Global
	Int iIndex = sStatName.Find(sXPActivityName)
	Return iIndex
EndFunction

Function setSkillModifierDefaults(GlobalVariable gDebug, Float[] fSkillModifier) Global
; Resets the default Skill Modifier values.
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started setSkillModifierDefaults Function]")
	DMN_SXPALog(gDebug, "Skill Modifier previous values: " + fSkillModifier + ".")
	fSkillModifier[0] = 1.00 ; Archery
	fSkillModifier[1] = 1.00 ; Block
	fSkillModifier[2] = 1.00 ; Heavy Armor
	fSkillModifier[3] = 1.00 ; One-Handed
	fSkillModifier[4] = 0.125 ; Smithing
	fSkillModifier[5] = 1.00 ; Two-Handed
	fSkillModifier[6] = 1.00 ; Alteration
	fSkillModifier[7] = 1.00 ; Conjuration
	fSkillModifier[8] = 1.00 ; Destruction
	fSkillModifier[9] = 0.50 ; Enchanting
	fSkillModifier[10] = 1.00 ; Illusion
	fSkillModifier[11] = 1.00 ; Restoration
	fSkillModifier[12] = 0.80 ; Alchemy
	fSkillModifier[13] = 1.00 ; Light Armor
	fSkillModifier[14] = 0.125 ; Lockpicking
	fSkillModifier[15] = 0.125 ; Pickpocket
	fSkillModifier[16] = 0.25 ; Sneak
	fSkillModifier[17] = 1.00 ; Speech
	DMN_SXPALog(gDebug, "Skill Modifier new values: " + fSkillModifier + ".")
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "setSkillModifierDefaults() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended setSkillModifierDefaults Function]\n\n")
EndFunction

Function setXPActivityStateDefaults(GlobalVariable gDebug, Bool[] bXPActivityState) Global
; Resets the default XP Activity State values.
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started setXPActivityStateDefaults Function]")
	DMN_SXPALog(gDebug, "XP Activity State previous values: " + bXPActivityState + ".")
	bXPActivityState[0] = True ; Locations Discovered
	bXPActivityState[1] = True ; Standing Stones Found
	bXPActivityState[2] = True ; Nirnroots Found
	bXPActivityState[3] = True ; Books Read
	bXPActivityState[4] = True ; Ingredients Harvested
	bXPActivityState[5] = True ; Wings Plucked
	bXPActivityState[6] = True ; Persuasions
	bXPActivityState[7] = True ; Intimidations
	bXPActivityState[8] = False ; Misc Objectives Completed
	bXPActivityState[9] = True ; Main Quests Completed
	bXPActivityState[10] = True ; Side Quests Completed
	bXPActivityState[11] = True ; The Companions Quests Completed
	bXPActivityState[12] = True ; College of Winterhold Quests Completed
	bXPActivityState[13] = True ; Thieves' Guild Quests Completed
	bXPActivityState[14] = True ; The Dark Brotherhood Quests Completed
	bXPActivityState[15] = True ; Civil War Quests Completed
	bXPActivityState[16] = True ; Daedric Quests Completed
	bXPActivityState[17] = True ; Questlines Completed
	bXPActivityState[18] = False ; People Killed
	bXPActivityState[19] = False ; Animals Killed
	bXPActivityState[20] = False ; Creatures Killed
	bXPActivityState[21] = False ; Undead Killed
	bXPActivityState[22] = False ; Daedra Killed
	bXPActivityState[23] = False ; Automatons Killed
	bXPActivityState[24] = False ; Weapons Disarmed
	bXPActivityState[25] = True ; Brawls Won
	bXPActivityState[26] = False ; Bunnies Slaughtered
	bXPActivityState[27] = True ; Dragon Souls Collected
	bXPActivityState[28] = True ; Words Of Power Learned
	bXPActivityState[29] = True ; Words Of Power Unlocked
	bXPActivityState[30] = True ; Shouts Mastered
	bXPActivityState[31] = False ; Souls Trapped
	bXPActivityState[32] = False ; Magic Items Made
	bXPActivityState[33] = False ; Weapons Improved
	bXPActivityState[34] = False ; Weapons Made
	bXPActivityState[35] = False ; Armor Improved
	bXPActivityState[36] = False ; Armor Made
	bXPActivityState[37] = False ; Potions Mixed
	bXPActivityState[38] = False ; Poisons Mixed
	DMN_SXPALog(gDebug, "XP Activity State new values: " + bXPActivityState + ".")
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "setXPActivityStateDefaults() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended setXPActivityStateDefaults Function]\n\n")
EndFunction

Function setXPModifierDefaults(GlobalVariable gDebug, Float[] fXPModifier) Global
; Resets the default XP Modifier values.
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started setXPModifierDefaults Function]")
	DMN_SXPALog(gDebug, "XP Modifier previous values: " + fXPModifier + ".")
	fXPModifier[0] = 0.60 ; Locations Discovered
	fXPModifier[1] = 5.00 ; Standing Stones Found
	fXPModifier[2] = 0.40 ; Nirnroots Found
	fXPModifier[3] = 0.40 ; Books Read
	fXPModifier[4] = 0.15 ; Ingredients Harvested
	fXPModifier[5] = 0.40 ; Wings Plucked
	fXPModifier[6] = 0.80 ; Persuasions
	fXPModifier[7] = 0.80 ; Intimidations
	fXPModifier[8] = 0.20 ; Misc Objectives Completed
	fXPModifier[9] = 4.00 ; Main Quests Completed
	fXPModifier[10] = 3.00 ; Side Quests Completed
	fXPModifier[11] = 3.00 ; The Companions Quests Completed
	fXPModifier[12] = 2.00 ; College of Winterhold Quests Completed
	fXPModifier[13] = 2.00 ; Thieves' Guild Quests Completed
	fXPModifier[14] = 1.50 ; The Dark Brotherhood Quests Completed
	fXPModifier[15] = 3.00 ; Civil War Quests Completed
	fXPModifier[16] = 2.00 ; Daedric Quests Completed
	fXPModifier[17] = 10.00 ; Questlines Completed
	fXPModifier[18] = 0.25 ; People Killed
	fXPModifier[19] = 0.40 ; Animals Killed
	fXPModifier[20] = 0.40 ; Creatures Killed
	fXPModifier[21] = 0.30 ; Undead Killed
	fXPModifier[22] = 0.50 ; Daedra Killed
	fXPModifier[23] = 0.50 ; Automatons Killed
	fXPModifier[24] = 0.60 ; Weapons Disarmed
	fXPModifier[25] = 3.00 ; Brawls Won
	fXPModifier[26] = 0.40 ; Bunnies Slaughtered
	fXPModifier[27] = 10.00 ; Dragon Souls Collected
	fXPModifier[28] = 1.50 ; Words Of Power Learned
	fXPModifier[29] = 3.00 ; Words Of Power Unlocked
	fXPModifier[30] = 5.00 ; Shouts Mastered
	fXPModifier[31] = 0.50 ; Souls Trapped
	fXPModifier[32] = 0.25 ; Magic Items Made
	fXPModifier[33] = 0.10 ; Weapons Improved
	fXPModifier[34] = 0.20 ; Weapons Made
	fXPModifier[35] = 0.10 ; Armor Improved
	fXPModifier[36] = 0.20 ; Armor Made
	fXPModifier[37] = 0.20 ; Potions Mixed
	fXPModifier[38] = 0.20 ; Poisons Mixed
	DMN_SXPALog(gDebug, "XP Modifier new values: " + fXPModifier + ".")
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "setXPModifierDefaults() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended setXPModifierDefaults Function]\n\n")
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
