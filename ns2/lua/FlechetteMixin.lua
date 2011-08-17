// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\FlechetteMixin.lua    
//    
//    Created by:  Andreas Urwalek (a_urwa@sbox.tugraz.at)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

FlechetteMixin = { }
FlechetteMixin.type = "Flechette"

FlechetteMixin.kWeakenedTime = 5

function FlechetteMixin.__prepareclass(toClass)
     ASSERT(toClass.networkVars ~= nil, "FlechetteMixin expects the class to have network fields")
    
    local addNetworkFields =
    {        
        isWeakened          = "boolean",
        timeOfHit        	= "float"          
    }
    
    for k, v in pairs(addNetworkFields) do
        toClass.networkVars[k] = v
    end
end

function FlechetteMixin:__initmixin()
    self.isWeakened       	= false
    self.timeOfHit   		= 0
end

function FlechetteMixin:TriggerFlechetteEffect()
    
	self.isWeakened = true
    self.timeOfHit = Shared.GetTime()
    
end

function FlechetteMixin:ClearFlechetteEffect()

    self.isWeakened       	= false
    self.timeOfHit   		= 0
    
end

function FlechetteMixin:GetIsWeakened () 
    return self.isWeakened
end

function FlechetteMixin:OnTakeDamage(damage, attacker, doer, point)

	if self.isWeakened then
		damage = damage * kFlechetteDamageScalar
	end
	
	if self:isa("Player") then
		Player.OnTakeDamage(self, damage, attacker, doer, point)
	elseif self:isa("Structure") then
		Structure.OnTakeDamage(self, damage, attacker, doer, point)
	else
		LiveScriptActor.OnTakeDamage(self, damage, attacker, doer, point)
	end
	
end


function FlechetteMixin:UpdateFlechette(updateEffectsInterval)    
    
    if not self:GetIsWeakened() then
    	return
	end
	
	local effectDuration = Shared.GetTime() - self.timeOfHit
    
    if effectDuration > FlechetteMixin.kWeakenedTime then
    	self:ClearFlechetteEffect()
	end
	
	self:TriggerEffects("flechette_on_target")	
    
end

