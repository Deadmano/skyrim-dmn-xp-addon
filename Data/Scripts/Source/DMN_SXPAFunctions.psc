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
