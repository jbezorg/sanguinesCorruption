Scriptname _sc_companion_alias extends ReferenceAlias  

_sc_slave_script slave
Actor            kCompanion
ObjectReference  kMarker
ObjectReference  kContainer
Int              iIndex

Event OnInit()
	slave      = self.GetOwningQuest() as _sc_slave_script
	kCompanion = self.GetReference() as Actor
	iIndex     = slave.companions.Find(self)
	
	if kCompanion
		kMarker    = slave.companionMarkers[iIndex].GetReference()
		kContainer = slave.companionContainers[iIndex].GetReference()
		
		if kContainer == none
			kContainer = slave.playerContainer.GetReference()
		endIf

		kCompanion.MoveTo( kMarker )
		kCompanion.RemoveAllItems( kContainer, true )
		kCompanion.SetOutfit( slave.re.nudeOutfit )
		kCompanion.EvaluatePackage()
		kCompanion.MoveToPackageLocation()
	endIf
EndEvent
