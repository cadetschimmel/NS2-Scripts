// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\Spray.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//                  Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// healing spray on secondary.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Alien/Ability.lua")

class 'Spray' (Ability)

Spray.kMapName = "spray"

Spray.kHealthSprayEnergyCost = kHealsprayEnergyCost
Spray.kHealRadius = 3.5

// Players heal by base amount + percentage of max health
Spray.kHealPlayerPercent = 4

// Structures heal by base x this multiplier (same as NS1)
Spray.kHealStructuresMultiplier = 5

Spray.kHealingSprayDamage = kHealsprayDamage
Spray.kHealthSprayDelay = kHealsprayFireDelay

Spray.kInfestationRange = .9
Spray.kInfestationMaxSize = 1.5

local networkVars = {
    chamberPoseParam        = "compensated float"
}

function Spray:GetHasSecondary(player)
    return true
end

function Spray:GetSecondaryEnergyCost(player)
    return self:ApplyEnergyCostModifier(Spray.kHealthSprayEnergyCost, player)
end

function Spray:GetIconOffsetY(secondary)
    return kAbilityOffset.Spit
end

// Find friendly players and structures in front of us, in cone and heal them by a 
// a percentage of their health
function Spray:HealEntities(player)

	//self:TriggerEffects("spray_alt_attack", { effecthostcoords = BuildCoordsFromDirection(player:GetViewCoords().zAxis, self:GetHealOrigin(player)) })
    
    local success = false
    
    local ents = GetEntitiesWithinRangeAreVisible("LiveScriptActor", self:GetHealOrigin(player), Spray.kHealRadius, true)
    
    for index, targetEntity in ipairs(ents) do

        local isEnemyPlayer = (GetEnemyTeamNumber(player:GetTeamNumber()) == targetEntity:GetTeamNumber()) and targetEntity:isa("Player")
        local isHealTarget = (player:GetTeamNumber() == targetEntity:GetTeamNumber())
        
        // TODO: Traceline to target to make sure we don't go through objects (or check line of sight because of area effect?)
        // GetHealthScalar() factors in health and armor.
        if isHealTarget and targetEntity:GetHealthScalar() < 1 then

            // Heal players by base amount plus a scaleable amount so it's effective vs. small and large targets
            local health = Spray.kHealingSprayDamage + targetEntity:GetMaxHealth() * Spray.kHealPlayerPercent/100.0
            
            // Heal structures by multiple of damage(so it doesn't take forever to heal hives, ala NS1)
            if targetEntity:isa("Structure") then
                health = Spray.kHealingSprayDamage * Spray.kHealStructuresMultiplier
            end
            
            targetEntity:AddHealth( health )
            
            // Put out entities on fire sometimes
            //if math.random() < kSprayDouseOnFireChance then
            //    targetEntity:SetGameEffectMask(kGameEffect.OnFire, false)
           // end
            
            targetEntity:TriggerEffects("sprayed")
            
            success = true
            
        elseif isEnemyPlayer then
        
            targetEntity:TakeDamage( Spray.kHealingSprayDamage, player, self, self:GetOrigin(), nil)
            targetEntity:TriggerEffects("sprayed")
            success = true
            
        end 
        
    end
    
    
    
    return success
        
end

function Spray:GetSecondaryAttackDelay()
    return Spray.kHealthSprayDelay 
end

function Spray:GetHealOrigin(player)

    // Don't project origin the full radius out in front of Gorge or we have edge-case problems with the Gorge 
    // not being able to hear himself
    local startPos = player:GetEyePos()
    local trace = Shared.TraceRay(startPos, startPos + (player:GetViewAngles():GetCoords().zAxis * Spray.kHealRadius * .9), PhysicsMask.Bullets, EntityFilterOne(player))
    return trace.endPoint
    
end

// Given a gorge player's position and view angles, return a position and orientation
// for infestation patch. Used to preview placement via a ghost structure and then to create it.
// Also returns bool if it's a valid position or not.
function Spray:GetPositionForInfestation(player)

    local validPosition = false
    
    local origin = player:GetEyePos() + player:GetViewAngles():GetCoords().zAxis * Spray.kInfestationRange

    // Trace short distance in front
    local trace = Shared.TraceRay(player:GetEyePos(), origin, PhysicsMask.AllButPCsAndRagdolls, EntityFilterTwo(player, self))
    
    local displayOrigin = Vector()
    VectorCopy(trace.endPoint, displayOrigin)
    
    // If it hits something, position on this surface (must be the world or another structure)
    if trace.fraction < 1 then
    
        if trace.entity == nil then
            validPosition = true
        elseif not trace.entity:isa("LiveScriptActor") then
            validPosition = true
        end
        
        VectorCopy(trace.endPoint, displayOrigin)
        
    end
    
    local coords = nil
    
    if validPosition then
    
        // Don't allow placing infestation above or below us and don't draw either
        local infestationFacing = Vector()
        VectorCopy(player:GetViewAngles():GetCoords().zAxis, infestationFacing)
        
        coords = BuildCoords(trace.normal, infestationFacing, displayOrigin, Spray.kInfestationMaxSize * 2)    

        
        ASSERT(ValidateValue(coords.xAxis))
        ASSERT(ValidateValue(coords.yAxis))
        ASSERT(ValidateValue(coords.zAxis))

        local infestations = GetEntitiesForTeamWithinRange("Infestation", player:GetTeamNumber(), coords.origin, 1)
        
        if table.count(infestations) >= 3 then
            validPosition = false
        end
        
    end
    
    return coords, validPosition

end

function Spray:SprayInfestation(player, coords)

    player:TriggerEffects("start_create_infestation")

    player:SetAnimAndMode(Gorge.kCreateStructure, kPlayerMode.GorgeStructure)    

    local infestation = CreateEntity(Infestation.kMapName, coords.origin, player:GetTeamNumber())
    
    infestation:SetMaxRadius(Spray.kInfestationMaxSize)
    infestation:SetCoords(coords)
    infestation:SetLifetime(kGorgeInfestationLifetime)
    infestation:SetRadiusPercent(.1)
    infestation:SetGrowthRateScalar(3)
    
    //player:TriggerEffects("create_infestation")

end

function Spray:HealSpray(player)

    self:HealEntities( player )     
    
    player:SetActivityEnd( player:AdjustFuryFireDelay(self:GetSecondaryAttackDelay() ))
    
    return true
    
end

function Spray:PerformSecondaryAttack(player)

    if Server then           
    
        // Trace to see if we hit a wall - if so, spray infestation. Otherwise, heal/attack.
        /*local coords, valid = self:GetPositionForInfestation(player)        
        if valid then
        
            success = self:SprayInfestation(player, coords)
            
        else
        */
            self:HealEntities( player )
            
        //end
        
    end        
    
    player:SetActivityEnd( player:AdjustFuryFireDelay(self:GetSecondaryAttackDelay() ))
    
    return true

end

function Spray:UpdateViewModelPoseParameters(viewModel, input)

    Ability.UpdateViewModelPoseParameters(self, viewModel, input)

    // Move away from chamber 
    self.chamberPoseParam = Clamp(Slerp(self.chamberPoseParam, 0, input.time), 0, 1)
    viewModel:SetPoseParam("chamber", self.chamberPoseParam)
    
end

function Spray:GetEffectParams(tableParams)

    Ability.GetEffectParams(self, tableParams)
    
    // Override host coords for spray to be where heal origin is
    local player = self:GetParent()
    if player then
        tableParams[kEffectHostCoords] = BuildCoordsFromDirection(player:GetViewCoords().zAxis, self:GetHealOrigin(player))
    end
    
end

Shared.LinkClassToMap("Spray", Spray.kMapName, networkVars )
