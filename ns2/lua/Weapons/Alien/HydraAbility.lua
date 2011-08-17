// ======= Copyright � 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\HydraStructureAbility.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Gorge builds hydra.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'HydraStructureAbility' (StructureAbility)

HydraStructureAbility.kMapName = "hydra_ability"

function HydraStructureAbility:GetEnergyCost(player)
    return 40
end

function HydraStructureAbility:GetPrimaryAttackDelay()
    return 1.0
end

function HydraStructureAbility:GetIconOffsetY(secondary)
    return kAbilityOffset.Hydra
end

function HydraStructureAbility:GetGhostModelName(ability)
    return Hydra.kModelName
end

function HydraStructureAbility:GetDropStructureId()
    return kTechId.Hydra
end

function HydraStructureAbility:GetSuffixName()
    return "hydra"
end

function HydraStructureAbility:GetDropClassName()
    return "Hydra"
end

function HydraStructureAbility:GetDropMapName()
    return Hydra.kMapName
end

Shared.LinkClassToMap("HydraStructureAbility", HydraStructureAbility.kMapName, {} )
