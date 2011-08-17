// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\BileBomb.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/Spray.lua")
Script.Load("lua/Weapons/Alien/Bomb.lua")

class 'BileBomb' (Spray)

BileBomb.kMapName = "bilebomb"
BileBomb.kBombSpeed = 10

local networkVars = {
    bombMode                = "boolean"
}

function BileBomb:PerformSecondaryAttack(player)

    self.bombMode = false
    
    self:HealSpray(player)
    
    return true
    
end

function BileBomb:OnCreate()
    Ability.OnCreate(self)
    self.chamberPoseParam = 0
    self.bombMode = true
end

function BileBomb:CanUseWeapon(player)
	return player.GetHasTwoHives and player:GetHasTwoHives()
end

function BileBomb:GetEnergyCost(player)
    return self:ApplyEnergyCostModifier(kBileBombEnergyCost, player)
end

function BileBomb:GetIconOffsetY(secondary)
    return kAbilityOffset.Spit
end

function BileBomb:GetPrimaryAttackDelay()
    return kBileBombFireDelay
end

function BileBomb:GetDeathIconIndex()

    if self.bombMode then
        return kDeathMessageIcon.BileBomb
    else
        return kDeathMessageIcon.Spray
    end

end

function BileBomb:GetHUDSlot()
    return 2
end

function BileBomb:PerformPrimaryAttack(player)

	self.bombMode = true

    self:FireBombProjectile(player)        
        
    player:SetActivityEnd(player:AdjustFuryFireDelay(self:GetPrimaryAttackDelay()))
    
    return true
end

function BileBomb:FireBombProjectile(player)

    if Server then
        
        local viewAngles = player:GetViewAngles()
        local viewCoords = viewAngles:GetCoords()
        local startPoint = player:GetEyePos() + viewCoords.zAxis * 1
        
        local bomb = CreateEntity(Bomb.kMapName, startPoint, player:GetTeamNumber())
        SetAnglesFromVector(bomb, viewCoords.zAxis)
        
        bomb:SetPhysicsType(Actor.PhysicsType.Kinematic)
        
        local startVelocity = viewCoords.zAxis * BileBomb.kBombSpeed
        bomb:SetVelocity(startVelocity)
        
        bomb:SetGravityEnabled(true)
        
        // Set bombowner to player so we don't collide with ourselves and so we
        // can attribute a kill to us
        bomb:SetOwner(player)
        
    end

end

Shared.LinkClassToMap("BileBomb", BileBomb.kMapName, {} )
