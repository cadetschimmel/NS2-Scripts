// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\MiniCrag.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// PreForm of the Crag structure. Supplies only reduced passive effect and has the option
// for the commander to grow up
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Structure.lua")
Script.Load("lua/InfestationMixin.lua")

class 'MiniCrag' (Structure)

PrepareClassForMixin(MiniCrag, InfestationMixin)

MiniCrag.kMapName = "minicrag"

MiniCrag.kModelName = PrecacheAsset("models/alien/mini_crag/mini_crag.model")

MiniCrag.kHealRadius = 5



function MiniCrag:OnInit()
    InitMixin(self, InfestationMixin)    
    Structure.OnInit(self) 

    if Server then 
        self.targetSelector = Server.targetCache:CreateSelector(
                self,
                MiniCrag.kHealRadius, 
                false, // we heal targets we don't have a los to
                TargetCache.kMmtl, // yea, we heal what the marines wants to hurt
                TargetCache.kAshtl,// marine static targets + infestations
                { HealableTargetFilter() }, // filter away unhurt targets
                { IsaPrioritizer("Player") }) // and prioritize players
    end    
end

function MiniCrag:OnConstructionComplete()

    Structure.OnConstructionComplete(self)
    
    self:SetNextThink(Crag.kThinkInterval)
    
end 

function MiniCrag:GetIsAlienStructure()
    return true
end

function MiniCrag:GetTechButtons(techId)

    local techButtons = nil
    
    if techId == kTechId.RootMenu then 
    
        techButtons = { kTechId.UpgradeMiniCrag }

    end
    
    return techButtons
    
end

function MiniCrag:OnResearchComplete(structure, researchId)

    local success = Structure.OnResearchComplete(self, structure, researchId)

    if success then
    
        // Transform into Crag
        if structure and (structure:GetId() == self:GetId()) and (researchId == kTechId.UpgradeMiniCrag) then
        
        	local new_structure = self:Replace(Crag.kMapName)
        	new_structure:OnInit()
        	self:TriggerEffects("upgrade_mini_structure")
        	success = true
            
        end
    
    end
    
    return success
    
end

function MiniCrag:TryHeal(target, sqRange)
    local amountHealed = target:AddHealth(Crag.kHealAmount / 2)
    if amountHealed > 0 then
        target:TriggerEffects("crag_target_healed")           
    end
    return amountHealed
end

function MiniCrag:PerformHealing(energyCost)

    // acquire up to kMaxTargets healable targets inside range, players first
    local targets = self.targetSelector:AcquireTargets(Crag.kMaxTargets)
    local entsHealed = 0
    
    for _,target in ipairs(targets) do
        local healAmount = self:TryHeal(target, sqRange) 
        entsHealed = entsHealed + ((healAmount > 0 and 1) or 0)
    end

    if entsHealed > 0 then
        self:AddEnergy(-energyCost)        
        self:TriggerEffects("crag_heal")       
    end
    
end

function MiniCrag:UpdateHealing()

    local time = Shared.GetTime()
    
    if self.timeOfLastHeal == nil or (time > self.timeOfLastHeal + Crag.kHealInterval) then
    
        // Only heal if it has the energy to do so
        local energyCost = LookupTechData(kTechId.CragHeal, kTechDataCostKey, 0) / 2
        
        if self:GetEnergy() >= energyCost then
    
            self:PerformHealing(energyCost)

            self.timeOfLastHeal = time
            
        end
        
    end
    
end

function MiniCrag:OnThink()

    Structure.OnThink(self)
    
    if self:GetIsBuilt() then
    
        self:UpdateHealing()
        
    end
        
    self:SetNextThink(Crag.kThinkInterval)
    
end

if Server then
 function MiniCrag:OnDestroy()
    self:ClearInfestation()
    Structure.OnDestroy(self)
 end
end

Shared.LinkClassToMap("MiniCrag", MiniCrag.kMapName, {})