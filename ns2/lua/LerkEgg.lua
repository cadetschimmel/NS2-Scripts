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

class 'LerkEgg' (LifeFormEgg)

LerkEgg.kMapName = "lerkegg"
LerkEgg.kTechIdToEvolve = kTechId.Lerk

function LerkEgg:GetTechIdToEvolve()
	return LerkEgg.kTechIdToEvolve
end

Shared.LinkClassToMap("LerkEgg", LerkEgg.kMapName, {})