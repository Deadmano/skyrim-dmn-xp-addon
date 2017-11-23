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

ScriptName DMN_SXPAConfiguratorMenuBook Extends ObjectReference

{Mod configuration script for the Book version of the configurator.}

Import Debug
Import Game

DMN_SXPAConfiguratorMenu Property DMN_SXPACM Auto

Event OnRead()
; Disable all other menus temporarily leaving only the message box to show.
	DisablePlayerControls(False, False, False, False, False, True)
; Undo the above change.
	EnablePlayerControls(False, False, False, False, False, True)
; Fire up the configuration function.
	DMN_SXPACM.configureMod()
EndEvent
