;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname _sc_rescue_tif_01 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
slavery.remove(akSpeaker)
slave.unequipBindings(akSpeaker)
akSpeaker.SetAV("WaitingForPlayer", 0)

GetOwningQuest().SetObjectiveCompleted(qf.companions.Find(akSpeaker))
qf.completed += 1

if qf.completed >= qf.prisoners
	GetOwningQuest().SetStage(10)
endIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

_sc_slave_script property slave   auto
_sc_rescue_qf    property qf      auto
_sf_slavery      property slavery auto
