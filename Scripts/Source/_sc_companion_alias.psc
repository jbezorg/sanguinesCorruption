Scriptname _sc_companion_alias extends ReferenceAlias  

_sc_slave_script slave
Actor            kCompanion
Actor            kMaster
ObjectReference  kMarker
ObjectReference  kContainer
Int              iIndex

Event OnInit()
	slave      = self.GetOwningQuest() as _sc_slave_script
	kCompanion = self.GetActorReference()
	iIndex     = slave.companions.Find(self)
	
	if kCompanion
		kMarker    = slave.companionMarkers[iIndex].GetReference()
		kMaster    = slave.companionMasters[iIndex].GetActorReference()
		kContainer = slave.companionContainers[iIndex].GetReference()
		
		if kContainer == none
			kContainer = slave.playerContainer.GetReference()
		endIf

		kCompanion.MoveTo( kMarker )
		kCompanion.SetOutfit( slave.re.nudeOutfit )
		kCompanion.RemoveAllItems( kContainer, true )

		slave.equipBindings(kCompanion)

		kCompanion.EvaluatePackage()
		kCompanion.MoveToPackageLocation()
		kCompanion.SetAV("WaitingForPlayer", 1)
		
		slave.slavery.Make(kCompanion, kMaster)
	endIf
EndEvent
