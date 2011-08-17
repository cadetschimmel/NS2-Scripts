// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Shift.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Alien structure that allows commander to outmaneuver and redeploy forces. 
//
// Recall - Ability that lets players jump to nearest structure (or hive) under attack (cooldown 
// of a few seconds)
// Energize - Triggered ability that gives energy to nearby players and structures
// Echo - Targeted ability that lets Commander move a structure or drifter elsewhere on the map
// (even a hive or harvester!). 
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Structure.lua")
Script.Load("lua/InfestationMixin.lua")

class 'Shift' (Structure)

PrepareClassForMixin(Shift, InfestationMixin)

Shift.kMapName = "shift"

Shift.kModelName = PrecacheAsset("models/alien/shift/shift.model")

Shift.kEchoSoundEffect = PrecacheAsset("sound/ns2.fev/alien/structures/shift/echo")
Shift.kEnergizeSoundEffect = PrecacheAsset("sound/ns2.fev/alien/structures/shift/energize")
Shift.kEnergizeTargetSoundEffect = PrecacheAsset("sound/ns2.fev/alien/structures/shift/energize_player")
//Shift.kRecallSoundEffect = PrecacheAsset("sound/ns2.fev/alien/structures/shift/recall")

Shift.kEchoEffect = PrecacheAsset("cinematics/alien/shift/echo.cinematic")
Shift.kEnergizeEffect = PrecacheAsset("cinematics/alien/shift/energize.cinematic")
Shift.kEnergizeSmallTargetEffect = PrecacheAsset("cinematics/alien/shift/energize_small.cinematic")
Shift.kEnergizeLargeTargetEffect = PrecacheAsset("cinematics/alien/shift/energize_large.cinematic")

Shift.kEnergizeRange = 10
Shift.kEnergizeAmount = 4
Shift.kThinkInterval = .25
Shift.kEnergizeInterval = 2.0
Shift.kMaxTargets = 3

function EnergizeAbleTargetFilter(energizer)
	return 
		function(target, targetPoint) 
			if target.GetEnergy and target.GetMaxEnergy then
				return target:GetEnergy() < target:GetMaxEnergy() 
			else
				return false 
			end
		end
end

function Shift:OnInit()
    InitMixin(self, InfestationMixin)    
    Structure.OnInit(self) 

    if Server then 
        self.targetSelector = Server.targetCache:CreateSelector(
                self,
                Shift.kEnergizeRange,
                false, // we energize targets we don't have a los to
                TargetCache.kMmtl, // yea, we energize what the marines wants to hurt
                TargetCache.kAshtl,// marine static targets + infestations
                { EnergizeAbleTargetFilter() }, // filter away unhurt targets
                { IsaPrioritizer("Player") }) // and prioritize players
    end
end

function Shift:OnConstructionComplete()

    Structure.OnConstructionComplete(self)
    
    self:SetNextThink(Shift.kThinkInterval)
    
end

function Shift:GetIsAlienStructure()
    return true
end

function Shift:PerformEnergize()

    // acquire up to kMaxTargets energizeable targets inside range, players first
    local targets = self.targetSelector:AcquireTargets(Shift.kMaxTargets)
    local entsEnergized = 0
    
    for _,target in ipairs(targets) do
        local energizeAmount = self:TryEnergize(target, sqRange) 
        entsEnergized = entsEnergized + ((energizeAmount > 0 and 1) or 0)
    end

    if entsEnergized > 0 then   
        local energyCost = LookupTechData(kTechId.ShiftEnergize, kTechDataCostKey, 0)  
        self:AddEnergy(-energyCost)
    end
    
end

function Shift:TryEnergize(target, sqRange)

	local amountEnergized = 0
	
    if target.AddEnergy then 
    
    	target:AddEnergy(Shift.kEnergizeAmount)
    	amountEnergized = Shift.kEnergizeAmount    
    	local effectName = ConditionalValue(target:isa("Hive") or target:isa("Onos"), Shift.kEnergizeLargeTargetEffect, Shift.kEnergizeSmallTargetEffect)
	    Shared.CreateEffect(nil, effectName, target)
	    target:PlaySound(Shift.kEnergizeTargetSoundEffect)
	    
	end
	    
    return amountEnergized
end

function Shift:UpdateEnergize()

    local time = Shared.GetTime()
    
    if self.timeOfLastEnergize == nil or (time > self.timeOfLastEnergize + Shift.kEnergizeInterval) then
    
        // Only energize if it has the energy to do so
        local energyCost = LookupTechData(kTechId.ShiftEnergize, kTechDataCostKey, 0)
        
        if self:GetEnergy() >= energyCost then
    
            self:PerformEnergize()

            self.timeOfLastEnergize = time
            
        end
        
    end
    
end

// Look for nearby friendlies to energize
function Shift:OnThink()

    Structure.OnThink(self)
    
    if self:GetIsBuilt() then
    
        self:UpdateEnergize()
        
    end
        
    self:SetNextThink(Shift.kThinkInterval)
    
end

function Shift:GetTechButtons(techId)

    local techButtons = nil
    
    if(techId == kTechId.RootMenu) then 
    
        techButtons = { kTechId.UpgradesMenu, kTechId.ShiftRecall, kTechId.ShiftEnergize, kTechId.Attack,
        				kTechId.None, kTechId.None, kTechId.None, kTechId.None,
        				kTechId.AdrenalineTech, kTechId.StompTech, kTechId.None, kTechId.None }  // celerety / slow maybe?
        
        // Allow structure to be upgraded to mature version
        local upgradeIndex = 1
        
        if(self:GetTechId() == kTechId.Shift) then
            techButtons[upgradeIndex] = kTechId.UpgradeShift
        else
            techButtons[upgradeIndex] = kTechId.ShiftEcho
        end

    end
    
    return techButtons
    
end

function Shift:OnResearchComplete(structure, researchId)

    local success = Structure.OnResearchComplete(self, structure, researchId)
    
    if success then
    
        // Transform into mature shift
        if structure and (structure:GetId() == self:GetId()) and (researchId == kTechId.UpgradeShift) then
        
            success = self:Upgrade(kTechId.MatureShift)
            
        end
        
    end
    
    return success
    
end

function Shift:TriggerEcho(position)
    return false
end

function Shift:PerformActivation(techId, position, normal, commander)

    local success = false
    
    if techId == kTechId.ShiftEcho then
        success = self:TriggerEcho(position)
    //elseif techId == kTechId.ShiftEnergize then
    //    success = self:TriggerEnergize()
    end
    
    return success
    
end

if Server then
 function Shift:OnDestroy()
    self:ClearInfestation()
    Structure.OnDestroy(self)
 end
end

Shared.LinkClassToMap("Shift", Shift.kMapName, {})

class 'MatureShift' (Shift)

MatureShift.kMapName = "matureshift"

Shared.LinkClassToMap("MatureShift", MatureShift.kMapName, {})