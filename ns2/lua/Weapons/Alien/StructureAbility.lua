// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\StructureAbility.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Entity.lua")

class 'StructureAbility' (Entity)

StructureAbility.kMapName = "structureability"

// Child should override
function StructureAbility:GetEnergyCost(player)
    ASSERT(false)
end

// Child should override
function StructureAbility:GetPrimaryAttackDelay()
    ASSERT(false)
end

// Child should override
function StructureAbility:GetIconOffsetY(secondary)
    ASSERT(false)
end

// Child should override
function StructureAbility:GetDropStructureId()
    ASSERT(false)
end

function StructureAbility:GetGhostModelName(ability)
    ASSERT(false)
end

// Child should override ("hydra", "cyst", etc.). 
function StructureAbility:GetSuffixName()
    ASSERT(false)
end

// Child should override ("Hydra")
function StructureAbility:GetDropClassName()
    ASSERT(false)
end

// Child should override 
function StructureAbility:GetDropMapName()
    ASSERT(false)
end

function StructureAbility:CreateStructure()
	return false
end

function StructureAbility:IsAllowed()
	return true
end

function CheckTeamHasStructure(structure_name)

	local structures = EntityListToTable(Shared.GetEntitiesWithClassname(structure_name))
	local mature_structures = EntityListToTable(Shared.GetEntitiesWithClassname("Mature" .. structure_name))
	local amount = table.count(structures) + table.count(mature_structures)
	
	// Print("team has (%s) (%s)", tostring(amount), structure_name)
	
	if amount == 0 then
		return false
	else
		return true
	end
	
end

Shared.LinkClassToMap("StructureAbility", StructureAbility.kMapName, {} )
