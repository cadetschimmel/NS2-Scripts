// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\LifeFormEgg.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Thing that aliens spawn out of.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Egg.lua")

class 'LifeFormEgg' (Egg)

LifeFormEgg.kMistEffect = PrecacheAsset("cinematics/alien/egg/mist_special.cinematic")

LifeFormEgg.kMapName = "lifeformegg"
LifeFormEgg.lastMistEffect = nil
LifeFormEgg.kMistIntervall = 13

function LifeFormEgg:GetAllowedToUse(player)
	return (LookupTechData(player:GetTechId(), kTechDataCostKey) < LookupTechData(self:GetTechIdToEvolve(), kTechDataCostKey))
end

function LifeFormEgg:OnUse(player, elapsedTime, useAttachPoint, usePoint)

	if Server then
	
		local teamNum = self:GetTeamNumber()
		local allowed = self:GetAllowedToUse(player)
	    if self:GetIsBuilt() and self:GetIsActive() and (teamNum == player:GetTeamNumber()) and allowed then
	
			
			if self:EvolvePlayer(player) then
				DestroyEntity(self)
			end
	        
	    end
    
    end
    
end

function LifeFormEgg:OnThink()

	Egg.OnThink(self)
	
	if Shared.GetTime() - self.lastMistEffect > LifeFormEgg.kMistIntervall then
		Shared.CreateEffect(nil, LifeFormEgg.kMistEffect, nil, self:GetCoords())
		self.lastMistEffect = Shared.GetTime()
	end

end

function LifeFormEgg:OnInit()
    InitMixin(self, InfestationMixin)
    
    Structure.OnInit(self)
    
    self.queuedPlayerId = nil
    self.lastMistEffect = Shared.GetTime()
    
    if Server then
    
        self:SetNextThink(Egg.kThinkInterval)
    
        self:PlaySound(Egg.kSpawnSoundName)
        
        Shared.CreateEffect(nil, LifeFormEgg.kMistEffect, nil, self:GetCoords())
        
    end
    
end

function LifeFormEgg:GetCanBeUsed(player)
    return true
end

// override this function
function LifeFormEgg:GetTechIdToEvolve()
end

function LifeFormEgg:EvolvePlayer(player)

	local techid = self:GetTechIdToEvolve()
	local success = false
	if techid ~= nil then
		//success = player:Evolve(techid)
		
		
        local newPlayer = player:Replace(Embryo.kMapName)
        //local position = self:GetOrigin()
        //position.y = position.y + Embryo.kEvolveSpawnOffset
        newPlayer:SetOrigin(self:GetOrigin())
        
        // Clear angles, in case we were wall-walking or doing some crazy alien thing
        local angles = Angles(self:GetAngles())
        angles.roll = 0.0
        angles.pitch = 0.0
        newPlayer:SetAngles(angles)
        
        // Eliminate velocity so that we don't slide or jump as an egg
        newPlayer:SetVelocity(Vector(0, 0, 0))
        
        newPlayer:DropToFloor()
        
        newPlayer:SetGestationData( { techid }, { kTechId.Skulk } , 1, 1)
        newPlayer.evolveTime = newPlayer:GetEvolutionTime() / 2
        
        success = true
		
	end
	
	return success

end

Shared.LinkClassToMap("LifeFormEgg", LifeFormEgg.kMapName, {})