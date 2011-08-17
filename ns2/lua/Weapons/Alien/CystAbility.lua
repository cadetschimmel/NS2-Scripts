// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\CystStructureAbility.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Gorge builds hydra.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'CystStructureAbility' (StructureAbility)

CystStructureAbility.kModelName = PrecacheAsset("models/alien/small_pustule/small_pustule.model")
CystStructureAbility.kOffModelName = PrecacheAsset("models/alien/small_pustule/small_pustule_off.model")
CystStructureAbility.kMapName = "cyst_ability"

function CystStructureAbility:GetEnergyCost(player)
    return 40
end

function CystStructureAbility:GetPrimaryAttackDelay()
    return 1.0
end

function CystStructureAbility:GetIconOffsetY(secondary)
    return kAbilityOffset.Hydra
end

function CystStructureAbility:GetDropStructureId()
    return kTechId.MiniCyst
end

function CystStructureAbility:GetSuffixName()
    return "minicyst"
end

function CystStructureAbility:GetDropClassName()
    return "MiniCyst"
end

function CystStructureAbility:GetDropMapName()
    return MiniCyst.kMapName
end

function CystStructureAbility:GetConnection(ability)

    PROFILE("CystStructureAbility:GetConnection")

    local player = ability:GetParent()
    local coords = ability:GetPositionForStructure(player)
    return GetCystParentFromPoint(coords.origin, coords.yAxis)
    
end

function CystStructureAbility:GetGhostModelName(ability)

    // Use a different model if we're within connection range or not
    local connectedEnt = CystStructureAbility.GetConnection(self, ability)
    
    return ConditionalValue(connectedEnt, MiniCyst.kModelName, MiniCyst.kOffModelName)
    
end

function CystStructureAbility:CreateStructure(coords, player)

    // Create mini cyst
    local cyst, connected = CreateCyst(player, coords.origin, coords.yAxis, true)
    
    // Set initial model on cyst depending if we're connected or not
    if cyst then
        local modelName = cyst:GetCystModelName(connected)
        cyst:SetModel(modelName)
    end
    
    return cyst
    
end

/* Uncomment to see lines to connection
if Client then
function CystStructureAbility:OnUpdate(deltaTime)

    DropStructureAbility.OnUpdate(self, deltaTime)
    
    local connectedEnt, connectedTrack = self:GetConnection()
    if connectedEnt then
        local player = self:GetParent()
        local coords = self:GetPositionForStructure(player)
        DebugLine(coords.origin, connectedEnt:GetModelOrigin(), 1, 0, 0, 1, 0, 1)
    end
    
end
end
*/

Shared.LinkClassToMap("CystStructureAbility", CystStructureAbility.kMapName, {} )
