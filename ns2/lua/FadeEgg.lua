// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Egg.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Thing that aliens spawn out of.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/LifeFormEgg.lua")

class 'FadeEgg' (LifeFormEgg)

FadeEgg.kMapName = "fadeegg"
FadeEgg.kTechIdToEvolve = kTechId.Fade

function FadeEgg:GetTechIdToEvolve()
	return FadeEgg.kTechIdToEvolve
end

Shared.LinkClassToMap("FadeEgg", FadeEgg.kMapName, {})
