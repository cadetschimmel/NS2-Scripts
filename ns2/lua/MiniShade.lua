// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\MiniShade.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// PreForm of the Shade structure. Supplies only reduced passive effect and has the option
// for the commander to grow up
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Structure.lua")
Script.Load("lua/InfestationMixin.lua")

class 'MiniShade' (Structure)

PrepareClassForMixin(MiniShade, InfestationMixin)

MiniShade.kMapName = "minishade"

MiniShade.kModelName = PrecacheAsset("models/alien/mini_shade/mini_shade.model")

MiniShade.kDistortRadius = 8

function MiniShade:OnInit()
    InitMixin(self, InfestationMixin)    
    Structure.OnInit(self) 
end
 
function MiniShade:GetIsAlienStructure()
    return true
end

function MiniShade:GetTechButtons(techId)

    local techButtons = nil
    
    if techId == kTechId.RootMenu then 
    
        techButtons = { kTechId.UpgradeMiniShade }

    end
    
    return techButtons
    
end

function MiniShade:OnResearchComplete(structure, researchId)

    local success = Structure.OnResearchComplete(self, structure, researchId)

    if success then
    
        // Transform into Shade
        if structure and (structure:GetId() == self:GetId()) and (researchId == kTechId.UpgradeMiniShade) then
        
        	local new_structure = self:Replace(Shade.kMapName)
        	new_structure:OnInit()
        	self:TriggerEffects("upgrade_mini_structure")
        	success = true
            
        end
    
    end
    
    return success
    
end

if Server then
 function MiniShade:OnDestroy()
    self:ClearInfestation()
    Structure.OnDestroy(self)
 end
end

Shared.LinkClassToMap("MiniShade", MiniShade.kMapName, {})