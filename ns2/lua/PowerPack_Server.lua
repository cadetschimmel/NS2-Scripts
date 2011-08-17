// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\PowerPack_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// A buildable, potentially portable, marine power source.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Structure.lua")

function PowerPack:OnConstructionComplete()

    Structure.OnConstructionComplete(self)
    
    self:UpdateNearbyPowerState()

end

// Needed for recycling 
function PowerPack:OnDestroy()

    Structure.OnDestroy(self)
    
    self:UpdateNearbyPowerState()
    
end

function PowerPack:SafeDestroy()
    self:SetIsAlive(false)
    self:SetNextThink(-1)
    
    Structure.SafeDestroy(self)
end

function PowerPack:OnThink()

	Structure.OnThink(self)

	if self.mode == PowerPack.kMode.Default then
		if self:GetEnergy() > PowerPack.kEnergyPerShock and self:GetIsEnemyNearby() then

			self:TriggerEffects("power_pack_charge")
			self:ChargeUp()
			
		else
			self:SetNextThink(PowerPack.kElectrifiedThinkTime)
		end
		
	elseif self.mode == PowerPack.kMode.Charging then
	
		self:TriggerEffects("power_pack_shock")
		self:ReleaseShock()
		
	elseif self.mode == PowerPack.kMode.Shocking then
	
		// TODO: set think time animation time of shock
		self:SetNextThink(PowerPack.kChargeTimeTime*2)
		self.mode = PowerPack.kMode.Default
	
	end


end

function PowerPack:GetIsEnemyNearby()

    local enemyUnits = GetEntitiesForTeam("LiveScriptActor", GetEnemyTeamNumber(self:GetTeamNumber()))
    
    for index, enemy in ipairs(enemyUnits) do                
    
        if enemy:GetIsVisible() and not enemy:isa("Commander") and enemy:GetIsAlive() and (enemy:isa("Player") or enemy:isa("Structure")) then
            local dist = (enemy:GetOrigin() - self:GetOrigin()):GetLength()
            if dist < PowerPack.kShockRange then
        
                return true
                
            end
            
        end
        
    end

    return false
    
end

// TODO: change icon
function PowerPack:GetDeathIconIndex()
    return kDeathMessageIcon.SporeCloud
end

function PowerPack:GetDamageType()
	return kDamageType.Structural
end

function PowerPack:ReleaseShock()

	self.mode = PowerPack.kMode.Shocking

    // When checking if shock can reach something, only walls and door entities will block the damage.
    local filterNonDoors = EntityFilterAllButIsa("Door")
    local enemies = GetEntitiesForTeam("LiveScriptActor", GetEnemyTeamNumber(self:GetTeamNumber()))
    local direction = nil
    for index, entity in ipairs(enemies) do
    
    	direction = entity:GetOrigin() - self:GetOrigin()
        if direction:GetLength() < PowerPack.kShockRange then

            if not entity:isa("Commander") and (entity:isa("Player") or entity:isa("Structure"))  then

                // Make sure powernode can "see" target
                local targetPosition = entity:GetOrigin() + Vector(0, entity:GetExtents().y, 0)
                local trace = Shared.TraceRay(self:GetOrigin(), targetPosition, PhysicsMask.Bullets, filterNonDoors)
                if trace.fraction == 1.0 or trace.entity == entity then
                
                    entity:TakeDamage(PowerPack.kDamage, self, self, direction)
                    
                end
                
            end
            
        end
        
    end
    
	self:SetEnergy(self:GetEnergy() - PowerPack.kEnergyPerShock)

end

function PowerPack:ChargeUp()

	self.mode = PowerPack.kMode.Charging
	
	self:SetNextThink(PowerPack.kChargeTimeTime)
	//TODO: play charge sound, cinematic

end

function PowerPack:UpdateNearbyPowerState()

    // Trigger event to update power for nearby structures
    local structures = GetEntitiesForTeamWithinXZRange("Structure", self:GetTeamNumber(), self:GetOrigin(), PowerPack.kRange)

    for index, structure in ipairs(structures) do
    
        structure:UpdatePoweredState()
        
    end

end

function PowerPack:OnResearchComplete(structure, researchId)

    local success = Structure.OnResearchComplete(self, structure, researchId)

    if success then

        if structure and (structure:GetId() == self:GetId()) and (researchId == kTechId.PowerPackElectrify) then
        
            success = self:Upgrade(kTechId.ElectrifiedPowerPack)
            self.mode = ElectrifiedPowerPack.kMode.Default
            self:SetEnergy(kElectrifiedPowerInitialEnergy)
            self:SetNextThink(ElectrifiedPowerPack.kElectrifiedThinkTime)            
            
        end
        
    end
    
    return success    
    
end
