// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\SpitSpray.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Spit attack on primary, healing spray on secondary.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/Spray.lua")
Script.Load("lua/Weapons/Alien/Spit.lua")

class 'SpitSpray' (Spray)

SpitSpray.kMapName = "spitspray"

SpitSpray.kSpitDelay = kSpitFireDelay
SpitSpray.kSpitSpeed = 40

local networkVars = {
    spitMode                = "boolean"
}

function SpitSpray:PerformSecondaryAttack(player)

    self.spitMode = false
    
    self:HealSpray(player)
    
    return true
    
end

function SpitSpray:OnCreate()
    Ability.OnCreate(self)
    self.chamberPoseParam = 0
    self.spitMode = true
end

function SpitSpray:GetEnergyCost(player)
    return self:ApplyEnergyCostModifier(kSpitEnergyCost, player)
end

function SpitSpray:GetHUDSlot()
    return 1
end

function SpitSpray:GetDeathIconIndex()
    if self.spitMode then
        return kDeathMessageIcon.Spit
    else
        return kDeathMessageIcon.Spray
    end
end

function SpitSpray:GetIconOffsetY(secondary)
    return kAbilityOffset.Spit
end

function SpitSpray:CreateSpitProjectile(player)   

    if Server then
        
        local viewAngles = player:GetViewAngles()
        local viewCoords = viewAngles:GetCoords()
        local startPoint = player:GetEyePos() + viewCoords.zAxis * 1
        
        local spit = CreateEntity(Spit.kMapName, startPoint, player:GetTeamNumber())
        SetAnglesFromVector(spit, viewCoords.zAxis)
        
        spit:SetPhysicsType(Actor.PhysicsType.Kinematic)
        
        local startVelocity = viewCoords.zAxis * SpitSpray.kSpitSpeed
        spit:SetVelocity(startVelocity)
        
        spit:SetGravityEnabled(false)
        
        // Set spit owner to player so we don't collide with ourselves and so we
        // can attribute a kill to us
        spit:SetOwner(player)
        
    end

end

function SpitSpray:GetPrimaryAttackDelay()
    return SpitSpray.kSpitDelay
end

function SpitSpray:GetPrimaryEnergyCost()
    return kSpitEnergyCost
end

function SpitSpray:PerformPrimaryAttack(player)
    
    self.spitMode = true
    
    player:SetActivityEnd(player:AdjustFuryFireDelay(self:GetPrimaryAttackDelay()))

    self:CreateSpitProjectile(player)
    
    return true
end

Shared.LinkClassToMap("SpitSpray", SpitSpray.kMapName, networkVars )
