Scriptname _sc_rescue_alias extends ReferenceAlias  

event OnDeath(Actor akKiller)
	Actor kCompanion = self.GetActorReference()
	_sc_rescue_qf qf = self.GetOwningQuest() as _sc_rescue_qf

	GetOwningQuest().SetObjectiveFailed(qf.companions.Find(kCompanion))
	
	qf.completed += 1
	
	if qf.completed >= qf.prisoners
		GetOwningQuest().SetStage(10)
	endIf
endEvent
