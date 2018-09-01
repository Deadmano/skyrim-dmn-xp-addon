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

Function giveConfiguratorBook(Book akConfigurator, Bool bRemoveOnly = False) Global
; Save the amount of configurators the player has in their inventory.
	Actor kRef = GetPlayer()
	Int i = kRef.GetItemCount(akConfigurator)
	If (i == 0 && !bRemoveOnly)
; If the player has none, add a single configurator to their inventory, silently.
		kRef.AddItem(akConfigurator, 1, True)
	ElseIf (i >= 1 && !bRemoveOnly)
; Else remove every configurator in the player inventory and add one, silently.
		kRef.RemoveItem(akConfigurator, i, True)
		kRef.AddItem(akConfigurator, 1, True)
	ElseIf (i >= 1 && bRemoveOnly)
		kRef.RemoveItem(akConfigurator, i, True)
	EndIf
EndFunction

Function giveConfiguratorSpell(Spell akConfigurator, Bool bRemoveOnly = False) Global
	Actor kRef = GetPlayer()
	If (kRef.HasSpell(akConfigurator) && !bRemoveOnly)
; If the player has the configurator spell, remove it and re-add it, silently.
		kRef.RemoveSpell(akConfigurator)
		kRef.AddSpell(akConfigurator, False)
	ElseIf (!bRemoveOnly)
; Else add the configurator spell, silently.
		kRef.AddSpell(akConfigurator, False)
	ElseIf (kRef.HasSpell(akConfigurator) && bRemoveOnly)
		kRef.RemoveSpell(akConfigurator)
	EndIf
EndFunction

Function spendXP(GlobalVariable gDebug, GlobalVariable gTotalXP, Bool bUseExponentialSkillCost, Float[] fSkillMultiplier, Int[] iSkillXP, Int[] iSkillXPSpent, Int[] iSkillXPSpentEffective, String[] sSkillName, String sSkill, Int iAmount, Bool bAuto = False) Global
	DMN_SXPALog(gDebug, "[Started spendXP Function]")
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	Actor kRef = GetPlayer()
	Bool bLevelUpSkill = False
	Float fEffectiveXP
	Float fSkillCost
	Float fSkillCostBase
	Float fSkillCostExponent
	Float fSkillLevel
	Int iCount
	Int iCurrentXP = gTotalXP.GetValue() as Int
	Int iEffectiveXP
	Int iIndex
	Int iLevelsGained
	Int iNewXP
	Int iPlayerLevel
	Int iSkillCost
	Int iSkillImproveOffset
; Set the improvement multiplier offsets to balance out XP conversion.
	If (sSkill == "Alchemy")
		iSkillImproveOffset = 65
	ElseIf (sSkill == "Enchanting")
		iSkillImproveOffset = 170
	ElseIf (sSkill == "Lockpicking")
		iSkillImproveOffset = 300
	ElseIf (sSkill == "Pickpocket")
		iSkillImproveOffset = 250
	ElseIf (sSkill == "Smithing")
		iSkillImproveOffset = 300
	ElseIf (sSkill == "Sneak")
		iSkillImproveOffset = 120
	EndIf
	iIndex = sSkillName.Find(sSkill) as Int
; Get the skill level chosen to assign XP to.
	fSkillLevel = kRef.GetActorValue(convertSkillName(sSkill, True))
; Get the player's current level.
	iPlayerLevel = GetPlayer().GetLevel()
; How much actual skill XP will be converted from the generic XP invested.
	fEffectiveXP = (iAmount * fSkillMultiplier[iIndex])
	iEffectiveXP = round(fEffectiveXP)
; Adding the actual converted skill XP to the array.
	iSkillXP[iIndex] = iSkillXP[iIndex] + iEffectiveXP
; Adding the amount of generic XP spent to the array.
	iSkillXPSpent[iIndex] = iSkillXPSpent[iIndex] + iAmount
; Adding the converted skill XP spent to the array.
	iSkillXPSpentEffective[iIndex] = iSkillXPSpentEffective[iIndex] + iEffectiveXP
; Initial skill cost calculations for the level-up While loop.
	If (bUseExponentialSkillCost)
	; Exponential formula.
		fSkillCostBase = 1.17
		fSkillCost = pow(fSkillCostBase, fSkillLevel)
		iSkillCost = ceiling(fSkillCost)
	Else
	; Linear formula.
		fSkillCostExponent = 1.95
		fSkillCost = (pow(fSkillLevel, fSkillCostExponent)) + iSkillImproveOffset
		iSkillCost = ceiling(fSkillCost)
	EndIf
; Ensure we only run the skill level-up if there is enough skill-specific XP.
	If (iSkillXP[iIndex] >= iSkillCost)
		bLevelUpSkill = True
	Else
		DMN_SXPALog(gDebug, "Not enough skill-specific XP to level up. Skipping skill level-up section.")
	EndIf
; Assign skill levels so long as we have enough skill XP for each level.
	While (bLevelUpSkill)
		iCount += 1
		fSkillLevel = kRef.GetActorValue(convertSkillName(sSkill, True)) + iCount
		If (!bAuto)
			DMN_SXPALog(gDebug, "Calculating XP Cost For Level: " + (fSkillLevel as Int) + ".")
		EndIf
		If (!bAuto)
			DMN_SXPALog(gDebug, "Skill XP Available: " + iSkillXP[iIndex] + ".")
		EndIf
		If (bUseExponentialSkillCost)
		; Calculate the cost to level up the skill using the exponential formula.
			fSkillCost = pow(fSkillCostBase, fSkillLevel)
			If (!bAuto)
				DMN_SXPALog(gDebug, "Skill Cost Base: " + fSkillCostBase + ".")
			EndIf
		Else
		; Calculate the cost to level up the skill using the linear formula.
			fSkillCost = (pow(fSkillLevel, fSkillCostExponent)) + iSkillImproveOffset
			If (!bAuto)
				DMN_SXPALog(gDebug, "Skill Cost Exponent: " + fSkillCostExponent + ".")
			EndIf
		EndIf
		If (!bAuto)
			DMN_SXPALog(gDebug, "Gross Skill Cost As Float: " + fSkillCost + ".")
		EndIf
		iSkillCost = ceiling(fSkillCost)
		If (!bAuto)
			DMN_SXPALog(gDebug, "Rounded Skill Cost As Int: " + iSkillCost + ".")
		EndIf
	; If we have enough skill XP, continue levelling up the skill.
		If (iSkillXP[iIndex] >= iSkillCost)
			bLevelUpSkill = True
			iSkillXP[iIndex] = iSkillXP[iIndex] - iSkillCost
			iLevelsGained += 1
	; If we don't, stop.
		Else
			If (!bAuto)
				DMN_SXPALog(gDebug, "Ran out of skill-specific XP, exiting loop now.")
			EndIf
			fSkillLevel -= 1
			bLevelUpSkill = False
		EndIf
		If (!bAuto)
			DMN_SXPALog(gDebug, "Skill XP Remaining: " + iSkillXP[iIndex] + ".\n\n")
		EndIf
	EndWhile
; Ensure we only level up a skill if at least 1 level was earned.
	If (iLevelsGained > 0)
		IncrementSkillBy(convertSkillName(sSkill, True), iLevelsGained)
	EndIf
	If (iLevelsGained == 1)
		Notification("Skyrim XP Addon: " + sSkill + " reached enough experience points to level up! (" + (fSkillLevel - iLevelsGained) + " > " + (fSkillLevel) + ")")
	ElseIf (iLevelsGained > 1)
		Notification("Skyrim XP Addon: " + sSkill + " reached enough experience points to level up " + iLevelsGained + " times! (" + (fSkillLevel - iLevelsGained) + " > " + (fSkillLevel) + ")")
	EndIf
	If (iAmount > 0)
		Notification("Skyrim XP Addon: Converted " + iAmount + " generic XP to " + sSkill + " specific XP. (" + iEffectiveXP + "XP)")
	EndIf
		DMN_SXPALog(gDebug, "Chosen Skill: " + sSkill + ".")
	If (!bAuto)
		DMN_SXPALog(gDebug, "Skill Index: " + iIndex + ".")
		DMN_SXPALog(gDebug, "Skill Multiplier: " + fSkillMultiplier[iIndex] + ".")
		DMN_SXPALog(gDebug, "Original Skill Level: " + ((fSkillLevel - iLevelsGained) as Int) + ".")
		If (iLevelsGained > 0)
			DMN_SXPALog(gDebug, "New Skill Level: " + (fSkillLevel as Int) + ".")
			DMN_SXPALog(gDebug, "Skill Levels Gained: " + iLevelsGained + ".")
		EndIf
		DMN_SXPALog(gDebug, "Player Level: " + iPlayerLevel + ".")
		If (bUseExponentialSkillCost)
			DMN_SXPALog(gDebug, "XP System Type: Exponential.")
		Else
			DMN_SXPALog(gDebug, "XP System Type: Linear.")
		EndIf
		If (iCurrentXP > 0)
			DMN_SXPALog(gDebug, "Available Generic XP: " + iCurrentXP + ".")
		EndIf
		If (iAmount > 0)
			DMN_SXPALog(gDebug, "Generic XP Invested: " + iAmount + ".")
		EndIf
		If (iEffectiveXP > 0)
			DMN_SXPALog(gDebug, "Converted To Skill-Specific XP: " + iEffectiveXP + ".")
		EndIf
	EndIf
	If (iAmount > 0)
		iNewXP = iCurrentXP - iAmount
		gTotalXP.SetValue(iNewXP)
		If (!bAuto)
			DMN_SXPALog(gDebug, "Remaining Generic XP: " + iNewXP + ".")
		EndIf
	EndIf
	If (!bAuto)
		DMN_SXPALog(gDebug, "Skill XP Cost To Level " + ((fSkillLevel as Int) + 1) + ": " + iSkillCost + " (" + fSkillCost + ")" + ".")
		DMN_SXPALog(gDebug, "Skill XP Available: " + iSkillXP[iIndex] + ".")
	EndIf
	DMN_SXPALog(gDebug, "Additional Generic XP Required For Level " + ((fSkillLevel as Int) + 1) + ": " + ((iSkillCost - iSkillXP[iIndex]) / fSkillMultiplier[iIndex]) as Int + " (" + ((fSkillCost - iSkillXP[iIndex]) / fSkillMultiplier[iIndex]) + ")" + ".")
	DMN_SXPALog(gDebug, "Additional Skill XP Required For Level " + ((fSkillLevel as Int) + 1) + ": " + (iSkillCost - iSkillXP[iIndex]) + " (" + (fSkillCost - iSkillXP[iIndex]) + ")" + ".")
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "getRandomXPValue() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended spendXP Function]\n\n")
EndFunction

Function autoSpendXP(GlobalVariable gDebug, GlobalVariable gAutoSpendXPBusy, GlobalVariable gTotalXP, Bool bUseExponentialSkillCost, Int iReserveXP, Float[] fSkillMultiplier, Float[] fTaggedSkillsPriority, Int[] iSkillXP, Int[] iSkillXPSpent, Int[] iSkillXPSpentEffective, String[] sSkillName, String[] sTaggedSkills) Global
	DMN_SXPALog(gDebug, "[Started autoSpendXP Function]")
	Bool bAutoSpendXPBusy
	Bool bBlock01
	Bool bBlock02
	Bool bBlock03
	Bool bBlock04
	Bool bCanSpendXP
	Bool bCanSplitSkill01
	Bool bCanSplitSkill02
	Bool bCanSplitSkill03
	Bool bCanSplitSkill04
	Float fTaggedSkill01XP
	Float fTaggedSkill02XP
	Float fTaggedSkill03XP
	Float fTaggedSkill04XP
	Float fPercentageRemaining
	Float fPercentageRemainingSplit
	Float fTaggedSkill01Percentage = fTaggedSkillsPriority[0]
	Float fTaggedSkill02Percentage = fTaggedSkillsPriority[1]
	Float fTaggedSkill03Percentage = fTaggedSkillsPriority[2]
	Float fTaggedSkill04Percentage = fTaggedSkillsPriority[3]
	Float fTaggedSkillsPercentage
	Float fTaggedSkillsPercentageRemainder
	Float fTaggedSkillsPercentageRemainderSplit
	Int iCurrentXP = gTotalXP.GetValue() as Int
	Int iNumSkillSlots = sTaggedSkills.Length
	Int iNumTaggedSkills
	Int iIndex
	Int iSkillsCanSplit
	Int iTaggedSkill01XP
	Int iTaggedSkill02XP
	Int iTaggedSkill03XP
	Int iTaggedSkill04XP
	String sPriority
	String sSkill01
	String sSkill02
	String sSkill03
	String sSkill04
	String sTaggedSkill01 = sTaggedSkills[0]
	String sTaggedSkill02 = sTaggedSkills[1]
	String sTaggedSkill03 = sTaggedSkills[2]
	String sTaggedSkill04 = sTaggedSkills[3]
	bAutoSpendXPBusy = gAutoSpendXPBusy.GetValue() as Int
	If (bAutoSpendXPBusy)
		DMN_SXPALog(gDebug, "Function was called, but we are still busy completing the last request. Skipping this request until the previous request has completed...")
	Else
	; Lock the function to ensure no extra instances are run.
		gAutoSpendXPBusy.SetValue(1)
		While (iIndex < iNumSkillSlots)
		; Check if there is an empty skill slot at the current index.
			If (sTaggedSkills[iIndex] == "")
			; If there is, we do nothing.
				DMN_SXPALog(gDebug, "Skill slot " + (iIndex + 1) + " is empty.")
			Else
			; If there isn't, figure out the tagged skill priority and
			; increment the tagged skills counter by 1.
				If (fTaggedSkillsPriority[iIndex] == 0.60)
					sPriority = "high"
				ElseIf (fTaggedSkillsPriority[iIndex] == 0.30)
					sPriority = "medium"
				ElseIf (fTaggedSkillsPriority[iIndex] == 0.10)
					sPriority = "low"
				EndIf
				DMN_SXPALog(gDebug, "Skill slot " + (iIndex + 1) + " is tagged with " + sTaggedSkills[iIndex] + " (" + sPriority + " priority).")
				iNumTaggedSkills += 1
			EndIf
			iIndex += 1
		EndWhile
		If (iNumTaggedSkills == 0)
			DMN_SXPALog(gDebug, "No skills have been tagged, skipping function run.")
			gAutoSpendXPBusy.SetValue(0)
		ElseIf (iCurrentXP == 0)
			DMN_SXPALog(gDebug, "No generic XP to spend, skipping function run.")
			gAutoSpendXPBusy.SetValue(0)
		ElseIf ((iCurrentXP / iNumTaggedSkills) < 1)
			DMN_SXPALog(gDebug, "Not enough generic XP to spend, skipping function run.")
			gAutoSpendXPBusy.SetValue(0)
		ElseIf ((iReserveXP >= iCurrentXP) || (((iCurrentXP - iReserveXP) / iNumTaggedSkills) < 1))
			DMN_SXPALog(gDebug, "Not enough generic XP to spend due to reserved XP, skipping function run.")
			gAutoSpendXPBusy.SetValue(0)
		ElseIf (iNumTaggedSkills > 0)
			gAutoSpendXPBusy.SetValue(1)
			DMN_SXPALog(gDebug, "Number Of Tagged Skills: " + iNumTaggedSkills + ".")
			DMN_SXPALog(gDebug, "Number Of Free Skill Slots: " + (iNumSkillSlots - iNumTaggedSkills) + ".\n\n")
			bCanSpendXP = True
			fTaggedSkillsPercentage += fTaggedSkillsPriority[0]
			fTaggedSkillsPercentage += fTaggedSkillsPriority[1]
			fTaggedSkillsPercentage += fTaggedSkillsPriority[2]
			fTaggedSkillsPercentage += fTaggedSkillsPriority[3]
			iSkillsCanSplit = iNumTaggedSkills
			DMN_SXPALog(gDebug, "Total Priority Percentages: ~" + (round(fTaggedSkillsPercentage * 100)) + "% (" + (fTaggedSkillsPercentage * 100) + ").")
			While (bCanSpendXP)
			; Check if the fTaggedSkillsPercentage variable is less than 1.00 (100% XP) and
			; if it is, calculate the remaining percentage , divide it by the amount of tagged
			; skills and add that value to the fTaggedSkillsPercentageRemainderSplit variable.
				If (fTaggedSkillsPercentage < 1.00)
					fTaggedSkillsPercentageRemainder = 1.00 - fTaggedSkillsPercentage
					fTaggedSkillsPercentageRemainderSplit = fTaggedSkillsPercentageRemainder / iNumTaggedSkills
					DMN_SXPALog(gDebug, "Percentage Under 100%: ~" + (round(fTaggedSkillsPercentageRemainder * 100)) + "% (" + (fTaggedSkillsPercentageRemainder * 100) + ").")
				ElseIf (fTaggedSkillsPercentage > 1.00)
					fTaggedSkillsPercentageRemainder = fTaggedSkillsPercentage - 1.00
					fTaggedSkillsPercentageRemainderSplit = fTaggedSkillsPercentageRemainder / iNumTaggedSkills
					DMN_SXPALog(gDebug, "Percentage Over 100%: ~" + (round(fTaggedSkillsPercentageRemainder * 100)) + "% (" + (fTaggedSkillsPercentageRemainder * 100) + ").")
				Else
					DMN_SXPALog(gDebug, "Remaining Percentage: ~" + (round(fTaggedSkillsPercentageRemainder * 100)) + "% (" + (fTaggedSkillsPercentageRemainder * 100) + ").")
				EndIf
				fPercentageRemaining = fTaggedSkillsPercentageRemainder
				fPercentageRemainingSplit = fTaggedSkillsPercentageRemainderSplit
				bCanSplitSkill01 = False
				bCanSplitSkill02 = False
				bCanSplitSkill03 = False
				bCanSplitSkill04 = False
			; Check if the tagged skill slot is empty, and if it is we do nothing.
				If (sTaggedSkill01 == "" || sTaggedSkill01 == "None")
					fTaggedSkill01XP = 0
					sTaggedSkill01 = "None"
				Else
			; If it isn't, figure out if we need to add or subtract from the total percentage amount
			; and then calculate the XP to be spent on the tagged skill based on its priority.
					If (fTaggedSkillsPercentage < 1.00)
						fTaggedSkill01Percentage += fTaggedSkillsPercentageRemainderSplit
						fPercentageRemaining -= fPercentageRemainingSplit
					ElseIf (fTaggedSkillsPercentage > 1.00 && fPercentageRemainingSplit < fTaggedSkill01Percentage)
						fTaggedSkill01Percentage -= fPercentageRemainingSplit
						fTaggedSkillsPercentage -= fPercentageRemainingSplit
						fPercentageRemaining -= fPercentageRemainingSplit
						bCanSplitSkill01 = True
					EndIf
					fTaggedSkill01XP = (iCurrentXP - iReserveXP) * fTaggedSkill01Percentage
				EndIf
				If (sTaggedSkill02 == "" || sTaggedSkill02 == "None")
					fTaggedSkill02XP = 0
					sTaggedSkill02 = "None"
				Else
					If (fTaggedSkillsPercentage < 1.00)
						fTaggedSkill02Percentage += fTaggedSkillsPercentageRemainderSplit
						fPercentageRemaining -= fPercentageRemainingSplit
					ElseIf (fTaggedSkillsPercentage > 1.00 && fPercentageRemainingSplit < fTaggedSkill02Percentage)
						fTaggedSkill02Percentage -= fPercentageRemainingSplit
						fTaggedSkillsPercentage -= fPercentageRemainingSplit
						fPercentageRemaining -= fPercentageRemainingSplit
						bCanSplitSkill02 = True
					EndIf
					fTaggedSkill02XP = (iCurrentXP - iReserveXP) * fTaggedSkill02Percentage
				EndIf
				If (sTaggedSkill03 == "" || sTaggedSkill03 == "None")
					fTaggedSkill03XP = 0
					sTaggedSkill03 = "None"
				Else
					If (fTaggedSkillsPercentage < 1.00)
						fTaggedSkill03Percentage += fTaggedSkillsPercentageRemainderSplit
						fPercentageRemaining -= fPercentageRemainingSplit
					ElseIf (fTaggedSkillsPercentage > 1.00 && fPercentageRemainingSplit < fTaggedSkill03Percentage)
						fTaggedSkill03Percentage -= fPercentageRemainingSplit
						fTaggedSkillsPercentage -= fPercentageRemainingSplit
						fPercentageRemaining -= fPercentageRemainingSplit
						bCanSplitSkill03 = True
					EndIf
					fTaggedSkill03XP = (iCurrentXP - iReserveXP) * fTaggedSkill03Percentage
				EndIf
				If (sTaggedSkill04 == "" || sTaggedSkill04 == "None")
					fTaggedSkill04XP = 0
					sTaggedSkill04 = "None"
				Else
					If (fTaggedSkillsPercentage < 1.00)
						fTaggedSkill04Percentage += fTaggedSkillsPercentageRemainderSplit
						fPercentageRemaining -= fPercentageRemainingSplit
					ElseIf (fTaggedSkillsPercentage > 1.00 && fPercentageRemainingSplit < fTaggedSkill04Percentage)
						fTaggedSkill04Percentage -= fPercentageRemainingSplit
						fTaggedSkillsPercentage -= fPercentageRemainingSplit
						fPercentageRemaining -= fPercentageRemainingSplit
						bCanSplitSkill04 = True
					EndIf
					fTaggedSkill04XP = (iCurrentXP - iReserveXP) * fTaggedSkill04Percentage
				EndIf
				If (!bCanSplitSkill01 && !bBlock01)
					iSkillsCanSplit -= 1
					bBlock01 = True
				EndIf		
				If (!bCanSplitSkill02 && !bBlock02)
					iSkillsCanSplit -= 1
					bBlock02 = True
				EndIf
				If (!bCanSplitSkill03 && !bBlock03)
					iSkillsCanSplit -= 1
					bBlock03 = True
				EndIf
				If (!bCanSplitSkill04 && !bBlock04)
					iSkillsCanSplit -= 1
					bBlock04 = True
				EndIf
				If (fTaggedSkillsPercentage > 1.00)
					DMN_SXPALog(gDebug, "Split Percentage: ~-" + (round(fPercentageRemainingSplit * 100)) + "% (-" + (fPercentageRemainingSplit * 100) + ") x" + iNumTaggedSkills + ".\n\n")
				ElseIf (fTaggedSkillsPercentage < 1.00)
					DMN_SXPALog(gDebug, "Split Percentage: ~+" + (round(fTaggedSkillsPercentageRemainderSplit * 100)) + "% (+" + (fTaggedSkillsPercentageRemainderSplit * 100) + ") x" + iNumTaggedSkills + ".\n\n")
				Else
					DMN_SXPALog(gDebug, "Split Percentage: ~" + (round(fTaggedSkillsPercentageRemainderSplit * 100)) + "% (" + (fTaggedSkillsPercentageRemainderSplit * 100) + ") x" + iNumTaggedSkills + ".\n\n")
				EndIf
				If (iSkillsCanSplit < iNumTaggedSkills)
					fPercentageRemainingSplit = fPercentageRemaining / iSkillsCanSplit
				EndIf
			; Once there is no more XP priority percentage over/under to allocate
			; to tagged skills we can exit the loop and spend XP on the skills.
				If (fPercentageRemaining <= 0)
					bCanSpendXP = False
				EndIf
			EndWhile
		; Round down the XP we will spend on tagged skills to avoid negative integers.
		; If the resulting XP after automatic spending is less than the
		; reserved XP, we then set the amount of XP to be spent to 0.
			iTaggedSkill01XP = Floor(fTaggedSkill01XP)
			If !((iCurrentXP - iTaggedSkill01XP) >= iReserveXP)
				fTaggedSkill01XP = 0
				iTaggedSkill01XP = 0
			EndIf
			iTaggedSkill02XP = Floor(fTaggedSkill02XP)
			If !((iCurrentXP - iTaggedSkill02XP) >= iReserveXP)
				fTaggedSkill02XP = 0
				iTaggedSkill02XP = 0
			EndIf
			iTaggedSkill03XP = Floor(fTaggedSkill03XP)
			If !((iCurrentXP - iTaggedSkill03XP) >= iReserveXP)
				fTaggedSkill03XP = 0
				iTaggedSkill03XP = 0
			EndIf
			iTaggedSkill04XP = Floor(fTaggedSkill04XP)
			If !((iCurrentXP - iTaggedSkill04XP) >= iReserveXP)
				fTaggedSkill04XP = 0
				iTaggedSkill04XP = 0
			EndIf
			DMN_SXPALog(gDebug, "Tagged Skills:")
			DMN_SXPALog(gDebug, "01 - " + sTaggedSkill01 + " (~" + round(fTaggedSkill01Percentage * 100) + "% | " + (fTaggedSkill01Percentage * 100) + ").")
			DMN_SXPALog(gDebug, "02 - " + sTaggedSkill02 + " (~" + round(fTaggedSkill02Percentage * 100) + "% | " + (fTaggedSkill02Percentage * 100) + ").")
			DMN_SXPALog(gDebug, "03 - " + sTaggedSkill03 + " (~" + round(fTaggedSkill03Percentage * 100) + "% | " + (fTaggedSkill03Percentage * 100) + ").")
			DMN_SXPALog(gDebug, "04 - " + sTaggedSkill04 + " (~" + round(fTaggedSkill04Percentage * 100) + "% | " + (fTaggedSkill04Percentage * 100) + ").\n\n")
			DMN_SXPALog(gDebug, "Generic XP Invested (Float):")
			DMN_SXPALog(gDebug, sTaggedSkill01 + ": " + fTaggedSkill01XP + "XP.")
			DMN_SXPALog(gDebug, sTaggedSkill02 + ": " + fTaggedSkill02XP + "XP.")
			DMN_SXPALog(gDebug, sTaggedSkill03 + ": " + fTaggedSkill03XP + "XP.")
			DMN_SXPALog(gDebug, sTaggedSkill04 + ": " + fTaggedSkill04XP + "XP.\n\n")
			DMN_SXPALog(gDebug, "Generic XP Invested (Int):")
			DMN_SXPALog(gDebug, sTaggedSkill01 + ": " + iTaggedSkill01XP + "XP.")
			DMN_SXPALog(gDebug, sTaggedSkill02 + ": " + iTaggedSkill02XP + "XP.")
			DMN_SXPALog(gDebug, sTaggedSkill03 + ": " + iTaggedSkill03XP + "XP.")
			DMN_SXPALog(gDebug, sTaggedSkill04 + ": " + iTaggedSkill04XP + "XP.\n\n")
			If (sTaggedSkill01 != "None" && iTaggedSkill01XP > 0)
				spendXP(gDebug, gTotalXP, bUseExponentialSkillCost, fSkillMultiplier, iSkillXP, iSkillXPSpent, iSkillXPSpentEffective, sSkillName, sTaggedSkill01, iTaggedSkill01XP, True)
			EndIf
			If (sTaggedSkill02 != "None" && iTaggedSkill02XP > 0)
				spendXP(gDebug, gTotalXP, bUseExponentialSkillCost, fSkillMultiplier, iSkillXP, iSkillXPSpent, iSkillXPSpentEffective, sSkillName, sTaggedSkill02, iTaggedSkill02XP, True)
			EndIf
			If (sTaggedSkill03 != "None" && iTaggedSkill03XP > 0)
				spendXP(gDebug, gTotalXP, bUseExponentialSkillCost, fSkillMultiplier, iSkillXP, iSkillXPSpent, iSkillXPSpentEffective, sSkillName, sTaggedSkill03, iTaggedSkill03XP, True)
			EndIf
			If (sTaggedSkill04 != "None" && iTaggedSkill04XP > 0)
				spendXP(gDebug, gTotalXP, bUseExponentialSkillCost, fSkillMultiplier, iSkillXP, iSkillXPSpent, iSkillXPSpentEffective, sSkillName, sTaggedSkill04, iTaggedSkill04XP, True)
			EndIf
			Int iNewXP = gTotalXP.GetValue() as Int
			DMN_SXPALog(gDebug, "Available Generic XP: " + iCurrentXP + ".")
			DMN_SXPALog(gDebug, "Remaining Generic XP: " + iNewXP + ".")
			DMN_SXPALog(gDebug, "Generic XP Reserved: " + iReserveXP + ".")
			DMN_SXPALog(gDebug, "Generic XP Spent: " + (iCurrentXP - iNewXP) + ".")
		; Once we have completed the above tasks, we can
		; free up the function to be called once more.
			gAutoSpendXPBusy.SetValue(0)
		EndIf
	EndIf
	DMN_SXPALog(gDebug, "[Ended autoSpendXP Function]\n\n")
EndFunction

Int Function getRandomXPValue(GlobalVariable gDebug, GlobalVariable gMinXP, GlobalVariable gMaxXP, Float[] fXPMultiplier, Int iIndex, Bool bUseExponentialXPGain, Bool bSilent = False) Global
	Float fStart ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	Float fRandomXPGain
	Float fXPGainBase
	Float fXPGainExponent
	Int iRandomXPGain
	If (!bSilent)
		fStart = GetCurrentRealTime()
		DMN_SXPALog(gDebug, "[Started getRandomXPValue Function]")
	EndIf
; Part 1: Getting a random XP value between the min and max XP variables.
	Int iMinXP = gMinXP.GetValue() as Int
	Int iMaxXP = gMaxXP.GetValue() as Int
	Float fRandomXP = RandomInt(iMinXP, iMaxXP)
	If (!bSilent)
		DMN_SXPALog(gDebug, "Min XP: " + iMinXP)
		DMN_SXPALog(gDebug, "Max XP: " + iMaxXP)
		DMN_SXPALog(gDebug, "Random XP (Min~Max): " + fRandomXP)
	EndIf
; Part 2: Getting the total random XP value based on the player level and formula below.
	Int iPlayerLevel = GetPlayer().GetLevel()
	If (bUseExponentialXPGain)
	; Exponential XP gain.
		fXPGainBase = 1.15
		fRandomXPGain = (pow(fXPGainBase, iPlayerLevel) + fRandomXP) * fXPMultiplier[iIndex]
	Else
	; Linear XP gain.
		fXPGainExponent = 1.60
		fRandomXPGain = pow(iPlayerLevel, fXPGainExponent) * fXPMultiplier[iIndex] + fRandomXP
	EndIf
	iRandomXPGain = ceiling(fRandomXPGain)
	; String sPrettyXP = prettyPrintXP(fRandomXPGain)
	; Notification("Skyrim XP Addon: Pretty XP Display - " + sPrettyXP)
	If (!bSilent)
		DMN_SXPALog(gDebug, "Player Level: " + iPlayerLevel + ".")
		If (bUseExponentialXPGain)
			DMN_SXPALog(gDebug, "XP System Type: Exponential.")
			DMN_SXPALog(gDebug, "XP Gain Base: " + fXPGainBase + ".")
		Else
			DMN_SXPALog(gDebug, "XP System Type: Linear.")
			DMN_SXPALog(gDebug, "XP Gain Exponent: " + fXPGainExponent + ".")
		EndIf
		DMN_SXPALog(gDebug, "XP Multiplier: " + fXPMultiplier[iIndex] + ".")
		DMN_SXPALog(gDebug, "Random XP Gain (Float): " + fRandomXPGain + ".")
		; DMN_SXPALog(gDebug, "Pretty Print XP Value: " + sPrettyXP)
		DMN_SXPALog(gDebug, "Random XP Gain (Int): " + iRandomXPGain + "." + "\n")
		fStop = GetCurrentRealTime()
		DMN_SXPALog(gDebug, "getRandomXPValue() function took " + (fStop - fStart) + " seconds to complete.")
		DMN_SXPALog(gDebug, "[Ended getRandomXPValue Function]")
	EndIf
	Return iRandomXPGain
EndFunction

Function setRandomXPValue(GlobalVariable gDebug, GlobalVariable gMinXP, GlobalVariable gMaxXP, GlobalVariable gXP, Float[] fXPMultiplier, Int iIndex, String[] sStatName, String[] sNotificationMessage, Bool bUseExponentialXPGain, Int iUpdateCount = 0, Bool bIsUpdate = False) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	Int iCurrentXP = gXP.GetValue() as Int
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
			Int k = getRandomXPValue(gDebug, gMinXP, gMaxXP, fXPMultiplier, iIndex, bUseExponentialXPGain)
			iRandomXP += k
			DMN_SXPALog(gDebug, sStatName[iIndex] + " " + "(" + (i+1) + "/" + iUpdateCount + ")" + " XP: " + k + ".")
			i += 1
			Float fRunStop = GetCurrentRealTime()
			fFunctionRunDuration = fFunctionRunDuration + (fRunStop - fRunStart)
			iFunctionRuns += 1
			If (iFunctionRuns == 10)
				Float fAverageFunctionRunDuration = fFunctionRunDuration / 10
				estimateScriptDuration(gDebug, fAverageFunctionRunDuration, iUpdateCount, "Estimated time to finish rewarding existing XP activities:")
			EndIf
		EndWhile
		Int iNewXP = iCurrentXP + iRandomXP
	; Check if the XP that will be added will cause an integer overflow, and if so, do nothing.
		If ((iCurrentXP + iRandomXP) >= 2147483647)
			MessageBox("Skyrim XP Addon\n\nYou have hit the generic XP limit, and as such, no more generic XP will be rewarded until you spend some of your generic XP.")
			DMN_SXPALog(gDebug, "Assigning the earned XP will cause an overflow. Skipping XP assignment instead!")
	; If no integer overflow is detected we can go ahead and add the random XP value.
		ElseIf ((iCurrentXP + iRandomXP) < 2147483647)
			DMN_SXPALog(gDebug, "Previous XP: " + iCurrentXP + ".")
			gXP.SetValue(iNewXP)
			DMN_SXPALog(gDebug, "XP Assigned: " + iRandomXP + ".")
			DMN_SXPALog(gDebug, "Current XP: " + gXP.GetValue() as Int + ".")
			If (bIsUpdate)
				Notification("Skyrim XP Addon: Previously detected \"" + sStatName[iIndex] + "\" (x" + iUpdateCount + "). +" + iRandomXP + "XP combined!")
			Else
				Notification(sNotificationMessage[iIndex] + " (x" + iUpdateCount + ") +" + iRandomXP + "XP combined!")
			EndIf
		Else
			DMN_SXPALog(gDebug, "WARNING: An unknown error occurred assigning XP!")
			DMN_SXPALog(gDebug, "The New XP value would have been: " + iNewXP + ".")
			DMN_SXPALog(gDebug, "The previous XP was: " + iCurrentXP + ".")
			DMN_SXPALog(gDebug, "The random XP value was: " + iRandomXP + ".")
		EndIf
	Else
		DMN_SXPALog(gDebug, "Assigning random XP for: " + sStatName[iIndex] + " now.")
		Int iRandomXP = getRandomXPValue(gDebug, gMinXP, gMaxXP, fXPMultiplier, iIndex, bUseExponentialXPGain)
		Int iNewXP = iCurrentXP + iRandomXP
	; Check if the XP that will be added will cause an integer overflow, and if so, do nothing.
		If ((iCurrentXP + iRandomXP) >= 2147483647)
			MessageBox("Skyrim XP Addon\n\nYou have hit the generic XP limit, and as such, no more generic XP will be rewarded until you spend some of your generic XP.")
			DMN_SXPALog(gDebug, "Assigning the earned XP will cause an overflow. Skipping XP assignment instead!")
	; If no integer overflow is detected we can go ahead and add the random XP value.
		ElseIf ((iCurrentXP + iRandomXP) < 2147483647)
			DMN_SXPALog(gDebug, "Previous XP: " + iCurrentXP + ".")
			gXP.SetValue(iNewXP)
			DMN_SXPALog(gDebug, "XP Assigned: " + iRandomXP + ".")
			DMN_SXPALog(gDebug, "Current XP: " + gXP.GetValue() as Int + ".")
			Notification(sNotificationMessage[iIndex] + " +" + iRandomXP + "XP!")
		Else
			DMN_SXPALog(gDebug, "WARNING: An unknown error occurred assigning XP!")
			DMN_SXPALog(gDebug, "The New XP value would have been: " + iNewXP + ".")
			DMN_SXPALog(gDebug, "The previous XP was: " + iCurrentXP + ".")
			DMN_SXPALog(gDebug, "The random XP value was: " + iRandomXP + ".")
		EndIf
	EndIf
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "setRandomXPValue() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended setRandomXPValue Function]\n\n")
EndFunction

Function rewardExistingXPActivities(GlobalVariable gDebug, GlobalVariable gMinXP, GlobalVariable gMaxXP, GlobalVariable gXP, Bool[] bXPActivityState, Float[] fXPMultiplier, Int[] iTrackedStatCount, String[] sStatName, Bool bUseExponentialXPGain, Message mMessage) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started rewardExistingXPActivities Function]")
	Bool bHitXPLimit
; Part 1: Getting a random XP value between the min and max XP variables and multiplying it by the XP activity multiplier.
	Int iMinXP = gMinXP.GetValue() as Int
	Int iMaxXP = gMaxXP.GetValue() as Int
	Float fRandomXP
; Part 2: Getting the player level.
	Int iPlayerLevel = GetPlayer().GetLevel()
; Part 3: Estimating how long the entire function should take to run, to inform the player.
	Int iCurrentXP
	Int iIndex = 0
	Int iStartXP
	Int iTotalUpdateCount
	Int iTotalXPAllocated
	iStartXP = gXP.GetValue() as Int
	While (iIndex < sStatName.Length)
		If (bXPActivityState[iIndex])
			Int iStatValue = QueryStat(sStatName[iIndex])
			Int iUpdateCount = iStatValue - iTrackedStatCount[iIndex]
			iTotalUpdateCount += iUpdateCount
			iUpdateCount = 0
			iStatValue = 0
		EndIf
		iIndex += 1
	EndWhile
	iIndex = 0
	If (iTotalUpdateCount > 0)
		Float fFunctionRunDuration = 0.00
		Int iLoopsRun = 0
		While (iLoopsRun < 101) ; Run 100 loops to get a time estimate.
			Float fRunStart = GetCurrentRealTime()
			fRandomXP = RandomInt(iMinXP, iMaxXP)
			Float fRunStop = GetCurrentRealTime()
			fFunctionRunDuration = fFunctionRunDuration + (fRunStop - fRunStart)
			iLoopsRun += 1
			If (iLoopsRun == 100) ; Once we have run 100 loops, pass the information on to our helper function.
			; We divide by 6 at the end to simulate the way we give out XP for existing activities (bulk vs. 1 by 1).
				Float fAverageFunctionRunDuration = fFunctionRunDuration / iLoopsRun / 6
				If (iTotalUpdateCount < 1000)
					estimateScriptDuration(gDebug, fAverageFunctionRunDuration, iTotalUpdateCount, "Estimated time to finish rewarding pre-existing XP activity actions:")
				Else
					estimateScriptDuration(gDebug, fAverageFunctionRunDuration, iTotalUpdateCount, "There are currently " + iTotalUpdateCount + " pre-existing XP activity actions that need to be rewarded. This may take a while and it is advised that you do not quit or reload a save until the process is complete.\n\nEstimated time to completion:\n", True)
				EndIf
			EndIf
		EndWhile
	EndIf
	If (iTotalUpdateCount == 0)
		DMN_SXPALog(gDebug, "There are no existing tracked activities that need updating!")
	Else
		DMN_SXPALog(gDebug, "An update was queued to assign XP values to existing stats!\n\n")
		iTotalUpdateCount = 0
	; Part 4: Looping through each XP activity and seeing if any of the values are greater than our stored values, if they are, update them.
		While (iIndex < sStatName.Length)
			Float fExponentialXPGainFormula
			Float fLinearXPGainFormula
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
			Float fXPGainBase = 1.15
			Float fXPGainExponent = 1.60
			Float k
			Int i = 0
			iCurrentXP = gXP.GetValue() as Int
			fRandomXP = RandomInt(iMinXP, iMaxXP)
			fExponentialXPGainFormula = (pow(fXPGainBase, iPlayerLevel) + fRandomXP) * fXPMultiplier[iIndex]
			fLinearXPGainFormula = pow(iPlayerLevel, fXPGainExponent) * fXPMultiplier[iIndex] + fRandomXP
			If (bXPActivityState[iIndex])
				Int iStatValue = QueryStat(sStatName[iIndex])
				Int iUpdateCount = iStatValue - iTrackedStatCount[iIndex]
				If (iStatValue > iTrackedStatCount[iIndex])
					iTrackedStatCount[iIndex] = iStatValue
					DMN_SXPALog(gDebug, "Beginning update for: " + sStatName[iIndex] + " (x" + iUpdateCount + ") now.")
					DMN_SXPALog(gDebug, "Min XP: " + iMinXP + ".")
					DMN_SXPALog(gDebug, "Max XP: " + iMaxXP + ".")
					DMN_SXPALog(gDebug, "Random XP (Min~Max): " + fRandomXP + ".")
					DMN_SXPALog(gDebug, "Player Level: " + iPlayerLevel + ".")
					If (bUseExponentialXPGain)
						DMN_SXPALog(gDebug, "XP System Type: Exponential.")
						DMN_SXPALog(gDebug, "XP Gain Base: " + fXPGainBase + ".")
					Else
						DMN_SXPALog(gDebug, "XP System Type: Linear.")
						DMN_SXPALog(gDebug, "XP Gain Exponent: " + fXPGainExponent + ".")
					EndIf
					DMN_SXPALog(gDebug, "XP Multiplier: " + fXPMultiplier[iIndex] + ".")
				; Part 5: Estimating the amount of times the XP activity was performed at previous levels.
					Float fActivityCount1Percent = iUpdateCount * 0.01 ; Example Input: 250 = 250 * 0.01 = 2.5. 1%.
					Float fActivityCount4Percent = iUpdateCount * 0.04 ; Example Input: 250 = 250 * 0.04 = 10. 4%.
					Float fActivityCount5Percent = iUpdateCount * 0.05 ; Example Input: 250 = 250 * 0.05 = 12.5. 5%.
					Float fActivityCount10Percent = iUpdateCount * 0.10 ; Example Input: 250 = 250 * 0.10 = 25. 10%.
					Float fActivityCount15Percent = iUpdateCount * 0.15 ; Example Input: 250 = 250 * 0.15 = 37.5. 15%.
					Float fActivityCount65Percent = iUpdateCount * 0.65 ; Example Input: 250 = 250 * 0.65 = 162.5. 65%.
				; Part 6: Calculating the amount of XP earned for the XP activity at the level thresholds.
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
						If (bUseExponentialXPGain)
							k = fExponentialXPGainFormula * fActivityCount1Percent ; Squared.
						Else
							k = fLinearXPGainFormula * fActivityCount1Percent ; Squared.
						EndIf
						fRandomXPValueFull += k
						DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount1Percent + "/" + fActivityCount1Percent + ") XP: " + k + ".")
						k = 0
					Else
						While (i < iActivityCount1Percent)
							If (bUseExponentialXPGain)
								k = fExponentialXPGainFormula ; Squared.
							Else
								k = fLinearXPGainFormula ; Squared.
							EndIf
							fRandomXPValueFull += k
							DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + (i+1) + "/" + iActivityCount1Percent + ") XP: " + k + ".")
							k = 0
							i += 1
						EndWhile
						If (bUseExponentialXPGain)
							k = fExponentialXPGainFormula * fActivityCount1PercentRemainder ; Squared.
						Else
							k = fLinearXPGainFormula * fActivityCount1PercentRemainder ; Squared.
						EndIf
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
						If (bUseExponentialXPGain)
							k = fExponentialXPGainFormula * fActivityCount4Percent ; 2 Squared.
						Else
							k = fLinearXPGainFormula * fActivityCount4Percent ; 2 Squared.
						EndIf
						fRandomXPValueHalf += k
						DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount4Percent + "/" + fActivityCount4Percent + ") XP: " + k + ".")
						k = 0
					Else
						While (i < iActivityCount4Percent)
							If (bUseExponentialXPGain)
								k = fExponentialXPGainFormula ; 2 Squared.
							Else
								k = fLinearXPGainFormula ; 2 Squared.
							EndIf
							fRandomXPValueHalf += k
							DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + (i+1) + "/" + iActivityCount4Percent + ") XP: " + k + ".")
							k = 0
							i += 1
						EndWhile
						If (bUseExponentialXPGain)
							k = fExponentialXPGainFormula * fActivityCount4PercentRemainder ; 2 Squared.
						Else
							k = fLinearXPGainFormula * fActivityCount4PercentRemainder ; 2 Squared.
						EndIf
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
						If (bUseExponentialXPGain)
							k = fExponentialXPGainFormula * fActivityCount5Percent ; 3 Squared.
						Else
							k = fLinearXPGainFormula * fActivityCount5Percent ; 3 Squared.
						EndIf
						fRandomXPValueThird += k
						DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount5Percent + "/" + fActivityCount5Percent + ") XP: " + k + ".")
						k = 0
					Else
						While (i < iActivityCount5Percent)
							If (bUseExponentialXPGain)
								k = fExponentialXPGainFormula ; 3 Squared.
							Else
								k = fLinearXPGainFormula ; 3 Squared.
							EndIf
							fRandomXPValueThird += k
							DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + (i+1) + "/" + iActivityCount5Percent + ") XP: " + k + ".")
							k = 0
							i += 1
						EndWhile
						If (bUseExponentialXPGain)
							k = fExponentialXPGainFormula * fActivityCount5PercentRemainder ; 3 Squared.
						Else
							k = fLinearXPGainFormula * fActivityCount5PercentRemainder ; 3 Squared.
						EndIf
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
						If (bUseExponentialXPGain)
							k = fExponentialXPGainFormula * fActivityCount10Percent ; 4 Squared.
						Else
							k = fLinearXPGainFormula * fActivityCount10Percent ; 4 Squared.
						EndIf
						fRandomXPValueFourth += k
						DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount10Percent + "/" + fActivityCount10Percent + ") XP: " + k + ".")
						k = 0
					Else
						While (i < iActivityCount10Percent)
							If (bUseExponentialXPGain)
								k = fExponentialXPGainFormula ; 4 Squared.
							Else
								k = fLinearXPGainFormula ; 4 Squared.
							EndIf
							fRandomXPValueFourth += k
							DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + (i+1) + "/" + iActivityCount10Percent + ") XP: " + k + ".")
							k = 0
							i += 1
						EndWhile
						If (bUseExponentialXPGain)
							k = fExponentialXPGainFormula * fActivityCount10PercentRemainder ; 4 Squared.
						Else
							k = fLinearXPGainFormula * fActivityCount10PercentRemainder ; 4 Squared.
						EndIf
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
						If (bUseExponentialXPGain)
							k = fExponentialXPGainFormula * fActivityCount15Percent ; 5 Squared.
						Else
							k = fLinearXPGainFormula * fActivityCount15Percent ; 5 Squared.
						EndIf
						fRandomXPValueFifth += k
						DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount15Percent + "/" + fActivityCount15Percent + ") XP: " + k + ".")
						k = 0
					Else
						While (i < iActivityCount15Percent)
							If (bUseExponentialXPGain)
								k = fExponentialXPGainFormula ; 5 Squared.
							Else
								k = fLinearXPGainFormula ; 5 Squared.
							EndIf
							fRandomXPValueFifth += k
							DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + (i+1) + "/" + iActivityCount15Percent + ") XP: " + k + ".")
							k = 0
							i += 1
						EndWhile
						If (bUseExponentialXPGain)
							k = fExponentialXPGainFormula * fActivityCount15PercentRemainder ; 5 Squared.
						Else
							k = fLinearXPGainFormula * fActivityCount15PercentRemainder ; 5 Squared.
						EndIf
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
						If (bUseExponentialXPGain)
							k = fExponentialXPGainFormula * fActivityCount65Percent ; 6 Squared.
						Else
							k = fLinearXPGainFormula * fActivityCount65Percent ; 6 Squared.
						EndIf
						fRandomXPValueSixth += k
						DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount65Percent + "/" + fActivityCount65Percent + ") XP: " + k + ".")
						k = 0
					Else
						While (i < iActivityCount65Percent)
							If (bUseExponentialXPGain)
								k = fExponentialXPGainFormula ; 6 Squared.
							Else
								k = fLinearXPGainFormula ; 6 Squared.
							EndIf
							fRandomXPValueSixth += k
							DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + (i+1) + "/" + iActivityCount65Percent + ") XP: " + k + ".")
							k = 0
							i += 1
						EndWhile
						If (bUseExponentialXPGain)
							k = fExponentialXPGainFormula * fActivityCount65PercentRemainder ; 6 Squared.
						Else
							k = fLinearXPGainFormula * fActivityCount65PercentRemainder ; 6 Squared.
						EndIf
						fRandomXPValueSixth += k
						DMN_SXPALog(gDebug, sStatName[iIndex] + " (" + fActivityCount65PercentRemainder + "/" + fActivityCount65PercentRemainder + ") XP: " + k + ".")
						k = 0
						i = 0
					EndIf
					DMN_SXPALog(gDebug, "Total amount of XP gained for " + sStatName[iIndex] + " at level " +  iPlayerLevel / 6 + ": " + fRandomXPValueSixth + ".\n\n")
					fRandomXPValueSixthTotal += fRandomXPValueSixth
					fRandomXPValueSixth = 0
				; Part 7: Calculating the total amount of XP earned for the XP activity.
					Float fFinalRandomXPValue = fRandomXPValueFullTotal + fRandomXPValueHalfTotal + fRandomXPValueThirdTotal + fRandomXPValueFourthTotal + fRandomXPValueFifthTotal + fRandomXPValueSixthTotal
					Int iRandomXPValue = round(fFinalRandomXPValue)
					DMN_SXPALog(gDebug, "Total amount of " + sStatName[iIndex] + ":" + " " + iUpdateCount + ".")
					DMN_SXPALog(gDebug, "Total amount of XP gained for " + sStatName[iIndex] + ":" + " " + iRandomXPValue + ".")
				; Part 8: Adding the total amount of XP earned for the XP activity to the total experience points.
					Int iNewXP = iCurrentXP + iRandomXPValue
				; Check if the XP that will be added will cause an integer overflow, and if so, do nothing.
					If ((iCurrentXP + iRandomXPValue) >= 2147483647)
						bHitXPLimit = True
						iRandomXPValue = 0
						iUpdateCount = 0
						DMN_SXPALog(gDebug, "Assigning the earned XP will cause an overflow. Skipping XP assignment instead!")
						DMN_SXPALog(gDebug, "WARNING: Assigning the earned XP will cause an overflow. Skipping XP assignment instead!")
				; If no integer overflow is detected we can go ahead and add the random XP value.
					ElseIf ((iCurrentXP + iRandomXPValue) < 2147483647)
						DMN_SXPALog(gDebug, "XP To Assign: " + iRandomXPValue + ".")
						If (iUpdateCount > 1)
							debugNotification(gDebug, "Skyrim XP Addon DEBUG: Previously detected \"" + sStatName[iIndex] + "\" (x" + iUpdateCount + "). +" + iRandomXPValue + "XP combined!")
						Else
							debugNotification(gDebug, "Skyrim XP Addon DEBUG: Previously detected \"" + sStatName[iIndex] + "\" (x" + iUpdateCount + "). +" + iRandomXPValue + "XP!")
						EndIf
					Else
						DMN_SXPALog(gDebug, "WARNING: An unknown error occurred assigning XP!")
						DMN_SXPALog(gDebug, "The New XP value would have been: " + iNewXP + ".")
						DMN_SXPALog(gDebug, "The previous XP was: " + iCurrentXP + ".")
						DMN_SXPALog(gDebug, "The random XP value was: " + iRandomXPValue + ".")
					EndIf
					DMN_SXPALog(gDebug, "Completed update for: " + sStatName[iIndex] + ".\n\n")
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
					iUpdateCount = 0
					iStatValue = 0
				EndIf
			EndIf
			iIndex += 1
		EndWhile
		If (iTotalXPAllocated > 0)
			Int iButton = mMessage.Show(iTotalXPAllocated)
			Int iNewXP = iCurrentXP + iTotalXPAllocated
			If (iButton == 0)
			; [Accept XP]
				If (iNewXP < 2147483647)
					DMN_SXPALog(gDebug, "Previous XP: " + iStartXP + ".")
					gXP.SetValue(iNewXP)
					DMN_SXPALog(gDebug, "Current XP: " + gXP.GetValue() as Int + ".")
					DMN_SXPALog(gDebug, "XP Assigned: " + (iNewXP - iStartXP) + ".\n\n")
				Else
					gXP.SetValue(2147483647)
				EndIf
		; Show a notification that combines all previously earned XP and activity count totals and displays it to the player.
			If (iTotalUpdateCount > 1)
				Notification("Skyrim XP Addon: Gained " + iTotalXPAllocated + " XP across " + iTotalUpdateCount + " tracked activity events.")
			ElseIf (iTotalUpdateCount > 0)
				Notification("Skyrim XP Addon: Gained " + iTotalXPAllocated + " XP across " + iTotalUpdateCount + " tracked activity event.")
			EndIf
			ElseIf (iButton == 1)
			; [Discard XP]
				Notification("Skyrim XP Addon: No XP will be rewarded for existing XP activities that were enabled.")
				DMN_SXPALog(gDebug, "Total XP To Be Assigned: " + (iNewXP - iStartXP) + ".")
				DMN_SXPALog(gDebug, "The user chose to not accept the XP reward. Skipping XP assignment...\n\n")
			EndIf
		EndIf
	; Show a message box to the player informing them that they have reached the generic XP limit.
		If (bHitXPLimit)
			MessageBox("Skyrim XP Addon\n\nYou have hit the generic XP limit, and as such, no more generic XP will be rewarded until you spend some of your generic XP.")
		EndIf
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

Function updatePlayerStats(GlobalVariable gDebug, GlobalVariable gMinXP, GlobalVariable gMaxXP, GlobalVariable gXP, Bool[] bXPActivityState, Float[] fXPMultiplier, Int[] iTrackedStatCount, String[] sStatName, String[] sNotificationMessage, Bool bUseExponentialXPGain, Bool bUpdateStats = False) Global
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
					setRandomXPValue(gDebug, gMinXP, gMaxXP, gXP, fXPMultiplier, iIndex, sStatName, sNotificationMessage, bUseExponentialXPGain, iUpdateCount, True)
				ElseIf (iUpdateCount > 1)
					setRandomXPValue(gDebug, gMinXP, gMaxXP, gXP, fXPMultiplier, iIndex, sStatName, sNotificationMessage, bUseExponentialXPGain, iUpdateCount)
				Else
					setRandomXPValue(gDebug, gMinXP, gMaxXP, gXP, fXPMultiplier, iIndex, sStatName, sNotificationMessage, bUseExponentialXPGain)
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

Function estimateScriptDuration(GlobalVariable gDebug, Float fAverageFunctionRunDuration, Int iUpdateCount, String sNotificationMessage, Bool bUseMessageBox = False) Global
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
	If (iFunctionDurationMinutes > 2)
		If (!bUseMessageBox)
			Notification("Skyrim XP Addon: " + sNotificationMessage + " " + iFunctionDurationMinutes + " minutes and " + iFunctionDurationSeconds + " seconds.")
		Else
			MessageBox("Skyrim XP Addon:\n\n" + sNotificationMessage + " " + iFunctionDurationMinutes + " minutes and " + iFunctionDurationSeconds + " seconds.")
		EndIf
	ElseIf (iFunctionDurationMinutes > 1)
		If (!bUseMessageBox)
			Notification("Skyrim XP Addon: " + sNotificationMessage + " " + iFunctionDurationMinutes + " minutes and " + iFunctionDurationSeconds + " seconds.")
		Else
			MessageBox("Skyrim XP Addon:\n\n" + sNotificationMessage + " " + iFunctionDurationMinutes + " minutes and " + iFunctionDurationSeconds + " seconds.")
		EndIf
	ElseIf (iFunctionDurationMinutes == 1)
		If (!bUseMessageBox)
			Notification("Skyrim XP Addon: " + sNotificationMessage + " " + iFunctionDurationMinutes + " minute and " + iFunctionDurationSeconds + " seconds.")
		Else
			MessageBox("Skyrim XP Addon:\n\n" + sNotificationMessage + " " + iFunctionDurationMinutes + " minute and " + iFunctionDurationSeconds + " seconds.")
		EndIf
	ElseIf (iFunctionDurationMinutes < 1)
		If (!bUseMessageBox)
			Notification("Skyrim XP Addon: " + sNotificationMessage + " " + iFunctionDurationSeconds + " seconds.")
		Else
			MessageBox("Skyrim XP Addon:\n\n" + sNotificationMessage + " " + iFunctionDurationSeconds + " seconds.")
		EndIf
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

Function resetSXPAProgress(GlobalVariable gDebug, GlobalVariable gMonitoring, GlobalVariable gMinXP, GlobalVariable gMaxXP, GlobalVariable gXP, Bool[] bXPActivityState, Float[] fXPMultiplier, Int[] iSkillXP, Int[] iSkillXPSpent, Int[] iSkillXPSpentEffective, Int[] iTrackedStatCount, String[] sSkillName, String[] sStatName, Bool bUseExponentialXPGain, Message mMessage) Global
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
	rewardExistingXPActivities(gDebug, gMinXP, gMaxXP, gXP, bXPActivityState, fXPMultiplier, iTrackedStatCount, sStatName, bUseExponentialXPGain, mMessage)
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

Function setSXPADefaults(GlobalVariable gDebug, GlobalVariable gMonitoring, GlobalVariable gMinXP, GlobalVariable gMaxXP, Bool[] bXPActivityState, Book akConfiguratorBook, Float[] fSkillMultiplier, Float[] fXPMultiplier, Int iConfiguratorType, Int iPassiveMonitoring, Spell akConfiguratorSpell) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started setSXPADefaults Function]\n\n")
; Set the Skill Multipliers to default values.
	setSkillMultiplierDefaults(gDebug, fSkillMultiplier)
; Set the XP Activity states to default.
	setXPActivityStateDefaults(gDebug, bXPActivityState)
; Set the XP Multipliers to default values.
	setXPMultiplierDefaults(gDebug, fXPMultiplier)
; Set the minimum XP reward to default.
	gMinXP.SetValue(250) 
; Set the maximum XP reward to default.
	gMaxXP.SetValue(1000)
; Remove the book configurator, if it exists.
	giveConfiguratorBook(akConfiguratorBook, True)
; Add the spell configurator, if the player doesn't already have it.
	giveConfiguratorSpell(akConfiguratorSpell)
; Set the configurator to default (skill).
	iConfiguratorType = 1
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

Int Function getXPActivityStateForMCM(String sXPActivityName, GlobalVariable gDebug, Bool[] bXPActivityState, String[] sStatName) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started getXPActivityStateForMCM Function]")
	Int iIndex = sStatName.Find(sXPActivityName)
	Bool bState = bXPActivityState[iIndex]
	DMN_SXPALog(gDebug, sStatName[iIndex] + " state is set to " + bState + ".")
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "getXPActivityStateForMCM() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended getXPActivityStateForMCM Function]\n\n")
	Return bState as Int
EndFunction

Float Function getXPActivityMultiplierForMCM(String sXPActivityName, GlobalVariable gDebug, Float[] fXPMultiplier, String[] sStatName, Bool bGetDefault = False) Global
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started getXPActivityMultiplierForMCM Function]")
	Float fMult
	Int iIndex = sStatName.Find(sXPActivityName)
	If (!bGetDefault)
		fMult = fXPMultiplier[iIndex]
		DMN_SXPALog(gDebug, sStatName[iIndex] + " multiplier is set to " + fMult + ".")
	ElseIf (bGetDefault)
		fMult = setXPMultiplierDefaults(gDebug, fXPMultiplier, False, iIndex, True)
		DMN_SXPALog(gDebug, sStatName[iIndex] + " default multiplier is  " + fMult + ".")
	EndIf
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "getXPActivityMultiplierForMCM() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended getXPActivityMultiplierForMCM Function]\n\n")
	Return fMult as Float
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

Function setSkillMultiplierDefaults(GlobalVariable gDebug, Float[] fSkillMultiplier) Global
; Resets the default Skill Multiplier values.
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started setSkillMultiplierDefaults Function]")
	DMN_SXPALog(gDebug, "Skill Multiplier previous values: " + fSkillMultiplier + ".")
	fSkillMultiplier[0] = 1.00 ; Archery
	fSkillMultiplier[1] = 1.00 ; Block
	fSkillMultiplier[2] = 1.00 ; Heavy Armor
	fSkillMultiplier[3] = 1.00 ; One-Handed
	fSkillMultiplier[4] = 0.125 ; Smithing
	fSkillMultiplier[5] = 1.00 ; Two-Handed
	fSkillMultiplier[6] = 1.00 ; Alteration
	fSkillMultiplier[7] = 1.00 ; Conjuration
	fSkillMultiplier[8] = 1.00 ; Destruction
	fSkillMultiplier[9] = 0.50 ; Enchanting
	fSkillMultiplier[10] = 1.00 ; Illusion
	fSkillMultiplier[11] = 1.00 ; Restoration
	fSkillMultiplier[12] = 0.80 ; Alchemy
	fSkillMultiplier[13] = 1.00 ; Light Armor
	fSkillMultiplier[14] = 0.125 ; Lockpicking
	fSkillMultiplier[15] = 0.125 ; Pickpocket
	fSkillMultiplier[16] = 0.25 ; Sneak
	fSkillMultiplier[17] = 1.00 ; Speech
	DMN_SXPALog(gDebug, "Skill Multiplier new values: " + fSkillMultiplier + ".")
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "setSkillMultiplierDefaults() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended setSkillMultiplierDefaults Function]\n\n")
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
	bXPActivityState[39] = True ; Locks Picked
	bXPActivityState[40] = True ; Items Pickpocketed
	bXPActivityState[41] = False ; Jail Escapes
	bXPActivityState[42] = True ; Items Stolen
	bXPActivityState[43] = False ; Mauls
	bXPActivityState[44] = False ; Necks Bitten
	bXPActivityState[45] = False ; Days as a Werewolf
	bXPActivityState[46] = False ; Days as a Vampire
	bXPActivityState[47] = True ; Dungeons Cleared
	bXPActivityState[48] = False ; Days Passed
	bXPActivityState[49] = False ; Chests Looted
	bXPActivityState[50] = False ; Horses Owned
	bXPActivityState[51] = False ; Houses Owned
	bXPActivityState[52] = False ; Stores Invested In
	bXPActivityState[53] = False ; Barters
	bXPActivityState[54] = False ; Bribes
	DMN_SXPALog(gDebug, "XP Activity State new values: " + bXPActivityState + ".")
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "setXPActivityStateDefaults() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended setXPActivityStateDefaults Function]\n\n")
EndFunction

Float Function setXPMultiplierDefaults(GlobalVariable gDebug, Float[] fXPMultiplier, Bool bSingleUpdate = False, Int iArrayIndex = 0, Bool bGetDefault = False) Global
; Resets the default XP Multiplier values.
	Float fStart = GetCurrentRealTime() ; Log the time the function started running.
	Float fStop ; Log the time the function stopped running.
	DMN_SXPALog(gDebug, "[Started setXPMultiplierDefaults Function]")
	Float[] fMult = New Float[55]
	fMult[0] = 0.40 ; Locations Discovered
	fMult[1] = 8.00 ; Standing Stones Found
	fMult[2] = 0.40 ; Nirnroots Found
	fMult[3] = 0.25 ; Books Read
	fMult[4] = 0.05 ; Ingredients Harvested
	fMult[5] = 0.07 ; Wings Plucked
	fMult[6] = 0.80 ; Persuasions
	fMult[7] = 0.80 ; Intimidations
	fMult[8] = 0.20 ; Misc Objectives Completed
	fMult[9] = 6.00 ; Main Quests Completed
	fMult[10] = 4.00 ; Side Quests Completed
	fMult[11] = 3.00 ; The Companions Quests Completed
	fMult[12] = 3.00 ; College of Winterhold Quests Completed
	fMult[13] = 3.00 ; Thieves' Guild Quests Completed
	fMult[14] = 3.00 ; The Dark Brotherhood Quests Completed
	fMult[15] = 5.00 ; Civil War Quests Completed
	fMult[16] = 3.00 ; Daedric Quests Completed
	fMult[17] = 10.00 ; Questlines Completed
	fMult[18] = 0.20 ; People Killed
	fMult[19] = 0.15 ; Animals Killed
	fMult[20] = 0.30 ; Creatures Killed
	fMult[21] = 0.30 ; Undead Killed
	fMult[22] = 0.60 ; Daedra Killed
	fMult[23] = 0.60 ; Automatons Killed
	fMult[24] = 0.30 ; Weapons Disarmed
	fMult[25] = 2.00 ; Brawls Won
	fMult[26] = 0.10 ; Bunnies Slaughtered
	fMult[27] = 7.00 ; Dragon Souls Collected
	fMult[28] = 1.00 ; Words Of Power Learned
	fMult[29] = 3.00 ; Words Of Power Unlocked
	fMult[30] = 6.00 ; Shouts Mastered
	fMult[31] = 0.20 ; Souls Trapped
	fMult[32] = 0.30 ; Magic Items Made
	fMult[33] = 0.25 ; Weapons Improved
	fMult[34] = 0.50 ; Weapons Made
	fMult[35] = 0.25 ; Armor Improved
	fMult[36] = 0.50 ; Armor Made
	fMult[37] = 0.10 ; Potions Mixed
	fMult[38] = 0.10 ; Poisons Mixed
	fMult[39] = 0.50 ; Locks Picked
	fMult[40] = 0.05 ; Items Pickpocketed
	fMult[41] = 3.00 ; Jail Escapes
	fMult[42] = 0.02 ; Items Stolen
	fMult[43] = 0.20 ; Mauls
	fMult[44] = 0.40 ; Necks Bitten
	fMult[45] = 0.10 ; Days as a Werewolf
	fMult[46] = 0.10 ; Days as a Vampire
	fMult[47] = 4.00 ; Dungeons Cleared
	fMult[48] = 0.10 ; Days Passed
	fMult[49] = 0.05 ; Chests Looted
	fMult[50] = 3.00 ; Horses Owned
	fMult[51] = 5.00 ; Houses Owned
	fMult[52] = 2.50 ; Stores Invested In
	fMult[53] = 0.15 ; Barters
	fMult[54] = 1.00 ; Bribes
	If (!bSingleUpdate && !bGetDefault)
		DMN_SXPALog(gDebug, "XP Multiplier previous values: " + fXPMultiplier + ".")
		Int iIndex = 0
		While (iIndex < fMult.Length)
			fXPMultiplier[iIndex] = fMult[iIndex]
			iIndex += 1
		EndWhile
		DMN_SXPALog(gDebug, "XP Multiplier new values: " + fXPMultiplier + ".")
		Return 0
	ElseIf (bSingleUpdate)
	; If called for a single update, set the value as passed in.
		DMN_SXPALog(gDebug, "Previous array value: " + fXPMultiplier[iArrayIndex] + ".")
		fXPMultiplier[iArrayIndex] = fMult[iArrayIndex]
		DMN_SXPALog(gDebug, "Set array value to default: " + fXPMultiplier[iArrayIndex] + ".")
		Return 0
	ElseIf (bGetDefault)
		Float fMultDefault = fMult[iArrayIndex]
		Return fMultDefault
	EndIf
	fStop = GetCurrentRealTime()
	DMN_SXPALog(gDebug, "setXPMultiplierDefaults() function took " + (fStop - fStart) + " seconds to complete.")
	DMN_SXPALog(gDebug, "[Ended setXPMultiplierDefaults Function]\n\n")
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

String Function convertSkillName(String sSkillName, Bool bInternal = False) Global
; Certain skills have differing internal and in-game names or formatting, such as
; "Archery" being "Marksman" internally or "Heavy Armor" being "HeavyArmor" internally.
; This function aims to correct that for script usage elsewhere.
; The bInternal parameter is used for internal calculations, reverse operation.
;----
;Internal to pretty print.
	String sConvertedSkillName = sSkillName
	If (sSkillName == "HeavyArmor" && !bInternal)
		sConvertedSkillName = "Heavy Armor"
	ElseIf (sSkillName == "LightArmor" && !bInternal)
		sConvertedSkillName = "Light Armor"
	ElseIf (sSkillName == "Marksman" && !bInternal)
		sConvertedSkillName = "Archery"
	ElseIf (sSkillName == "OneHanded" && !bInternal)
		sConvertedSkillName = "One-Handed"
	ElseIf (sSkillName == "Speechcraft" && !bInternal)
		sConvertedSkillName = "Speech"
	ElseIf (sSkillName == "TwoHanded" && !bInternal)
		sConvertedSkillName = "Two-Handed"
	EndIf
;Pretty print to internal.
	If (sSkillName == "Heavy Armor" && bInternal)
		sConvertedSkillName = "HeavyArmor"
	ElseIf (sSkillName == "Light Armor" && bInternal)
		sConvertedSkillName = "LightArmor"
	ElseIf (sSkillName == "Archery" && bInternal)
		sConvertedSkillName = "Marksman"
	ElseIf (sSkillName == "One-Handed" && bInternal)
		sConvertedSkillName = "OneHanded"
	ElseIf (sSkillName == "Speech" && bInternal)
		sConvertedSkillName = "Speechcraft"
	ElseIf (sSkillName == "Two-Handed" && bInternal)
		sConvertedSkillName = "TwoHanded"
	EndIf
	Return sConvertedSkillName
EndFunction

Int Function indexSkillName(String sSkillName) Global
; Creates an index listing from 1-18 for all Vanilla skill names so that
; they can be used elsewhere in scripts.
	Int iSkillIndex
	If (sSkillName == "Archery")
		iSkillIndex = 1
	ElseIf (sSkillName == "Block")
		iSkillIndex = 2
	ElseIf (sSkillName == "Heavy Armor")
		iSkillIndex = 3
	ElseIf (sSkillName == "One-Handed")
		iSkillIndex = 4
	ElseIf (sSkillName == "Smithing")
		iSkillIndex = 5
	ElseIf (sSkillName == "Two-Handed")
		iSkillIndex = 6
	ElseIf (sSkillName == "Alteration")
		iSkillIndex = 7
	ElseIf (sSkillName == "Conjuration")
		iSkillIndex = 8
	ElseIf (sSkillName == "Destruction")
		iSkillIndex = 9
	ElseIf (sSkillName == "Enchanting")
		iSkillIndex = 10
	ElseIf (sSkillName == "Illusion")
		iSkillIndex = 11
	ElseIf (sSkillName == "Restoration")
		iSkillIndex = 12
	ElseIf (sSkillName == "Alchemy")
		iSkillIndex = 13
	ElseIf (sSkillName == "Light Armor")
		iSkillIndex = 14
	ElseIf (sSkillName == "Lockpicking")
		iSkillIndex = 15
	ElseIf (sSkillName == "Pickpocket")
		iSkillIndex = 16
	ElseIf (sSkillName == "Sneak")
		iSkillIndex = 17
	ElseIf (sSkillName == "Speech")
		iSkillIndex = 18
	Else
	; An error occured.
		iSkillIndex = -1
	EndIf
	Return iSkillIndex
EndFunction
