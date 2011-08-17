// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\FetchMixin.lua    
//    
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

Script.Load("lua/FunctionContracts.lua")

FetchMixin = { }
FetchMixin.type = "Fetch"

FetchMixin.fetcherPos = nil

FetchMixin.kBlinkInEffect = PrecacheAsset("cinematics/alien/fade/blink_in.cinematic")
FetchMixin.kBlinkOutEffect = PrecacheAsset("cinematics/alien/fade/blink_out.cinematic")
FetchMixin.kFetchDropoffTime = .7
FetchMixin.kElevateTime = 4
FetchMixin.kFetchCooldown = 4

function FetchMixin.__prepareclass(toClass)
     ASSERT(toClass.networkVars ~= nil, "FetchMixin expects the class to have network fields")
    
    local addNetworkFields =
    {        
        beingFetched          = "boolean",
        fetchStartTime		  = "float",
        fetchCoolDown		  = "float"
    }
    
    for k, v in pairs(addNetworkFields) do
        toClass.networkVars[k] = v
    end
end

function FetchMixin:__initmixin()    
	self.beingFetched = false
	self.fetchStartTime = 0
	self.fetcherPos = Vector(0, 0, 0)
	self.fetchCoolDown = 0
end

// override this to apply individual fetch speed, for example jetpack could alter fetch
function FetchMixin:GetFetchSpeed()
	return self:GetMaxSpeed()
end

function FetchMixin:PreUpdateMove(input, runningPrediction)

    PROFILE("FetchMixin:PreUpdateMove")

    if self:GetIsEthereal() or self.fadeLeap then
			local redirectDir = self:GetFetchDirection() * self:GetFetchSpeed()
        	redirectDir.y = redirectDir.y + 0.2 // always give small upwards-boost
        
        if (redirectDir:GetLength() ~= 0) then
            self:SetVelocity(redirectDir)
        end
    end
    
end

function FetchMixin:AdjustMove(input)

    PROFILE("FetchMixin:AdjustMove")

    Alien.AdjustMove(self, input)

    if self:GetIsEthereal() then
    
    	if (input.move:GetLength() == 0) then
        	input.move.y = 1
    	end
        
    end
    
    return input
    
end

function FetchMixin:GetGravityAllowed()
	return not self:GetIsEthereal()
end


function FetchMixin:GetMoveDirection(moveVelocity)
	if self:GetIsEthereal() then
		return self:GetFetchDirection() * self:GetFetchSpeed()
	else
		return Player.GetMoveDirection(self, moveVelocity)
	end
end

function FetchMixin:GetMaxBackwardSpeedScalar()
	if self.beingFetched then
		return 1
	else 
		return Player.GetMaxBackwardSpeedScalar(self)
	end
end


// override this to apply individual fetch direction, for example jetpack could alter fetch
function FetchMixin:GetFetchDirection()
	local fetchdirection = self.fetcherPos - self:GetOrigin()
	fetchdirection:Normalize()
	return fetchdirection
end

function FetchMixin:ClampSpeed(input, velocity)

    PROFILE("FetchMixin:ClampSpeed")

	if not self.beingFetched then
		return Player.ClampSpeed(self, input, velocity)
	end
	
	return velocity

end

function FetchMixin:CanGetFetched()
	if self.fetchCoolDown == 0 then
		return true
	else
		return false
	end
end

function FetchMixin:GetFetched(fetcher)
	
	if self:CanGetFetched() then
	
		self.fetchStartTime = Shared.GetTime()
		self.beingFetched = true
		self.fetcherPos = fetcher:GetOrigin()
		
		if not self.beingFetched then
			// initial fetch, play cinematics
			self:TriggerFetchInEffects(self)			
		end
		
		return true
	
	else
		return false
	end

end

function FetchMixin:UpdateFetch(updateEffectsInterval)

	if self.fetchCooldown then 
	
		local newcd = self.fetchCooldown - updateEffectsInterval
		if newcd < 0 then 
			self.fetchCooldown = 0
		else
			self.fetchCooldown = newcd
		end
		
	end
	
	if not self.beingFetched then return false end
	
	if Shared.GetTime() - self.fetchStartTime > FetchMixin.kFetchDropoffTime then
	
		self:FetchOut()
		
	end

end

function FetchMixin:FetchOut()

	self.beingFetched = false
	self:TriggerFetchOutEffects()	
	self.fetchCooldown = FetchMixin.kFetchCooldown
	self.fetchStartTime = 0
	self.fetcherPos = Vector(0, 0, 0)

end

function FetchMixin:GetEthereal()
	return self.beingFetched
end

function FetchMixin:TriggerFetchInEffects()

    if not Shared.GetIsRunningPrediction() then
        self:TriggerEffects("blink_in")
    end
    
    self.beingFetched = true
    self:SetGravityEnabled(false)
end

function FetchMixin:TriggerFetchOutEffects()

    // Play particle effect at vanishing position
    if not Shared.GetIsRunningPrediction() then
        self:TriggerEffects("blink_out")
        if Client and Client.GetLocalPlayer():GetId() == self:GetId() then
            self:TriggerEffects("blink_out_local")
        end
    end
    
    self.beingFetched = false    
    self:SetGravityEnabled(true)
    
end


