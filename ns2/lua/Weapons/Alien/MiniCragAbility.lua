// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\MiniCragStructureAbility.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Gorge builds MiniCrag.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'MiniCragStructureAbility' (StructureAbility)

MiniCragStructureAbility.kMapName = "minicrag_ability"

function MiniCragStructureAbility:GetEnergyCost(player)
    return 40
end

function MiniCragStructureAbility:GetPrimaryAttackDelay()
    return 1.0
end

function MiniCragStructureAbility:GetIconOffsetY(secondary)
    return kAbilityOffset.Hydra
end

function MiniCragStructureAbility:GetGhostModelName(ability)
    return MiniCrag.kModelName
end

function MiniCragStructureAbility:GetDropStructureId()
    return kTechId.MiniCrag
end

function MiniCragStructureAbility:GetSuffixName()
    return "MiniCrag"
end

function MiniCragStructureAbility:GetDropClassName()
    return "MiniCrag"
end

function MiniCragStructureAbility:GetDropMapName()
    return MiniCrag.kMapName
end

function MiniCragStructureAbility:IsAllowed()

	return CheckTeamHasStructure("Crag")
	
end

Shared.LinkClassToMap("MiniCragStructureAbility", MiniCragStructureAbility.kMapName, {} )
