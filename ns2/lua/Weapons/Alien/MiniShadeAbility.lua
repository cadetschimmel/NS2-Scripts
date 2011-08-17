// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\MiniShadeStructureAbility.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Gorge builds MiniShade.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'MiniShadeStructureAbility' (StructureAbility)

MiniShadeStructureAbility.kMapName = "minishade_ability"

function MiniShadeStructureAbility:GetEnergyCost(player)
    return 40
end

function MiniShadeStructureAbility:GetPrimaryAttackDelay()
    return 1.0
end

function MiniShadeStructureAbility:GetIconOffsetY(secondary)
    return kAbilityOffset.Hydra
end

function MiniShadeStructureAbility:GetGhostModelName(ability)
    return MiniShade.kModelName
end

function MiniShadeStructureAbility:GetDropStructureId()
    return kTechId.MiniShade
end

function MiniShadeStructureAbility:GetSuffixName()
    return "MiniShade"
end

function MiniShadeStructureAbility:GetDropClassName()
    return "MiniShade"
end

function MiniShadeStructureAbility:GetDropMapName()
    return MiniShade.kMapName
end

function MiniShadeStructureAbility:IsAllowed()

	return CheckTeamHasStructure("Shade")
	
end

Shared.LinkClassToMap("MiniShadeStructureAbility", MiniShadeStructureAbility.kMapName, {} )
