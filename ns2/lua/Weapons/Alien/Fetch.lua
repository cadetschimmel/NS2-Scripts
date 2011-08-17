// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\Fetch.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")

class 'Fetch' (Ability)

Fetch.kMapName = "fetch"


if Client then
    Script.Load("lua/Weapons/Alien/Fetch_Client.lua")
end

//Fetch.kFetchSound = PrecacheAsset("sound/ns2.fev/alien/fade/Fetch")

//Fetch.kFetchInEffect = PrecacheAsset("cinematics/alien/fade/Fetch_in.cinematic")
//Fetch.kFetchOutEffect = PrecacheAsset("cinematics/alien/fade/Fetch_out.cinematic")
//Fetch.kFetchViewEffect = PrecacheAsset("cinematics/alien/fade/Fetch_view.cinematic")

// Fetch
Fetch.kSecondaryAttackDelay = 0
Fetch.kFetchEnergyCost = kFetchEnergyCost
Fetch.kFetchMaxDistance = 20
Fetch.kMaxFetchTime = 0.8
Fetch.kFetchIntervall = 0.2

Fetch.kOrientationScanRadius = 2.5
Fetch.kStartEtherealForce = 15
// The amount of time that must pass before the player can enter the ether again.
Fetch.kMinEnterEtherealTime = 0.5
Fetch.lastHitCheck = 0

Fetch.networkVars =
{
    // True when we're moving quickly "through the ether"
    ethereal           = "boolean",
    
    etherealStartTime = "float",
    
    // True when Fetch started and button not yet released
    FetchButtonDown    = "boolean",
}

kFetchType = enum( {'Unknown', 'OnObject', 'InAir', 'Attack'} )


function Fetch:GetIsBlinking()
    return self:GetEthereal() or ((self.blinkEndTime ~= nil) and (Shared.GetTime() < (self.blinkEndTime + kEpsilon)))
end

function Fetch:OnInit()

    Ability.OnInit(self)
    self.showingGhost = false
    self.ethereal = false
    self.FetchButtonDown = false
    self.lastHitCheck = 0
    
end

function Fetch:OnHolster(player)

    Ability.OnHolster(self, player)
    
    if self.showingGhost then
    
        self.showingGhost = false
        
        if Client then
            self:DestroyGhost()
        end
        
    end
    
end

function Fetch:GetHasSecondary(player)
	return player.GetHasThreeHives and player:GetHasThreeHives()
end

function Fetch:GetSecondaryEnergyCost(player)
    //return ConditionalValue(self.showingGhost, Fetch.kFetchEnergyCost, 0)
    return self:ApplyEnergyCostModifier(kFetchInitialEnergyCost, player)
end

function Fetch:GetSecondaryAttackDelay()
    return Fetch.kSecondaryAttackDelay
end

function Fetch:GetSecondaryAttackRequiresPress()
    return true
end

function Fetch:TriggerFetchOutEffects(player)

    // Play particle effect at vanishing position
    if not Shared.GetIsRunningPrediction() then
        self:TriggerEffects("blink_out", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
        if Client and Client.GetLocalPlayer():GetId() == player:GetId() then
            self:TriggerEffects("blink_out_local", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
        end
    end
    
    //player:SetAnimAndMode(Fade.kBlinkhOutAnim, kPlayerMode.FadeBlinkOut)

end

function Fetch:TriggerFetchInEffects(player)

    if not Shared.GetIsRunningPrediction() then
        self:TriggerEffects("blink_in", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
    end
    
    //player:SetAnimAndMode(Fade.kBlinkInAnim, kPlayerMode.FadeBlinkIn)
    
end

// Cannot attack while Fetching.
function Fetch:GetPrimaryAttackAllowed(player)
    return not self:GetIsFetching() and Ability.GetPrimaryAttackAllowed(self, player)
end

function Fetch:CanUseWeapon(player)
	return player.GetHasThreeHives and player:GetHasThreeHives()
end

function Fetch:GetIsFetching()
	return self.ethereal
end

function Fetch:PerformPrimaryAttack(player)

    self.showingGhost = false
    return true
end

function Fetch:CheckAndHitTarget(player)

	local hitTarget = nil
    local viewAngles = player:GetViewAngles()
    local viewCoords = viewAngles:GetCoords()
    
    local startPoint = player:GetEyePos()
    
    local filter = EntityFilterTwo(player, self)
    if Client then
        DbgTracer.MarkClientFire(player, startPoint)
    end

	local endPoint = startPoint + viewCoords.zAxis * Fetch.kFetchMaxDistance
	
    local trace = Shared.TraceRay(startPoint, endPoint, PhysicsMask.Bullets, filter)
    //self:TriggerEffects("armory_health", {effecthostcoords = Coords.GetTranslation(trace.endPoint) })
    
    if Server then
        Server.dbgTracer:TraceBullet(player, startPoint, trace)  
    end

	hitTarget = trace.entity
	

	if hitTarget and HasMixin(hitTarget, "Fetch") and hitTarget:GetTeamNumber() ~= player:GetTeamNumber() then // only able to fetch enemy and "fetch-able" entities
		
		hitTarget:GetFetched(player)
		
		if Server then
			self:GetParent():SetTimeTargetHit()
		end
	
	end	


end

function Fetch:OnSecondaryAttack(player)

    if not self.etherealStartTime or Shared.GetTime() - self.etherealStartTime >= Fetch.kMinEnterEtherealTime then
    
        // Enter "ether" fast movement mode, but don't keep going ethereal when button still held down after
        // running out of energy
        if not self.FetchButtonDown then
            self:SetEthereal(player, true)
            self.FetchButtonDown = true
            player.isethereal = true
        end
        
    end
    
    Ability.OnSecondaryAttack(self, player)
    
end

function Fetch:OnSecondaryAttackEnd(player)

    if self.ethereal then
        self:SetEthereal(player, false)
        player.isethereal = false
    end
    
    Ability.OnSecondaryAttackEnd(self, player)
    
    self.FetchButtonDown = false
    
end

function Fetch:GetEthereal()
    return self.ethereal
end

function Fetch:SetEthereal(player, state)

	//if not (player.GetHasTwoHives and player:GetHasTwoHives()) then
	//	return false
	//end

    // Enter or leave invulnerable invisible fast-moving mode
    if self.ethereal ~= state then
    

        if state then
        
            // dont activate ethereal mode if we dont have the required energy
            if player:GetEnergy() < self:ApplyEnergyCostModifier(kFetchInitialEnergyCost, player) then 
            	return false 
            end
            
            self.etherealStartTime = Shared.GetTime()
            self:TriggerFetchOutEffects(player)
        else
            self:TriggerFetchInEffects(player)
        end
        
        self.ethereal = state
        
        // Set player visibility state
        //player:SetIsVisible(not self.ethereal)
        //player:SetGravityEnabled(not self.ethereal)
        
        player:SetEthereal(state)
        
        // Give player initial velocity in direction we're pressing, or forward if 
        if self.ethereal then
        
        	//make fade stop initially
        	player:SetVelocity( Vector(0,0,0) )
        
        	// drain activation cost
        	player:DeductAbilityEnergy(kFetchInitialEnergyCost)

        else
        
            // Increase current velocity when coming out of Fetch
            player:SetVelocity( player:GetVelocity() * 3 )
            
        end
        
    end
    
end

function Fetch:OnSetInactive(player)
	if self.ethereal then
		self:OnSecondaryAttackEnd(player)
	end
end

function Fetch:IsOverTime()
	if Shared.GetTime() - self.etherealStartTime > Fetch.kMaxFetchTime then
		return true
	else
		return false
	end
end

function Fetch:OnProcessMove(player, input)

    if self:GetIsActive() and self.ethereal then
    
        // Decrease energy while in Fetch mode
        player:DeductAbilityEnergy(input.time * kFetchEnergyCost)
        
        if (Shared.GetTime() - self.lastHitCheck) > Fetch.kFetchIntervall then
        	self.lastHitCheck = Shared.GetTime()
        	self:CheckAndHitTarget(player)
        end
        
        //player:SetVelocity( Vector(0,0,0) )
        
    end
    
    // End Fetch mode if out of energy
    if player:isa("Alien") and ( (player:GetEnergy() == 0) or self:IsOverTime() ) and self.ethereal then
        self:SetEthereal(player, false)
        player.isethereal = self:GetEthereal()
	end
        
    Ability.OnProcessMove(self, player, input)
    
end

Shared.LinkClassToMap("Fetch", Fetch.kMapName, Fetch.networkVars )
