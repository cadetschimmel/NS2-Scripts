// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\MiniShift.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// PreForm of the Shift structure. Supplies only reduced passive effect and has the option
// for the commander to grow up
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Structure.lua")
Script.Load("lua/Shift.lua") // required for target filter function
Script.Load("lua/InfestationMixin.lua")

class 'MiniShift' (Structure)

PrepareClassForMixin(Shift, InfestationMixin)

MiniShift.kMapName = "minishift"

MiniShift.kModelName = PrecacheAsset("models/alien/mini_shift/mini_shift.model")

MiniShift.kEnergizeRadius = 5

function MiniShift:OnInit()
    InitMixin(self, InfestationMixin)    
    Structure.OnInit(self) 

    if Server then 
        self.targetSelector = Server.targetCache:CreateSelector(
                self,
                MiniShift.kEnergizeRadius,
                false, // we energize targets we don't have a los to
                TargetCache.kMmtl, // yea, we energize what the marines wants to hurt
                TargetCache.kAshtl,// marine static targets + infestations
                { EnergizeAbleTargetFilter() }, // filter away unhurt targets
                { IsaPrioritizer("Player") }) // and prioritize players
    end
end


function MiniShift:OnConstructionComplete()

    Structure.OnConstructionComplete(self)
    
    self:SetNextThink(Shift.kThinkInterval)
    
end
 
function MiniShift:GetIsAlienStructure()
    return true
end


function MiniShift:PerformEnergize()

    // acquire up to kMaxTargets energizeable targets inside range, players first
    local targets = self.targetSelector:AcquireTargets(Shift.kMaxTargets)
    local entsEnergized = 0
    
    for _,target in ipairs(targets) do
        local energizeAmount = self:TryEnergize(target, sqRange) 
        entsEnergized = entsEnergized + ((energizeAmount > 0 and 1) or 0)
    end

    if entsEnergized > 0 then   
        local energyCost = LookupTechData(kTechId.ShiftEnergize, kTechDataCostKey, 0)  / 2
        self:AddEnergy(-energyCost)
    end
    
end

function MiniShift:TryEnergize(target, sqRange)

	local amountEnergized = 0
	
    if target.AddEnergy then 
    
    	target:AddEnergy(Shift.kEnergizeAmount / 2 )
    	amountEnergized = Shift.kEnergizeAmount / 2  
    	local effectName = ConditionalValue(target:isa("Hive") or target:isa("Onos"), Shift.kEnergizeLargeTargetEffect, Shift.kEnergizeSmallTargetEffect)
	    Shared.CreateEffect(nil, effectName, target)
	    target:PlaySound(Shift.kEnergizeTargetSoundEffect)
	    
	end
	    
    return amountEnergized
end

function MiniShift:UpdateEnergize()

    local time = Shared.GetTime()
    
    if self.timeOfLastEnergize == nil or (time > self.timeOfLastEnergize + Shift.kEnergizeInterval) then
    
        // Only energize if it has the energy to do so
        local energyCost = LookupTechData(kTechId.ShiftEnergize, kTechDataCostKey, 0) / 2
        
        if self:GetEnergy() >= energyCost then
    
            self:PerformEnergize()

            self.timeOfLastEnergize = time
            
        end
        
    end
    
end

// Look for nearby friendlies to energize
function MiniShift:OnThink()

    Structure.OnThink(self)
    
    if self:GetIsBuilt() then
    
        self:UpdateEnergize()
        
    end
        
    self:SetNextThink(Shift.kThinkInterval)
    
end

function MiniShift:GetTechButtons(techId)

    local techButtons = nil
    
    if techId == kTechId.RootMenu then 
    
        techButtons = { kTechId.UpgradeMiniShift }

    end
    
    return techButtons
    
end

function MiniShift:OnResearchComplete(structure, researchId)

    local success = Structure.OnResearchComplete(self, structure, researchId)

    if success then
    
        // Transform into Shift
        if structure and (structure:GetId() == self:GetId()) and (researchId == kTechId.UpgradeMiniShift) then
        
        	local new_structure = self:Replace(Shift.kMapName)
        	new_structure:OnInit()
        	self:TriggerEffects("upgrade_mini_structure")
        	success = true
            
        end
    
    end
    
    return success
    
end

if Server then
 function MiniShift:OnDestroy()
    self:ClearInfestation()
    Structure.OnDestroy(self)
 end
end

Shared.LinkClassToMap("MiniShift", MiniShift.kMapName, {})