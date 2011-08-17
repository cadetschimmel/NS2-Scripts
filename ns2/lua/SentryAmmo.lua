// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Sentry.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Structure.lua")
Script.Load("lua/DropPack.lua")

class 'SentryAmmo' (Structure)

SentryAmmo.kMapName = "sentryammo"
SentryAmmo.kModelName = ""
SentryAmmo.kRefillSound = PrecacheAsset("sound/ns2.fev/marine/common/pickup_ammo")
SentryAmmo.kPackDropEffect = PrecacheAsset("cinematics/marine/spawn_item.cinematic")

function SentryAmmo:GetRequiresPower()
    return false
end

function SentryAmmo:OnCreate()

	Structure.OnCreate(self)
	
	self:SetIsVisible(false)
    self:SetPathingFlag(kPathingFlags.UnBuildable)

end

function SentryAmmo:OnDestroy()
        
    Structure.OnDestroy(self)

end

function SentryAmmo:RefillNearestSentry()
	
	local refilltarget = GetEntitiesForTeamWithinRange("Sentry", self:GetTeamNumber(), self:GetOrigin(), 1.5)
	
	if refilltarget ~= nil then
		if refilltarget[1] ~= nil and refilltarget[1]:AddReserve() then
			return true
		else
			return false
		end
	else
		return false
	end

end



Shared.LinkClassToMap("SentryAmmo", SentryAmmo.kMapName, {})