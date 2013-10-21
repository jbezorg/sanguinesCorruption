Scriptname _sc_utility extends Quest  

function _alterTintMask(actor akActor, int type = 6, int alpha = 0, int red = 125, int green = 90, int blue = 70) Global
	; Sets the tintMask color for the particular type and index
	; a,r,g,b: 0-255 range
	int color = Math.LeftShift(alpha, 24) + Math.LeftShift(red, 16) + Math.LeftShift(green, 8) + blue

	; Types
	; 0 - Frekles
	; 1 - Lips
	; 2 - Cheeks
	; 3 - Eyeliner
	; 4 - Upper Eyesocket
	; 5 - Lower Eyesocket
	; 6 - SkinTone
	; 7 - Warpaint
	; 8 - Frownlines
	; 9 - Lower Cheeks
	; 10 - Nose
	; 11 - Chin
	; 12 - Neck
	; 13 - Forehead
	; 14 - Dirt
 	int index_count = Game.GetNumTintsByType(type)

 	int index = 0
 	while(index < index_count)
 		Game.SetTintMaskColor(color, type, index)
 		index = index + 1
 	EndWhile

 	Game.UpdateTintMaskColors()

 	If SKSE.GetPluginVersion("NiOverride") >= 1
 	 	NiOverride.ApplyOverrides(akActor)
 	 	NiOverride.ApplyNodeOverrides(akActor)
 	Endif
EndFunction
