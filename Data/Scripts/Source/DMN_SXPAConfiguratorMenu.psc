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

ScriptName DMN_SXPAConfiguratorMenu Extends ObjectReference

{Temporary mod configuration script pre-MCM.}

Import Game
Import Debug
Import Utility
Import DMN_SXPAFunctions

GlobalVariable Property DMN_SXPAActiveMonitoring Auto
GlobalVariable Property DMN_SXPAExperienceMin Auto
GlobalVariable Property DMN_SXPAExperienceMax Auto
GlobalVariable Property DMN_SXPAExperiencePoints Auto

Message Property DMN_SXPAConfigMenu Auto
Message Property DMN_SXPAConfigMenuMiscellaneous Auto
Message Property DMN_SXPAConfigMenuMiscellaneousDebugSettings Auto
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
Message Property DMN_SXPAConfigMenuTrackingActivityCategoriesMagic Auto
Message Property DMN_SXPAConfigMenuTrackingActivityCategoriesQuests01 Auto
Message Property DMN_SXPAConfigMenuTrackingActivityCategoriesQuests02 Auto
Message Property DMN_SXPAConfigMenuXP Auto
Message Property DMN_SXPAConfigMenuXPMinMax Auto
Message Property DMN_SXPAConfigMenuXPMinMaxRewardMax Auto
Message Property DMN_SXPAConfigMenuXPMinMaxRewardMin Auto
Message Property DMN_SXPAConfigMenuXPMultiplier Auto
Message Property DMN_SXPAConfigMenuXPMultiplierValues Auto
Message Property DMN_SXPAConfigMenuSpendXP Auto
Message Property DMN_SXPAConfigMenuSpendXPCombat Auto
Message Property DMN_SXPAConfigMenuSpendXPMagic Auto
Message Property DMN_SXPAConfigMenuSpendXPStealth Auto
Message Property DMN_SXPAConfigMenuSpendXPAmount Auto

DMN_SXPAEventHandler Property DMN_SXPAEH Auto
DMN_SXPAPlayerAlias Property DMN_SXPAPA Auto

Event OnRead()
; Disable all other menus temporarily leaving only the message box to show.
	DisablePlayerControls(False, False, False, False, False, True)
; Undo the above change.
	EnablePlayerControls(False, False, False, False, False, True)
; Fire up the configuration function.
	configureMod()
EndEvent

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
		Int iXPActivityIndex
		Int minXP
		Int maxXP
		String sXPActivityName
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
			EndIf
	; Show the XP Settings menu.
	; --------------------------
		ElseIf (iMenu == 2)
			iButton = DMN_SXPAConfigMenuXP.Show()
			If (iButton == 0)
			; [Configure Min/Max XP]
				iMenu = 3
			ElseIf (iButton == 1)
			; [Configure Multipliers]
				iMenu = 4
			ElseIf (iButton == 2)
				iMenu = 0
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
			EndIf
	; Show the Configure Multipliers menu.
	; -----------------------------------
		ElseIf (iMenu == 4)
			iButton = DMN_SXPAConfigMenuXPMultiplier.Show()
			If (iButton == 0)
			; [Locations Discovered]
				iButton = DMN_SXPAConfigMenuXPMultiplierValues.Show()
				If (iButton == 0)
					fMultiplierLocationsDiscovered = 0.40
				ElseIf (iButton == 1)
					fMultiplierLocationsDiscovered = 0.80
				ElseIf (iButton == 2)
					fMultiplierLocationsDiscovered = 1.20
				ElseIf (iButton == 3)
					fMultiplierLocationsDiscovered = 2.00
				ElseIf (iButton == 4)
					fMultiplierLocationsDiscovered = 2.50
				ElseIf (iButton == 5)
					fMultiplierLocationsDiscovered = 3.00
				ElseIf (iButton == 6)
					fMultiplierLocationsDiscovered = 4.00
				ElseIf (iButton == 7)
					fMultiplierLocationsDiscovered = 6.00
				ElseIf (iButton == 8)
					fMultiplierLocationsDiscovered = 10.00
				ElseIf (iButton == 9)
				; [Return to Configure Multipliers]
					iMenu = 4
				EndIf
				If (fMultiplierLocationsDiscovered > 0)
					DMN_SXPAEH.fXPModifier[0] = fMultiplierLocationsDiscovered
					Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[0] + " XP multiplier set to " + fMultiplierLocationsDiscovered + ".")
				EndIf
			ElseIf (iButton == 1)
			; [Standing Stones Found]
				iButton = DMN_SXPAConfigMenuXPMultiplierValues.Show()
				If (iButton == 0)
					fMultiplierStandingStonesFound = 0.40
				ElseIf (iButton == 1)
					fMultiplierStandingStonesFound = 0.80
				ElseIf (iButton == 2)
					fMultiplierStandingStonesFound = 1.20
				ElseIf (iButton == 3)
					fMultiplierStandingStonesFound = 2.00
				ElseIf (iButton == 4)
					fMultiplierStandingStonesFound = 2.50
				ElseIf (iButton == 5)
					fMultiplierStandingStonesFound = 3.00
				ElseIf (iButton == 6)
					fMultiplierStandingStonesFound = 4.00
				ElseIf (iButton == 7)
					fMultiplierStandingStonesFound = 6.00
				ElseIf (iButton == 8)
					fMultiplierStandingStonesFound = 10.00
				ElseIf (iButton == 9)
				; [Return to Configure Multipliers]
					iMenu = 4
				EndIf
				If (fMultiplierStandingStonesFound > 0)
					DMN_SXPAEH.fXPModifier[1] = fMultiplierStandingStonesFound
					Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[1] + " XP multiplier set to " + fMultiplierStandingStonesFound + ".")
				EndIf
			ElseIf (iButton == 2)
			; [Nirnroots Found]
				iButton = DMN_SXPAConfigMenuXPMultiplierValues.Show()
				If (iButton == 0)
					fMultiplierNirnrootsFound = 0.40
				ElseIf (iButton == 1)
					fMultiplierNirnrootsFound = 0.80
				ElseIf (iButton == 2)
					fMultiplierNirnrootsFound = 1.20
				ElseIf (iButton == 3)
					fMultiplierNirnrootsFound = 2.00
				ElseIf (iButton == 4)
					fMultiplierNirnrootsFound = 2.50
				ElseIf (iButton == 5)
					fMultiplierNirnrootsFound = 3.00
				ElseIf (iButton == 6)
					fMultiplierNirnrootsFound = 4.00
				ElseIf (iButton == 7)
					fMultiplierNirnrootsFound = 6.00
				ElseIf (iButton == 8)
					fMultiplierNirnrootsFound = 10.00
				ElseIf (iButton == 9)
				; [Return to Configure Multipliers]
					iMenu = 4
				EndIf
				If (fMultiplierNirnrootsFound > 0)
					DMN_SXPAEH.fXPModifier[2] = fMultiplierNirnrootsFound
					Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[2] + " XP multiplier set to " + fMultiplierNirnrootsFound + ".")
				EndIf
			ElseIf (iButton == 3)
			; [Books Read]
				iButton = DMN_SXPAConfigMenuXPMultiplierValues.Show()
				If (iButton == 0)
					fMultiplierBooksRead = 0.40
				ElseIf (iButton == 1)
					fMultiplierBooksRead = 0.80
				ElseIf (iButton == 2)
					fMultiplierBooksRead = 1.20
				ElseIf (iButton == 3)
					fMultiplierBooksRead = 2.00
				ElseIf (iButton == 4)
					fMultiplierBooksRead = 2.50
				ElseIf (iButton == 5)
					fMultiplierBooksRead = 3.00
				ElseIf (iButton == 6)
					fMultiplierBooksRead = 4.00
				ElseIf (iButton == 7)
					fMultiplierBooksRead = 6.00
				ElseIf (iButton == 8)
					fMultiplierBooksRead = 10.00
				ElseIf (iButton == 9)
				; [Return to Configure Multipliers]
					iMenu = 4
				EndIf
				If (fMultiplierBooksRead > 0)
					DMN_SXPAEH.fXPModifier[3] = fMultiplierBooksRead
					Notification("Skyrim XP Addon: " + DMN_SXPAEH.sStatName[3] + " XP multiplier set to " + fMultiplierBooksRead + ".")
				EndIf
			ElseIf (iButton == 4)
			; [Return to XP Settings]
				iMenu = 2
			EndIf
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
			EndIf
	; Show the Spend XP - Combat menu.
	; -------------------------------------
		ElseIf (iMenu == 8)
			Int i = DMN_SXPAExperiencePoints.GetValue() as Int
			String sSkill
			Int iAmount
			iButton = DMN_SXPAConfigMenuSpendXPCombat.Show(i)
			If (iButton == 0)
			; [Archery]
				sSkill = "Marksman"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Combat]
					iMenu = 8
				EndIf
			ElseIf (iButton == 1)
			; [Block]
				sSkill = "Block"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Combat]
					iMenu = 8
				EndIf
			ElseIf (iButton == 2)
			; [Heavy Armor]
				sSkill = "HeavyArmor"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Combat]
					iMenu = 8
				EndIf
			ElseIf (iButton == 3)
			; [One-Handed]
				sSkill = "OneHanded"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Combat]
					iMenu = 8
				EndIf
			ElseIf (iButton == 4)
			; [Smithing]
				sSkill = "Smithing"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Combat]
					iMenu = 8
				EndIf
			ElseIf (iButton == 5)
			; [Two-Handed]
				sSkill = "TwoHanded"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Combat]
					iMenu = 8
				EndIf
			ElseIf (iButton == 6)
			; [Return to Spend XP]
				iMenu = 7
			EndIf
			If (sSkill && iAmount > 0)
				spendXP(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAExperiencePoints, DMN_SXPAEH.fSkillModifier, DMN_SXPAEH.iSkillXP, DMN_SXPAEH.iSkillXPSpent, DMN_SXPAEH.iSkillXPSpentEffective, DMN_SXPAEH.sSkillName, sSkill, iAmount)
				sSkill = ""
				iAmount = 0
			EndIf
	; Show the Spend XP - Magic menu.
	; -------------------------------------
		ElseIf (iMenu == 9)
			Int i = DMN_SXPAExperiencePoints.GetValue() as Int
			String sSkill
			Int iAmount
			iButton = DMN_SXPAConfigMenuSpendXPMagic.Show(i)
			If (iButton == 0)
			; [Alteration]
				sSkill = "Alteration"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
					iMenu = 9
				; [Return to Spend XP - Magic]
				EndIf
			ElseIf (iButton == 1)
			; [Conjuration]
				sSkill = "Conjuration"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Magic]
					iMenu = 9
				EndIf
			ElseIf (iButton == 2)
			; [Destruction]
				sSkill = "Destruction"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Magic]
					iMenu = 9
				EndIf
			ElseIf (iButton == 3)
			; [Enchanting]
				sSkill = "Enchanting"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Magic]
					iMenu = 9
				EndIf
			ElseIf (iButton == 4)
			; [Illusion]
				sSkill = "Illusion"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Magic]
					iMenu = 9
				EndIf
			ElseIf (iButton == 5)
			; [Restoration]
				sSkill = "Restoration"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Magic]
					iMenu = 9
				EndIf
			ElseIf (iButton == 6)
			; [Return to Spend XP]
				iMenu = 7
			EndIf
			If (sSkill && iAmount > 0)
				spendXP(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAExperiencePoints, DMN_SXPAEH.fSkillModifier, DMN_SXPAEH.iSkillXP, DMN_SXPAEH.iSkillXPSpent, DMN_SXPAEH.iSkillXPSpentEffective, DMN_SXPAEH.sSkillName, sSkill, iAmount)
				sSkill = ""
				iAmount = 0
			EndIf
	; Show the Spend XP - Stealth menu.
	; -------------------------------------
		ElseIf (iMenu == 10)
			Int i = DMN_SXPAExperiencePoints.GetValue() as Int
			String sSkill
			Int iAmount
			iButton = DMN_SXPAConfigMenuSpendXPStealth.Show(i)
			If (iButton == 0)
			; [Alchemy]
				sSkill = "Alchemy"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Stealth]
					iMenu = 10
				EndIf
			ElseIf (iButton == 1)
			; [Light Armor]
				sSkill = "LightArmor"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Stealth]
					iMenu = 10
				EndIf
			ElseIf (iButton == 2)
			; [Lockpicking]
				sSkill = "Lockpicking"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Stealth]
					iMenu = 10
				EndIf
			ElseIf (iButton == 3)
			; [Pickpocket]
				sSkill = "Pickpocket"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Stealth]
					iMenu = 10
				EndIf
			ElseIf (iButton == 4)
			; [Sneak]
				sSkill = "Sneak"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Stealth]
					iMenu = 10
				EndIf
			ElseIf (iButton == 5)
			; [Speech]
				sSkill = "Speechcraft"
				iButton = DMN_SXPAConfigMenuSpendXPAmount.Show(i)
				If (iButton == 0)
				; [100XP]
					iAmount = 100
				ElseIf (iButton == 1)
				; [500XP]
					iAmount = 500
				ElseIf (iButton == 2)
				; [1000XP]
					iAmount = 1000
				ElseIf (iButton == 3)
				; [5000XP]
					iAmount = 5000
				ElseIf (iButton == 4)
				; [Return to Spend XP - Stealth]
					iMenu = 10
				EndIf
			ElseIf (iButton == 6)
			; [Return to Spend XP]
				iMenu = 7
			EndIf
			If (sSkill && iAmount > 0)
				spendXP(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAExperiencePoints, DMN_SXPAEH.fSkillModifier, DMN_SXPAEH.iSkillXP, DMN_SXPAEH.iSkillXPSpent, DMN_SXPAEH.iSkillXPSpentEffective, DMN_SXPAEH.sSkillName, sSkill, iAmount)
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
			; Since we're exiting the tracking activities menu, let's check for any XP activities the player may have
			; chosen to enable, and if any are found, set random XP values for them as existing XP activities.
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName)
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
				updatePlayerStats(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.sNotificationMessage, True)
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
				updatePlayerStats(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.sNotificationMessage, True)
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
			EndIf
	; Show the Tracking Options - Activity - General menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 13)
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesGeneral01.Show()
			If (iButton == 0)
			; [Locations Discovered]
				sXPActivityName = "Locations Discovered"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 1)
			; [Standing Stones Found]
				sXPActivityName = "Standing Stones Found"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 2)
			; [Books Read]
				sXPActivityName = "Books Read"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 3)
			; [Persuasions]
				sXPActivityName = "Persuasions"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 4)
			; [Intimidations]
				sXPActivityName = "Intimidations"
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 5)
			; [Return to Tracking Options - Activity Categories]
				iMenu = 11
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
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesQuests01.Show()
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
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesQuests02.Show()
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
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesCombat01.Show()
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
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesCombat02.Show()
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
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesMagic.Show()
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
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesCrafting01.Show()
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
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesCrafting02.Show()
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
			iButton = DMN_SXPAConfigMenuTrackingActivityCategoriesCrime.Show()
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
			;iButton = .Show()
			If (iButton == 0)
			; [Placeholder]
				sXPActivityName = ""
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 1)
			; [Placeholder]
				sXPActivityName = ""
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 2)
			; [Placeholder]
				sXPActivityName = ""
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 3)
			; [Placeholder]
				sXPActivityName = ""
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 4)
			; [>>]
				iMenu = 23
			ElseIf (iButton == 5)
			; [Return to Tracking Options - Activity Categories]
				iMenu = 11
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
			;iButton = .Show()
			If (iButton == 0)
			; [Placeholder]
				sXPActivityName = ""
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 1)
			; [Placeholder]
				sXPActivityName = ""
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 2)
			; [Placeholder]
				sXPActivityName = ""
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 3)
			; [Placeholder]
				sXPActivityName = ""
				iXPActivityIndex = getXPActivityIndex(sXPActivityName, DMN_SXPAEH.sStatName)
				bXPActivityState = getXPActivityState(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.bXPActivityState, iXPActivityIndex, DMN_SXPAEH.sStatName)
			ElseIf (iButton == 4)
			; [Return to Tracking Options - Activity - General 02]
				iMenu = 22
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
			; [Wipe SXPA Player Data]
				iMenu = 26
			ElseIf (iButton == 2)
			; [Reset SXPA Default Values]
				iMenu = 27
			ElseIf (iButton == 3)
			; [Return to Main Config]
				iMenu = 0
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
				rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName)
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
			; [Return to Miscellaneous]
				iMenu = 24
			EndIf
	; Show the Miscellaneous - Wipe Confirmation menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 26)
			iButton = DMN_SXPAConfigMenuMiscellaneousWipeConfirmation.Show()
			If (iButton == 0)
			; [Wipe My SXPA Data]
				Notification("Skyrim XP Addon: Wiping player's SXPA data...")
				resetSXPAProgress(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAActiveMonitoring, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.iSkillXP, DMN_SXPAEH.iSkillXPSpent, DMN_SXPAEH.iSkillXPSpentEffective, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sSkillName, DMN_SXPAEH.sStatName)
				Notification("Skyrim XP Addon: SXPA player data has been wiped!")
			; Register for XP activity active tracking once more.
				DMN_SXPAPA.waitForStatChange()
				bMenu = False
			ElseIf (iButton == 1)
			; [Wipe My SXPA Data And Reset SXPA Values To Default]
				Notification("Skyrim XP Addon: Wiping player's SXPA data and restoring SXPA default values...")
				resetSXPAProgress(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAActiveMonitoring, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.iSkillXP, DMN_SXPAEH.iSkillXPSpent, DMN_SXPAEH.iSkillXPSpentEffective, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sSkillName, DMN_SXPAEH.sStatName)
				setSXPADefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAActiveMonitoring, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fSkillModifier, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.iPassiveMonitoring)
			; Register for XP activity active tracking once more.
				DMN_SXPAPA.waitForStatChange()
				Notification("Skyrim XP Addon: SXPA player data has been wiped and SXPA default values restored!")
				bMenu = False
			ElseIf (iButton == 2)
			; [Return to Miscellaneous]
				iMenu = 24
			EndIf
	; Show the Miscellaneous - Reset Confirmation menu.
	; ----------------------------------------------------
		ElseIf (iMenu == 27)
			iButton = DMN_SXPAConfigMenuMiscellaneousResetConfirmation.Show()
			If (iButton == 0)
			; [Reset SXPA Values To Default]
				Notification("Skyrim XP Addon: Restoring SXPA default values...")
				setSXPADefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAActiveMonitoring, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fSkillModifier, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.iPassiveMonitoring)
			; Register for XP activity active tracking once more.
				DMN_SXPAPA.waitForStatChange()
				Notification("Skyrim XP Addon: SXPA default values have been restored!")
				bMenu = False
			ElseIf (iButton == 1)
			; [Reset SXPA Values To Default And Wipe My SXPA Data]
				Notification("Skyrim XP Addon: Restoring SXPA default values and wiping player's SXPA data...")
				setSXPADefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAActiveMonitoring, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fSkillModifier, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.iPassiveMonitoring)
				resetSXPAProgress(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAActiveMonitoring, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.iSkillXP, DMN_SXPAEH.iSkillXPSpent, DMN_SXPAEH.iSkillXPSpentEffective, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sSkillName, DMN_SXPAEH.sStatName)
			; Register for XP activity active tracking once more.
				DMN_SXPAPA.waitForStatChange()
				Notification("Skyrim XP Addon: SXPA default values have been restored and SXPA player data wiped!")
				bMenu = False
			ElseIf (iButton == 2)
			; [Return to Miscellaneous]
				iMenu = 24
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
