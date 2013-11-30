Scriptname _sc_slave_script extends questVersioning  

LocationAlias[]   Property companionLocations  Auto
ReferenceAlias[]  Property companions          Auto
ReferenceAlias[]  Property companionMarkers    Auto
ReferenceAlias[]  Property companionContainers Auto
ReferenceAlias[]  Property companionMasters    Auto

LocationAlias     Property fortunateLocation   Auto
LocationAlias     Property playerSlaveLocation Auto
ReferenceAlias    Property playerSlave         Auto
ReferenceAlias    Property playerSlaveCage     Auto
ReferenceAlias    Property playerContainer     Auto
ReferenceAlias    Property playerMaster        Auto

Keyword[]         Property LocationType        Auto

_sc_mcm_script    Property mcm                 auto
_sc_ae_script     Property ae                  auto
_sc_resources     Property re                  auto
_sf_slavery       Property slavery             auto


Actor           kPlayer
Actor           kMaster
ObjectReference kContainer
Location        kLocation

int Function qvGetVersion()
	return 1
endFunction

function qvUpdate( int aiCurrentVersion )
	if (qvCurrentVersion >= 2 && aiCurrentVersion < 2)
	endIf
endFunction

function equipBindings(Actor akActor)
	if !akActor.IsEquipped(re.zbfGagRing)
		akActor.AddItem(re.zbfGagRing, 1, true)
		akActor.EquipItem(re.zbfGagRing, true, true)
	endIf
	if !akActor.IsEquipped(re.zbfBindings)
		akActor.AddItem(re.zbfBindings, 1, true)
		akActor.EquipItem(re.zbfBindings, true, true)
	endIf
endFunction

function unequipBindings(Actor akActor)
	int cnt = 0
	cnt = akActor.GetItemCount(re.zbfGagRing)
	if cnt
		if akActor.IsEquipped(re.zbfGagRing)
			akActor.unequipItem(re.zbfGagRing, false, true)
		endIf
		akActor.DropObject(re.zbfGagRing, cnt)
	endIf
	
	cnt = akActor.GetItemCount(re.zbfBindings)
	if cnt
		if akActor.IsEquipped(re.zbfBindings)
			akActor.unequipItem(re.zbfBindings, false, true)
		endIf
		akActor.DropObject(re.zbfBindings, cnt)
	endIf
endFunction

event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
	Debug.TraceConditional("SC::OnStoryScript: aiValue1=" + aiValue1 + ", aiValue2=" + aiValue2, ae.ae.VERBOSE)
	while !self.IsRunning()
		Utility.Wait(1.0)
	endWhile

	if Game.GetCameraState() != 0
		Game.ForceFirstPerson()
	endIf

	kPlayer    = playerSlave.GetActorReference()
	kMaster    = playerMaster.GetActorReference()
	kContainer = playerContainer.GetReference() as ObjectReference
	kLocation  = playerSlaveLocation.GetLocation()
	
	int status = slavery.Make(kPlayer, kMaster)

	Debug.TraceConditional("SC::OnStoryScript:Status::" + status, ae.ae.VERBOSE)
	if status > 0
		kPlayer.MoveTo( playerSlaveCage.GetReference() )
		kPlayer.RemoveAllItems( kContainer, true )
		equipBindings(kPlayer)
		re.GameHour.Mod( Utility.RandomFloat(20.0, 28.0) )
		kPlayer.PlayIdle( re.getUpPlayer )
		Utility.Wait(6.0)
		Game.EnablePlayerControls()
		
		
		int idx = LocationType.length
		while idx > 0
			idx -= 1
			if kLocation.HasKeyword(LocationType[idx])
				re.questTrigger.SendStoryEvent(kLocation, kMaster as ObjectReference, kPlayer as ObjectReference, idx )
				idx = 0
			endIf
		endWhile
	else
		;some place else
	endIf

	ae.SexLab.AllowActor(kPlayer)	
endEvent
