// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\BurstEvolve.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
// 
// Burst is main attack, good against structures. Alt attack evolve to last life-form
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Alien/BiteLeap.lua")

class 'BurstEvolve' (BiteLeap)

BurstEvolve.kMapName = "burst"

BurstEvolve.kPrimaryEnergyCost = 11

BurstEvolve.kEvolveDelay = 1

BurstEvolve.kBurstDelay = 1

// All two hive skulks have leap - but it goes away as soon as the second hive does
function BurstEvolve:GetHasSecondary(player)
    return true
end

function BurstEvolve:GetPrimaryEnergyCost(player)
    return BurstEvolve.kPrimaryEnergyCost
end

function BurstEvolve:GetSecondaryEnergyCost(player)
    return 0
end

// evolve to last life-form if on infestation and enough room to gestate
function BurstEvolve:PerformSecondaryAttack(player)
    
	if Server and player.EvolveToLastLifeForm and player:GetGameEffectMask(kGameEffect.OnInfestation) then
		player:EvolveToLastLifeForm()
	end
    
    player:SetActivityEnd(player:AdjustFuryFireDelay(self:GetSecondaryAttackDelay()))
    
    return true
    
end

function BurstEvolve:PerformMelee(player, trace, direction)
	self:ApplyMeleeHit(player, kBurstDamage, trace, direction) 
end

function BurstEvolve:GetPrimaryAttackDelay()
	return BurstEvolve.kBurstDelay
end

function BurstEvolve:GetSecondaryAttackDelay()
	return BurstEvolve.kEvolveDelay
end

function BurstEvolve:GetPrimaryAttackPrefix()
	return 'burst'
end

function BurstEvolve:GetSecondaryAttackPrefix()
	return 'burst'
end

Shared.LinkClassToMap("BurstEvolve", BurstEvolve.kMapName, {} )

