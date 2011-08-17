// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\FireMixin.lua    
//    
//    Created by:   Andrew Spiering (andrew@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

FireMixin = { }
FireMixin.type = "Fire"

function FireMixin.__prepareclass(toClass)
     ASSERT(toClass.networkVars ~= nil, "EnergyMixin expects the class to have network fields")
    
    local addNetworkFields =
    {        
        stopChance                      = "float",
        timeLastUpdateStopChance        = "float",
		numStacks						= "float",
		timeLastStackAdded				= "float",
		timeBurnInit                    = "float"
    }
    
    for k, v in pairs(addNetworkFields) do
        toClass.networkVars[k] = v
    end
end

function FireMixin:__initmixin()
    self.fireAttackerId             = Entity.invalidId
    self.fireDoerId                 = Entity.invalidId
    
    self.stopChance                 = 0
    self.timeLastUpdateStopChance   = 0
	self.numStacks					= 0
	self.timeLastStackAdded			= 0
	self.timeBurnInit               = 0
end

function FireMixin:OverrideSetFire(attacker, doer)
    if self.OnOverrideSetFire then
        self:OnOverrideSetFire(attacker, doer)    
    end
end

function FireMixin:SetOnFire(attacker, doer)
    if not  self:GetCanBeSetOnFire() then
        return
    end
    
    self:SetGameEffectMask(kGameEffect.OnFire, true)
    
    self.fireAttackerId = attacker:GetId()
    self.fireDoerId = doer:GetId()
    
    
    
    if self.timeLastStackAdded == 0 or Shared.GetTime() - self.timeLastStackAdded > kFlamethrowerStackRate then
        self.timeLastStackAdded = Shared.GetTime()
        if self.numStacks < kFlamethrowerMaxStacks then
            self.numStacks = self.numStacks + 1;
        end
    end
    
    local additional_damage = 0
    
    if(self.numStacks > 0) then
        additional_damage = kFlamethrowerDamage * self.numStacks
        self:TakeDamage(additional_damage, Shared.GetEntity(self.fireAttackerId), Shared.GetEntity(self.fireDoerId)) //additional fire damage per stack
    end

    self.timeBurnInit = Shared.GetTime()
    
    self:OverrideSetFire(attacker, doer)
end

function FireMixin:ClearFire()
    self:SetGameEffectMask(kGameEffect.OnFire, false)
    
    self.fireAttackerId             = Entity.invalidId
    self.fireDoerId                 = Entity.invalidId
    
    self.stopChance                 = 0
    self.timeLastUpdateStopChance   = nil
	self.timeLastStackAdded			= 0
	self.numStacks					= 0
	self.timeBurnInit               = 0
	
end

function FireMixin:GetIsOnFire () 
    return self:GetGameEffectMask(kGameEffect.OnFire)
end

function FireMixin:_GetStopChance ()
    if self.timeLastUpdateStopChance == nil or (Shared.GetTime() > self.timeLastUpdateStopChance + 10) then
        self.stopChance = self.stopChance + kStopFireProbability        
        self.timeLastUpdateStopChance = Shared.GetTime()
    end
    return self.stopChance
end

function FireMixin:GetCanBeSetOnFire ()
  if self.OnOverrideCanSetFire then
    return self:OnOverrideCanSetFire(attacker, doer)
  else
    return true
  end
  
end

function FireMixin:UpdateFire(updateEffectsInterval)    

	//Shared.Message("fire mixin update")

    if not self:GetIsOnFire() then
        return
    end
    
    // Do damage over time
    local dot = kBurnDamagePerSecond * updateEffectsInterval * self.numStacks
	
	// hack, don't know why those ID's become invalid
	if self.fireAttackerId and self.fireDoerId then
		self:TakeDamage(dot, Shared.GetEntity(self.fireAttackerId), Shared.GetEntity(self.fireDoerId))
	else
		self:ClearFire()
	end
    // See if we put ourselves out
    if Shared.GetTime() - self.timeBurnInit > kFlamethrowerBurnDuration then
        self:ClearFire()
    end
    
    //local stopFireChance = updateEffectsInterval * self:_GetStopChance()
    //if (NetworkRandom() < kFlamethrowerDuration) then
    //    self:ClearFire()
    //end
end