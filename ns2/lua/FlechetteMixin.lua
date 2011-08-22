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

// additional damage
function FlechetteMixin:TakeDamageServer(damage, attacker, doer, point, direction)
	
    if self.isWeakened and (self:GetIsAlive() and GetGamerules():CanEntityDoDamageTo(attacker, self)) then

        // Get damage type from source    
        local damageType = kDamageType.Normal
        if doer ~= nil then 
            damageType = doer:GetDamageType()
        end

        // Take into account upgrades on attacker (armor1, weapons1, etc.)        
        damage = GetGamerules():GetUpgradedDamage(attacker, doer, damage, damageType)

        // highdamage cheat speeds things up for testing
        damage = damage * GetGamerules():GetDamageMultiplier()
        
        damage = damage * kFlechetteDamageScalar
        
        // Children can override to change damage according to player mode, damage type, etc.
        local armorUsed, healthUsed
        damage, armorUsed, healthUsed = self:ComputeDamage(attacker, damage, damageType)
        
        local oldHealth = self:GetHealth()
        
        self:SetArmor(self:GetArmor() - armorUsed)
        self:SetHealth(math.max(self:GetHealth() - healthUsed, 0))
        
        if self:GetHealth() == 0 then
            self:SetOverkillHealth(healthUsed - oldHealth)
        end
        
        if damage > 0 then
        
            self:OnTakeDamage(damage, attacker, doer, point)

            // Remember time we were last hurt for Swarm upgrade
            self:SetLastDamage(Shared.GetTime(), attacker)
            
            // Notify the doer they are giving out damage.
            local doerPlayer = doer
            if doer and doer:GetParent() and doer:GetParent():isa("Player") then
                doerPlayer = doer:GetParent()
            end
            if doerPlayer and doerPlayer:isa("Player") then
                // Not sent reliably as this notification is just an added bonus.
                // GetDeathIconIndex used to identify the attack type.
                Server.SendNetworkMessage(doerPlayer, "GiveDamageIndicator", BuildGiveDamageIndicatorMessage(damage, doer:GetDeathIconIndex(), self:isa("Player"), self:GetTeamNumber()), false)
            end
                
            if (oldHealth > 0 and self:GetHealth() == 0) then
            
                // Do this first to make sure death message is sent
                GetGamerules():OnKill(self, damage, attacker, doer, point, direction)
        
                self:OnKill(damage, attacker, doer, point, direction)
                
                self:ProcessFrenzy(attacker, self)

                self.justKilled = true
                
            end
            
        end
        
    end
    
    return (self.justKilled == true)
	
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

