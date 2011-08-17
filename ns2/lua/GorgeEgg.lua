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

class 'GorgeEgg' (LifeFormEgg)

GorgeEgg.kMapName = "gorgeegg"
GorgeEgg.kTechIdToEvolve = kTechId.Gorge

function GorgeEgg:GetTechIdToEvolve()
	return GorgeEgg.kTechIdToEvolve
end

Shared.LinkClassToMap("GorgeEgg", GorgeEgg.kMapName, {})