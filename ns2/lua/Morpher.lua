// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\SporeMine.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Thing that aliens spawn out of.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Structure.lua")
Script.Load("lua/InfestationMixin.lua")

class 'Morpher' (Structure)

PrepareClassForMixin(Morpher, InfestationMixin)

Morpher.kMapName = "morpher"

Morpher.kModelName = PrecacheAsset("models/alien/morpher/morpher.model")


function Morpher:OnConstructionComplete()

    Structure.OnConstructionComplete(self)
    
end

function Morpher:GetIsAlienStructure()
    return true
end

function Morpher:OnResearchComplete(structure, researchId)

    local success = Structure.OnResearchComplete(self, structure, researchId)
    
    return success    
    
end

function Morpher:GetTechButtons(techId)

    local techButtons = nil
    
    if(techId == kTechId.RootMenu) then 
    
        techButtons = { kTechId.Melee1Tech, kTechId.Melee2Tech, kTechId.Melee3Tech, kTechId.None,
        				kTechId.AlienArmor1Tech, kTechId.AlienArmor2Tech, kTechId.AlienArmor3Tech, kTechId.None,
        				kTechId.LerkTech, kTechId.FadeTech, kTechId.OnosTech, kTechId.None,
        				 }
        
        // Allow structure to be ugpraded to mature version
        local upgradeIndex = table.maxn(techButtons) + 1
        
        if(self:GetTechId() == kTechId.Morpher) then
            techButtons[upgradeIndex] = kTechId.UpgradeMorpher
        elseif(self:GetTechId() == kTechId.MatureMorpher) then
            techButtons[upgradeIndex] = kTechId.MorpherBabblers
        end        
    end
    
    return techButtons
    
end

/*
function Morpher:PerformActivation(techId, position, normal, commander)

    local success = false
    
    if techId == kTechId.MorpherUmbra then
        success = self:TriggerUmbra(commander)
    elseif techId == kTechId.MorpherBabblers then
        success = self:TargetBabblers(position)
    end
    
    return success
    
end
*/

function Morpher:OnInit()
    InitMixin(self, InfestationMixin)    
    Structure.OnInit(self) 
end

if Server then
 function Morpher:OnDestroy()
    self:ClearInfestation()
    Structure.OnDestroy(self)
 end
end

Shared.LinkClassToMap("Morpher", Morpher.kMapName, {})
