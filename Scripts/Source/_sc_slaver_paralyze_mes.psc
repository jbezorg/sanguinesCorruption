Scriptname _sc_slaver_paralyze_mes extends ActiveMagicEffect  

event OnEffectStart(Actor akTarget, Actor akCaster)
	akTarget.AllowPCDialogue(false)
endEvent

event OnEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.AllowPCDialogue(true)
endEvent

