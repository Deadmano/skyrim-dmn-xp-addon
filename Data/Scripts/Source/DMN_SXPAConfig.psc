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
; Version: 2.0.0
;===============

Import DMN_DeadmaniacFunctionsSXPA
Import DMN_SXPAFunctions
Import Debug
Import Game
Import Utility

DMN_SXPAEventHandler Property DMN_SXPAEH Auto
DMN_SXPAEventHandlerData Property DMN_SXPAEHD Auto
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
; BEGIN v1.1.0
;-------------

Message Property DMN_SXPAUpdateAnnouncement_v1_1_0 Auto
{The message that is shown to the player for the update to version 1.1.0. Auto-Fill.}

; END v1.1.0
;-------------

; BEGIN v1.2.0
;-------------

; The variable that handles checking for the active monitoring state.
Bool bActiveMonitoringEnabled

GlobalVariable Property DMN_SXPAActiveMonitoring Auto
{Handles active (always on) XP activity tracking. Auto-Fill.}

Message Property DMN_SXPAUpdateAnnouncement_v1_2_0 Auto
{The message that is shown to the player for the update to version 1.2.0. Auto-Fill.}

; END v1.2.0
;-------------

; BEGIN v2.0.0
;-------------

; The variable that, if true, will supress the
; message about the debug variable being on.
Bool bSuppressDebugState

Message Property DMN_SXPAMessageDebugEnabled Auto
{The message that is shown to the player if debugging mode is enabled. Auto-Fill.}

Message Property DMN_SXPAUpdateAnnouncement_v2_0_0 Auto
{The message that is shown to the player for the update to version 2.0.0. Auto-Fill.}

; END v2.0.0
;-------------
;
; END Update Related Variables and Properties
;==============================================

Event OnInit()
	preMaintenance() ; Function to run before the main script maintenance.
    Maintenance() ; Function to handle script maintenance.
	postMaintenance() ; Function to run after the main script maintenance.
EndEvent

Function preMaintenance()
	If (!bSuppressDebugState)
		If (DMN_SXPADebug.GetValue() as Int == 1)
			Int iChoice = DMN_SXPAMessageDebugEnabled.Show()
			If (iChoice == 0)
			; [Disable Debugging]
				DMN_SXPADebug.SetValue(0)
				If (DMN_SXPADebug.GetValue() as Int == 0)
					Notification("Skyrim XP Addon: Successfully disabled debugging mode.")
				Else
					Notification("Skyrim XP Addon: Could not disable debugging mode.")
				EndIf
			ElseIf (iChoice == 1)
				bSuppressDebugState = True
				Notification("Skyrim XP Addon: You will no longer be notified about the debugging mode going forward.")
			ElseIf (iChoice == 2)
				Notification("Skyrim XP Addon: You will be reminded about the debugging mode on the next game load.")
			EndIf
		EndIf
	EndIf
	; Disable XP activity active tracking whilst updates are running to avoid any issues if
	; active tracking was already enabled and not disabled by the user.
	Int DMN_SXPAActiveMonitoringState = DMN_SXPAActiveMonitoring.GetValue() As Int
	If (DMN_SXPAActiveMonitoringState == 1)
		bActiveMonitoringEnabled = True
		DMN_SXPALog(DMN_SXPADebug, "\n")
		DMN_SXPALog(DMN_SXPADebug, "Disabling XP activity active tracking temporarily...")
		DMN_SXPAActiveMonitoring.SetValue(0)
		If (DMN_SXPAActiveMonitoring.GetValue() == 0)
			DMN_SXPALog(DMN_SXPADebug, "XP activity active tracking was disabled.\n\n")
		Else
			DMN_SXPALog(DMN_SXPADebug, "WARNING: XP activity active tracking was NOT disabled!\n\n")
		EndIf
	EndIf
EndFunction
 
Function Maintenance()
; The latest (current) version of Skyrim XP Addon. Update this to the version number.
	parseSXPAVersion("2", "0", "0") ; <--- CHANGE! No more than: "9e9", "99", "9".
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
	rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName)
	
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
		resetStatValues(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName)
	EndIf
; END v1.0.0 FIXES/PATCHES

; BEGIN v1.1.0 FIXES/PATCHES
	If (DMN_SXPAiVersionInstalled.GetValue() as Int < ver3ToInteger("1", "2", "0"))
	; Reset the XP Spent variable due to inaccurate calculations since v1.0.0.
		resetArrayDataInt(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.iSkillXPSpent)
	EndIf
; END v1.1.0 FIXES/PATCHES

; BEGIN v1.2.0 FIXES/PATCHES
	If (DMN_SXPAiVersionInstalled.GetValue() as Int < ver3ToInteger("2", "0", "0"))
	; Backup user data then reset the Event Handler quest so the new properties/variables are accessible.
		DMN_SXPAEHD.updateEventHandlerData()
	; Correct certain XP modifier values for balancing purposes.
		DMN_SXPAEH.fXPModifier[0] = 0.60 ; Locations Discovered.
		DMN_SXPAEH.fXPModifier[1] = 5.00 ; Standing Stones Found.
		DMN_SXPAEH.fXPModifier[2] = 0.40 ; Nirnroots Found.
		DMN_SXPAEH.fXPModifier[4] = 0.15 ; Ingredients Harvested.
		DMN_SXPAEH.fXPModifier[5] = 0.40 ; Wings Plucked.
		DMN_SXPAEH.fXPModifier[6] = 0.80 ; Persuasions.
		DMN_SXPAEH.fXPModifier[7] = 0.80 ; Intimidations.
	; 0 = Locations Discovered, 1 = Standing Stones Found, 2 = Nirnroots Found, 3 = Books Read.
	; 4 = Ingredients Harvested, 5 = Wings Plucked, 6 = Persuasions, 7 = Intimidations.
	EndIf
; END v1.2.0 FIXES/PATCHES

; BEGIN NON-SPECIFIC VERSION UPDATES
;-----------------------------------

; Perform a check for array lengths to ensure they are all the same length as each array
; element is necessary for every other array element of the same size. Without every
; element in the correct place for each array, things can go seriously wrong such as
; calculations or wrong XP activities being enabled/disabled, wrong XP being given, etc.
	If (DMN_SXPAEH.sStatName)
		Int iArrayStatName = DMN_SXPAEH.sStatName.Length
		Int iArraybXPActivityState = DMN_SXPAEH.bXPActivityState.Length
		Int iArrayfXPModifier = DMN_SXPAEH.fXPModifier.Length
		Int iArrayiTrackedStatCount = DMN_SXPAEH.iTrackedStatCount.Length
		Int iArraysNotificationMessage = DMN_SXPAEH.sNotificationMessage.Length
		DMN_SXPALog(DMN_SXPADebug, "Stat Name Array Length: " + iArrayStatName + ".")
		DMN_SXPALog(DMN_SXPADebug, "XP Activity State Array Length: " + iArraybXPActivityState + ".")
		DMN_SXPALog(DMN_SXPADebug, "XP Modifier Array Length: " + iArrayfXPModifier + ".")
		DMN_SXPALog(DMN_SXPADebug, "Tracked Stat Count Array Length: " + iArrayiTrackedStatCount + ".")
		DMN_SXPALog(DMN_SXPADebug, "Notification Message Array Length: " + iArraysNotificationMessage + ".")
		If (iArraybXPActivityState < iArrayStatName || iArrayfXPModifier < iArrayStatName || iArrayiTrackedStatCount < iArrayStatName || iArraysNotificationMessage < iArrayStatName)
			DMN_SXPALog(DMN_SXPADebug, "ERROR: Array lengths DO NOT match!\n\n")
			MessageBox("Skyrim XP Addon \n\nERROR! The Array lengths DO NOT match, indicating some kind of major fault has occurred! Please report this on the SXPA page.")
		Else
			DMN_SXPALog(DMN_SXPADebug, "SUCCESS: Array lengths match.\n\n")
		EndIf
	EndIf

; Calls a function that checks for existing XP activities and rewards balanced XP taking into account when the player may have started up until their current level.
; This is required after the Event Handler quest is reset to uncover and reward the newly added XP activities.
	rewardExistingXPActivities(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName)

;-----------------------------------
; END NON-SPECIFIC VERSION UPDATES

	; // BEGIN VERSION SPECIFIC ANNOUNCEMENT MESSAGES
	;------------------------------------------------
	
	Int updateCount = 0
	; Change this to the latest update announcement message.
	Message latestUpdate = DMN_SXPAUpdateAnnouncement_v2_0_0

; v1.1.0
;-------
	If (DMN_SXPAiVersionInstalled.GetValue() as Int < ver3ToInteger("1", "1", "0") && \
		DMN_SXPAiVersionRunning >= 1100)
		Wait(3.0)
		DMN_SXPAUpdateAnnouncement_v1_1_0.Show()
		updateCount += 1
	EndIf
; v1.2.0
;-------
	If (DMN_SXPAiVersionInstalled.GetValue() as Int < ver3ToInteger("1", "2", "0") && \
		DMN_SXPAiVersionRunning >= 1200)
		Wait(3.0)
		DMN_SXPAUpdateAnnouncement_v1_2_0.Show()
		updateCount += 1
	EndIf
; v2.0.0
;-------
	If (DMN_SXPAiVersionInstalled.GetValue() as Int < ver3ToInteger("2", "0", "0") && \
		DMN_SXPAiVersionRunning >= 2000)
		Wait(3.0)
		Int iChoice = DMN_SXPAUpdateAnnouncement_v2_0_0.Show()
		If (iChoice == 0)
		; [Let's Begin A New Journey Together! (Balanced)]
			Notification("Skyrim XP Addon: Wiping player's SXPA data and restoring SXPA default values...")
			resetSXPAProgress(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAActiveMonitoring, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.iSkillXP, DMN_SXPAEH.iSkillXPSpent, DMN_SXPAEH.iSkillXPSpentEffective, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sSkillName, DMN_SXPAEH.sStatName)
			setSXPADefaults(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAActiveMonitoring, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fSkillModifier, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.iPassiveMonitoring)
		; Register for XP activity active tracking once more.
			DMN_SXPAPA.waitForStatChange()
			Notification("Skyrim XP Addon: SXPA player data has been wiped and SXPA default values restored!")
		ElseIf (iChoice == 1)
		; [I'd Prefer To Leave Things As Is (Not Recommended)]
			Notification("Skyrim XP Addon: Your SXPA user data and settings were left untouched.")
		EndIf
		updateCount += 1
	EndIf

	; // END VERSION SPECIFIC ANNOUNCEMENT MESSAGES
	;------------------------------------------------

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
; Add (or update) the mod configurator to the player inventory silently.
	giveConfigurator(DMN_SXPAConfigurator)
	debugNotification(DMN_SXPADebug, "Skyrim XP Addon DEBUG: Gave the player the latest Skyrim XP Addon Configurator!")
EndFunction

Function postMaintenance()
; Re-enable XP activity active tracking if active tracking was already enabled prior.
	If (bActiveMonitoringEnabled)
		bActiveMonitoringEnabled = None
		DMN_SXPALog(DMN_SXPADebug, "Re-enabling XP activity active tracking.")
		DMN_SXPAActiveMonitoring.SetValue(1)
		If (DMN_SXPAActiveMonitoring.GetValue() == 1)
			DMN_SXPALog(DMN_SXPADebug, "XP activity active tracking was enabled.\n\n")
		Else
			DMN_SXPALog(DMN_SXPADebug, "WARNING: XP activity active tracking was NOT enabled!\n\n")
		EndIf
	; Register for XP activity active tracking once more.
		DMN_SXPAPA.waitForStatChange()
	Else
	; Since XP activity active tracking is disabled, call a manual update.
	; Update all existing stats and assign random XP values for each of them.
		updatePlayerStats(DMN_SXPAEH.DMN_SXPADebug, DMN_SXPAEH.DMN_SXPAExperienceMin, DMN_SXPAEH.DMN_SXPAExperienceMax, DMN_SXPAEH.DMN_SXPAExperiencePoints, DMN_SXPAEH.bXPActivityState, DMN_SXPAEH.fXPModifier, DMN_SXPAEH.iTrackedStatCount, DMN_SXPAEH.sStatName, DMN_SXPAEH.sNotificationMessage, True)
	EndIf
EndFunction
