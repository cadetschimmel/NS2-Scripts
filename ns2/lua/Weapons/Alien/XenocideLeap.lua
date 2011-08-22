// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\XenocideLeap.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
// 
// Bite is main attack, leap is secondary.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/Leap.lua")

class 'XenocideLeap' (Leap)

XenocideLeap.kMapName = "xenocide"

XenocideLeap.kRadius = 8.0

XenocideLeap.kMaxDamage = 200

XenocideLeap.kDelay = 2

XenocideLeap.kAttackDelay = .5

function XenocideLeap:GetEnergyCost(player)
    return self:ApplyEnergyCostModifier(kXenocideEnergyCost, player)
end

function XenocideLeap:GetHUDSlot()
    return 3
end

function XenocideLeap:GetIconOffsetY(secondary)
    return kAbilityOffset.Bite
end

function XenocideLeap:CanUseWeapon(player)
	return player.GetHasThreeHives and player:GetHasThreeHives()
end

function XenocideLeap:GetDeathIconIndex()
    return kDeathMessageIcon.Bite
end

function XenocideLeap:GetPrimaryAttackDelay()
	return XenocideLeap.kAttackDelay
end

function XenocideLeap:PerformPrimaryAttack(player)

    if Server then
    	player:TriggerXenocideTimer()
	end
	
	player:SetActivityEnd(player:AdjustFuryFireDelay(self:GetPrimaryAttackDelay()))
	
    return true
end

Shared.LinkClassToMap("XenocideLeap", XenocideLeap.kMapName, { } )
