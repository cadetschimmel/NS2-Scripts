// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\ExtendedRifle.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Marine/Rifle.lua")

class 'ExtendedRifle' (Rifle)

ExtendedRifle.kMapName = "extendedrifle"

ExtendedRifle.kModelName = PrecacheAsset("models/marine/rifle/rifle.model")
ExtendedRifle.kViewModelName = PrecacheAsset("models/marine/rifle/rifle_view.model")

ExtendedRifle.kClipSize = kExtendedRifleClipSize

function ExtendedRifle:GetClipSize()
    return ExtendedRifle.kClipSize
end

function ExtendedRifle:GetPrimaryAttackPrefix()
	return "rifle"
end

function ExtendedRifle:GetSecondaryAttackPrefix()
	return "rifle"
end

Shared.LinkClassToMap("ExtendedRifle", ExtendedRifle.kMapName, {} )