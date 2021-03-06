Scriptname _sc_ae_script extends _ae_mod_base  

; VERSION 1 =======================================================================================
SexLabFramework           property SexLab                         auto
Faction                   property CurrentHireling                auto
Faction                   property CurrentFollowerFaction         auto
Keyword                   property ActorTypeNPC                   auto
String[]                  property defeatEvents                   auto
Bool                      property bSexLabDefeatLoaded = false    auto  hidden
Faction                   property kSexLabDefeatFaction           auto  hidden

; VERSION 4
Spell                     property _sc_knockout                   auto

; =================================================================================================
; START UTILITY FUNCTIONS =========================================================================
; =================================================================================================



; END UTILITY FUNCTIONS ===========================================================================
;
;
; =================================================================================================
; START AE CONTROLS ===============================================================================
; =================================================================================================
; This will be called during the mod selection process to see if the actor in
; question qualifies for your event. If this function returns false then your
; mod will be skipped.
;
; If it is not defined in your mod then your mod events will not be triggered.
Bool function qualifyActor(Actor akActor = none, String asStat = "")
	bool bReturn = false
	
	if akActor && SexLab.ValidateActor(akActor) > 0
		Actor kAttacker = ae.GetLastAttacker(akActor) as Actor

		if kAttacker && SexLab.ValidateActor(kAttacker) > 0 && asStat == ae.HEALTH
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
; =================================================================================================
; START AE VERSIONING =============================================================================
; =================================================================================================
; This functions exactly as and has the same purpose as the SkyUI function
; GetVersion(). It returns the static version of the AE script.
int function aeGetVersion()
	return 8
endFunction

function aeUpdate( int aiVersion )
	bSexLabDefeatLoaded  = false
	kSexLabDefeatFaction = none
	int idx = Game.GetModCount()
	while idx > 0
		idx -= 1
		if Game.GetModName(idx) == "SexLabDefeat.esp"
			bSexLabDefeatLoaded = true
			kSexLabDefeatFaction = Game.GetFormFromFile(0x00001d92, "SexLabDefeat.esp") as Faction
			idx = 0
		endIf
	endWhile

	bSexLabDefeatLoaded = false
	
	if bSexLabDefeatLoaded
		idx = defeatEvents.length
		while idx > 0
			idx -= 1
			RegisterForModEvent(defeatEvents[idx], "defeatAnimaEnd")
		endWhile
		
		if myIndex >= 0
			myIndex = -1
			ae.unRegister(self)
		endIf
	elseIf myIndex < 0
		aeRegisterMod()
	endIf
	
	if (myVersion >= 4 && aiVersion < 4)
		_sc_knockout = Game.GetFormFromFile(0x00005e29, "sanguinesCorruption.esp") as Spell
	endIf
endFunction
; END AE VERSIONING ===============================================================================
;
;
; =================================================================================================
; START SC FUNCTIONS ==============================================================================
; =================================================================================================
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

int function countCompanions()
	int cnt = 0
	int idx = myActorsList.length
	while idx > 1
		idx -= 1
		if myActorsList[idx]
			cnt += 1
		endIf
	endWhile
	return cnt
endFunction

function startEnslavement(actor[] akActors, actor akSlave)
	int idx = akActors.length
	while idx > 0
		idx -= 1
		if akActors[idx].IsGhost()
			akActors[idx].SetGhost(False)
		endIf
	endWhile

	_sc_knockout.RemoteCast(akSlave, akSlave, akSlave)

	Debug.TraceConditional("SC::startEnslavement: akActors=" + akActors + ", akSlave=" + akSlave, ae.VERBOSE)
endFunction
; END SC FUNCTIONS ================================================================================
;
;
; =================================================================================================
; START SC EVENTS =================================================================================
; =================================================================================================
event OnInit()
	aeRegisterMod()
	aeRegisterEvents()
endEvent

; On a AE Health Event
event OnSCEvent(String asEventName, string asStat, float afStatValue, Form akSender)
	Debug.TraceConditional("SC::OnSCEvent: " + asEventName, ae.VERBOSE)

	Actor kSender = akSender as Actor

	if asEventName == myEvent + ae._START && asStat == ae.HEALTH
		String sHook    = "sanguines" + kSender.GetFormID() as string
		Actor kAttacker = ae.GetLastAttacker(kSender) as Actor
		
		if !bSexLabDefeatLoaded
			kSender.StopCombat()
			kSender.StopCombatAlarm()
			kSender.SetGhost()
			kAttacker.StopCombat()
			kAttacker.StopCombatAlarm()
			kAttacker.SetGhost()
				
			Actor[] captureActors = new actor[2]
			captureActors[0] = kSender
			captureActors[1] = kAttacker

			if kSender.GetDistance(kAttacker) < 256.0
				RegisterForModEvent("AnimationEnd_" + sHook,   "scAnimaEnd")

				sslBaseAnimation[] animations = SexLab.PickAnimationsByActors(captureActors, aggressive = true)
				
				if SexLab.StartSex(captureActors, animations, Victim=kSender, hook=sHook) < 0
					UnregisterForModEvent("AnimationEnd_" + sHook)
					startEnslavement(captureActors, kSender )
				endIf
			else
				startEnslavement(captureActors, kSender )
			endIf
		endIf
	endIf
endEvent

; Sexlab SC Events
event scAnimaEnd(string eventName, string argString, float argNum, form sender)
	actor[] actorList = SexLab.HookActors(argString)
	actor kSlave      = SexLab.HookVictim(argString)

	startEnslavement(actorList, kSlave)

	UnregisterForModEvent(eventName)
	Debug.TraceConditional("SC::" + eventName + ": " + actorList, ae.VERBOSE)
endEvent

; Sexlab Defeat Events
event defeatAnimaEnd(string eventName, string argString, float argNum, form sender)
	actor[] actorList = SexLab.HookActors(argString)
	actor kSlave      = SexLab.HookVictim(argString)
	
	if kSlave == Game.GetPlayer()
		startEnslavement(actorList, kSlave)

		;Int idx = defeatEvents.length
		;while idx > 0
		;	idx -= 1
		;	UnregisterForModEvent(defeatEvents[idx])
		;endWhile
		Debug.TraceConditional("SC::" + eventName + ": " + actorList, ae.VERBOSE)
	endIf
endEvent
; END SC EVENTS ===================================================================================
