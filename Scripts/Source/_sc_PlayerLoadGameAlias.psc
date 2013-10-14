Scriptname _sc_PlayerLoadGameAlias extends ReferenceAlias  

event OnPlayerLoadGame()
	Quest me = self.GetOwningQuest()

endEvent

event OnCellLoad()
	Quest me = self.GetOwningQuest()

	if ( me as _sc_mcm_script ).bRegisterCompanions
		( me as _sc_ae_script ).AddCompanions()
	endIf
endEvent
