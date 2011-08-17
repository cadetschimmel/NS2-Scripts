// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\MiniShiftStructureAbility.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Gorge builds MiniShift.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'MiniShiftStructureAbility' (StructureAbility)

MiniShiftStructureAbility.kMapName = "minishift_ability"

function MiniShiftStructureAbility:GetEnergyCost(player)
    return 40
end

function MiniShiftStructureAbility:GetPrimaryAttackDelay()
    return 1.0
end

function MiniShiftStructureAbility:GetIconOffsetY(secondary)
    return kAbilityOffset.Hydra
end

function MiniShiftStructureAbility:GetGhostModelName(ability)
    return MiniShift.kModelName
end

function MiniShiftStructureAbility:GetDropStructureId()
    return kTechId.MiniShift
end

function MiniShiftStructureAbility:GetSuffixName()
    return "MiniShift"
end

function MiniShiftStructureAbility:GetDropClassName()
    return "MiniShift"
end

function MiniShiftStructureAbility:GetDropMapName()
    return MiniShift.kMapName
end

function MiniShiftStructureAbility:IsAllowed()

	return CheckTeamHasStructure("Shift")
	
end

Shared.LinkClassToMap("MiniShiftStructureAbility", MiniShiftStructureAbility.kMapName, {} )
