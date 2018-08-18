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

ScriptName DMN_SXPAConfiguratorMenu Extends Quest

{Temporary mod configuration script pre-MCM.}

Import Debug
Import Game
Import Utility
Import DMN_SXPAFunctions

GlobalVariable Property DMN_SXPAActiveMonitoring Auto
GlobalVariable Property DMN_SXPAAutomaticXPSpending Auto
GlobalVariable Property DMN_SXPAExperienceMin Auto
GlobalVariable Property DMN_SXPAExperienceMax Auto
GlobalVariable Property DMN_SXPAExperiencePoints Auto

Message Property DMN_SXPAConfigMenu Auto
Message Property DMN_SXPAConfigMenuMiscellaneous Auto
Message Property DMN_SXPAConfigMenuMiscellaneousDebugSettings Auto
Message Property DMN_SXPAConfigMenuMiscellaneousModCompatibility01 Auto
Message Property DMN_SXPAConfigMenuMiscellaneousModCompatibility01_1 Auto
Message Property DMN_SXPAConfigMenuMiscellaneousResetConfirmation Auto
Message Property DMN_SXPAConfigMenuMiscellaneousWipeConfirmation Auto
Message Property DMN_SXPAConfigMenuTracking Auto
Message Property DMN_SXPAConfigMenuTrackingType Auto
Message Property DMN_SXPAConfigMenuTrackingActivityCategories Auto
Message Property DMN_SXPAConfigMenuTrackingActivityCategoriesCombat01 Auto
Message Property DMN_SXPAConfigMenuTrackingActivityCategoriesCombat02 Auto
Message Property DMN_SXPAConfigMenuTrackingActivityCategoriesCrafting01 Auto
Message Property DMN_SXPAConfigMenuTrackingActivityCategoriesCrafting02 Auto
Message Property DMN_SXPAConfigMenuTrackingActivityCategoriesCrime Auto
Message Property DMN_SXPAConfigMenuTrackingActivityCategoriesGeneral01 Auto
Message Property DMN_SXPAConfigMenuTrackingActivityCategoriesGeneral02 Auto
Message Property DMN_SXPAConfigMenuTrackingActivityCategoriesGeneral03 Auto
Message Property DMN_SXPAConfigMenuTrackingActivityCategoriesMagic Auto
Message Property DMN_SXPAConfigMenuTrackingActivityCategoriesQuests01 Auto
Message Property DMN_SXPAConfigMenuTrackingActivityCategoriesQuests02 Auto
Message Property DMN_SXPAConfigMenuXP Auto
Message Property DMN_SXPAConfigMenuXPAutomaticSpending Auto
Message Property DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkills Auto
Message Property DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsChoices01 Auto
Message Property DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsChoices02 Auto
Message Property DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsChoices03 Auto
Message Property DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsPriority Auto
Message Property DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsSlot01 Auto
Message Property DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsSlot02 Auto
Message Property DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsSlot03 Auto
Message Property DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsSlot04 Auto
Message Property DMN_SXPAConfigMenuXPMinMax Auto
Message Property DMN_SXPAConfigMenuXPMinMaxRewardMax Auto
Message Property DMN_SXPAConfigMenuXPMinMaxRewardMin Auto
Message Property DMN_SXPAConfigMenuXPMultiplierCategories Auto
Message Property DMN_SXPAConfigMenuXPMultiplierCategoriesCombat01 Auto
Message Property DMN_SXPAConfigMenuXPMultiplierCategoriesCombat02 Auto
Message Property DMN_SXPAConfigMenuXPMultiplierCategoriesCrafting01 Auto
Message Property DMN_SXPAConfigMenuXPMultiplierCategoriesCrafting02 Auto
Message Property DMN_SXPAConfigMenuXPMultiplierCategoriesCrime Auto
Message Property DMN_SXPAConfigMenuXPMultiplierCategoriesGeneral01 Auto
Message Property DMN_SXPAConfigMenuXPMultiplierCategoriesGeneral02 Auto
Message Property DMN_SXPAConfigMenuXPMultiplierCategoriesGeneral03 Auto
Message Property DMN_SXPAConfigMenuXPMultiplierCategoriesMagic Auto
Message Property DMN_SXPAConfigMenuXPMultiplierCategoriesQuests01 Auto
Message Property DMN_SXPAConfigMenuXPMultiplierCategoriesQuests02 Auto
Message Property DMN_SXPAConfigMenuXPMultiplierValues Auto
Message Property DMN_SXPAConfigMenuXPSystemType Auto
Message Property DMN_SXPAConfigMenuXPSystemTypeConfigure Auto
Message Property DMN_SXPAConfigMenuSpendXP Auto
Message Property DMN_SXPAConfigMenuSpendXPCombat Auto
Message Property DMN_SXPAConfigMenuSpendXPMagic Auto
Message Property DMN_SXPAConfigMenuSpendXPStealth Auto
Message Property DMN_SXPAConfigMenuSpendXPAmount Auto

Book Property DMN_SXPAConfiguratorBook Auto
{The mod configurator in book form. Auto-Fill.}
Spell Property DMN_SXPAConfiguratorSpell Auto
{The mod configurator in spell form. Auto-Fill.}

DMN_SXPAEventHandler Property DMN_SXPAEH Auto
DMN_SXPAPlayerAlias Property DMN_SXPAPA Auto

Function configureMod(Bool bMenu = True, Int iButton = 0, Int iMenu = 0)
; Stop further config menu activation until we finish processing this request.
	GotoState("configuring")
	While (bMenu)
		Bool bActiveMonitoringEnabled
		Bool bXPActivityState
		Float fMultiplierLocationsDiscovered
		Float fMultiplierStandingStonesFound
		Float fMultiplierNirnrootsFound
		Float fMultiplierBooksRead
		Float fMultChoice
		Int iTagSkillChosen
		Int iTagSkillPriority
		Int iXPActivityIndex
		Int minXP
		Int maxXP
		String sXPActivityName
		Float[] fMultOption = New Float[8]
		fMultOption[0] = 0.10
		fMultOption[1] = 0.25
		fMultOption[2] = 0.40
		fMultOption[3] = 0.80
		fMultOption[4] = 1.00
		fMultOption[5] = 3.00
		fMultOption[6] = 6.00
		fMultOption[7] = 10.00
	; Prevent any possible issues with recycling the iButton.
		If (iButton == -1)
	; Show the Main Config menu.
		ElseIf (iMenu == 0)
			iButton = DMN_SXPAConfigMenu.Show()
			If (iButton == 0)
			; [Spend XP]
				iMenu = 7
			ElseIf (iButton == 1)
			; [Tracking Options]
				iMenu = 1
			ElseIf (iButton == 2)
			; [XP Settings]
				iMenu = 2
			ElseIf (iButton == 3)
			; [Miscellaneous]
				iMenu = 24
			ElseIf (iButton == 4)
			; [Exit]
				bMenu = False
			EndIf
	; Show the Tracking Options menu.
	; -------------------------------
		ElseIf (iMenu == 1)
			iButton = DMN_SXPAConfigMenuTracking.Show()
			If (iButton == 0)
			; [Tracked Activities]
				iMenu = 11
			ElseIf (iButton == 1)
			; [Tracking Type]
				iMenu = 12
			ElseIf (iButton == 2)
			; [Return To Main Config]
				iMenu = 0
			ElseIf (iButton == 3)
			; [X]
				bMenu = False
			EndIf
	; Show the XP Settings menu.
	; --------------------------
		ElseIf (iMenu == 2)
			iButton = DMN_SXPAConfigMenuXP.Show()
			If (iButton == 0)
			; [Configure Automatic XP Spending]
				iMenu = 29
			ElseIf (iButton == 1)
			; [Configure XP System Type]
				iMenu = 35
			ElseIf (iButton == 2)
			; [Configure Min/Max XP]
				iMenu = 3
			ElseIf (iButton == 3)
			; [Configure Multipliers]
				iMenu = 4
			ElseIf (iButton == 4)
				iMenu = 0
			ElseIf (iButton == 5)
			; [X]
				bMenu = False
			EndIf
	; Show the Configure Min/Max XP menu.
	; -----------------------------------
		ElseIf (iMenu == 3)
			iButton = DMN_SXPAConfigMenuXPMinMax.Show()
			If (iButton == 0)
			; [Minimum Base XP Reward]
				iMenu = 5
			ElseIf (iButton == 1)
			; [Maximum Base XP Reward]
				iMenu = 6
			ElseIf (iButton == 2)
			; [Return to XP Settings]
				iMenu = 2
			ElseIf (iButton == 3)
			; [X]
				bMenu = False
			EndIf
	; Show the Configure Multipliers menu.
	; -----------------------------------
		ElseIf (iMenu == 4)
			Float fMult
			iButton = DMN_SXPAConfigMenuXPMultiplierCategories.Show()
			If (iButton == 0)
			; [General]
				iMenu = 40
			ElseIf (iButton == 1)
			; [Quests]
				iMenu = 43
			ElseIf (iButton == 2)
			; [Combat]
				iMenu = 45
			ElseIf (iButton == 3)
			; [Magic]
				iMenu = 47
			ElseIf (iButton == 4)
			; [Crafting]
				iMenu = 48
			ElseIf (iButton == 5)
			; [Crime]
				iMenu = 50
			ElseIf (iButton == 6)
			; [Return to XP Settings]
				iMenu = 2
			ElseIf (iButton == 7)
			; [X]
				bMenu = False
			EndIf
	; Show the Multiplier Categories - Activities - General 01 menu.
	; -------------------------------------------------------------
		ElseIf (iMenu == 40)
			Float i01 = getXPActivityMultiplierForMCM("Mauls", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i010 = getXPActivityMultiplierForMCM("Mauls", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i02 = getXPActivityMultiplierForMCM("Necks Bitten", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i020 = getXPActivityMultiplierForMCM("Necks Bitten", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i03 = getXPActivityMultiplierForMCM("Days as a Werewolf", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i030 = getXPActivityMultiplierForMCM("Days as a Werewolf", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i04 = getXPActivityMultiplierForMCM("Days as a Vampire", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i040 = getXPActivityMultiplierForMCM("Days as a Vampire", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i05 = getXPActivityMultiplierForMCM("Locations Discovered", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i050 = getXPActivityMultiplierForMCM("Locations Discovered", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i06 = getXPActivityMultiplierForMCM("Dungeons Cleared", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i060 = getXPActivityMultiplierForMCM("Dungeons Cleared", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float fMult
			Bool bReset
			iButton = DMN_SXPAConfigMenuXPMultiplierCategoriesGeneral01.Show(i01, i02, i03, i04, i05, i06)
			If (iButton == 0)
			; [Mauls]
				sXPActivityName = "Mauls"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i01, i010)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 01]
					iMenu = 40
				EndIf
			ElseIf (iButton == 1)
			; [Necks Bitten]
				sXPActivityName = "Necks Bitten"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i02, i020)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 01]
					iMenu = 40
				EndIf
			ElseIf (iButton == 2)
			; [Days as a Werewolf]
				sXPActivityName = "Days as a Werewolf"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i03, i030)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 01]
					iMenu = 40
				EndIf
			ElseIf (iButton == 3)
			; [Days as a Vampire]
				sXPActivityName = "Days as a Vampire"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i04, i040)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 01]
					iMenu = 40
				EndIf
			ElseIf (iButton == 4)
			; [Locations Discovered]
				sXPActivityName = "Locations Discovered"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i05, i050)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 01]
					iMenu = 40
				EndIf
			ElseIf (iButton == 5)
			; [Locations Cleared]
				sXPActivityName = "Dungeons Cleared"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i06, i060)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 01]
					iMenu = 40
				EndIf
			ElseIf (iButton == 6)
			; [>>]
				iMenu = 41
			ElseIf (iButton == 7)
			; [Return to Configure Multipliers]
				iMenu = 4
			ElseIf (iButton == 8)
			; [X]
				bMenu = False
			EndIf
			If (bReset)
				setXPMultiplierDefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, True, iXPActivityIndex)
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to its default value!")
			EndIf
			If (fMult > 0)
				DMN_SXPAEH.fXPMultiplier[iXPActivityIndex] = fMult
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to " + fMult + ".")
				fMult = 0
			EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			bReset = False
	; Show the Multiplier Categories - Activities - General 02 menu.
	; -------------------------------------------------------------
		ElseIf (iMenu == 41)
			Float i01 = getXPActivityMultiplierForMCM("Days Passed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i010 = getXPActivityMultiplierForMCM("Days Passed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i02 = getXPActivityMultiplierForMCM("Standing Stones Found", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i020 = getXPActivityMultiplierForMCM("Standing Stones Found", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i03 = getXPActivityMultiplierForMCM("Chests Looted", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i030 = getXPActivityMultiplierForMCM("Chests Looted", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i04 = getXPActivityMultiplierForMCM("Books Read", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i040 = getXPActivityMultiplierForMCM("Books Read", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i05 = getXPActivityMultiplierForMCM("Horses Owned", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i050 = getXPActivityMultiplierForMCM("Horses Owned", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i06 = getXPActivityMultiplierForMCM("Houses Owned", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i060 = getXPActivityMultiplierForMCM("Houses Owned", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float fMult
			Bool bReset
			iButton = DMN_SXPAConfigMenuXPMultiplierCategoriesGeneral02.Show(i01, i02, i03, i04, i05, i06)
			If (iButton == 0)
			; [Days Passed]
				sXPActivityName = "Days Passed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i01, i010)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 02]
					iMenu = 41
				EndIf
			ElseIf (iButton == 1)
			; [Standing Stones Found]
				sXPActivityName = "Standing Stones Found"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i02, i020)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 02]
					iMenu = 41
				EndIf
			ElseIf (iButton == 2)
			; [Chests Looted]
				sXPActivityName = "Chests Looted"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i03, i030)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 02]
					iMenu = 41
				EndIf
			ElseIf (iButton == 3)
			; [Books Read]
				sXPActivityName = "Books Read"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i04, i040)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 02]
					iMenu = 41
				EndIf
			ElseIf (iButton == 4)
			; [Horses Owned]
				sXPActivityName = "Horses Owned"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i05, i050)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 02]
					iMenu = 41
				EndIf
			ElseIf (iButton == 5)
			; [Houses Owned]
				sXPActivityName = "Houses Owned"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i06, i060)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 02]
					iMenu = 41
				EndIf
			ElseIf (iButton == 6)
			; [>>]
				iMenu = 42
			ElseIf (iButton == 7)
			; [Return to Multiplier Categories - Activities - General 01]
				iMenu = 40
			ElseIf (iButton == 8)
			; [X]
				bMenu = False
			EndIf
			If (bReset)
				setXPMultiplierDefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, True, iXPActivityIndex)
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to its default value!")
			EndIf
			If (fMult > 0)
				DMN_SXPAEH.fXPMultiplier[iXPActivityIndex] = fMult
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to " + fMult + ".")
				fMult = 0
			EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			bReset = False
	; Show the Multiplier Categories - Activities - General 03 menu.
	; -------------------------------------------------------------
		ElseIf (iMenu == 42)
			Float i01 = getXPActivityMultiplierForMCM("Stores Invested In", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i010 = getXPActivityMultiplierForMCM("Stores Invested In", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i02 = getXPActivityMultiplierForMCM("Barters", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i020 = getXPActivityMultiplierForMCM("Barters", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i03 = getXPActivityMultiplierForMCM("Persuasions", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i030 = getXPActivityMultiplierForMCM("Persuasions", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i04 = getXPActivityMultiplierForMCM("Bribes", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i040 = getXPActivityMultiplierForMCM("Bribes", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i05 = getXPActivityMultiplierForMCM("Intimidations", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i050 = getXPActivityMultiplierForMCM("Intimidations", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float fMult
			Bool bReset
			iButton = DMN_SXPAConfigMenuXPMultiplierCategoriesGeneral03.Show(i01, i02, i03, i04, i05)
			If (iButton == 0)
			; [Stores Invested In]
				sXPActivityName = "Stores Invested In"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i01, i010)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 03]
					iMenu = 42
				EndIf
			ElseIf (iButton == 1)
			; [Successful Barters]
				sXPActivityName = "Barters"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i02, i020)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 03]
					iMenu = 42
				EndIf
			ElseIf (iButton == 2)
			; [Successful Persuasions]
				sXPActivityName = "Persuasions"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i03, i030)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 03]
					iMenu = 42
				EndIf
			ElseIf (iButton == 3)
			; [Successful Bribes]
				sXPActivityName = "Bribes"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i04, i040)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 03]
					iMenu = 42
				EndIf
			ElseIf (iButton == 4)
			; [Successful Intimidations]
				sXPActivityName = "Intimidations"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i05, i050)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - General 03]
					iMenu = 42
				EndIf
			ElseIf (iButton == 5)
			; [Return to Multiplier Categories - Activities - General 03]
				iMenu = 41
			ElseIf (iButton == 6)
			; [X]
				bMenu = False
			EndIf
			If (bReset)
				setXPMultiplierDefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, True, iXPActivityIndex)
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to its default value!")
			EndIf
			If (fMult > 0)
				DMN_SXPAEH.fXPMultiplier[iXPActivityIndex] = fMult
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to " + fMult + ".")
				fMult = 0
			EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			bReset = False
	; Show the Multiplier Categories - Activities - Quests 01 menu.
	; -------------------------------------------------------------
		ElseIf (iMenu == 43)
			Float i01 = getXPActivityMultiplierForMCM("Misc Objectives Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i010 = getXPActivityMultiplierForMCM("Misc Objectives Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i02 = getXPActivityMultiplierForMCM("Main Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i020 = getXPActivityMultiplierForMCM("Main Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i03 = getXPActivityMultiplierForMCM("Side Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i030 = getXPActivityMultiplierForMCM("Side Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i04 = getXPActivityMultiplierForMCM("The Companions Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i040 = getXPActivityMultiplierForMCM("The Companions Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i05 = getXPActivityMultiplierForMCM("College of Winterhold Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i050 = getXPActivityMultiplierForMCM("College of Winterhold Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float fMult
			Bool bReset
			iButton = DMN_SXPAConfigMenuXPMultiplierCategoriesQuests01.Show(i01, i02, i03, i04, i05)
			If (iButton == 0)
			; [Misc Objectives]
				sXPActivityName = "Misc Objectives Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i01, i010)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Quests 01]
					iMenu = 43
				EndIf
			ElseIf (iButton == 1)
			; [Main Quests]
				sXPActivityName = "Main Quests Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i02, i020)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Quests 01]
					iMenu = 43
				EndIf
			ElseIf (iButton == 2)
			; [Side Quests]
				sXPActivityName = "Side Quests Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i03, i030)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Quests 01]
					iMenu = 43
				EndIf
			ElseIf (iButton == 3)
			; [Companions Quests]
				sXPActivityName = "The Companions Quests Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i04, i040)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Quests 01]
					iMenu = 43
				EndIf
			ElseIf (iButton == 4)
			; [College of Winterhold Quests]
				sXPActivityName = "College of Winterhold Quests Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i05, i050)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Quests 01]
					iMenu = 43
				EndIf
			ElseIf (iButton == 5)
			; [>>]
				iMenu = 44
			ElseIf (iButton == 6)
			; [Return to Configure Multipliers]
				iMenu = 4
			ElseIf (iButton == 7)
			; [X]
				bMenu = False
			EndIf
			If (bReset)
				setXPMultiplierDefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, True, iXPActivityIndex)
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to its default value!")
			EndIf
			If (fMult > 0)
				DMN_SXPAEH.fXPMultiplier[iXPActivityIndex] = fMult
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to " + fMult + ".")
				fMult = 0
			EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			bReset = False
	; Show the Multiplier Categories - Activities - Quests 02 menu.
	; -------------------------------------------------------------
		ElseIf (iMenu == 44)
			Float i01 = getXPActivityMultiplierForMCM("Thieves' Guild Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i010 = getXPActivityMultiplierForMCM("Thieves' Guild Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i02 = getXPActivityMultiplierForMCM("The Dark Brotherhood Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i020 = getXPActivityMultiplierForMCM("The Dark Brotherhood Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i03 = getXPActivityMultiplierForMCM("Civil War Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i030 = getXPActivityMultiplierForMCM("Civil War Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i04 = getXPActivityMultiplierForMCM("Daedric Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i040 = getXPActivityMultiplierForMCM("Daedric Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i05 = getXPActivityMultiplierForMCM("Questlines Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i050 = getXPActivityMultiplierForMCM("Questlines Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float fMult
			Bool bReset
			iButton = DMN_SXPAConfigMenuXPMultiplierCategoriesQuests02.Show(i01, i02, i03, i04, i05)
			If (iButton == 0)
			; [Thieves Guild Quests]
				sXPActivityName = "Thieves' Guild Quests Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i01, i010)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Quests 02]
					iMenu = 44
				EndIf
			ElseIf (iButton == 1)
			; [Dark Brotherhood Quests]
				sXPActivityName = "The Dark Brotherhood Quests Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i02, i020)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Quests 02]
					iMenu = 44
				EndIf
			ElseIf (iButton == 2)
			; [Civil War Quests]
				sXPActivityName = "Civil War Quests Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i03, i030)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Quests 02]
					iMenu = 44
				EndIf
			ElseIf (iButton == 3)
			; [Daedric Quests]
				sXPActivityName = "Daedric Quests Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i04, i040)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Quests 02]
					iMenu = 44
				EndIf
			ElseIf (iButton == 4)
			; [Questlines]
				sXPActivityName = "Questlines Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i05, i050)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Quests 02]
					iMenu = 44
				EndIf
			ElseIf (iButton == 5)
			; [Return to Multiplier Categories - Activities - Quests 01]
				iMenu = 43
			ElseIf (iButton == 6)
			; [X]
				bMenu = False
			EndIf
			If (bReset)
				setXPMultiplierDefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, True, iXPActivityIndex)
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to its default value!")
			EndIf
			If (fMult > 0)
				DMN_SXPAEH.fXPMultiplier[iXPActivityIndex] = fMult
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to " + fMult + ".")
				fMult = 0
			EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			bReset = False
	; Show the Multiplier Categories - Activities - Combat 01 menu.
	; -------------------------------------------------------------
		ElseIf (iMenu == 45)
			Float i01 = getXPActivityMultiplierForMCM("People Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i010 = getXPActivityMultiplierForMCM("People Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i02 = getXPActivityMultiplierForMCM("Animals Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i020 = getXPActivityMultiplierForMCM("Animals Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i03 = getXPActivityMultiplierForMCM("Creatures Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i030 = getXPActivityMultiplierForMCM("Creatures Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i04 = getXPActivityMultiplierForMCM("Undead Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i040 = getXPActivityMultiplierForMCM("Undead Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i05 = getXPActivityMultiplierForMCM("Daedra Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i050 = getXPActivityMultiplierForMCM("Daedra Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float fMult
			Bool bReset
			iButton = DMN_SXPAConfigMenuXPMultiplierCategoriesCombat01.Show(i01, i02, i03, i04, i05)
			If (iButton == 0)
			; [People Killed]
				sXPActivityName = "People Killed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i01, i010)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Combat 01]
					iMenu = 45
				EndIf
			ElseIf (iButton == 1)
			; [Animals Killed]
				sXPActivityName = "Animals Killed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i02, i020)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Combat 01]
					iMenu = 45
				EndIf
			ElseIf (iButton == 2)
			; [Creatures Killed]
				sXPActivityName = "Creatures Killed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i03, i030)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Combat 01]
					iMenu = 45
				EndIf
			ElseIf (iButton == 3)
			; [Undead Killed]
				sXPActivityName = "Undead Killed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i04, i040)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Combat 01]
					iMenu = 45
				EndIf
			ElseIf (iButton == 4)
			; [Daedra Killed]
				sXPActivityName = "Daedra Killed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i05, i050)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Combat 01]
					iMenu = 45
				EndIf
			ElseIf (iButton == 5)
			; [>>]
				iMenu = 46
			ElseIf (iButton == 6)
			; [Return to Configure Multipliers]
				iMenu = 4
			ElseIf (iButton == 7)
			; [X]
				bMenu = False
			EndIf
			If (bReset)
				setXPMultiplierDefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, True, iXPActivityIndex)
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to its default value!")
			EndIf
			If (fMult > 0)
				DMN_SXPAEH.fXPMultiplier[iXPActivityIndex] = fMult
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to " + fMult + ".")
				fMult = 0
			EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			bReset = False
	; Show the Multiplier Categories - Activities - Combat 02 menu.
	; -------------------------------------------------------------
		ElseIf (iMenu == 46)
			Float i01 = getXPActivityMultiplierForMCM("Automatons Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i010 = getXPActivityMultiplierForMCM("Automatons Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i02 = getXPActivityMultiplierForMCM("Weapons Disarmed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i020 = getXPActivityMultiplierForMCM("Weapons Disarmed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i03 = getXPActivityMultiplierForMCM("Brawls Won", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i030 = getXPActivityMultiplierForMCM("Brawls Won", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i04 = getXPActivityMultiplierForMCM("Bunnies Slaughtered", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i040 = getXPActivityMultiplierForMCM("Bunnies Slaughtered", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float fMult
			Bool bReset
			iButton = DMN_SXPAConfigMenuXPMultiplierCategoriesCombat02.Show(i01, i02, i03, i04)
			If (iButton == 0)
			; [Automatons Killed]
				sXPActivityName = "Automatons Killed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i01, i010)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Combat 02]
					iMenu = 46
				EndIf
			ElseIf (iButton == 1)
			; [Weapons Disarmed]
				sXPActivityName = "Weapons Disarmed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i02, i020)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Combat 02]
					iMenu = 46
				EndIf
			ElseIf (iButton == 2)
			; [Brawls Won]
				sXPActivityName = "Brawls Won"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i03, i030)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Combat 02]
					iMenu = 46
				EndIf
			ElseIf (iButton == 3)
			; [Bunnies Slaughtered]
				sXPActivityName = "Bunnies Slaughtered"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i04, i040)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Combat 02]
					iMenu = 46
				EndIf
			ElseIf (iButton == 4)
			; [Return to Multiplier Categories - Activities - Combat 01]
				iMenu = 45
			ElseIf (iButton == 5)
			; [X]
				bMenu = False
			EndIf
			If (bReset)
				setXPMultiplierDefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, True, iXPActivityIndex)
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to its default value!")
			EndIf
			If (fMult > 0)
				DMN_SXPAEH.fXPMultiplier[iXPActivityIndex] = fMult
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to " + fMult + ".")
				fMult = 0
			EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			bReset = False
	; Show the Multiplier Categories - Activities - Magic menu.
	; -------------------------------------------------------------
		ElseIf (iMenu == 47)
			Float i01 = getXPActivityMultiplierForMCM("Dragon Souls Collected", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i010 = getXPActivityMultiplierForMCM("Dragon Souls Collected", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i02 = getXPActivityMultiplierForMCM("Words Of Power Learned", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i020 = getXPActivityMultiplierForMCM("Words Of Power Learned", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i03 = getXPActivityMultiplierForMCM("Words Of Power Unlocked", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i030 = getXPActivityMultiplierForMCM("Words Of Power Unlocked", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i04 = getXPActivityMultiplierForMCM("Shouts Mastered", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i040 = getXPActivityMultiplierForMCM("Shouts Mastered", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float fMult
			Bool bReset
			iButton = DMN_SXPAConfigMenuXPMultiplierCategoriesMagic.Show(i01, i02, i03, i04)
			If (iButton == 0)
			; [Dragon Souls Collected]
				sXPActivityName = "Dragon Souls Collected"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i01, i010)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Magic]
					iMenu = 47
				EndIf
			ElseIf (iButton == 1)
			; [Words Of Power Learned]
				sXPActivityName = "Words Of Power Learned"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i02, i020)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Magic]
					iMenu = 47
				EndIf
			ElseIf (iButton == 2)
			; [Words Of Power Unlocked]
				sXPActivityName = "Words Of Power Unlocked"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i03, i030)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Magic]
					iMenu = 47
				EndIf
			ElseIf (iButton == 3)
			; [Shouts Mastered]
				sXPActivityName = "Shouts Mastered"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i04, i040)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Magic]
					iMenu = 47
				EndIf
			ElseIf (iButton == 4)
			; [Return to Configure Multipliers]
				iMenu = 4
			ElseIf (iButton == 5)
			; [X]
				bMenu = False
			EndIf
			If (bReset)
				setXPMultiplierDefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, True, iXPActivityIndex)
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to its default value!")
			EndIf
			If (fMult > 0)
				DMN_SXPAEH.fXPMultiplier[iXPActivityIndex] = fMult
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to " + fMult + ".")
				fMult = 0
			EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			bReset = False
	; Show the Multiplier Categories - Activities - Crafting 01 menu.
	; -------------------------------------------------------------
		ElseIf (iMenu == 48)
			Float i01 = getXPActivityMultiplierForMCM("Souls Trapped", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i010 = getXPActivityMultiplierForMCM("Souls Trapped", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i02 = getXPActivityMultiplierForMCM("Magic Items Made", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i020 = getXPActivityMultiplierForMCM("Magic Items Made", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i03 = getXPActivityMultiplierForMCM("Weapons Improved", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i030 = getXPActivityMultiplierForMCM("Weapons Improved", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i04 = getXPActivityMultiplierForMCM("Weapons Made", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i040 = getXPActivityMultiplierForMCM("Weapons Made", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i05 = getXPActivityMultiplierForMCM("Armor Improved", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i050 = getXPActivityMultiplierForMCM("Armor Improved", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i06 = getXPActivityMultiplierForMCM("Armor Made", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i060 = getXPActivityMultiplierForMCM("Armor Made", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float fMult
			Bool bReset
			iButton = DMN_SXPAConfigMenuXPMultiplierCategoriesCrafting01.Show(i01, i02, i03, i04, i05, i06)
			If (iButton == 0)
			; [Souls Trapped]
				sXPActivityName = "Souls Trapped"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i01, i010)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Crafting 01]
					iMenu = 48
				EndIf
			ElseIf (iButton == 1)
			; [Magic Items Made]
				sXPActivityName = "Magic Items Made"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i02, i020)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Crafting 01]
					iMenu = 48
				EndIf
			ElseIf (iButton == 2)
			; [Weapons Improved]
				sXPActivityName = "Weapons Improved"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i03, i030)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Crafting 01]
					iMenu = 48
				EndIf
			ElseIf (iButton == 3)
			; [Weapons Made]
				sXPActivityName = "Weapons Made"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i04, i040)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Crafting 01]
					iMenu = 48
				EndIf
			ElseIf (iButton == 4)
			; [Armor Improved]
				sXPActivityName = "Armor Improved"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i05, i050)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Crafting 01]
					iMenu = 48
				EndIf
			ElseIf (iButton == 5)
			; [Armor Made]
				sXPActivityName = "Armor Made"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i06, i060)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Crafting 01]
					iMenu = 48
				EndIf
			ElseIf (iButton == 6)
			; [>>]
				iMenu = 49
			ElseIf (iButton == 7)
			; [Return to Configure Multipliers]
				iMenu = 4
			ElseIf (iButton == 8)
			; [X]
				bMenu = False
			EndIf
			If (bReset)
				setXPMultiplierDefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, True, iXPActivityIndex)
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to its default value!")
			EndIf
			If (fMult > 0)
				DMN_SXPAEH.fXPMultiplier[iXPActivityIndex] = fMult
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to " + fMult + ".")
				fMult = 0
			EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			bReset = False
	; Show the Multiplier Categories - Activities - Crafting 02 menu.
	; -------------------------------------------------------------
		ElseIf (iMenu == 49)
			Float i01 = getXPActivityMultiplierForMCM("Potions Mixed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i010 = getXPActivityMultiplierForMCM("Potions Mixed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i02 = getXPActivityMultiplierForMCM("Poisons Mixed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i020 = getXPActivityMultiplierForMCM("Poisons Mixed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i03 = getXPActivityMultiplierForMCM("Ingredients Harvested", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i030 = getXPActivityMultiplierForMCM("Ingredients Harvested", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i04 = getXPActivityMultiplierForMCM("Nirnroots Found", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i040 = getXPActivityMultiplierForMCM("Nirnroots Found", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i05 = getXPActivityMultiplierForMCM("Wings Plucked", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i050 = getXPActivityMultiplierForMCM("Wings Plucked", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float fMult
			Bool bReset
			iButton = DMN_SXPAConfigMenuXPMultiplierCategoriesCrafting02.Show(i01, i02, i03, i04, i05)
			If (iButton == 0)
			; [Potions Mixed]
				sXPActivityName = "Potions Mixed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i01, i010)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Crafting 02]
					iMenu = 49
				EndIf
			ElseIf (iButton == 1)
			; [Poisons Mixed]
				sXPActivityName = "Poisons Mixed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i02, i020)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Crafting 02]
					iMenu = 49
				EndIf
			ElseIf (iButton == 2)
			; [Ingredients Harvested]
				sXPActivityName = "Ingredients Harvested"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i03, i030)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Crafting 02]
					iMenu = 49
				EndIf
			ElseIf (iButton == 3)
			; [Nirnroots Found]
				sXPActivityName = "Nirnroots Found"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i04, i040)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Crafting 02]
					iMenu = 49
				EndIf
			ElseIf (iButton == 4)
			; [Wings Plucked]
				sXPActivityName = "Wings Plucked"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i05, i050)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Crafting 02]
					iMenu = 49
				EndIf
			ElseIf (iButton == 5)
			; [Return to Multiplier Categories - Activities - Crafting 01]
				iMenu = 48
			ElseIf (iButton == 6)
			; [X]
				bMenu = False
			EndIf
			If (bReset)
				setXPMultiplierDefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, True, iXPActivityIndex)
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to its default value!")
			EndIf
			If (fMult > 0)
				DMN_SXPAEH.fXPMultiplier[iXPActivityIndex] = fMult
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to " + fMult + ".")
				fMult = 0
			EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			bReset = False
	; Show the Multiplier Categories - Activities - Crime menu.
	; -------------------------------------------------------------
		ElseIf (iMenu == 50)
			Float i01 = getXPActivityMultiplierForMCM("Locks Picked", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i010 = getXPActivityMultiplierForMCM("Locks Picked", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i02 = getXPActivityMultiplierForMCM("Items Pickpocketed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i020 = getXPActivityMultiplierForMCM("Items Pickpocketed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i03 = getXPActivityMultiplierForMCM("Jail Escapes", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i030 = getXPActivityMultiplierForMCM("Jail Escapes", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float i04 = getXPActivityMultiplierForMCM("Items Stolen", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName)
			Float i040 = getXPActivityMultiplierForMCM("Items Stolen", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.sStatName, True)
			Float fMult
			Bool bReset
			iButton = DMN_SXPAConfigMenuXPMultiplierCategoriesCrime.Show(i01, i02, i03, i04)
			If (iButton == 0)
			; [Locks Picked]
				sXPActivityName = "Locks Picked"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i01, i010)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Crime]
					iMenu = 50
				EndIf
			ElseIf (iButton == 1)
			; [Items Pickpocketed]
				sXPActivityName = "Items Pickpocketed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i02, i020)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Crime]
					iMenu = 50
				EndIf
			ElseIf (iButton == 2)
			; [Jail Escapes]
				sXPActivityName = "Jail Escapes"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i03, i030)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Crime]
					iMenu = 50
				EndIf
			ElseIf (iButton == 3)
			; [Items Stolen]
				sXPActivityName = "Items Stolen"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				fMultChoice = DMN_SXPAConfigMenuXPMultiplierValues.Show(i04, i040)
				If (fMultChoice == 0)
					fMult = fMultOption[0]
				ElseIf (fMultChoice == 1)
					fMult = fMultOption[1]
				ElseIf (fMultChoice == 2)
					fMult = fMultOption[2]
				ElseIf (fMultChoice == 3)
					fMult = fMultOption[3]
				ElseIf (fMultChoice == 4)
					fMult = fMultOption[4]
				ElseIf (fMultChoice == 5)
					fMult = fMultOption[5]
				ElseIf (fMultChoice == 6)
					fMult = fMultOption[6]
				ElseIf (fMultChoice == 7)
					fMult = fMultOption[7]
				ElseIf (fMultChoice == 8)
				; [Reset]
					bReset = True
				ElseIf (iButton == 9)
				; [Return to Multiplier Categories - Activities - Crime]
					iMenu = 50
				EndIf
			ElseIf (iButton == 4)
			; [Return to Configure Multipliers]
				iMenu = 4
			ElseIf (iButton == 5)
			; [X]
				bMenu = False
			EndIf
			If (bReset)
				setXPMultiplierDefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.fXPMultiplier, True, iXPActivityIndex)
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to its default value!")
			EndIf
			If (fMult > 0)
				DMN_SXPAEH.fXPMultiplier[iXPActivityIndex] = fMult
				Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[iXPActivityIndex] + " XP multiplier set to " + fMult + ".")
				fMult = 0
			EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			bReset = False
	; Show the Minimum Base XP Reward menu.
	; -------------------------------------
		ElseIf (iMenu == 5)
			iButton = DMN_SXPAConfigMenuXPMinMaxRewardMin.Show()
			If (iButton == 0)
			; [25XP]
				minXP = 25
				iMenu = 3
			ElseIf (iButton == 1)
			; [50XP]
				minXP = 50
				iMenu = 3
			ElseIf (iButton == 2)
			; [100XP]
				minXP = 100
				iMenu = 3
			ElseIf (iButton == 3)
			; [250XP]
				minXP = 250
				iMenu = 3
			ElseIf (iButton == 4)
			; [500XP]
				minXP = 500
				iMenu = 3
			ElseIf (iButton == 5)
			; [750XP]
				minXP = 750
				iMenu = 3
			ElseIf (iButton == 6)
			; [1000XP]
				minXP = 1000
				iMenu = 3
			ElseIf (iButton == 7)
			; [Return to Configure Min/Max XP]
				iMenu = 3
			ElseIf (iButton == 8)
			; [X]
				bMenu = False
			EndIf
			If (minXP > 0)
				DMN_SXPAExperienceMin.SetValue(minXP)
				Notification("Skyrim XP Addon: Minimum base XP reward set to " + minXP + "XP.")
			EndIf
	; Show the Maximum Base XP Reward menu.
	; -------------------------------------
		ElseIf (iMenu == 6)
			iButton = DMN_SXPAConfigMenuXPMinMaxRewardMax.Show()
			If (iButton == 0)
			; [100XP]
				maxXP = 100
				iMenu = 3
			ElseIf (iButton == 1)
			; [200XP]
				maxXP = 200
				iMenu = 3
			ElseIf (iButton == 2)
			; [400XP]
				maxXP = 400
				iMenu = 3
			ElseIf (iButton == 3)
			; [1000XP]
				maxXP = 1000
				iMenu = 3
			ElseIf (iButton == 4)
			; [2000XP]
				maxXP = 2000
				iMenu = 3
			ElseIf (iButton == 5)
			; [3000XP]
				maxXP = 3000
				iMenu = 3
			ElseIf (iButton == 6)
			; [4000XP]
				maxXP = 4000
				iMenu = 3
			ElseIf (iButton == 7)
			; [Return to Configure Min/Max XP]
				iMenu = 3
			ElseIf (iButton == 8)
			; [X]
				bMenu = False
			EndIf
			If (maxXP > 0)
				DMN_SXPAExperienceMax.SetValue(maxXP)
				Notification("Skyrim XP Addon: Maximum base XP reward set to " + maxXP + "XP.")
			EndIf
	; Show the Spend XP menu.
	; -------------------------------------
		ElseIf (iMenu == 7)
			Int i = DMN_SXPAExperiencePoints.GetValue() as Int
			iButton = DMN_SXPAConfigMenuSpendXP.Show(i)
			If (iButton == 0)
			; [Combat]
				iMenu = 8
			ElseIf (iButton == 1)
			; [Magic]
				iMenu = 9
			ElseIf (iButton == 2)
			; [Stealth]
				iMenu = 10
			ElseIf (iButton == 3)
			; [Return To Main Menu]
				iMenu = 0
			ElseIf (iButton == 4)
			; [X]
				bMenu = False
			EndIf
	; Show the Spend XP - Combat menu.
	; -------------------------------------
		ElseIf (iMenu == 8)
			Int i = DMN_SXPAExperiencePoints.GetValue() as Int
			Int i10 = (i * 0.10) as Int
			Int i25 = (i * 0.25) as Int
			Int i50 = (i * 0.50) as Int
			Int i75 = (i * 0.75) as Int
			String sSkill
			Int iAmount
			iButton = DMN_SXPAConfigMenuSpendXPCombat.Show(i)
			If (iButton == 0)
			; [Archery]
				sSkill = "Archery"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
				; [Return to Spend XP - Combat]
					iMenu = 8
				EndIf
			ElseIf (iButton == 1)
			; [Block]
				sSkill = "Block"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
				; [Return to Spend XP - Combat]
					iMenu = 8
				EndIf
			ElseIf (iButton == 2)
			; [Heavy Armor]
				sSkill = "Heavy Armor"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
				; [Return to Spend XP - Combat]
					iMenu = 8
				EndIf
			ElseIf (iButton == 3)
			; [One-Handed]
				sSkill = "One-Handed"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
				; [Return to Spend XP - Combat]
					iMenu = 8
				EndIf
			ElseIf (iButton == 4)
			; [Smithing]
				sSkill = "Smithing"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 6)
				; [Return to Spend XP - Combat]
					iMenu = 8
				EndIf
			ElseIf (iButton == 5)
			; [Two-Handed]
				sSkill = "Two-Handed"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
				; [Return to Spend XP - Combat]
					iMenu = 8
				EndIf
			ElseIf (iButton == 6)
			; [Return to Spend XP]
				iMenu = 7
			ElseIf (iButton == 7)
			; [X]
				bMenu = False
			EndIf
			If (sSkill && iAmount > 0)
				spendXP(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAExperiencePoints, DMN_SXPAEH.bUseExponentialSkillCost, DMN_SXPAEH.fSkillMultiplier, DMN_SXPAEH.iSkillXP, DMN_SXPAEH.iSkillXPSpent, DMN_SXPAEH.iSkillXPSpentEffective, DMN_SXPAEH.sSkillName, sSkill, iAmount)
				sSkill = ""
				iAmount = 0
			EndIf
	; Show the Spend XP - Magic menu.
	; -------------------------------------
		ElseIf (iMenu == 9)
			Int i = DMN_SXPAExperiencePoints.GetValue() as Int
			Int i10 = (i * 0.10) as Int
			Int i25 = (i * 0.25) as Int
			Int i50 = (i * 0.50) as Int
			Int i75 = (i * 0.75) as Int
			String sSkill
			Int iAmount
			iButton = DMN_SXPAConfigMenuSpendXPMagic.Show(i)
			If (iButton == 0)
			; [Alteration]
				sSkill = "Alteration"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
					iMenu = 9
				; [Return to Spend XP - Magic]
				EndIf
			ElseIf (iButton == 1)
			; [Conjuration]
				sSkill = "Conjuration"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
				; [Return to Spend XP - Magic]
					iMenu = 9
				EndIf
			ElseIf (iButton == 2)
			; [Destruction]
				sSkill = "Destruction"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
				; [Return to Spend XP - Magic]
					iMenu = 9
				EndIf
			ElseIf (iButton == 3)
			; [Enchanting]
				sSkill = "Enchanting"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
				; [Return to Spend XP - Magic]
					iMenu = 9
				EndIf
			ElseIf (iButton == 4)
			; [Illusion]
				sSkill = "Illusion"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
				; [Return to Spend XP - Magic]
					iMenu = 9
				EndIf
			ElseIf (iButton == 5)
			; [Restoration]
				sSkill = "Restoration"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
				; [Return to Spend XP - Magic]
					iMenu = 9
				EndIf
			ElseIf (iButton == 6)
			; [Return to Spend XP]
				iMenu = 7
			ElseIf (iButton == 7)
			; [X]
				bMenu = False
			EndIf
			If (sSkill && iAmount > 0)
				spendXP(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAExperiencePoints, DMN_SXPAEH.bUseExponentialSkillCost, DMN_SXPAEH.fSkillMultiplier, DMN_SXPAEH.iSkillXP, DMN_SXPAEH.iSkillXPSpent, DMN_SXPAEH.iSkillXPSpentEffective, DMN_SXPAEH.sSkillName, sSkill, iAmount)
				sSkill = ""
				iAmount = 0
			EndIf
	; Show the Spend XP - Stealth menu.
	; -------------------------------------
		ElseIf (iMenu == 10)
			Int i = DMN_SXPAExperiencePoints.GetValue() as Int
			Int i10 = (i * 0.10) as Int
			Int i25 = (i * 0.25) as Int
			Int i50 = (i * 0.50) as Int
			Int i75 = (i * 0.75) as Int
			String sSkill
			Int iAmount
			iButton = DMN_SXPAConfigMenuSpendXPStealth.Show(i)
			If (iButton == 0)
			; [Alchemy]
				sSkill = "Alchemy"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
				; [Return to Spend XP - Stealth]
					iMenu = 10
				EndIf
			ElseIf (iButton == 1)
			; [Light Armor]
				sSkill = "Light Armor"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
				; [Return to Spend XP - Stealth]
					iMenu = 10
				EndIf
			ElseIf (iButton == 2)
			; [Lockpicking]
				sSkill = "Lockpicking"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
				; [Return to Spend XP - Stealth]
					iMenu = 10
				EndIf
			ElseIf (iButton == 3)
			; [Pickpocket]
				sSkill = "Pickpocket"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
				; [Return to Spend XP - Stealth]
					iMenu = 10
				EndIf
			ElseIf (iButton == 4)
			; [Sneak]
				sSkill = "Sneak"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
				; [Return to Spend XP - Stealth]
					iMenu = 10
				EndIf
			ElseIf (iButton == 5)
			; [Speech]
				sSkill = "Speech"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i, i10, i25, i50, i75)
				If (iButton == 0)
				; [100 XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [1,000 XP]
					iAmount = 1000
				ElseIf (iButton == 2)
				; [10,000 XP]
					iAmount = 10000
				ElseIf (iButton == 3)
				; [100,000 XP]
					iAmount = 100000
				ElseIf (iButton == 4)
				; [10% XP]
					iAmount = i10
				ElseIf (iButton == 5)
				; [25% XP]
					iAmount = i25
				ElseIf (iButton == 6)
				; [50% XP]
					iAmount = i50
				ElseIf (iButton == 7)
				; [75% XP]
					iAmount = i75
				ElseIf (iButton == 8)
				; [100% XP]
					iAmount = i
				ElseIf (iButton == 9)
				; [Return to Spend XP - Stealth]
					iMenu = 10
				EndIf
			ElseIf (iButton == 6)
			; [Return to Spend XP]
				iMenu = 7
			ElseIf (iButton == 7)
			; [X]
				bMenu = False
			EndIf
			If (sSkill && iAmount > 0)
				spendXP(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAExperiencePoints, DMN_SXPAEH.bUseExponentialSkillCost, DMN_SXPAEH.fSkillMultiplier, DMN_SXPAEH.iSkillXP, DMN_SXPAEH.iSkillXPSpent, DMN_SXPAEH.iSkillXPSpentEffective, DMN_SXPAEH.sSkillName, sSkill, iAmount)
				sSkill = ""
				iAmount = 0
			EndIf
	; Show the Tracking Options - Activity Categories menu.
	; -----------------------------------------------------
		ElseIf (iMenu == 11)
		; Temporarily disable active monitoring if it is on whilst in the tracking options menu.
			Int DMN_SXPAActiveMonitoringState = DMN_SXPAActiveMonitoring.GetValue() As Int
			If (DMN_SXPAActiveMonitoringState == 1)
				bActiveMonitoringEnabled = True
				DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Disabling XP activity active tracking temporarily...")
				DMN_SXPAActiveMonitoring.SetValue(0)
				If (DMN_SXPAActiveMonitoring.GetValue() == 0)
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was disabled.\n\n")
				Else
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT disabled!\n\n")
				EndIf
			EndIf
			iButton = DMN_SXPAConfigMenuTrackingActivityCategories.Show()
			If (iButton == 0)
			; [General]
				iMenu = 13
			ElseIf (iButton == 1)
			; [Quests]
				iMenu = 14
			ElseIf (iButton == 2)
			; [Combat]
				iMenu = 16
			ElseIf (iButton == 3)
			; [Magic]
				iMenu = 18
			ElseIf (iButton == 4)
			; [Crafting]
				iMenu = 19
			ElseIf (iButton == 5)
			; [Crime]
				iMenu = 21
			ElseIf (iButton == 6)
			; Since we're leaving the tracking activities menu, let's check for any XP activities the player may have
			; chosen to enable, and if any are found, set random XP values for them as existing XP activities.
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
			; We'll also go ahead and re-enable active monitoring if it was enabled to begin with.
				If (bActiveMonitoringEnabled)
					bActiveMonitoringEnabled = None
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Re-enabling XP activity active tracking.")
					DMN_SXPAActiveMonitoring.SetValue(1)
					If (DMN_SXPAActiveMonitoring.GetValue() == 1)
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was enabled.\n\n")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT enabled!\n\n")
					EndIf
				; Register for XP activity active tracking once more.
					DMN_SXPAPA.waitForStatChange()
				EndIf
			; [Return To Tracking Options]
				iMenu = 1
			ElseIf (iButton == 7)
			; Since we're exiting the tracking activities menu, let's check for any XP activities the player may have
			; chosen to enable, and if any are found, set random XP values for them as existing XP activities.
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
			; We'll also go ahead and re-enable active monitoring if it was enabled to begin with.
				If (bActiveMonitoringEnabled)
					bActiveMonitoringEnabled = None
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Re-enabling XP activity active tracking.")
					DMN_SXPAActiveMonitoring.SetValue(1)
					If (DMN_SXPAActiveMonitoring.GetValue() == 1)
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was enabled.\n\n")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT enabled!\n\n")
					EndIf
				; Register for XP activity active tracking once more.
					DMN_SXPAPA.waitForStatChange()
				EndIf
			; [X]
				bMenu = False
			EndIf
	; Show the Tracking Options - Type menu.
	; --------------------------------------
		ElseIf (iMenu == 12)
			iButton = DMN_SXPAConfigMenuTrackingType.Show()
			If (iButton == 0)
			; [Turn Off Active Tracking]
				DMN_SXPAActiveMonitoring.SetValue(0 as Int)
				Notification("Skyrim XP Addon: Active (always monitoring) tracking has been disabled.")
			ElseIf (iButton == 1)
			; [Turn Off Passive Tracking]
				DMN_SXPAEH.iPassiveMonitoring = 0
				DMN_SXPAEH.stopTracking() ; Stop the built-in TrackedStatsEvent function.
				Notification("Skyrim XP Addon: Passive (event triggered) tracking has been disabled.")
			ElseIf (iButton == 2)
			; [Switch To Active Tracking]
				DMN_SXPAEH.iPassiveMonitoring = 0
				DMN_SXPAActiveMonitoring.SetValue(1 as Int)
			; Update all existing tracked stats.
				updatePlayerStats(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.sNotificationMessage, DMN_SXPAEH.bUseExponentialXPGain, True)
				Wait(3.0)
				DMN_SXPAPA.waitForStatChange() ; Start the custom stat monitoring function.
				Notification("Skyrim XP Addon: Switched to active (always monitoring) tracking.")
			ElseIf (iButton == 3)
			; [Switch To Passive Tracking]
				DMN_SXPAEH.iPassiveMonitoring = 1
				DMN_SXPAEH.startTracking() ; Start the built-in TrackedStatsEvent function.
				DMN_SXPAActiveMonitoring.SetValue(0 as Int)
				Notification("Skyrim XP Addon: Switched to passive (event triggered) tracking.")
			ElseIf (iButton == 4)
			; [Turn On Active Tracking]
				DMN_SXPAActiveMonitoring.SetValue(1 as Int)
			; Update all existing tracked stats.
				updatePlayerStats(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.sNotificationMessage, DMN_SXPAEH.bUseExponentialXPGain, True)
				Wait(3.0)
				DMN_SXPAPA.waitForStatChange() ; Start the custom stat monitoring function.
				Notification("Skyrim XP Addon: Active (always monitoring) tracking has been enabled.")
			ElseIf (iButton == 5)
			; [Turn On Passive Tracking]
				DMN_SXPAEH.iPassiveMonitoring = 1
				DMN_SXPAEH.startTracking() ; Start the built-in TrackedStatsEvent function.
				Notification("Skyrim XP Addon: Passive (event triggered) tracking has been enabled.")
			ElseIf (iButton == 6)
			; [Return to Tracking Options]
				iMenu = 1
			ElseIf (iButton == 7)
			; Since we're exiting the tracking options menu, let's check for any XP activities the player may have
			; chosen to enable, and if any are found, set random XP values for them as existing XP activities.
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
			; We'll also go ahead and re-enable active monitoring if it was enabled to begin with.
				If (bActiveMonitoringEnabled)
					bActiveMonitoringEnabled = None
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Re-enabling XP activity active tracking.")
					DMN_SXPAActiveMonitoring.SetValue(1)
					If (DMN_SXPAActiveMonitoring.GetValue() == 1)
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was enabled.\n\n")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT enabled!\n\n")
					EndIf
				; Register for XP activity active tracking once more.
					DMN_SXPAPA.waitForStatChange()
				EndIf
			; [X]
				bMenu = False
			EndIf
	; Show the Tracking Options - Activity - General 01 menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 13)
			Int i01 = getXPActivityStateForMCM("Mauls", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i02 = getXPActivityStateForMCM("Necks Bitten", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i03 = getXPActivityStateForMCM("Days as a Werewolf", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i04 = getXPActivityStateForMCM("Days as a Vampire", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i05 = getXPActivityStateForMCM("Locations Discovered", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i06 = getXPActivityStateForMCM("Dungeons Cleared", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesGeneral01.Show(i01, i02, i03, i04, i05, i06)
			If (iButton == 0)
			; [Mauls]
				sXPActivityName = "Mauls"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 1)
			; [Necks Bitten]
				sXPActivityName = "Necks Bitten"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 2)
			; [Days as a Werewolf]
				sXPActivityName = "Days as a Werewolf"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 3)
			; [Days as a Vampire]
				sXPActivityName = "Days as a Vampire"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 4)
			; [Locations Discovered]
				sXPActivityName = "Locations Discovered"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 5)
			; [Locations Cleared]
				sXPActivityName = "Dungeons Cleared"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 6)
			; [>>]
				iMenu = 22
			ElseIf (iButton == 7)
			; [Return to Tracking Options - Activity Categories]
				iMenu = 11
			ElseIf (iButton == 8)
			; Since we're exiting the tracking activities menu, let's check for any XP activities the player may have
			; chosen to enable, and if any are found, set random XP values for them as existing XP activities.
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
			; We'll also go ahead and re-enable active monitoring if it was enabled to begin with.
				If (bActiveMonitoringEnabled)
					bActiveMonitoringEnabled = None
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Re-enabling XP activity active tracking.")
					DMN_SXPAActiveMonitoring.SetValue(1)
					If (DMN_SXPAActiveMonitoring.GetValue() == 1)
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was enabled.\n\n")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT enabled!\n\n")
					EndIf
				; Register for XP activity active tracking once more.
					DMN_SXPAPA.waitForStatChange()
				EndIf
			; [X]
				bMenu = False
			EndIf
			If (sXPActivityName && iXPActivityIndex >= 0)
				If (bXPActivityState)
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, False, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to disabled.")
				Else
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, True, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to enabled.")
				EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			EndIf
	; Show the Tracking Options - Activity - Quests 01 menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 14)
			Int i01 = getXPActivityStateForMCM("Misc Objectives Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i02 = getXPActivityStateForMCM("Main Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i03 = getXPActivityStateForMCM("Side Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i04 = getXPActivityStateForMCM("The Companions Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i05 = getXPActivityStateForMCM("College of Winterhold Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesQuests01.Show(i01, i02, i03, i04, i05)
			If (iButton == 0)
			; [Misc Objectives]
				sXPActivityName = "Misc Objectives Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 1)
			; [Main Quests]
				sXPActivityName = "Main Quests Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 2)
			; [Side Quests]
				sXPActivityName = "Side Quests Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 3)
			; [Companions Quests]
				sXPActivityName = "The Companions Quests Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 4)
			; [College of Winterhold Quests]
				sXPActivityName = "College of Winterhold Quests Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 5)
			; [[>>]]
				iMenu = 15
			ElseIf (iButton == 6)
			; [Return to Tracking Options - Activity Categories]
				iMenu = 11
			ElseIf (iButton == 7)
			; Since we're exiting the tracking activities menu, let's check for any XP activities the player may have
			; chosen to enable, and if any are found, set random XP values for them as existing XP activities.
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
			; We'll also go ahead and re-enable active monitoring if it was enabled to begin with.
				If (bActiveMonitoringEnabled)
					bActiveMonitoringEnabled = None
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Re-enabling XP activity active tracking.")
					DMN_SXPAActiveMonitoring.SetValue(1)
					If (DMN_SXPAActiveMonitoring.GetValue() == 1)
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was enabled.\n\n")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT enabled!\n\n")
					EndIf
				; Register for XP activity active tracking once more.
					DMN_SXPAPA.waitForStatChange()
				EndIf
			; [X]
				bMenu = False
			EndIf
			If (sXPActivityName && iXPActivityIndex >= 0)
				If (bXPActivityState)
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, False, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to disabled.")
				Else
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, True, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to enabled.")
				EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			EndIf
	; Show the Tracking Options - Activity - Quests 02 menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 15)
			Int i01 = getXPActivityStateForMCM("Thieves' Guild Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i02 = getXPActivityStateForMCM("The Dark Brotherhood Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i03 = getXPActivityStateForMCM("Civil War Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i04 = getXPActivityStateForMCM("Daedric Quests Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i05 = getXPActivityStateForMCM("Questlines Completed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesQuests02.Show(i01, i02, i03, i04, i05)
			If (iButton == 0)
			; [Thieves Guild Quests]
				sXPActivityName = "Thieves' Guild Quests Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 1)
			; [Dark Brotherhood Quests]
				sXPActivityName = "The Dark Brotherhood Quests Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 2)
			; [Civil War Quests]
				sXPActivityName = "Civil War Quests Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 3)
			; [Daedric Quests]
				sXPActivityName = "Daedric Quests Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 4)
			; [Questlines]
				sXPActivityName = "Questlines Completed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 5)
			; [[Return to Tracking Options - Activity - Quests 01]]
				iMenu = 14
			ElseIf (iButton == 6)
			; Since we're exiting the tracking activities menu, let's check for any XP activities the player may have
			; chosen to enable, and if any are found, set random XP values for them as existing XP activities.
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
			; We'll also go ahead and re-enable active monitoring if it was enabled to begin with.
				If (bActiveMonitoringEnabled)
					bActiveMonitoringEnabled = None
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Re-enabling XP activity active tracking.")
					DMN_SXPAActiveMonitoring.SetValue(1)
					If (DMN_SXPAActiveMonitoring.GetValue() == 1)
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was enabled.\n\n")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT enabled!\n\n")
					EndIf
				; Register for XP activity active tracking once more.
					DMN_SXPAPA.waitForStatChange()
				EndIf
			; [X]
				bMenu = False
			EndIf
			If (sXPActivityName && iXPActivityIndex >= 0)
				If (bXPActivityState)
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, False, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to disabled.")
				Else
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, True, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to enabled.")
				EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			EndIf
	; Show the Tracking Options - Activity - Combat 01 menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 16)
			Int i01 = getXPActivityStateForMCM("People Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i02 = getXPActivityStateForMCM("Animals Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i03 = getXPActivityStateForMCM("Creatures Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i04 = getXPActivityStateForMCM("Undead Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i05 = getXPActivityStateForMCM("Daedra Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesCombat01.Show(i01, i02, i03, i04, i05)
			If (iButton == 0)
			; [People Killed]
				sXPActivityName = "People Killed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 1)
			; [Animals Killed]
				sXPActivityName = "Animals Killed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 2)
			; [Creatures Killed]
				sXPActivityName = "Creatures Killed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 3)
			; [Undead Killed]
				sXPActivityName = "Undead Killed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 4)
			; [Daedra Killed]
				sXPActivityName = "Daedra Killed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 5)
			; [>>]
				iMenu = 17
			ElseIf (iButton == 6)
			; [Return to Tracking Options - Activity Categories]
				iMenu = 11
			ElseIf (iButton == 7)
			; Since we're exiting the tracking activities menu, let's check for any XP activities the player may have
			; chosen to enable, and if any are found, set random XP values for them as existing XP activities.
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
			; We'll also go ahead and re-enable active monitoring if it was enabled to begin with.
				If (bActiveMonitoringEnabled)
					bActiveMonitoringEnabled = None
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Re-enabling XP activity active tracking.")
					DMN_SXPAActiveMonitoring.SetValue(1)
					If (DMN_SXPAActiveMonitoring.GetValue() == 1)
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was enabled.\n\n")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT enabled!\n\n")
					EndIf
				; Register for XP activity active tracking once more.
					DMN_SXPAPA.waitForStatChange()
				EndIf
			; [X]
				bMenu = False
			EndIf
			If (sXPActivityName && iXPActivityIndex >= 0)
				If (bXPActivityState)
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, False, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to disabled.")
				Else
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, True, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to enabled.")
				EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			EndIf
	; Show the Tracking Options - Activity - Combat 02 menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 17)
			Int i01 = getXPActivityStateForMCM("Automatons Killed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i02 = getXPActivityStateForMCM("Weapons Disarmed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i03 = getXPActivityStateForMCM("Brawls Won", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i04 = getXPActivityStateForMCM("Bunnies Slaughtered", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesCombat02.Show(i01, i02, i03, i04)
			If (iButton == 0)
			; [Automatons Killed]
				sXPActivityName = "Automatons Killed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 1)
			; [Weapons Disarmed]
				sXPActivityName = "Weapons Disarmed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 2)
			; [Brawls Won]
				sXPActivityName = "Brawls Won"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 3)
			; [Bunnies Slaughtered]
				sXPActivityName = "Bunnies Slaughtered"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 4)
			; [Return to Tracking Options - Activity - Combat 01]
				iMenu = 16
			ElseIf (iButton == 5)
			; Since we're exiting the tracking activities menu, let's check for any XP activities the player may have
			; chosen to enable, and if any are found, set random XP values for them as existing XP activities.
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
			; We'll also go ahead and re-enable active monitoring if it was enabled to begin with.
				If (bActiveMonitoringEnabled)
					bActiveMonitoringEnabled = None
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Re-enabling XP activity active tracking.")
					DMN_SXPAActiveMonitoring.SetValue(1)
					If (DMN_SXPAActiveMonitoring.GetValue() == 1)
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was enabled.\n\n")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT enabled!\n\n")
					EndIf
				; Register for XP activity active tracking once more.
					DMN_SXPAPA.waitForStatChange()
				EndIf
			; [X]
				bMenu = False
			EndIf
			If (sXPActivityName && iXPActivityIndex >= 0)
				If (bXPActivityState)
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, False, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to disabled.")
				Else
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, True, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to enabled.")
				EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			EndIf
	; Show the Tracking Options - Activity - Magic menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 18)
			Int i01 = getXPActivityStateForMCM("Dragon Souls Collected", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i02 = getXPActivityStateForMCM("Words Of Power Learned", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i03 = getXPActivityStateForMCM("Words Of Power Unlocked", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i04 = getXPActivityStateForMCM("Shouts Mastered", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesMagic.Show(i01, i02, i03, i04)
			If (iButton == 0)
			; [Dragon Souls Collected]
				sXPActivityName = "Dragon Souls Collected"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 1)
			; [Words Of Power Learned]
				sXPActivityName = "Words Of Power Learned"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 2)
			; [Words Of Power Unlocked]
				sXPActivityName = "Words Of Power Unlocked"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 3)
			; [Shouts Mastered]
				sXPActivityName = "Shouts Mastered"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 4)
			; [Return to Tracking Options - Activity Categories]
				iMenu = 11
			ElseIf (iButton == 5)
			; Since we're exiting the tracking activities menu, let's check for any XP activities the player may have
			; chosen to enable, and if any are found, set random XP values for them as existing XP activities.
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
			; We'll also go ahead and re-enable active monitoring if it was enabled to begin with.
				If (bActiveMonitoringEnabled)
					bActiveMonitoringEnabled = None
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Re-enabling XP activity active tracking.")
					DMN_SXPAActiveMonitoring.SetValue(1)
					If (DMN_SXPAActiveMonitoring.GetValue() == 1)
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was enabled.\n\n")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT enabled!\n\n")
					EndIf
				; Register for XP activity active tracking once more.
					DMN_SXPAPA.waitForStatChange()
				EndIf
			; [X]
				bMenu = False
			EndIf
			If (sXPActivityName && iXPActivityIndex >= 0)
				If (bXPActivityState)
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, False, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to disabled.")
				Else
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, True, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to enabled.")
				EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			EndIf
	; Show the Tracking Options - Activity - Crafting 01 menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 19)
		; Get the states of the XP activities to display in the menu shown to the player.
			Int i01 = getXPActivityStateForMCM("Souls Trapped", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i02 = getXPActivityStateForMCM("Magic Items Made", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i03 = getXPActivityStateForMCM("Weapons Improved", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i04 = getXPActivityStateForMCM("Weapons Made", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i05 = getXPActivityStateForMCM("Armor Improved", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i06 = getXPActivityStateForMCM("Armor Made", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesCrafting01.Show(i01, i02, i03, i04, i05, i06)
			If (iButton == 0)
			; [Souls Trapped]
				sXPActivityName = "Souls Trapped"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 1)
			; [Magic Items Made]
				sXPActivityName = "Magic Items Made"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 2)
			; [Weapons Improved]
				sXPActivityName = "Weapons Improved"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 3)
			; [Weapons Made]
				sXPActivityName = "Weapons Made"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 4)
			; [Armor Improved]
				sXPActivityName = "Armor Improved"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 5)
			; [Armor Made]
				sXPActivityName = "Armor Made"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 6)
			; [[>>]]
				iMenu = 20
			ElseIf (iButton == 7)
			; [Return to Tracking Options - Activity Categories]
				iMenu = 11
			ElseIf (iButton == 8)
			; Since we're exiting the tracking activities menu, let's check for any XP activities the player may have
			; chosen to enable, and if any are found, set random XP values for them as existing XP activities.
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
			; We'll also go ahead and re-enable active monitoring if it was enabled to begin with.
				If (bActiveMonitoringEnabled)
					bActiveMonitoringEnabled = None
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Re-enabling XP activity active tracking.")
					DMN_SXPAActiveMonitoring.SetValue(1)
					If (DMN_SXPAActiveMonitoring.GetValue() == 1)
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was enabled.\n\n")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT enabled!\n\n")
					EndIf
				; Register for XP activity active tracking once more.
					DMN_SXPAPA.waitForStatChange()
				EndIf
			; [X]
				bMenu = False
			EndIf
			If (sXPActivityName && iXPActivityIndex >= 0)
				If (bXPActivityState)
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, False, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to disabled.")
				Else
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, True, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to enabled.")
				EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			EndIf
	; Show the Tracking Options - Activity - Crafting 02 menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 20)
		; Get the states of the XP activities to display in the menu shown to the player.
			Int i01 = getXPActivityStateForMCM("Potions Mixed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i02 = getXPActivityStateForMCM("Poisons Mixed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i03 = getXPActivityStateForMCM("Ingredients Harvested", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i04 = getXPActivityStateForMCM("Nirnroots Found", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i05 = getXPActivityStateForMCM("Wings Plucked", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesCrafting02.Show(i01, i02, i03, i04, i05)
			If (iButton == 0)
			; [Potions Mixed]
				sXPActivityName = "Potions Mixed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 1)
			; [Poisons Mixed]
				sXPActivityName = "Poisons Mixed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 2)
			; [Ingredients Harvested]
				sXPActivityName = "Ingredients Harvested"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 3)
			; [Nirnroots Found]
				sXPActivityName = "Nirnroots Found"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 4)
			; [Wings Plucked]
				sXPActivityName = "Wings Plucked"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 5)
			; [Return to Tracking Options - Activity - Crafting 01]
				iMenu = 19
			ElseIf (iButton == 6)
			; Since we're exiting the tracking activities menu, let's check for any XP activities the player may have
			; chosen to enable, and if any are found, set random XP values for them as existing XP activities.
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
			; We'll also go ahead and re-enable active monitoring if it was enabled to begin with.
				If (bActiveMonitoringEnabled)
					bActiveMonitoringEnabled = None
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Re-enabling XP activity active tracking.")
					DMN_SXPAActiveMonitoring.SetValue(1)
					If (DMN_SXPAActiveMonitoring.GetValue() == 1)
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was enabled.\n\n")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT enabled!\n\n")
					EndIf
				; Register for XP activity active tracking once more.
					DMN_SXPAPA.waitForStatChange()
				EndIf
			; [X]
				bMenu = False
			EndIf
			If (sXPActivityName && iXPActivityIndex >= 0)
				If (bXPActivityState)
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, False, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to disabled.")
				Else
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, True, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to enabled.")
				EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			EndIf
	; Show the Tracking Options - Activity - Crime menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 21)
			Int i01 = getXPActivityStateForMCM("Locks Picked", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i02 = getXPActivityStateForMCM("Items Pickpocketed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i03 = getXPActivityStateForMCM("Jail Escapes", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i04 = getXPActivityStateForMCM("Items Stolen", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesCrime.Show(i01, i02, i03, i04)
			If (iButton == 0)
			; [Locks Picked]
				sXPActivityName = "Locks Picked"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 1)
			; [Items Pickpocketed]
				sXPActivityName = "Items Pickpocketed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 2)
			; [Jail Escapes]
				sXPActivityName = "Jail Escapes"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 3)
			; [Items Stolen]
				sXPActivityName = "Items Stolen"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 4)
			; [Return to Tracking Options - Activity Categories]
				iMenu = 11
			ElseIf (iButton == 5)
			; Since we're exiting the tracking activities menu, let's check for any XP activities the player may have
			; chosen to enable, and if any are found, set random XP values for them as existing XP activities.
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
			; We'll also go ahead and re-enable active monitoring if it was enabled to begin with.
				If (bActiveMonitoringEnabled)
					bActiveMonitoringEnabled = None
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Re-enabling XP activity active tracking.")
					DMN_SXPAActiveMonitoring.SetValue(1)
					If (DMN_SXPAActiveMonitoring.GetValue() == 1)
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was enabled.\n\n")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT enabled!\n\n")
					EndIf
				; Register for XP activity active tracking once more.
					DMN_SXPAPA.waitForStatChange()
				EndIf
			; [X]
				bMenu = False
			EndIf
			If (sXPActivityName && iXPActivityIndex >= 0)
				If (bXPActivityState)
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, False, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to disabled.")
				Else
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, True, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to enabled.")
				EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			EndIf
	; Show the Tracking Options - Activity - General 02 menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 22)
			Int i01 = getXPActivityStateForMCM("Days Passed", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i02 = getXPActivityStateForMCM("Standing Stones Found", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i03 = getXPActivityStateForMCM("Chests Looted", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i04 = getXPActivityStateForMCM("Books Read", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i05 = getXPActivityStateForMCM("Horses Owned", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i06 = getXPActivityStateForMCM("Houses Owned", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesGeneral02.Show(i01, i02, i03, i04, i05, i06)
			If (iButton == 0)
			; [Days Passed]
				sXPActivityName = "Days Passed"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 1)
			; [Standing Stones Found]
				sXPActivityName = "Standing Stones Found"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 2)
			; [Chests Looted]
				sXPActivityName = "Chests Looted"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 3)
			; [Books Read]
				sXPActivityName = "Books Read"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 4)
			; [Horses Owned]
				sXPActivityName = "Horses Owned"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 5)
			; [Houses Owned]
				sXPActivityName = "Houses Owned"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 6)
			; [>>]
				iMenu = 23
			ElseIf (iButton == 7)
			; [Return to Tracking Options - Activity - General 01]
				iMenu = 13
			ElseIf (iButton == 8)
			; Since we're exiting the tracking activities menu, let's check for any XP activities the player may have
			; chosen to enable, and if any are found, set random XP values for them as existing XP activities.
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
			; We'll also go ahead and re-enable active monitoring if it was enabled to begin with.
				If (bActiveMonitoringEnabled)
					bActiveMonitoringEnabled = None
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Re-enabling XP activity active tracking.")
					DMN_SXPAActiveMonitoring.SetValue(1)
					If (DMN_SXPAActiveMonitoring.GetValue() == 1)
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was enabled.\n\n")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT enabled!\n\n")
					EndIf
				; Register for XP activity active tracking once more.
					DMN_SXPAPA.waitForStatChange()
				EndIf
			; [X]
				bMenu = False
			EndIf
			If (sXPActivityName && iXPActivityIndex >= 0)
				If (bXPActivityState)
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, False, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to disabled.")
				Else
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, True, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to enabled.")
				EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			EndIf
	; Show the Tracking Options - Activity - General 03 menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 23)
			Int i01 = getXPActivityStateForMCM("Stores Invested In", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i02 = getXPActivityStateForMCM("Barters", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i03 = getXPActivityStateForMCM("Persuasions", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i04 = getXPActivityStateForMCM("Bribes", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			Int i05 = getXPActivityStateForMCM("Intimidations", DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.sStatName)
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesGeneral03.Show(i01, i02, i03, i04, i05)
			If (iButton == 0)
			; [Stores Invested In]
				sXPActivityName = "Stores Invested In"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 1)
			; [Successful Barters]
				sXPActivityName = "Barters"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 2)
			; [Successful Persuasions]
				sXPActivityName = "Persuasions"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 3)
			; [Successful Bribes]
				sXPActivityName = "Bribes"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 4)
			; [Successful Intimidations]
				sXPActivityName = "Intimidations"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 5)
			; [Return to Tracking Options - Activity - General 02]
				iMenu = 22
			ElseIf (iButton == 6)
			; Since we're exiting the tracking activities menu, let's check for any XP activities the player may have
			; chosen to enable, and if any are found, set random XP values for them as existing XP activities.
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
			; We'll also go ahead and re-enable active monitoring if it was enabled to begin with.
				If (bActiveMonitoringEnabled)
					bActiveMonitoringEnabled = None
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Re-enabling XP activity active tracking.")
					DMN_SXPAActiveMonitoring.SetValue(1)
					If (DMN_SXPAActiveMonitoring.GetValue() == 1)
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was enabled.\n\n")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT enabled!\n\n")
					EndIf
				; Register for XP activity active tracking once more.
					DMN_SXPAPA.waitForStatChange()
				EndIf
			; [X]
				bMenu = False
			EndIf
			If (sXPActivityName && iXPActivityIndex >= 0)
				If (bXPActivityState)
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, False, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to disabled.")
				Else
					setXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, True, DMN_SXPAEH.sStatName)
					Notification("Skyrim XP Addon: Toggled " + sXPActivityName + " XP gain to enabled.")
				EndIf
			sXPActivityName = ""
			iXPActivityIndex = 0
			EndIf
	; Show the Miscellaneous menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 24)
			iButton = DMN_SXPAConfigMenuMiscellaneous.Show()
			If (iButton == 0)
			; [Debug Settings]
				iMenu = 25
			ElseIf (iButton == 1)
			; [Mod Compatibility]
				iMenu = 26
			ElseIf (iButton == 2)
			; [Reset SXPA Default Values]
				iMenu = 27
			ElseIf (iButton == 3)
			; [Wipe SXPA Player Data]
				iMenu = 28
			ElseIf (iButton == 4)
			; [Return to Main Config]
				iMenu = 0
			ElseIf (iButton == 5)
			; [X]
				bMenu = False
			EndIf
	; Show the Miscellaneous - Debug menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 25)
			iButton = DMN_SXPAConfigMenuMiscellaneousDebugSettings.Show()
			If (iButton == 0)
			; [Enable Debugging]
				DMN_SXPAEH.DMN_SXPADebug.SetValue(1)
				If (DMN_SXPAEH.DMN_SXPADebug.GetValue() As Int == 1)
					Notification("Skyrim XP Addon: Enabled debugging mode.")
				EndIf
			ElseIf (iButton == 1)
			; [Disable Debugging]
				DMN_SXPAEH.DMN_SXPADebug.SetValue(0)
				If (DMN_SXPAEH.DMN_SXPADebug.GetValue() As Int == 0)
					Notification("Skyrim XP Addon: Disabled debugging mode.")
				EndIf
			ElseIf (iButton == 2)
			; [Update Player Stats]
			; Temporarily disable active monitoring if it is on whilst we update existing player XP activities.
				Notification("Skyrim XP Addon: Initiated manual SXPA player stats update.")
				Int DMN_SXPAActiveMonitoringState = DMN_SXPAActiveMonitoring.GetValue() As Int
				If (DMN_SXPAActiveMonitoringState == 1)
					bActiveMonitoringEnabled = True
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Disabling XP activity active tracking temporarily...")
					DMN_SXPAActiveMonitoring.SetValue(0)
					If (DMN_SXPAActiveMonitoring.GetValue() == 0)
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was disabled.\n\n")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT disabled!\n\n")
					EndIf
				EndIf
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
			; We'll also go ahead and re-enable active monitoring if it was enabled to begin with.
				If (bActiveMonitoringEnabled)
					bActiveMonitoringEnabled = None
					DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: Re-enabling XP activity active tracking.")
					DMN_SXPAActiveMonitoring.SetValue(1)
					If (DMN_SXPAActiveMonitoring.GetValue() == 1)
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: XP activity active tracking was enabled.\n\n")
					Else
						DMN_SXPALog(DMN_SXPAEH.DMN_SXPADebug, "Configurator: WARNING: XP activity active tracking was NOT enabled!\n\n")
					EndIf
				; Register for XP activity active tracking once more.
					DMN_SXPAPA.waitForStatChange()
				EndIf
				Notification("Skyrim XP Addon: Completed manual SXPA player stats update.")
			ElseIf (iButton == 3)
			; [Switch To Book Configurator]
				giveConfiguratorSpell(DMN_SXPAConfiguratorSpell, True)
				giveConfiguratorBook(DMN_SXPAConfiguratorBook)
				DMN_SXPAEH.iConfiguratorType = 0
				If (DMN_SXPAEH.iConfiguratorType == 0)
					Notification("Skyrim XP Addon: Switched to the book configurator.")
					bMenu = False
				EndIf
			ElseIf (iButton == 4)
			; [Switch To Spell Configurator]
				giveConfiguratorBook(DMN_SXPAConfiguratorBook, True)
				giveConfiguratorSpell(DMN_SXPAConfiguratorSpell)
				DMN_SXPAEH.iConfiguratorType = 1
				If (DMN_SXPAEH.iConfiguratorType == 1)
					Notification("Skyrim XP Addon: Switched to the spell configurator.")
					bMenu = False
				EndIf
			ElseIf (iButton == 5)
			; [Return to Miscellaneous]
				iMenu = 24
			ElseIf (iButton == 6)
			; [X]
				bMenu = False
			EndIf
	; Show the Miscellaneous - Mod Compatibility 01 menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 26)
			Int i01 = DMN_SXPAEH.iModCompatibility[0]
			iButton = DMN_SXPAConfigMenuMiscellaneousModCompatibility01.Show()
			If (iButton == 0)
			; [SkyrimSouls - Unpaused Game Menus (SKSE Plugin)]
				iButton = DMN_SXPAConfigMenuMiscellaneousModCompatibility01_1.Show(i01)
				If (iButton == 0)
				; [Enable Compatibility]
					DMN_SXPAEH.iModCompatibility[0] = 1
					Notification("Skyrim XP Addon: Enabled compatibility for SkyrimSouls - Unpaused Game Menus (SKSE Plugin).")
				ElseIf (iButton == 1)
					DMN_SXPAEH.iModCompatibility[0] = 0
					Notification("Skyrim XP Addon: Disabled compatibility for SkyrimSouls - Unpaused Game Menus (SKSE Plugin).")
				; [Previous Menu]
				ElseIf (iButton == 2)
					iMenu = 26
				ElseIf (iButton == 3)
				; [X]
					bMenu = False
				EndIf
			ElseIf (iButton == 1)
			; [Return to Miscellaneous]
				iMenu = 24
			ElseIf (iButton == 2)
			; [X]
				bMenu = False
			EndIf
	; Show the Miscellaneous - Reset Confirmation menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 27)
			iButton = DMN_SXPAConfigMenuMiscellaneousResetConfirmation.Show()
			If (iButton == 0)
			; [Reset SXPA Values To Default]
				Notification("Skyrim XP Addon: Restoring SXPA default values...")
				setSXPADefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAActiveMonitoring, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.bXPActivityState, DMN_SXPAConfiguratorBook, DMN_SXPAEH.fSkillMultiplier, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iConfiguratorType, DMN_SXPAEH.iPassiveMonitoring, DMN_SXPAConfiguratorSpell)
			; Register for XP activity active tracking once more.
				DMN_SXPAPA.waitForStatChange()
				Notification("Skyrim XP Addon: SXPA default values have been restored!")
				bMenu = False
			ElseIf (iButton == 1)
			; [Reset SXPA Values To Default And Wipe My SXPA Data]
				Notification("Skyrim XP Addon: Restoring SXPA default values and wiping player's SXPA data...")
				setSXPADefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAActiveMonitoring, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.bXPActivityState, DMN_SXPAConfiguratorBook, DMN_SXPAEH.fSkillMultiplier, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iConfiguratorType, DMN_SXPAEH.iPassiveMonitoring, DMN_SXPAConfiguratorSpell)
				resetSXPAProgress(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAActiveMonitoring, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iSkillXP, DMN_SXPAEH.iSkillXPSpent, DMN_SXPAEH.iSkillXPSpentEffective, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sSkillName, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
			; Register for XP activity active tracking once more.
				DMN_SXPAPA.waitForStatChange()
				Notification("Skyrim XP Addon: SXPA default values have been restored and SXPA player data wiped!")
				bMenu = False
			ElseIf (iButton == 2)
			; [Return to Miscellaneous]
				iMenu = 24
			ElseIf (iButton == 3)
			; [X]
				bMenu = False
			EndIf
	; Show the Miscellaneous - Wipe Confirmation menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 28)
			iButton = DMN_SXPAConfigMenuMiscellaneousWipeConfirmation.Show()
			If (iButton == 0)
			; [Wipe My SXPA Data]
				Notification("Skyrim XP Addon: Wiping player's SXPA data...")
				resetSXPAProgress(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAActiveMonitoring, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iSkillXP, DMN_SXPAEH.iSkillXPSpent, DMN_SXPAEH.iSkillXPSpentEffective, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sSkillName, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
				Notification("Skyrim XP Addon: SXPA player data has been wiped!")
			; Register for XP activity active tracking once more.
				DMN_SXPAPA.waitForStatChange()
				bMenu = False
			ElseIf (iButton == 1)
			; [Wipe My SXPA Data And Reset SXPA Values To Default]
				Notification("Skyrim XP Addon: Wiping player's SXPA data and restoring SXPA default values...")
				resetSXPAProgress(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAActiveMonitoring, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iSkillXP, DMN_SXPAEH.iSkillXPSpent, DMN_SXPAEH.iSkillXPSpentEffective, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sSkillName, DMN_SXPAEH.sStatName, DMN_SXPAEH.bUseExponentialXPGain)
				setSXPADefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAActiveMonitoring, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.bXPActivityState, DMN_SXPAConfiguratorBook, DMN_SXPAEH.fSkillMultiplier, DMN_SXPAEH.fXPMultiplier, DMN_SXPAEH.iConfiguratorType, DMN_SXPAEH.iPassiveMonitoring, DMN_SXPAConfiguratorSpell)
			; Register for XP activity active tracking once more.
				DMN_SXPAPA.waitForStatChange()
				Notification("Skyrim XP Addon: SXPA player data has been wiped and SXPA default values restored!")
				bMenu = False
			ElseIf (iButton == 2)
			; [Return to Miscellaneous]
				iMenu = 24
			ElseIf (iButton == 3)
			; [X]
				bMenu = False
			EndIf
	; Show the Configure Automatic XP Spending menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 29)
			iButton = DMN_SXPAConfigMenuXPAutomaticSpending.Show()
			If (iButton == 0)
			; [Enable Automatic XP Spending]
				DMN_SXPAAutomaticXPSpending.SetValue(1)
				If (DMN_SXPAAutomaticXPSpending.GetValue() As Int == 1)
					Notification("Skyrim XP Addon: Enabled automatic XP spending.")
				EndIf
			ElseIf (iButton == 1)
			; [Disable Automatic XP Spending]
				DMN_SXPAAutomaticXPSpending.SetValue(0)
				If (DMN_SXPAAutomaticXPSpending.GetValue() As Int == 0)
					Notification("Skyrim XP Addon: Disabled automatic XP spending.")
				EndIf
			ElseIf (iButton == 2)
			; [Tagged Skills]
				iMenu = 30
			ElseIf (iButton == 3)
			; [Return to XP Settings]
				iMenu = 2
			ElseIf (iButton == 4)
			; [X]
				bMenu = False
			EndIf
	; Show the Configure Automatic XP Spending - Tagged Skills menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 30)
			iButton = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkills.Show()
			If (iButton == 0 || iButton == 1)
			; [Slot 01 Empty/Used]
				iMenu = 31
			ElseIf (iButton == 2 || iButton == 3)
			; [Slot 02 Empty/Used]
				iMenu = 32
			ElseIf (iButton == 4 || iButton == 5)
			; [Slot 03 Empty/Used]
				iMenu = 33
			ElseIf (iButton == 6 || iButton == 7)
			; [Slot 04 Empty/Used]
				iMenu = 34
			ElseIf (iButton == 8)
			; [Return to Configure Automatic XP Spending]
				iMenu = 29
			ElseIf (iButton == 9)
			; [X]
				bMenu = False
			EndIf
	; Show the Configure Automatic XP Spending - Tagged Skills - Slot 01 menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 31)
			String s01 ; Tagged skill name.
			String s02 = DMN_SXPAEH.sTaggedSkills[0] ; Current/Previous tagged skill name.
			String s03 ; Tagged skill priority.
			iButton = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsSlot01.Show()
			If (iButton == 0)
			; [Check Skill]
				MessageBox("Tagged skill: " + DMN_SXPAEH.sTaggedSkills[0] + ".")
			ElseIf (iButton == 1)
			Bool bPriorityMenu = True
			While (bPriorityMenu)
			; [Change Priority]
				iTagSkillPriority = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsPriority.Show()
				If (iTagSkillPriority == 0)
				; [Check Priority]
					If (DMN_SXPAEH.fTaggedSkillsPriority[0] == 0.60)
						s03 = "High."
					ElseIf (DMN_SXPAEH.fTaggedSkillsPriority[0] == 0.30)
						s03 = "Medium."
					ElseIf (DMN_SXPAEH.fTaggedSkillsPriority[0] == 0.10)
						s03 = "Low."
					EndIf
					MessageBox("Tagged skill priority: " + s03)
				ElseIf (iTagSkillPriority == 1)
				; [High Priority]
					DMN_SXPAEH.fTaggedSkillsPriority[0] = 0.60
					Notification("Skyrim XP Addon: Set \"" + s02 + "\"" + " automatic XP spend priority to High.")
					bPriorityMenu = False
				ElseIf (iTagSkillPriority == 2)
				; [Medium Priority]
					DMN_SXPAEH.fTaggedSkillsPriority[0] = 0.30
					Notification("Skyrim XP Addon: Set \"" + s02 + "\"" + " automatic XP spend priority to Medium.")
					bPriorityMenu = False
				ElseIf (iTagSkillPriority == 3)
				; [Low Priority]
					DMN_SXPAEH.fTaggedSkillsPriority[0] = 0.10
					Notification("Skyrim XP Addon: Set \"" + s02 + "\"" + " automatic XP spend priority to Low.")
					bPriorityMenu = False
				ElseIf (iTagSkillPriority == 4)
				; [Return to Configure Automatic XP Spending - Tagged Skills - Slot 01]
					bPriorityMenu = False
					iMenu = 31
				ElseIf (iTagSkillPriority == 5)
				; [X]
					bPriorityMenu = False
					bMenu = False
				EndIf
			EndWhile
			ElseIf (iButton == 2 || iButton == 3)
			; [Add Skill/Change Skill]
			Bool bSkills01 = True
			Bool bSkills02 = False
			Bool bSkills03 = False
			Bool bSkillsMenu = True
			While (bSkillsMenu)
				If (bSkills01)
					iTagSkillChosen = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsChoices01.Show()
					If (iTagSkillChosen == 0)
					; [Archery]
						s01 = "Archery"
					ElseIf (iTagSkillChosen == 1)
					; [Block]
						s01 = "Block"
					ElseIf (iTagSkillChosen == 2)
					; [Heavy Armor]
						s01 = "Heavy Armor"
					ElseIf (iTagSkillChosen == 3)
					; [One-Handed]
						s01 = "One-Handed"
					ElseIf (iTagSkillChosen == 4)
					; [Smithing]
						s01 = "Smithing"
					ElseIf (iTagSkillChosen == 5)
					; [Two-Handed]
						s01 = "Two-Handed"
					ElseIf (iTagSkillChosen == 6)
					; [>>]
						bSkills02 = True
						bSkills01 = False
					ElseIf (iTagSkillChosen == 7)
					; [Return to Configure Automatic XP Spending - Tagged Skills - Slot 01]
						iMenu = 31
					ElseIf (iTagSkillChosen == 8)
					; [X]
						bSkillsMenu = False
					EndIf
				; If a skill was tagged, set its default priority to medium.
					If (iButton == 2 && iTagSkillChosen >= 0 && iTagSkillChosen <= 5)
						DMN_SXPAEH.fTaggedSkillsPriority[0] = 0.30
					EndIf
					bSkills01 = False
				EndIf
				If (bSkills02)
					iTagSkillChosen = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsChoices02.Show()
					If (iTagSkillChosen == 0)
					; [Alteration]
						s01 = "Alteration"
					ElseIf (iTagSkillChosen == 1)
					; [Conjuration]
						s01 = "Conjuration"
					ElseIf (iTagSkillChosen == 2)
					; [Destruction]
						s01 = "Destruction"
					ElseIf (iTagSkillChosen == 3)
					; [Enchanting]
						s01 = "Enchanting"
					ElseIf (iTagSkillChosen == 4)
					; [Illusion]
						s01 = "Illusion"
					ElseIf (iTagSkillChosen == 5)
					; [Restoration]
						s01 = "Restoration"
					ElseIf (iTagSkillChosen == 6)
					; [>>]
						bSkills03 = True
						bSkills02 = False
					ElseIf (iTagSkillChosen == 7)
					; [Back]
						bSkills01 = True
						bSkills02 = False
					ElseIf (iTagSkillChosen == 8)
					; [X]
						bSkillsMenu = False
					EndIf
				; If a skill was tagged, set its default priority to medium.
					If (iButton == 2 && iTagSkillChosen >= 0 && iTagSkillChosen <= 5)
						DMN_SXPAEH.fTaggedSkillsPriority[0] = 0.30
					EndIf
					bSkills02 = False
				EndIf
				If (bSkills03)
					iTagSkillChosen = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsChoices03.Show()
					If (iTagSkillChosen == 0)
					; [Alchemy]
						s01 = "Alchemy"
					ElseIf (iTagSkillChosen == 1)
					; [Light Armor]
						s01 = "Light Armor"
					ElseIf (iTagSkillChosen == 2)
					; [Lockpicking]
						s01 = "Lockpicking"
					ElseIf (iTagSkillChosen == 3)
					; [Pickpocket]
						s01 = "Pickpocket"
					ElseIf (iTagSkillChosen == 4)
					; [Sneak]
						s01 = "Sneak"
					ElseIf (iTagSkillChosen == 5)
					; [Speech]
						s01 = "Speech"
					ElseIf (iTagSkillChosen == 6)
					; [Back]
						bSkills02 = True
						bSkills03 = False
					ElseIf (iTagSkillChosen == 7)
					; [X]
						bSkillsMenu = False
					EndIf
				; If a skill was tagged, set its default priority to medium.
					If (iButton == 2 && iTagSkillChosen >= 0 && iTagSkillChosen <= 5)
						DMN_SXPAEH.fTaggedSkillsPriority[0] = 0.30
					EndIf
					bSkills03 = False
				EndIf
				If (bSkills01 == False && bSkills02 == False && bSkills03 == False)
				; No menus left open by the user, completely exit the skill choices menu.
					bSkillsMenu = False
				EndIf
			EndWhile
			ElseIf (iButton == 4)
			; [Remove Skill]
				DMN_SXPAEH.sTaggedSkills[0] = ""
				DMN_SXPAEH.iTaggedSkillSlot01 = 0
				DMN_SXPAEH.bTaggedSkillSlot01Used = False
				DMN_SXPAEH.fTaggedSkillsPriority[0] = 0.00
				Notification("Skyrim XP Addon: Removed skill \"" + s02 + "\"" + " from tag slot 1.")
			ElseIf (iButton == 5)
			; [Return to Configure Automatic XP Spending - Tagged Skills]
				iMenu = 30
			ElseIf (iButton == 6)
			; [X]
				bMenu = False
			EndIf
		; Set the tagged skill to the chosen slot.
			If (s01 && s01 != "")
				DMN_SXPAEH.sTaggedSkills[0] = s01
				DMN_SXPAEH.iTaggedSkillSlot01 = indexSkillName(s01)
				DMN_SXPAEH.bTaggedSkillSlot01Used = True
				If (iButton == 2)
					Notification("Skyrim XP Addon: Added skill \"" + s01 + "\"" + " to tag slot 1.")
				ElseIf (iButton == 3)
					Notification("Skyrim XP Addon: Changed skill \"" + s02 + "\"" + " to \"" + s01 + "\"" + " in tag slot 1.")
				EndIf
				s01 = ""
				s03 = ""
			EndIf
	; Show the Configure Automatic XP Spending - Tagged Skills - Slot 02 menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 32)
			String s01 ; Tagged skill name.
			String s02 = DMN_SXPAEH.sTaggedSkills[1] ; Current/Previous tagged skill name.
			String s03 ; Tagged skill priority.
			iButton = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsSlot02.Show()
			If (iButton == 0)
			; [Check Skill]
				MessageBox("Tagged skill: " + DMN_SXPAEH.sTaggedSkills[1] + ".")
			ElseIf (iButton == 1)
			Bool bPriorityMenu = True
			While (bPriorityMenu)
			; [Change Priority]
				iTagSkillPriority = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsPriority.Show()
				If (iTagSkillPriority == 0)
				; [Check Priority]
					If (DMN_SXPAEH.fTaggedSkillsPriority[1] == 0.60)
						s03 = "High."
					ElseIf (DMN_SXPAEH.fTaggedSkillsPriority[1] == 0.30)
						s03 = "Medium."
					ElseIf (DMN_SXPAEH.fTaggedSkillsPriority[1] == 0.10)
						s03 = "Low."
					EndIf
					MessageBox("Tagged skill priority: " + s03)
				ElseIf (iTagSkillPriority == 1)
				; [High Priority]
					DMN_SXPAEH.fTaggedSkillsPriority[1] = 0.60
					Notification("Skyrim XP Addon: Set \"" + s02 + "\"" + " automatic XP spend priority to High.")
					bPriorityMenu = False
				ElseIf (iTagSkillPriority == 2)
				; [Medium Priority]
					DMN_SXPAEH.fTaggedSkillsPriority[1] = 0.30
					Notification("Skyrim XP Addon: Set \"" + s02 + "\"" + " automatic XP spend priority to Medium.")
					bPriorityMenu = False
				ElseIf (iTagSkillPriority == 3)
				; [Low Priority]
					DMN_SXPAEH.fTaggedSkillsPriority[1] = 0.10
					Notification("Skyrim XP Addon: Set \"" + s02 + "\"" + " automatic XP spend priority to Low.")
					bPriorityMenu = False
				ElseIf (iTagSkillPriority == 4)
				; [Return to Configure Automatic XP Spending - Tagged Skills - Slot 02]
					bPriorityMenu = False
					iMenu = 32
				ElseIf (iTagSkillPriority == 5)
				; [X]
					bPriorityMenu = False
					bMenu = False
				EndIf
			EndWhile
			ElseIf (iButton == 2 || iButton == 3)
			; [Add Skill/Change Skill]
			Bool bSkills01 = True
			Bool bSkills02 = False
			Bool bSkills03 = False
			Bool bSkillsMenu = True
			While (bSkillsMenu)
				If (bSkills01)
					iTagSkillChosen = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsChoices01.Show()
					If (iTagSkillChosen == 0)
					; [Archery]
						s01 = "Archery"
					ElseIf (iTagSkillChosen == 1)
					; [Block]
						s01 = "Block"
					ElseIf (iTagSkillChosen == 2)
					; [Heavy Armor]
						s01 = "Heavy Armor"
					ElseIf (iTagSkillChosen == 3)
					; [One-Handed]
						s01 = "One-Handed"
					ElseIf (iTagSkillChosen == 4)
					; [Smithing]
						s01 = "Smithing"
					ElseIf (iTagSkillChosen == 5)
					; [Two-Handed]
						s01 = "Two-Handed"
					ElseIf (iTagSkillChosen == 6)
					; [>>]
						bSkills02 = True
						bSkills01 = False
					ElseIf (iTagSkillChosen == 7)
					; [Return to Configure Automatic XP Spending - Tagged Skills - Slot 02]
						iMenu = 32
					ElseIf (iTagSkillChosen == 8)
					; [X]
						bSkillsMenu = False
					EndIf
				; If a skill was tagged, set its default priority to medium.
					If (iButton == 2 && iTagSkillChosen >= 0 && iTagSkillChosen <= 5)
						DMN_SXPAEH.fTaggedSkillsPriority[1] = 0.30
					EndIf
					bSkills01 = False
				EndIf
				If (bSkills02)
					iTagSkillChosen = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsChoices02.Show()
					If (iTagSkillChosen == 0)
					; [Alteration]
						s01 = "Alteration"
					ElseIf (iTagSkillChosen == 1)
					; [Conjuration]
						s01 = "Conjuration"
					ElseIf (iTagSkillChosen == 2)
					; [Destruction]
						s01 = "Destruction"
					ElseIf (iTagSkillChosen == 3)
					; [Enchanting]
						s01 = "Enchanting"
					ElseIf (iTagSkillChosen == 4)
					; [Illusion]
						s01 = "Illusion"
					ElseIf (iTagSkillChosen == 5)
					; [Restoration]
						s01 = "Restoration"
					ElseIf (iTagSkillChosen == 6)
					; [>>]
						bSkills03 = True
						bSkills02 = False
					ElseIf (iTagSkillChosen == 7)
					; [Back]
						bSkills01 = True
						bSkills02 = False
					ElseIf (iTagSkillChosen == 8)
					; [X]
						bSkillsMenu = False
					EndIf
				; If a skill was tagged, set its default priority to medium.
					If (iButton == 2 && iTagSkillChosen >= 0 && iTagSkillChosen <= 5)
						DMN_SXPAEH.fTaggedSkillsPriority[1] = 0.30
					EndIf
					bSkills02 = False
				EndIf
				If (bSkills03)
					iTagSkillChosen = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsChoices03.Show()
					If (iTagSkillChosen == 0)
					; [Alchemy]
						s01 = "Alchemy"
					ElseIf (iTagSkillChosen == 1)
					; [Light Armor]
						s01 = "Light Armor"
					ElseIf (iTagSkillChosen == 2)
					; [Lockpicking]
						s01 = "Lockpicking"
					ElseIf (iTagSkillChosen == 3)
					; [Pickpocket]
						s01 = "Pickpocket"
					ElseIf (iTagSkillChosen == 4)
					; [Sneak]
						s01 = "Sneak"
					ElseIf (iTagSkillChosen == 5)
					; [Speech]
						s01 = "Speech"
					ElseIf (iTagSkillChosen == 6)
					; [Back]
						bSkills02 = True
						bSkills03 = False
					ElseIf (iTagSkillChosen == 7)
					; [X]
						bSkillsMenu = False
					EndIf
				; If a skill was tagged, set its default priority to medium.
					If (iButton == 2 && iTagSkillChosen >= 0 && iTagSkillChosen <= 5)
						DMN_SXPAEH.fTaggedSkillsPriority[1] = 0.30
					EndIf
					bSkills03 = False
				EndIf
				If (bSkills01 == False && bSkills02 == False && bSkills03 == False)
				; No menus left open by the user, completely exit the skill choices menu.
					bSkillsMenu = False
				EndIf
			EndWhile
			ElseIf (iButton == 4)
			; [Remove Skill]
				DMN_SXPAEH.sTaggedSkills[1] = ""
				DMN_SXPAEH.iTaggedSkillSlot02 = 0
				DMN_SXPAEH.bTaggedSkillSlot02Used = False
				DMN_SXPAEH.fTaggedSkillsPriority[1] = 0.00
				Notification("Skyrim XP Addon: Removed skill \"" + s02 + "\"" + " from tag slot 2.")
			ElseIf (iButton == 5)
			; [Return to Configure Automatic XP Spending - Tagged Skills]
				iMenu = 30
			ElseIf (iButton == 6)
			; [X]
				bMenu = False
			EndIf
		; Set the tagged skill to the chosen slot.
			If (s01 && s01 != "")
				DMN_SXPAEH.sTaggedSkills[1] = s01
				DMN_SXPAEH.iTaggedSkillSlot02 = indexSkillName(s01)
				DMN_SXPAEH.bTaggedSkillSlot02Used = True
				If (iButton == 2)
					Notification("Skyrim XP Addon: Added skill \"" + s01 + "\"" + " to tag slot 2.")
				ElseIf (iButton == 3)
					Notification("Skyrim XP Addon: Changed skill \"" + s02 + "\"" + " to \"" + s01 + "\"" + " in tag slot 2.")
				EndIf
				s01 = ""
			EndIf
	; Show the Configure Automatic XP Spending - Tagged Skills - Slot 03 menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 33)
			String s01 ; Tagged skill name.
			String s02 = DMN_SXPAEH.sTaggedSkills[2] ; Current/Previous tagged skill name.
			String s03 ; Tagged skill priority.
			iButton = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsSlot03.Show()
			If (iButton == 0)
			; [Check Skill]
				MessageBox("Tagged skill: " + DMN_SXPAEH.sTaggedSkills[2] + ".")
			ElseIf (iButton == 1)
			Bool bPriorityMenu = True
			While (bPriorityMenu)
			; [Change Priority]
				iTagSkillPriority = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsPriority.Show()
				If (iTagSkillPriority == 0)
				; [Check Priority]
					If (DMN_SXPAEH.fTaggedSkillsPriority[2] == 0.60)
						s03 = "High."
					ElseIf (DMN_SXPAEH.fTaggedSkillsPriority[2] == 0.30)
						s03 = "Medium."
					ElseIf (DMN_SXPAEH.fTaggedSkillsPriority[2] == 0.10)
						s03 = "Low."
					EndIf
					MessageBox("Tagged skill priority: " + s03)
				ElseIf (iTagSkillPriority == 1)
				; [High Priority]
					DMN_SXPAEH.fTaggedSkillsPriority[2] = 0.60
					Notification("Skyrim XP Addon: Set \"" + s02 + "\"" + " automatic XP spend priority to High.")
					bPriorityMenu = False
				ElseIf (iTagSkillPriority == 2)
				; [Medium Priority]
					DMN_SXPAEH.fTaggedSkillsPriority[2] = 0.30
					Notification("Skyrim XP Addon: Set \"" + s02 + "\"" + " automatic XP spend priority to Medium.")
					bPriorityMenu = False
				ElseIf (iTagSkillPriority == 3)
				; [Low Priority]
					DMN_SXPAEH.fTaggedSkillsPriority[2] = 0.10
					Notification("Skyrim XP Addon: Set \"" + s02 + "\"" + " automatic XP spend priority to Low.")
					bPriorityMenu = False
				ElseIf (iTagSkillPriority == 4)
				; [Return to Configure Automatic XP Spending - Tagged Skills - Slot 03]
					bPriorityMenu = False
					iMenu = 33
				ElseIf (iTagSkillPriority == 5)
				; [X]
					bPriorityMenu = False
					bMenu = False
				EndIf
			EndWhile
			ElseIf (iButton == 2 || iButton == 3)
			; [Add Skill/Change Skill]
			Bool bSkills01 = True
			Bool bSkills02 = False
			Bool bSkills03 = False
			Bool bSkillsMenu = True
			While (bSkillsMenu)
				If (bSkills01)
					iTagSkillChosen = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsChoices01.Show()
					If (iTagSkillChosen == 0)
					; [Archery]
						s01 = "Archery"
					ElseIf (iTagSkillChosen == 1)
					; [Block]
						s01 = "Block"
					ElseIf (iTagSkillChosen == 2)
					; [Heavy Armor]
						s01 = "Heavy Armor"
					ElseIf (iTagSkillChosen == 3)
					; [One-Handed]
						s01 = "One-Handed"
					ElseIf (iTagSkillChosen == 4)
					; [Smithing]
						s01 = "Smithing"
					ElseIf (iTagSkillChosen == 5)
					; [Two-Handed]
						s01 = "Two-Handed"
					ElseIf (iTagSkillChosen == 6)
					; [>>]
						bSkills02 = True
						bSkills01 = False
					ElseIf (iTagSkillChosen == 7)
					; [Return to Configure Automatic XP Spending - Tagged Skills - Slot 03]
						iMenu = 33
					ElseIf (iTagSkillChosen == 8)
					; [X]
						bSkillsMenu = False
					EndIf
				; If a skill was tagged, set its default priority to medium.
					If (iButton == 2 && iTagSkillChosen >= 0 && iTagSkillChosen <= 5)
						DMN_SXPAEH.fTaggedSkillsPriority[2] = 0.30
					EndIf
					bSkills01 = False
				EndIf
				If (bSkills02)
					iTagSkillChosen = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsChoices02.Show()
					If (iTagSkillChosen == 0)
					; [Alteration]
						s01 = "Alteration"
					ElseIf (iTagSkillChosen == 1)
					; [Conjuration]
						s01 = "Conjuration"
					ElseIf (iTagSkillChosen == 2)
					; [Destruction]
						s01 = "Destruction"
					ElseIf (iTagSkillChosen == 3)
					; [Enchanting]
						s01 = "Enchanting"
					ElseIf (iTagSkillChosen == 4)
					; [Illusion]
						s01 = "Illusion"
					ElseIf (iTagSkillChosen == 5)
					; [Restoration]
						s01 = "Restoration"
					ElseIf (iTagSkillChosen == 6)
					; [>>]
						bSkills03 = True
						bSkills02 = False
					ElseIf (iTagSkillChosen == 7)
					; [Back]
						bSkills01 = True
						bSkills02 = False
					ElseIf (iTagSkillChosen == 8)
					; [X]
						bSkillsMenu = False
					EndIf
				; If a skill was tagged, set its default priority to medium.
					If (iButton == 2 && iTagSkillChosen >= 0 && iTagSkillChosen <= 5)
						DMN_SXPAEH.fTaggedSkillsPriority[2] = 0.30
					EndIf
					bSkills02 = False
				EndIf
				If (bSkills03)
					iTagSkillChosen = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsChoices03.Show()
					If (iTagSkillChosen == 0)
					; [Alchemy]
						s01 = "Alchemy"
					ElseIf (iTagSkillChosen == 1)
					; [Light Armor]
						s01 = "Light Armor"
					ElseIf (iTagSkillChosen == 2)
					; [Lockpicking]
						s01 = "Lockpicking"
					ElseIf (iTagSkillChosen == 3)
					; [Pickpocket]
						s01 = "Pickpocket"
					ElseIf (iTagSkillChosen == 4)
					; [Sneak]
						s01 = "Sneak"
					ElseIf (iTagSkillChosen == 5)
					; [Speech]
						s01 = "Speech"
					ElseIf (iTagSkillChosen == 6)
					; [Back]
						bSkills02 = True
						bSkills03 = False
					ElseIf (iTagSkillChosen == 7)
					; [X]
						bSkillsMenu = False
					EndIf
				; If a skill was tagged, set its default priority to medium.
					If (iButton == 2 && iTagSkillChosen >= 0 && iTagSkillChosen <= 5)
						DMN_SXPAEH.fTaggedSkillsPriority[2] = 0.30
					EndIf
					bSkills03 = False
				EndIf
				If (bSkills01 == False && bSkills02 == False && bSkills03 == False)
				; No menus left open by the user, completely exit the skill choices menu.
					bSkillsMenu = False
				EndIf
			EndWhile
			ElseIf (iButton == 4)
			; [Remove Skill]
				DMN_SXPAEH.sTaggedSkills[2] = ""
				DMN_SXPAEH.iTaggedSkillSlot03 = 0
				DMN_SXPAEH.bTaggedSkillSlot03Used = False
				DMN_SXPAEH.fTaggedSkillsPriority[2] = 0.00
				Notification("Skyrim XP Addon: Removed skill \"" + s02 + "\"" + " from tag slot 3.")
			ElseIf (iButton == 5)
			; [Return to Configure Automatic XP Spending - Tagged Skills]
				iMenu = 30
			ElseIf (iButton == 6)
			; [X]
				bMenu = False
			EndIf
		; Set the tagged skill to the chosen slot.
			If (s01 && s01 != "")
				DMN_SXPAEH.sTaggedSkills[2] = s01
				DMN_SXPAEH.iTaggedSkillSlot03 = indexSkillName(s01)
				DMN_SXPAEH.bTaggedSkillSlot03Used = True
				If (iButton == 2)
					Notification("Skyrim XP Addon: Added skill \"" + s01 + "\"" + " to tag slot 3.")
				ElseIf (iButton == 3)
					Notification("Skyrim XP Addon: Changed skill \"" + s02 + "\"" + " to \"" + s01 + "\"" + " in tag slot 3.")
				EndIf
				s01 = ""
			EndIf
	; Show the Configure Automatic XP Spending - Tagged Skills - Slot 04 menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 34)
			String s01 ; Tagged skill name.
			String s02 = DMN_SXPAEH.sTaggedSkills[3] ; Current/Previous tagged skill name.
			String s03 ; Tagged skill priority.
			iButton = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsSlot04.Show()
			If (iButton == 0)
			; [Check Skill]
				MessageBox("Tagged skill: " + DMN_SXPAEH.sTaggedSkills[3] + ".")
			ElseIf (iButton == 1)
			Bool bPriorityMenu = True
			While (bPriorityMenu)
			; [Change Priority]
				iTagSkillPriority = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsPriority.Show()
				If (iTagSkillPriority == 0)
				; [Check Priority]
					If (DMN_SXPAEH.fTaggedSkillsPriority[3] == 0.60)
						s03 = "High."
					ElseIf (DMN_SXPAEH.fTaggedSkillsPriority[3] == 0.30)
						s03 = "Medium."
					ElseIf (DMN_SXPAEH.fTaggedSkillsPriority[3] == 0.10)
						s03 = "Low."
					EndIf
					MessageBox("Tagged skill priority: " + s03)
				ElseIf (iTagSkillPriority == 1)
				; [High Priority]
					DMN_SXPAEH.fTaggedSkillsPriority[3] = 0.60
					Notification("Skyrim XP Addon: Set \"" + s02 + "\"" + " automatic XP spend priority to High.")
					bPriorityMenu = False
				ElseIf (iTagSkillPriority == 2)
				; [Medium Priority]
					DMN_SXPAEH.fTaggedSkillsPriority[3] = 0.30
					Notification("Skyrim XP Addon: Set \"" + s02 + "\"" + " automatic XP spend priority to Medium.")
					bPriorityMenu = False
				ElseIf (iTagSkillPriority == 3)
				; [Low Priority]
					DMN_SXPAEH.fTaggedSkillsPriority[3] = 0.10
					Notification("Skyrim XP Addon: Set \"" + s02 + "\"" + " automatic XP spend priority to Low.")
					bPriorityMenu = False
				ElseIf (iTagSkillPriority == 4)
				; [Return to Configure Automatic XP Spending - Tagged Skills - Slot 04]
					bPriorityMenu = False
					iMenu = 34
				ElseIf (iTagSkillPriority == 5)
				; [X]
					bPriorityMenu = False
					bMenu = False
				EndIf
			EndWhile
			ElseIf (iButton == 2 || iButton == 3)
			; [Add Skill/Change Skill]
			Bool bSkills01 = True
			Bool bSkills02 = False
			Bool bSkills03 = False
			Bool bSkillsMenu = True
			While (bSkillsMenu)
				If (bSkills01)
					iTagSkillChosen = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsChoices01.Show()
					If (iTagSkillChosen == 0)
					; [Archery]
						s01 = "Archery"
					ElseIf (iTagSkillChosen == 1)
					; [Block]
						s01 = "Block"
					ElseIf (iTagSkillChosen == 2)
					; [Heavy Armor]
						s01 = "Heavy Armor"
					ElseIf (iTagSkillChosen == 3)
					; [One-Handed]
						s01 = "One-Handed"
					ElseIf (iTagSkillChosen == 4)
					; [Smithing]
						s01 = "Smithing"
					ElseIf (iTagSkillChosen == 5)
					; [Two-Handed]
						s01 = "Two-Handed"
					ElseIf (iTagSkillChosen == 6)
					; [>>]
						bSkills02 = True
						bSkills01 = False
					ElseIf (iTagSkillChosen == 7)
					; [Return to Configure Automatic XP Spending - Tagged Skills - Slot 04]
						iMenu = 34
					ElseIf (iTagSkillChosen == 8)
					; [X]
						bSkillsMenu = False
					EndIf
				; If a skill was tagged, set its default priority to medium.
					If (iButton == 2 && iTagSkillChosen >= 0 && iTagSkillChosen <= 5)
						DMN_SXPAEH.fTaggedSkillsPriority[3] = 0.30
					EndIf
					bSkills01 = False
				EndIf
				If (bSkills02)
					iTagSkillChosen = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsChoices02.Show()
					If (iTagSkillChosen == 0)
					; [Alteration]
						s01 = "Alteration"
					ElseIf (iTagSkillChosen == 1)
					; [Conjuration]
						s01 = "Conjuration"
					ElseIf (iTagSkillChosen == 2)
					; [Destruction]
						s01 = "Destruction"
					ElseIf (iTagSkillChosen == 3)
					; [Enchanting]
						s01 = "Enchanting"
					ElseIf (iTagSkillChosen == 4)
					; [Illusion]
						s01 = "Illusion"
					ElseIf (iTagSkillChosen == 5)
					; [Restoration]
						s01 = "Restoration"
					ElseIf (iTagSkillChosen == 6)
					; [>>]
						bSkills03 = True
						bSkills02 = False
					ElseIf (iTagSkillChosen == 7)
					; [Back]
						bSkills01 = True
						bSkills02 = False
					ElseIf (iTagSkillChosen == 8)
					; [X]
						bSkillsMenu = False
					EndIf
				; If a skill was tagged, set its default priority to medium.
					If (iButton == 2 && iTagSkillChosen >= 0 && iTagSkillChosen <= 5)
						DMN_SXPAEH.fTaggedSkillsPriority[3] = 0.30
					EndIf
					bSkills02 = False
				EndIf
				If (bSkills03)
					iTagSkillChosen = DMN_SXPAConfigMenuXPAutomaticSpendingTaggedSkillsChoices03.Show()
					If (iTagSkillChosen == 0)
					; [Alchemy]
						s01 = "Alchemy"
					ElseIf (iTagSkillChosen == 1)
					; [Light Armor]
						s01 = "Light Armor"
					ElseIf (iTagSkillChosen == 2)
					; [Lockpicking]
						s01 = "Lockpicking"
					ElseIf (iTagSkillChosen == 3)
					; [Pickpocket]
						s01 = "Pickpocket"
					ElseIf (iTagSkillChosen == 4)
					; [Sneak]
						s01 = "Sneak"
					ElseIf (iTagSkillChosen == 5)
					; [Speech]
						s01 = "Speech"
					ElseIf (iTagSkillChosen == 6)
					; [Back]
						bSkills02 = True
						bSkills03 = False
					ElseIf (iTagSkillChosen == 7)
					; [X]
						bSkillsMenu = False
					EndIf
				; If a skill was tagged, set its default priority to medium.
					If (iButton == 2 && iTagSkillChosen >= 0 && iTagSkillChosen <= 5)
						DMN_SXPAEH.fTaggedSkillsPriority[3] = 0.30
					EndIf
					bSkills03 = False
				EndIf
				If (bSkills01 == False && bSkills02 == False && bSkills03 == False)
				; No menus left open by the user, completely exit the skill choices menu.
					bSkillsMenu = False
				EndIf
			EndWhile
			ElseIf (iButton == 4)
			; [Remove Skill]
				DMN_SXPAEH.sTaggedSkills[3] = ""
				DMN_SXPAEH.iTaggedSkillSlot04 = 0
				DMN_SXPAEH.bTaggedSkillSlot04Used = False
				DMN_SXPAEH.fTaggedSkillsPriority[3] = 0.00
				Notification("Skyrim XP Addon: Removed skill \"" + s02 + "\"" + " from tag slot 4.")
			ElseIf (iButton == 5)
			; [Return to Configure Automatic XP Spending - Tagged Skills]
				iMenu = 30
			ElseIf (iButton == 6)
			; [X]
				bMenu = False
			EndIf
		; Set the tagged skill to the chosen slot.
			If (s01 && s01 != "")
				DMN_SXPAEH.sTaggedSkills[3] = s01
				DMN_SXPAEH.iTaggedSkillSlot04 = indexSkillName(s01)
				DMN_SXPAEH.bTaggedSkillSlot04Used = True
				If (iButton == 2)
					Notification("Skyrim XP Addon: Added skill \"" + s01 + "\"" + " to tag slot 4.")
				ElseIf (iButton == 3)
					Notification("Skyrim XP Addon: Changed skill \"" + s02 + "\"" + " to \"" + s01 + "\"" + " in tag slot 4.")
				EndIf
				s01 = ""
			EndIf
	; Show the Configure XP System Type menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 35)
			iButton = DMN_SXPAConfigMenuXPSystemType.Show()
			If (iButton == 0)
			; [Switch To Exponential XP System]
				DMN_SXPAEH.bUseExponentialSkillCost = True
				DMN_SXPAEH.bUseExponentialXPGain = True
				If (DMN_SXPAEH.bUseExponentialSkillCost && DMN_SXPAEH.bUseExponentialXPGain)
					Notification("Skyrim XP Addon: Switched XP system type to exponential.")
				EndIf
			ElseIf (iButton == 1)
			; [Switch To Linear XP System]
				DMN_SXPAEH.bUseExponentialSkillCost = False
				DMN_SXPAEH.bUseExponentialXPGain = False
				If (!DMN_SXPAEH.bUseExponentialSkillCost && !DMN_SXPAEH.bUseExponentialXPGain)
					Notification("Skyrim XP Addon: Switched XP system type to linear.")
				EndIf
			ElseIf (iButton == 2)
			; [Configure Individual XP Systems]
				iMenu = 36
			ElseIf (iButton == 3)
			; [Return to XP Settings]
				iMenu = 2
			ElseIf (iButton == 4)
			; [X]
				bMenu = False
			EndIf
	; Show the Configure XP System Type - Individually Configure menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 36)
			iButton = DMN_SXPAConfigMenuXPSystemTypeConfigure.Show()
			If (iButton == 0)
			; [Switch To Exponential Skill Cost]
				DMN_SXPAEH.bUseExponentialSkillCost = True
				If (DMN_SXPAEH.bUseExponentialSkillCost)
					Notification("Skyrim XP Addon: Changed skill cost to exponential.")
				EndIf
			ElseIf (iButton == 1)
			; [Switch To Linear Skill Cost]
				DMN_SXPAEH.bUseExponentialSkillCost = False
				If (!DMN_SXPAEH.bUseExponentialSkillCost)
					Notification("Skyrim XP Addon: Changed skill cost to linear.")
				EndIf
			ElseIf (iButton == 2)
			; [Switch To Exponential XP Gain]
				DMN_SXPAEH.bUseExponentialXPGain = True
				If (DMN_SXPAEH.bUseExponentialXPGain)
					Notification("Skyrim XP Addon: Changed XP gain to exponential.")
				EndIf
			ElseIf (iButton == 3)
			; [Switch To Linear XP Gain]
				DMN_SXPAEH.bUseExponentialXPGain = False
				If (!DMN_SXPAEH.bUseExponentialXPGain)
					Notification("Skyrim XP Addon: Changed XP gain to linear.")
				EndIf
			ElseIf (iButton == 4)
			; [Return to Configure XP System Type]
				iMenu = 35
			ElseIf (iButton == 5)
			; [X]
				bMenu = False
			EndIf
		EndIf
	EndWhile
; We are now ready to configure other mod options.
	GoToState("configDone")
EndFunction

State configuring
	Function configureMod(Bool bMenu = True, Int iButton = 0, Int iMenu = 0)
	; Empty function to ensure user doesn't activate the config menu several times in succession.
		Notification("Skyrim XP Addon: Please wait for the previous configuration changes to complete...")
	EndFunction
EndState
