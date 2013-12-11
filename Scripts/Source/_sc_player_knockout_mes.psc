Scriptname _sc_player_knockout_mes extends activemagiceffect

event OnEffectStart(Actor akTarget, Actor akCaster)
	;ae.SexLab.ForbidActor(akTarget)

	re.strikeISM.Apply()
	Game.ForceFirstPerson()
	Game.DisablePlayerControls(true,true,true,true,true,true)
	akTarget.PlayIdle(re.knockoutPlayer)
	Utility.Wait(10.0)
	;re.blackoutISM.ApplyCrossFade(1.0)

	int sum = ae.countCompanions()
	int idx = ae.myActorsList.length
	int cnt = 0

	while idx > 1 && cnt < sum
		idx -= 1
		if ae.myActorsList[idx] != none
			if ae.SexLab.ValidateActor(ae.myActorsList[idx]) > 0
				slave.companions[cnt].ForceRefTo(ae.myActorsList[idx])
				cnt += 1
			else
				ae.myActorsList[idx].MoveToMyEditorLocation()
				ae.myActorsList[idx].SetAV("WaitingForPlayer", 1)
			endIf
		endIf
	endWhile

	Debug.Trace("slaveryTrigger.SendStoryEvent")
	re.slaveryTrigger.SendStoryEvent( aiValue1 = 1, aiValue2 = cnt )
endEvent

event OnEffectFinish(Actor akTarget, Actor akCaster)
	;ae.SexLab.AllowActor(akTarget)
endEvent

_sc_mcm_script   property mcm              auto
_sc_ae_script    property ae               auto
_sc_resources    property re               auto
_sc_slave_script property slave            auto
