// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\Leap.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//                  Andreas Urwalek (a_urwa@sbox.tugraz.at)
// 
// leap is secondary.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Alien/Ability.lua")

class 'Leap' (Ability)

Leap.kMapName = "leap"

// All two hive skulks have leap - but it goes away as soon as the second hive does
function Leap:GetHasSecondary(player)
    return player.GetHasTwoHives and player:GetHasTwoHives()
end

function Leap:GetSecondaryEnergyCost(player)
    return self:ApplyEnergyCostModifier(kLeapEnergyCost, player)
end

// Leap if it makes sense (not if looking down).
function Leap:PerformSecondaryAttack(player)

    local parent = self:GetParent()
    if parent and self:GetHasSecondary(player) then
    
        // Check to make sure there's nothing right in front of us
        local startPoint = player:GetEyePos()
        local viewCoords = player:GetViewAngles():GetCoords()
        local kLeapCheckRange = 2
        
        local trace = Shared.TraceRay(startPoint, startPoint + viewCoords.zAxis * kLeapCheckRange, PhysicsMask.AllButPCs, EntityFilterOne(player))
        if(trace.fraction == 1) then
        
            // Make sure we're on the ground or something else
            trace = Shared.TraceRay(startPoint, Vector(startPoint.x, startPoint.y - .5, startPoint.z), PhysicsMask.AllButPCs, EntityFilterOne(player))
            if(trace.fraction ~= 1 or player:GetCanJump()) then
        
                // TODO: Pass this into effects system
                local volume = ConditionalValue(player:GetHasUpgrade(kTechId.Leap), 1, .6)
                
                player:OnLeap()
                
                return true
                
            end
            
        end
        
    end
    
    return false
    
end

Shared.LinkClassToMap("Leap", Leap.kMapName, {} )
