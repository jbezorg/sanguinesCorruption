;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 6
Scriptname _sc_rescue_qf Extends Quest Hidden

;BEGIN ALIAS PROPERTY Companion009
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion009 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion011
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion011 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion010
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion010 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion016
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion016 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion006
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion006 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion004
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion004 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion015
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion015 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion018
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion018 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion013
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion013 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion007
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion007 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion014
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion014 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion017
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion017 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion003
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion003 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion000
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion000 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion001
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion001 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion012
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion012 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion008
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion008 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion002
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion002 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Companion005
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Companion005 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
int idx = 0

idx = self.GetNumAliases()
while idx > 0
	idx -= 1
	ReferenceAlias nthAlias = self.GetNthAlias(idx) as ReferenceAlias
	if nthAlias
		companions = slavery.PushActor(nthAlias.GetActorReference(), companions)

		if !self.IsObjectiveDisplayed(idx)
			self.SetObjectiveDisplayed(idx, true, true)
		endIf
	endIf
endWhile

prisoners = companions.length

idx = ae.myActorsList.length
while idx > 1
	idx -= 1
	if companions.Find( ae.myActorsList[idx] ) < 0 && ae.myActorsList[idx].GetAV("WaitingForPlayer") != 0
		ae.myActorsList[idx].SetAV("WaitingForPlayer", 0)
	endIf
endWhile
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
int idx = 0

idx = self.GetNumAliases()
while idx > 0
	idx -= 1
	ReferenceAlias nthAlias = self.GetNthAlias(idx) as ReferenceAlias
	if nthAlias && self.IsObjectiveDisplayed(idx)
		self.SetObjectiveDisplayed(idx, false)
	endIf
endWhile
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

_sc_mcm_script   property mcm               auto
_sc_ae_script    property ae                auto
_sc_resources    property re                auto
_sc_slave_script property slave             auto

actor[]          property companions = none auto hidden
int              property completed = 0     auto hidden Conditional 
int              property prisoners = 0     auto hidden Conditional 
