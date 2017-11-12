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

ScriptName DMN_SXPAConfig Extends Quest

{Skyrim XP Addon - Configuration Script by Deadmano.}
;==============================================
; Version: 1.1.0
;===============

Import DMN_DeadmaniacFunctionsSXPA
Import DMN_SXPAFunctions
Import Debug
Import Game
Import Utility

DMN_SXPAEventHandler Property DMN_SXPAEH Auto
DMN_SXPAPlayerAlias Property DMN_SXPAPA Auto

Book Property DMN_SXPAConfigurator Auto
{Stores the temporary mod configurator. Auto-Fill.}

GlobalVariable Property DMN_SXPADebug Auto
{Set to the debug global variable.}

; --

; User's Installed Script Version as an Integer.
GlobalVariable Property DMN_SXPAiVersionInstalled Auto 
{Stores the users Skyrim XP Addon version. Auto-Fill.}
; User's Installed Script Version as a string.
String DMN_SXPAsVersionInstalled 

; Current Script Version Being Run.
Int DMN_SXPAiVersionRunning
String DMN_SXPAsVersionRunning

; BEGIN Update Related Variables and Properties
;==============================================
;

; To come.

;
; END Update Related Variables and Properties
;==============================================

Event OnInit()
	preMaintenance() ; Function to run before the main script maintenance.
    Maintenance() ; Function to handle script maintenance.
	postMaintenance() ; Function to run after the main script maintenance.
EndEvent

Function preMaintenance()
	If (DMN_SXPAsVersionInstalled)
		; None for now.
	EndIf
EndFunction
 
Function Maintenance()
; The latest (current) version of Skyrim XP Addon. Update this to the version number.
	parseSXPAVersion("1", "1", "0") ; <--- CHANGE! No more than: "9e9", "99", "9".
; ---------------- UPDATE! ^^^^^^^^^^^

	If (DMN_SXPADebug.GetValue() == 1)
		If (DMN_SXPAsVersionInstalled)
			Wait(0.1)
			Notification("Skyrim XP Addon DEBUG: An existing install of Skyrim XP Addon was detected on this save!")
			If (DMN_SXPAsVersionInstalled == "")
				Wait(0.1)
				Notification("Skyrim XP Addon DEBUG: This save is referencing an unknown version of Skyrim XP Addon' configuration script.")
			Else
				Wait(0.1)
				Notification("Skyrim XP Addon DEBUG: This save is referencing version " + DMN_SXPAsVersionInstalled + " of Skyrim XP Addon' configuration script.")
			EndIf
			Wait(0.1)
			Notification("Skyrim XP Addon DEBUG: You are running Skyrim XP Addon' version " + DMN_SXPAsVersionRunning + " configuration script.")
		EndIf
	EndIf

; Check to see if this is a new install.
	If (DMN_SXPAiVersionInstalled.GetValue() as Int < ver3ToInteger("1", "0", "0"))
	
	; //Debug - Check if Skyrim XP Addon reaches the new install check.
		debugNotification(DMN_SXPADebug, "Skyrim XP Addon DEBUG: Checkpoint - New Install Check Reached.")
	
	; If it is, install Skyrim XP Addon for the first time to this save.
		installSXPA()

; Else check to see if the user's installed Skyrim XP Addon version is less than this running version of Skyrim XP Addon.
	ElseIf (DMN_SXPAiVersionInstalled.GetValue() as Int < DMN_SXPAiVersionRunning)

	; //Debug - Check if Skyrim XP Addon reaches the update check.
		debugNotification(DMN_SXPADebug, "Skyrim XP Addon DEBUG: Checkpoint - Update Check Reached.")
	
	; If it is then we need to run the update on this save.
		updateSXPA()

; Check to see if the user is loading a save with an existing Skyrim XP Addon install but is using older Skyrim XP Addon scripts than those saved with.
	ElseIf (DMN_SXPAiVersionInstalled.GetValue() as Int > DMN_SXPAiVersionRunning)
		Wait(0.1)
		MessageBox("Skyrim XP Addon has detected that you are using one or more outdated scripts than those used when this save was created. This is just a warning and you may continue to play with unknown side-effects; though for best results it is advised that you update to the latest version.")

; Check to see if the user's installed Skyrim XP Addon version matches this running version of Skyrim XP Addon.
	ElseIf (DMN_SXPAiVersionInstalled.GetValue() as Int == DMN_SXPAiVersionRunning)
	
	; //Debug - Check if Skyrim XP Addon reaches the versions match check.
		debugNotification(DMN_SXPADebug, "Skyrim XP Addon DEBUG: Checkpoint - Versions Match Check Reached.")
		debugNotification(DMN_SXPADebug, "Skyrim XP Addon DEBUG: String Value: " + DMN_SXPAsVersionRunning)
		debugNotification(DMN_SXPADebug, "Skyrim XP Addon DEBUG: Integer Value: " + DMN_SXPAiVersionRunning)

; No idea how the user got here, but good to grab just in case!
	Else
		Wait(0.1)
		MessageBox("WARNING: The version of Skyrim XP Addon cannot be detected! Please inform Deadmano.")
	EndIf
EndFunction

Function parseSXPAVersion(String sMajorVer, String sMinorVer, String sReleaseVer)
	DMN_SXPAiVersionRunning = ver3ToInteger(sMajorVer, sMinorVer, sReleaseVer)
	DMN_SXPAsVersionRunning = ver3ToString(sMajorVer, sMinorVer, sReleaseVer)
EndFunction

Function installSXPA()
; //Debug - Check if Skyrim XP Addon reaches the install function.
	debugNotification(DMN_SXPADebug, "Skyrim XP Addon DEBUG: Checkpoint - Install Function Reached.")
	Wait(0.1)
	Notification("Skyrim XP Addon: Installation and configuration in progress.")
	Notification("Skyrim XP Addon: Please do not quit or save the game until this process is complete.")
	
; Check for any existing XP activities the player may have done, and if any are found, reward the player with XP.
	rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.gStatValue, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.sStatName)
	
; Set the default configuration settings.
	configurationDefaults()
	
; Updates the user's installed Skyrim XP Addon version to this running version of Skyrim XP Addon.
	DMN_SXPAiVersionInstalled.SetValue(DMN_SXPAiVersionRunning as Int) ; Integer.
	DMN_SXPAsVersionInstalled = DMN_SXPAsVersionRunning ; String.
	Wait(0.1)
	Notification("Skyrim XP Addon: You are now running version " + DMN_SXPAsVersionInstalled + ". Enjoy!")
	Notification("Skyrim XP Addon: It is now safe to save your game to finalise the installation!")

; //Debug - Check if Skyrim XP Addon passes the install function.
	debugNotification(DMN_SXPADebug, "Skyrim XP Addon DEBUG: Checkpoint - Install Function Passed.")
EndFunction

Function updateSXPA()
; //Debug - Check if Skyrim XP Addon reaches the update function.
	debugNotification(DMN_SXPADebug, "Skyrim XP Addon DEBUG: Checkpoint - Update Function Reached.")

	If (DMN_SXPAsVersionInstalled == "")
		Wait(0.1)
		Notification("Skyrim XP Addon: Updating from a previous unknown version.")
	Else
		Wait(0.1)
		Notification("Skyrim XP Addon: Updating from version " + DMN_SXPAsVersionInstalled + ".")
	EndIf
	
	Notification("Skyrim XP Addon: Please do not quit or save the game until this process is complete.")

	; // BEGIN UPDATE FOR CURRENT SCRIPT VERSION
	;-------------------------------------------
	
; BEGIN v1.0.0 FIXES/PATCHES
	If (DMN_SXPAiVersionInstalled.GetValue() as Int < ver3ToInteger("1", "1", "0"))
	; Clear the player's stored SXPA experience value to resolve the error in XP calculations that resulted in inflated results.
		DMN_SXPAEH.DMN_SXPAExperiencePoints.SetValue(0)
	; Call the function to re-check all XP activities and re-assign XP values based on the corrected calculations.
		rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.gStatValue, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.sStatName)
	EndIf
; END v1.0.0 FIXES/PATCHES

	; // END UPDATE FOR CURRENT SCRIPT VERSION
	;-------------------------------------------
	
; Set the default configuration settings.
	configurationDefaults()

; Updates the user's installed Skyrim XP Addon version to this running version of Skyrim XP Addon.
	DMN_SXPAiVersionInstalled.SetValue(DMN_SXPAiVersionRunning as Int) ; Integer.
	DMN_SXPAsVersionInstalled = DMN_SXPAsVersionRunning ; String.
	Wait(0.1)
	Notification("Skyrim XP Addon: You are now running version " + DMN_SXPAsVersionInstalled + ". Enjoy!")
	Notification("Skyrim XP Addon: It is now safe to save your game to finalise the update!")

; //Debug - Check if Skyrim XP Addon passes the update function.
	debugNotification(DMN_SXPADebug, "Skyrim XP Addon DEBUG: Checkpoint - Update Function Passed.")
EndFunction

Function configurationDefaults()
; Update all existing stats and assign random XP values for each of them.
	updatePlayerStats(DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.gStatValue, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.sStatName, DMN_SXPAEH.sNotificationMessage, True)
	DMN_SXPAPA.waitForStatChange()
	
; Add (or update) the mod configurator to the player inventory silently.
	giveConfigurator(DMN_SXPAConfigurator)
	debugNotification(DMN_SXPADebug, "Skyrim XP Addon DEBUG: Gave the player the latest Skyrim XP Addon Configurator!")
EndFunction

Function postMaintenance()
	If (DMN_SXPAsVersionInstalled)
	; Update all existing stats and assign random XP values for each of them
	; on every game load, if Skyrim XP Addon has already been installed.
		updatePlayerStats(DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.gStatValue, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.sStatName, DMN_SXPAEH.sNotificationMessage)
		DMN_SXPAPA.waitForStatChange()
	EndIf
EndFunction
