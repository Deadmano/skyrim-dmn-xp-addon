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

ScriptName DMN_SXPAConfiguratorMenuSpell Extends ActiveMagicEffect

{Mod configuration script for the Lesser Power version of the configurator.}

Import Debug
Import Game

DMN_SXPAConfiguratorMenu Property DMN_SXPACM Auto

Spell Property DMN_SXPAConfigurator Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Actor kPlayer = GetPlayer()
	If (akCaster == kPlayer)
	; Fire up the configuration function.
		DMN_SXPACM.configureMod()
	EndIf
EndEvent
