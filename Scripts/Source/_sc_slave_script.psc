Scriptname _sc_slave_script extends questVersioning  

LocationAlias[]  Property companionLocations  Auto
ReferenceAlias[] Property companions          Auto
ReferenceAlias[] Property companionMarkers    Auto
ReferenceAlias[] Property companionContainers Auto

LocationAlias    Property playerSlaveLocation Auto
ReferenceAlias   Property playerSlave         Auto
ReferenceAlias   Property playerSlaveCage     Auto
ReferenceAlias   Property playerContainer     Auto

Keyword[]        Property LocationType        Auto

_sc_mcm_script   Property mcm                 auto
_sc_ae_script    Property ae                  auto
_sc_resources    Property re                  auto

Actor           kPlayer
ObjectReference kContainer

int Function qvGetVersion()
	return 1
endFunction

function qvUpdate( int aiCurrentVersion )
	if (qvCurrentVersion >= 2 && aiCurrentVersion < 2)
	endIf
endFunction

event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
	Debug.TraceConditional("SC::OnStoryScript: aiValue1=" + aiValue1 + ", aiValue2=" + aiValue2, ae.ae.VERBOSE)

	kPlayer    = playerSlave.GetReference() as Actor
	kContainer = playerContainer.GetReference() as ObjectReference

	kPlayer.MoveTo( playerSlaveCage.GetReference() )
	kPlayer.RemoveAllItems( kContainer, true )
	if !kPlayer.IsEquipped(re.zbfGagRing)
		kPlayer.AddItem(re.zbfGagRing, 1, true)
		kPlayer.EquipItem(re.zbfGagRing, true, true)
	endIf
	if !kPlayer.IsEquipped(re.zbfBindings)
		kPlayer.AddItem(re.zbfBindings, 1, true)
		kPlayer.EquipItem(re.zbfBindings, true, true)
	endIf
	Game.FadeOutGame(false, true, 2.0, 2.0)

	kPlayer.PlayIdle( re.getUpPlayer )
	Utility.Wait(6.0)
	Game.EnablePlayerControls()
endEvent
