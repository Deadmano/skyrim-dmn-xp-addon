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
Message Property DMN_SXPAConfigMenuTracking Auto
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
		Int minXP
		Int maxXP
		Float fMultiplierLocationsDiscovered
		Float fMultiplierStandingStonesFound
		Float fMultiplierNirnrootsFound
		Float fMultiplierBooksRead
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
			; [Exit]
				bMenu = False
			EndIf
	; Show the Tracking Options menu.
	; -------------------------------
		ElseIf (iMenu == 1)
			iButton = DMN_SXPAConfigMenuTracking.Show()
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
				updatePlayerStats(DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.gStatValue, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.sStatName, DMN_SXPAEH.sNotificationMessage, True)
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
				updatePlayerStats(DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.gStatValue, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.sStatName, DMN_SXPAEH.sNotificationMessage, True)
				Wait(3.0)
				DMN_SXPAPA.waitForStatChange() ; Start the custom stat monitoring function.
				Notification("Skyrim XP Addon: Active (always monitoring) tracking has been enabled.")
			ElseIf (iButton == 5)
			; [Turn On Passive Tracking]
				DMN_SXPAEH.iPassiveMonitoring = 1
				DMN_SXPAEH.startTracking() ; Start the built-in TrackedStatsEvent function.
				Notification("Skyrim XP Addon: Passive (event triggered) tracking has been enabled.")
			ElseIf (iButton == 6)
			; [Return to XP Settings]
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
				spendXP(DMN_SXPAExperiencePoints, DMN_SXPAEH.fSkillModifier, DMN_SXPAEH.iSkillXP, DMN_SXPAEH.iSkillXPSpent, DMN_SXPAEH.iSkillXPSpentEffective, DMN_SXPAEH.sSkillName, sSkill, iAmount)
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
				spendXP(DMN_SXPAExperiencePoints, DMN_SXPAEH.fSkillModifier, DMN_SXPAEH.iSkillXP, DMN_SXPAEH.iSkillXPSpent, DMN_SXPAEH.iSkillXPSpentEffective, DMN_SXPAEH.sSkillName, sSkill, iAmount)
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
				spendXP(DMN_SXPAExperiencePoints, DMN_SXPAEH.fSkillModifier, DMN_SXPAEH.iSkillXP, DMN_SXPAEH.iSkillXPSpent, DMN_SXPAEH.iSkillXPSpentEffective, DMN_SXPAEH.sSkillName, sSkill, iAmount)
				sSkill = ""
				iAmount = 0
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
