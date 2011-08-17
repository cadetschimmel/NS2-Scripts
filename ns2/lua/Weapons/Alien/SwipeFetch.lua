// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\SwipeFetch.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Swipe/Fetch - 
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Fetch.lua")

class 'SwipeFetch' (Fetch)

SwipeFetch.kMapName = "swipefetch"

local networkVars =
{
    lastSwipedEntityId = "entityid"
}

// TODO: Hold shift for "rebound" type ability. Shift while looking at enemy lets you blink above, behind or off of a wall.

SwipeFetch.kHitMarineSound = PrecacheAsset("sound/ns2.fev/alien/fade/swipe_hit_marine")
SwipeFetch.kScrapeMaterialSound = "sound/ns2.fev/materials/%s/scrape"
PrecacheMultipleAssets(SwipeFetch.kScrapeMaterialSound, kSurfaceList)

// Make sure to keep damage vs. structures less then Skulk
SwipeFetch.kSwipeEnergyCost = kSwipeEnergyCost
SwipeFetch.kPrimaryAttackDelay = kSwipeFireDelay
SwipeFetch.kDamage = kSwipeDamage
SwipeFetch.kRange = 1.5

function SwipeFetch:OnInit()

    Blink.OnInit(self)
    
    self.lastSwipedEntityId = Entity.invalidId

end

function SwipeFetch:GetEnergyCost(player)
    return self:ApplyEnergyCostModifier(SwipeFetch.kSwipeEnergyCost, player)
end

function SwipeFetch:GetPrimaryAttackDelay()
    return SwipeFetch.kPrimaryAttackDelay
end

function SwipeFetch:GetHUDSlot()
    return 3
end

function SwipeFetch:GetIconOffsetY(secondary)
    return kAbilityOffset.SwipeFetch
end

function SwipeFetch:GetPrimaryAttackRequiresPress()
    return false
end

function SwipeFetch:GetDeathIconIndex()
    return kDeathMessageIcon.SwipeBlink
end

// Claw attack, or blink if we're in that mode
function SwipeFetch:PerformPrimaryAttack(player)
    
    // Delete ghost
    //Fetch.PerformPrimaryAttack(self, player)

    // Play random animation
    player:SetActivityEnd( player:AdjustFuryFireDelay(self:GetPrimaryAttackDelay() ))
    
    // Check if the swipe may hit an entity. Don't actually do any damage yet.
    local didHit, trace = self:CheckMeleeCapsule(player, SwipeFetch.kDamage, SwipeFetch.kRange)
    self.lastSwipedEntityId = Entity.invalidId
    if didHit and trace and trace.entity then
        self.lastSwipedEntityId = trace.entity:GetId()
    end
    
    return true
    
end

function SwipeFetch:OnTag(tagName)

    Blink.OnTag(self, tagName)
    
    if tagName == "hit" then
        self:PerformMeleeAttack()
    end

end

function SwipeFetch:PerformMeleeAttack()

    local player = self:GetParent()
    if player then
    
        // Trace melee attack
        local didHit, trace = self:AttackMeleeCapsule(player, SwipeFetch.kDamage, SwipeFetch.kRange)
        if didHit then

            local hitObject = trace.entity
            local materialName = trace.surface
            
            if hitObject ~= nil then
            
                if hitObject:isa("Marine") then
                    Shared.PlaySound(player, SwipeFetch.kHitMarineSound)
                else
                
                    // Play special bite hit sound depending on material
                    local surface = trace.surface
                    if(surface ~= "") then
                        Shared.PlayWorldSound(nil, string.format(SwipeFetch.kScrapeMaterialSound, surface), nil, trace.endPoint)
                    end
                    
                end
                
            end
            
        end
        
    end
    
end

function SwipeFetch:GetEffectParams(tableParams)

    Blink.GetEffectParams(self, tableParams)
    
    // There is a special case for biting structures.
    if self.lastSwipedEntityId ~= Entity.invalidId then
        local lastSwipedEntity = Shared.GetEntity(self.lastSwipedEntityId)
        if lastSwipedEntity and lastSwipedEntity:isa("Structure") then
            tableParams[kEffectFilterHitSurface] = "structure"
        end
    end
    
end

Shared.LinkClassToMap("SwipeFetch", SwipeFetch.kMapName, networkVars )
