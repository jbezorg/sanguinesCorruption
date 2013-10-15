Scriptname _sc_ae_script extends _ae_mod_base  

; VERSION 1 =======================================================================================
SexLabFramework           property SexLab                         auto
Faction                   property CurrentHireling                auto
Faction                   property CurrentFollowerFaction         auto
Keyword                   property ActorTypeNPC                   auto
String[]                  property defeatEvents                   auto
Bool                      property bSexLabDefeatLoaded            auto  hidden
;DefeatConfig              property kSexLabDefeatResources         auto  hidden

Actor[]            sexActors
sslBaseAnimation[] animations


; START UTILITY FUNCTIONS =========================================================================



; END UTILITY FUNCTIONS ===========================================================================
;
;
;
; START AE CONTROLS ===============================================================================
; This will be called during the mod selection process to see if the actor in
; question qualifies for your event. If this function returns false then your
; mod will be skipped.
;
; If it is not defined in your mod then your mod events will not be triggered.
Bool function qualifyActor(Actor akActor = none, String asStat = "")
	bool bReturn = false
	
	if akActor && SexLab.ValidateActor(akActor)
		Actor kAttacker = ae.GetLastAttacker(akActor) as Actor

		if kAttacker && SexLab.ValidateActor(kAttacker) && asStat == ae.HEALTH
			bReturn = true
		endIf
	endIf

	Debug.TraceConditional("SC::qualifyActor:" + bReturn, ae.VERBOSE)
	return bReturn
endFunction

; This may be called during AE's cleanup process. Possibly due to a refid
; change. It will reregister the mod with AE.
function aeRegisterMod()
	myIndex = ae.register(self, 4, 0, myEvent, ae.HEALTH)
endFunction

; This function will be called when the user permanently disables the mod
; through the AE MCM menu.
function aeUninstallMod()
	Stop()
endFunction
; END AE CONTROLS =================================================================================
;
;
;
; START AE VERSIONING =============================================================================
; This functions exactly as and has the same purpose as the SkyUI function
; GetVersion(). It returns the static version of the AE script.
int function aeGetVersion()
	return 1
endFunction

function aeUpdate( int aiVersion )
	bSexLabDefeatLoaded    = Game.GetFormFromFile(0x00000d62, "SexLabDefeat.esp") != none
	;kSexLabDefeatResources = ( Game.GetFormFromFile(0x0004b8d1, "SexLabDefeat.esp") as Quest ) as DefeatConfig
endFunction
; END AE VERSIONING ===============================================================================
;
;
;
; START SC FUNCTIONS ==============================================================================
int function AddCompanions()
	myActorsList[0] = Game.GetPlayer()

	Actor thisActor = none
	Int   thisCount = 0
	Cell  thisCell  = myActorsList[0].GetParentCell()
	Int   idxNPC    = thisCell.GetNumRefs(43)
	
	Debug.Notification("$SC_COMPANIONS_CHECK")
	
	while idxNPC > 0 && thisCount < 19
		idxNPC -= 1
		thisActor = thisCell.GetNthRef(idxNPC,43) as Actor

		if thisActor && \
		   !thisActor.IsDead() && \
		   !thisActor.IsDisabled() && \
		   myActorsList.Find(thisActor) < 0 && \
		   thisActor.HasKeyword(ActorTypeNPC) && \
		   ( thisActor.GetFactionRank(CurrentHireling) >= 0 || thisActor.GetFactionRank(CurrentFollowerFaction) >= 0 || thisActor.IsPlayerTeammate() )
		
			thisCount += 1
			myActorsList[thisCount] = thisActor as Actor
			Debug.TraceConditional("SC::AddCompanions: " + thisActor.GetLeveledActorBase().GetName() + "@"+thisCount, ae.VERBOSE)
		else
			Debug.TraceConditional("SC::AddCompanions: " + thisActor.GetLeveledActorBase().GetName() + ":false", ae.VERBOSE)
		endif
	endWhile
	
	aeRegisterActors()
	
	return thisCount
endFunction

function RemoveCompanions()
	Int idxNPC = myActorsList.length
	while idxNPC > 1
		idxNPC -= 1
		ae.monitor(myActorsList[idxNPC], false)
		myActorsList[idxNPC] = none
	endWhile
endFunction
; END SC FUNCTIONS ================================================================================
;
;
;
; START SC EVENTS =================================================================================
event OnInit()
	aeRegisterMod()
endEvent

; On a AE Health Event
event OnSCEvent(String asEventName, string asStat, float afStatValue, Form akSender)
	Debug.TraceConditional("SC::OnSCEvent: " + asEventName, ae.VERBOSE)

	Actor kSender = akSender as Actor
	Int   idx     = 0

	if asEventName == myEvent + ae._START && asStat == ae.HEALTH
		Actor kAttacker = ae.GetLastAttacker(kSender) as Actor
		
		if !bSexLabDefeatLoaded
			kSender.StopCombat()
			kSender.StopCombatAlarm()
			kSender.SetGhost()
			kAttacker.StopCombat()
			kAttacker.StopCombatAlarm()
			kAttacker.SetGhost()
			
			sexActors    = new actor[2]
			sexActors[0] = kSender
			sexActors[1] = kAttacker

			RegisterForModEvent("AnimationStart_sanguines", "scAnimaStart")
			RegisterForModEvent("AnimationEnd_sanguines",   "scAnimaEnd")

			animations = SexLab.PickAnimationsByActors(sexActors, aggressive = true)
			
			if SexLab.StartSex(sexActors, animations, Victim=kSender, hook="sanguines") < 0
				sexActors[0].SetGhost(False)
				sexActors[1].SetGhost(False)
			endIf
		elseIf false ;kSender.HasSpell( kSexLabDefeatResources.DebuffConsSPL ) || kSender.HasSpell( kSexLabDefeatResources.TrueCalmSPL )
			idx = defeatEvents.length
			while idx > 0
				idx -= 1
				RegisterForModEvent(defeatEvents[idx], "defeatAnimaEnd")
				idx -= 1
				RegisterForModEvent(defeatEvents[idx], "defeatAnimaStart")
			endWhile
		endIf
	endIf
endEvent

; Sexlab SC Events
event scAnimaStart(string eventName, string argString, float argNum, form sender)
	actor[] actorList = SexLab.HookActors(argString)
	
	actorList[0].RestoreActorValue(ae.HEALTH, 10000)
	UnregisterForModEvent(eventName)

	Debug.TraceConditional("SC::" + eventName + ": " + actorList, ae.VERBOSE)
endEvent

event scAnimaEnd(string eventName, string argString, float argNum, form sender)
	actor[] actorList = SexLab.HookActors(argString)
	
	actorList[0].SetGhost(False)
	actorList[1].SetGhost(False)

	; do the enslavement stuff

	UnregisterForModEvent("AnimationEnd_sanguines")
	UnregisterForModEvent("StageEnd_sanguines")
	Debug.TraceConditional("SC::" + eventName + ": " + actorList, ae.VERBOSE)
endEvent

; Sexlab Defeat Events
event defeatAnimaStart(string eventName, string argString, float argNum, form sender)
	actor[] actorList = SexLab.HookActors(argString)
	actor kVictim = SexLab.HookVictim(argString)
	
	if kVictim && myActorsList.Find(kVictim) >= 0
		kVictim.RestoreActorValue(ae.HEALTH, 10000)
		UnregisterForModEvent(eventName)
		Debug.TraceConditional("SC::" + eventName + ": " + actorList, ae.VERBOSE)
	endIf
endEvent

event defeatAnimaEnd(string eventName, string argString, float argNum, form sender)
	actor[] actorList = SexLab.HookActors(argString)
	actor kVictim = SexLab.HookVictim(argString)
	
	if kVictim && myActorsList.Find(kVictim) >= 0
		; do the enslavement stuff


		Int idx = defeatEvents.length
		while idx > 0
			idx -= 1
			UnregisterForModEvent(defeatEvents[idx])
		endWhile
		Debug.TraceConditional("SC::" + eventName + ": " + actorList, ae.VERBOSE)
	endIf
endEvent
; END SC EVENTS ===================================================================================
