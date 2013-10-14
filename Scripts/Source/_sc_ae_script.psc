Scriptname _sc_ae_script extends _ae_mod_base  

; VERSION 1 =======================================================================================
SexLabFramework           property SexLab                         auto
Faction                   property CurrentHireling                auto
Faction                   property CurrentFollowerFaction         auto
Keyword                   property ActorTypeNPC                   auto
Bool                      property bSexLabDefeatLoaded            auto  hidden

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
	bSexLabDefeatLoaded = Game.GetFormFromFile(0x00000d62, "SexLabDefeat.esp") != none
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

	if asEventName == myEvent + ae._START && asStat == ae.HEALTH
		Actor kAttacker = ae.GetLastAttacker(kSender) as Actor

		kSender.StopCombatAlarm()
		kAttacker.StopCombat()
		kAttacker.StopCombatAlarm()
		
		sexActors    = new actor[2]
		sexActors[0] = kSender
		sexActors[1] = kAttacker

		RegisterForModEvent("AnimationStart_sanguines", "animaStart")
		RegisterForModEvent("AnimationEnd_sanguines",   "animaEnd")
		RegisterForModEvent("StageEnd_sanguines",       "stageEnd")

		animations = SexLab.PickAnimationsByActors(sexActors, aggressive = true)
		SexLab.StartSex(sexActors, animations, Victim=kSender, hook="sanguines")
		
		Debug.TraceConditional("SC::OnSCEvent:TEST: " + kAttacker, ae.VERBOSE)
	endIf
endEvent

; Sexlab Events
event estrusChaurusStart(string eventName, string argString, float argNum, form sender)
	sslThreadController control = SexLab.HookController(argString)
	sslBaseAnimation anim       = SexLab.HookAnimation(argString)
	actor[] actorList           = SexLab.HookActors(argString)
	
	actorList[0].RestoreActorValue(ae.HEALTH, 10000)

	UnregisterForModEvent("AnimationStart_sanguines")
endEvent

event estrusChaurusEnd(string eventName, string argString, float argNum, form sender)
	actor[] actorList = SexLab.HookActors(argString)

	UnregisterForModEvent("AnimationEnd_sanguines")
	UnregisterForModEvent("StageEnd_sanguines")
endEvent

event estrusChaurusStage(string eventName, string argString, float argNum, form sender)
	sslBaseAnimation anim = SexLab.HookAnimation(argString)
	actor[] actorList     = SexLab.HookActors(argString)
	int stage             = SexLab.HookStage(argString)

endEvent
