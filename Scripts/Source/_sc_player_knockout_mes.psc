Scriptname _sc_player_knockout_mes extends activemagiceffect  

event OnEffectStart(Actor akTarget, Actor akCaster)
	re.strikeISM.Apply()
	Game.ForceFirstPerson()
	Game.DisablePlayerControls(true,true,true,true,true,true)
	akTarget.PlayIdle(re.knockoutPlayer)
	Utility.Wait(10.0)
	Game.FadeOutGame(true, true, 0.0, 4.0)
	Utility.Wait(4.0)
	re.GameHour.Mod( Utility.RandomFloat(20.0, 28.0) )
	re.slaveryTrigger.SendStoryEvent( aiValue1 = 1, aiValue2 = ae.countCompanions() )
endEvent

event OnEffectFinish(Actor akTarget, Actor akCaster)

endEvent

_sc_mcm_script   property mcm              auto
_sc_ae_script    property ae               auto
_sc_resources    property re               auto
