// ======= Copyright � 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\BiteLeap.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
// 
// Bite is main attack, leap is secondary.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/Leap.lua")

class 'BiteLeap' (Leap)

BiteLeap.kMapName = "bite"

BiteLeap.kRange = 1.0    // 60" inches in NS1

// how much the two attacks diverge 
BiteLeap.kAttackSpreadDegrees = 20
// rotate around y-axis to get a wider horizontal spread, around x-axis to get a higher vertical spread
BiteLeap.kAttackRotationAxis = Vector.yAxis

local networkVars =
{
    lastBittenEntityId = "entityid"
}

function BiteLeap:OnInit()

    Ability.OnInit(self)
    
    self.lastBittenEntityId = Entity.invalidId

end

function BiteLeap:GetEnergyCost(player)
    return self:ApplyEnergyCostModifier(kBiteEnergyCost, player)
end

function BiteLeap:GetHUDSlot()
    return 1
end

function BiteLeap:GetIconOffsetY(secondary)
    return kAbilityOffset.Bite
end

function BiteLeap:GetRange()
    return BiteLeap.kRange
end

function BiteLeap:GetDeathIconIndex()
    return kDeathMessageIcon.Bite
end

function BiteLeap:GetPrimaryAttackDelay()
	return kBiteFireDelay
end

function BiteLeap:PerformPrimaryAttack(player)
    
    // Play random animation, speeding it up if we're under effects of fury
    player:SetActivityEnd( player:AdjustFuryFireDelay(self:GetPrimaryAttackDelay()) )

    // do a left and right melee attack, choose the juiciest target if any

    local viewCoords = player:GetViewAngles():GetCoords()
    

    local angle = BiteLeap.kAttackSpreadDegrees * math.pi / 180

    local leftCoords = viewCoords * Coords.GetRotation(BiteLeap.kAttackRotationAxis, -angle)
    local rightCoords = viewCoords * Coords.GetRotation(BiteLeap.kAttackRotationAxis, angle)

    self.traceRealAttack = true // enable tracing on both capsule checks
    // the left attack is the default
    local hit, trace, direction = self:CheckMeleeCapsule(player, kBiteDamage, BiteLeap.kRange, leftCoords)
    local rightHit, rightTrace, rightDirection = self:CheckMeleeCapsule(player, kBiteDamage, BiteLeap.kRange, rightCoords)   
    self.traceRealAttack = false
 
    // check if we should use the right hit instead of the left 
    if rightHit and rightTrace and rightTrace.entity ~= nil then
        // is the right hit a juicier target? Well, if it is an enemy player, then we switch to it
        if not trace.entity or (rightTrace.entity:isa("Player") and player:GetTeamType() ~= rightTrace.entity:GetTeamType()) then
            hit, trace, direction = rightHit, rightTrace, rightDirection
        end
    end

    self.lastBittenEntityId = Entity.invalidId
   
    if hit and trace and trace.entity ~= nil then
        self.lastBittenEntityId = trace.entity:GetId()

		self:PerformMelee(player, trace, direction)
               
    end        

    return true
end

function BiteLeap:PerformMelee(player, trace, direction)
	self:ApplyMeleeHit(player, kBiteDamage, trace, direction) 
end

function BiteLeap:GetEffectParams(tableParams)

    Ability.GetEffectParams(self, tableParams)
    
    // There is a special case for biting structures.
    if self.lastBittenEntityId ~= Entity.invalidId then
        local lastBittenEntity = Shared.GetEntity(self.lastBittenEntityId)
        if lastBittenEntity and lastBittenEntity:isa("Structure") then
            tableParams[kEffectFilterHitSurface] = "structure"
        end
    end
    
end

/**
 * Allow weapons to have different capsules
 * Skulks are low to the ground so they cast 2 attacks, one above and one below
 * to help them not hit the ground. Each cast should be half the height of the desired
 * cast (which is the y component here).
 */
function BiteLeap:GetMeleeCapsule()
    return Vector(0.4, 0.2, 0.4)
end

/**
 * Offset the start of the melee capsule with this much from the viewpoint.
 * Skulk needs a bit more than others, as they are four-legged critters, with more
 * of their body between their midpoint and their head.
 */
function BiteLeap:GetMeleeOffset()
    return 0.4
end

Shared.LinkClassToMap("BiteLeap", BiteLeap.kMapName, networkVars )
