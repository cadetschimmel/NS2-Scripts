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

class 'OnosEgg' (LifeFormEgg)

OnosEgg.kMapName = "onosegg"
OnosEgg.kTechIdToEvolve = kTechId.Onos

function OnosEgg:GetTechIdToEvolve()
	return OnosEgg.kTechIdToEvolve
end

Shared.LinkClassToMap("OnosEgg", OnosEgg.kMapName, {})
