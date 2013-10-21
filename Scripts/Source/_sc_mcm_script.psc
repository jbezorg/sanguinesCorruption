Scriptname _sc_mcm_script extends SKI_ConfigBase  Conditional


_sc_ae_script       property me                    auto
Bool                property bRegisterCompanions   auto  hidden

int function GetVersion()
	return 1000
endFunction

string function GetStringVer()
	return StringUtil.Substring((GetVersion() as float / 1000.0) as string, 0, 4)
endFunction

event OnConfigInit()
	Pages = New String[2]
	Pages[0] = "$SC_PAGE_0"
	Pages[1] = "$SC_PAGE_1"
endEvent

event OnVersionUpdate(int a_version)
	if (a_version >= 1001 && CurrentVersion < 1001)

	endIf
endEvent

event OnPageReset(string a_page)
	if (a_page == "" || !Self.IsRunning() )
		LoadCustomContent("jbezorg/sanguinesCorruption.dds", 135, 53)
		return
	else
		UnloadCustomContent()
	endIf
	
; UTILITY VARS ====================================================================================
	int    iCount
	int    iIndex
	string thisName


	int iOptionFlag = OPTION_FLAG_NONE

; STATUS ==========================================================================================
	if ( a_page == Pages[0] )
		AddHeaderOption("$SC_ESSENTIAL_TITLE")
		AddToggleOptionST("STATE_ESSENTIAL", me.myActorsList[0].GetActorBase().GetName(), me.myActorsList[0].IsEssential(), iOptionFlag)

	
; COMPANIONS ======================================================================================
	elseIf ( a_page == Pages[1] )
		AddHeaderOption("$SC_COMPANIONS_TITLE")
		if !bRegisterCompanions
			AddToggleOptionST("STATE_COMPANIONS", "$SC_REGISTER", bRegisterCompanions, iOptionFlag)
		else
			AddToggleOptionST("STATE_COMPANIONS", "$SC_UNREGISTER", bRegisterCompanions, iOptionFlag)
		endIf

		iCount = 0
		iIndex = me.myActorsList.length
		while iIndex > 1
			iIndex -= 1
			if me.myActorsList[iIndex] != none
				thisName = me.myActorsList[iIndex].GetLeveledActorBase().GetName()
				AddTextOption(thisName, "", iOptionFlag)
				iCount += 1
			endIf
		endWhile

		if iCount == 0
			AddTextOption("$SC_NONE", "", OPTION_FLAG_NONE)
		endIf		
	endIf
endEvent

; ESSENTIAL =======================================================================================
state STATE_ESSENTIAL ; TOGGLE
	event OnSelectST()
		ActorBase kBase     = me.myActorsList[0].GetActorBase()
		Bool kBaseEssential = !kBase.IsEssential()

		kBase.SetEssential( kBaseEssential )
		SetToggleOptionValueST( kBaseEssential )
	endEvent

	event OnDefaultST()
		ActorBase kBase = me.myActorsList[0].GetActorBase()
		kBase.SetEssential( false )
		SetToggleOptionValueST( false )
	endEvent

	event OnHighlightST()
		SetInfoText("$SC_ESSENTIAL_INFO")
	endEvent
endState

; COMPANIONS ======================================================================================
state STATE_COMPANIONS ; TOGGLE
	event OnSelectST()
		bRegisterCompanions = !bRegisterCompanions
		
		if bRegisterCompanions
			me.AddCompanions()
		else
			me.RemoveCompanions()
		endIf
		
		SetToggleOptionValueST( bRegisterCompanions )
		ForcePageReset()
	endEvent

	event OnDefaultST()
		bRegisterCompanions = false
		SetToggleOptionValueST( bRegisterCompanions )

		me.RemoveCompanions()
		ForcePageReset()
	endEvent

	event OnHighlightST()
		SetInfoText("$SC_COMPANIONS_INFO")
	endEvent
endState

