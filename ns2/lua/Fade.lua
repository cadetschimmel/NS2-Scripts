// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Fade.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Utility.lua")
Script.Load("lua/Weapons/Alien/SwipeBlink.lua")
Script.Load("lua/Weapons/Alien/StabBlink.lua")
Script.Load("lua/Weapons/Alien/SwipeFetch.lua")
Script.Load("lua/Alien.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")

class 'Fade' (Alien)
Fade.kMapName = "fade"
Fade.kModelName = PrecacheAsset("models/alien/fade/fade.model")
Fade.kViewModelName = PrecacheAsset("models/alien/fade/fade_view.model")

Fade.kSpawnSoundName = PrecacheAsset("sound/ns2.fev/alien/fade/spawn") 
Fade.kTauntSound = PrecacheAsset("sound/ns2.fev/alien/fade/taunt")
Fade.kJumpSound = PrecacheAsset("sound/ns2.fev/alien/fade/jump")

Fade.kAnimSwipeTable = { {1, "swipe"}, {1, "swipe2"}, {1, "swipe3"}, {1, "swipe4"}, {1, "swipe5"}, {1, "swipe6"} }
Fade.kAnimBlinkTable = { {1, "blink"} }
Fade.kAnimStabTable = { {1, "stab"}, {1, "stab2"} }
Fade.kBlinkInAnim = "blinkin"
Fade.kBlinkOutAnim = "blinkout"

Fade.kViewOffsetHeight = 1.2
Fade.XZExtents = .4
Fade.YExtents = .8
Fade.kHealth = kFadeHealth
Fade.kArmor = kFadeArmor
Fade.kFov = 90
Fade.kMass = 158 // ~350 pounds
Fade.kJumpHeight = 1
Fade.kMaxSpeed = 6.5
Fade.kStabSpeed = .5
Fade.kEtherealSpeed = 20
Fade.kFetchSpeed = 5
Fade.kAcceleration = 52
Fade.kEtherealAcceleration = 80

Fade.kFadeLeapSpeed = 35
Fade.kStartFadeLeapForce = 55
Fade.kFadeLeapIntervall = 1.3
Fade.kFadeLeapDuration = 0.09

if(Server) then
    Script.Load("lua/Fade_Server.lua")
end

Fade.kBlinkState = enum( {'Normal', 'BlinkOut', 'BlinkIn'} )

Fade.networkVars =
{
    isethereal    = "boolean",
    lastFadeLeap	 = "float",
    fadeLeap		 = "boolean"
}

PrepareClassForMixin(Fade, GroundMoveMixin)
PrepareClassForMixin(Fade, CameraHolderMixin)

function Fade:GetTauntSound()
    return Fade.kTauntSound
end

if Client then

	function Fade:GetSpecialCooldown()
	
		return Shared.GetTime() - (self.lastFadeLeap + Fade.kFadeLeapIntervall)
	
	end
	
end

if Client then
function Fade:IsSameDimension()
	
	if  Client.GetLocalPlayer():GetIsEthereal() or Client.GetLocalPlayer():isa("Fade") then 
		return true
	end
	
	// only visible for same dimension
	return not self.isethereal

end
end

function Fade:OnInit()

    InitMixin(self, GroundMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, CameraHolderMixin, { kFov = Fade.kFov })
    
    Alien.OnInit(self)
    
    self.blinkState = Fade.kBlinkState.Normal
    self.isethereal = false
    self.desiredMove = Vector()
    self.lastFadeLeap = 0
    self.fadeLeap = false
    
end

function Fade:PreCopyPlayerDataFrom()

    // Reset visibility and gravity in case we were in ether mode.
    self:SetIsVisible(true)
    self:SetGravityEnabled(true)

end

function Fade:GetBaseArmor()
    return Fade.kArmor
end

function Fade:GetArmorFullyUpgradedAmount()
    return kFadeArmorFullyUpgradedAmount
end

function Fade:GetMaxViewOffsetHeight()
    return Fade.kViewOffsetHeight
end

function Fade:GetViewModelName()
    return Fade.kViewModelName
end

function Fade:HandleButtons(input)

    Alien.HandleButtons(self, input)
    
    //self.isethereal = (bit.band(input.commands, Move.MovementModifier) ~= 0)
    self:UpdateFadeLeaping(input)
    
end

function Fade:GetAcceleration()
	if self:GetIsEthereal() then
		return Fade.kEtherealAcceleration
	elseif self.fadeLeap then
		return Fade.kStartFadeLeapForce
	else
		return Fade.kAcceleration
	end
end

/*
function Fade:PreUpdateMove(input, runningPrediction)

    PROFILE("Fade:PreUpdateMove")

    if self:GetIsEthereal() or self.fadeLeap then
        local move = GetNormalizedVector( input.move )
        local viewCoords = self:GetViewAngles():GetCoords()            
        local redirectDir = viewCoords:TransformVector( move )
        
        redirectDir.y = redirectDir.y * 0.4      
        
        if (move:GetLength() ~= 0) then
            self:SetVelocity(redirectDir * self:GetAcceleration())
        end
    end
    
end
*/

function Fade:GetFrictionForce(input, velocity)
    if self:GetIsEthereal() then
        if (input.move:GetLength() == 0) then
            return Vector(-velocity.x, -velocity.y, -velocity.z) * 4
        end
    end
    return Alien.GetFrictionForce(self, input, velocity)
end

function Fade:Getisethereal()
    return self.isethereal
end

function Fade:ConstrainMoveVelocity(moveVelocity)
    
    if not self:GetIsEthereal() or not self.fadeLeap then
        Alien.ConstrainMoveVelocity(self, moveVelocity)
    end
    
end

function Fade:GetDesiredFadeLeaping(input)

    local desiredFadeLeaping = (bit.band(input.commands, Move.MovementModifier) ~= 0) and (not self.crouching) and self:GetVelocity():GetLengthXZ() > 1
    
    // Not allowed to start leaping while in the air
    if (not self:GetIsOnGround() and desiredFadeLeaping and self.mode == kPlayerMode.Default) then
        desiredFadeLeaping = false
    end
    
    return desiredFadeLeaping

end

function Fade:UpdateFadeLeaping(input)

	local desiredFadeLeaping = self:GetDesiredFadeLeaping(input)
	
	if desiredFadeLeaping and ((Shared.GetTime() - self.lastFadeLeap) > self.kFadeLeapIntervall)  then
		
		// For modifying velocity
		self.fadeLeap = true
	
	end
	

end

function Fade:ClampSpeed(input, velocity)

	PROFILE("Fade:ClampSpeed")

	if self:GetIsFetching() then
	
	    // Only clamp XZ speed so it feels better
	    local moveSpeedXZ = velocity:GetLengthXZ()        
	    local maxSpeed = self:GetMaxSpeed()
	    
	    // Players moving backwards can't go full speed    
	    if input.move.z > 0 then
	    
	        maxSpeed = 2
	        
	    end
	    
	    if (moveSpeedXZ > maxSpeed) then
	    
	        local velocityY = velocity.y
	        velocity:Scale( maxSpeed / moveSpeedXZ )
	        velocity.y = velocityY
	        
	    end 
	    
	    return velocity
	
	else
		return Alien.ClampSpeed(self, input, velocity)
	end

end


function Fade:ModifyVelocity(input, velocity)   
	
		
    if not self:GetIsEthereal() then        
	
		Alien.ModifyVelocity(self, input, velocity)

    	// Give a little push forward
    	if self.fadeLeap then
    		
	        local pushDirection = GetNormalizedVector(self:GetVelocity())
	        local impulse = pushDirection * Fade.kStartFadeLeapForce
	
	        velocity.x = velocity.x + impulse.x
	        velocity.y = velocity.y + impulse.y
	        velocity.z = velocity.z + impulse.z
	        
	        self.fadeLeap = false
	        self.lastFadeLeap = Shared.GetTime()
	        self:SetVelocity(velocity)
	        
	        // Copied particle effect from blink
		    if not Shared.GetIsRunningPrediction() then
		        self:TriggerEffects("fade_leap", {effecthostcoords = Coords.GetTranslation(self:GetEyePos() - Vector(0, 1, 0))})
		        if Client and Client.GetLocalPlayer():GetId() == player:GetId() then
		            self:TriggerEffects("fade_leap_local", {effecthostcoords = Coords.GetTranslation(self:GetEyePos())})
		        end
		        
		        //self:SetAnimAndMode(Fade.kBlinkOutAnim, kPlayerMode.FadeBlinkOut)
		    end

        end
	elseif self:GetIsBlinking() then		
		
		local move = GetNormalizedVector( input.move )		
		
		if (move:GetLength() ~= 0) then 			
			local viewCoords = self:GetViewAngles():GetCoords()					
			local redirectDir = viewCoords:TransformVector( move )
			local newVelocity = velocity + redirectDir * input.time * Fade.kEtherealAcceleration
			
			velocity.x = newVelocity.x	
			velocity.y = redirectDir.y * velocity:GetLength()
			velocity.z = newVelocity.z		
		end		
    end  
    
end

function Fade:GetIsOnGround()
    if self:GetIsEthereal() or self.fadeLeap then
        return false
    end
    return Alien.GetIsOnGround(self)
end

function Fade:GetAcceleration()
    if self:GetIsEthereal() then
        return Fade.kEtherealAcceleration
    end
    return Alien.GetAcceleration(self)
end

function Fade:GetIsEthereal()

	return self:GetIsBlinking() or self:GetIsFetching()
    //local weapon = self:GetActiveWeapon()
    //return (weapon and weapon.GetEthereal and weapon:GetEthereal())
    
end

function Fade:GetIsFetching()

    local weapon = self:GetActiveWeapon()
    return (weapon ~= nil and weapon:isa("Fetch") and weapon:GetEthereal())
    
end

function Fade:GetMaxSpeed()

    local success, speed = self:GetCamouflageMaxSpeed(self.movementModiferState)
    if success then
        return speed
    end

    // Ethereal Fades move very quickly
    if self:GetIsBlinking() then
        return Fade.kEtherealSpeed
    end
    
    if self:GetIsFadeLeaping() then
    	return Fade.kFadeLeapSpeed
    end
    
    if self:GetIsFetching() then
        return Fade.kFetchSpeed
    end

    local baseSpeed = Fade.kMaxSpeed    
    if self.mode == kPlayerMode.FadeStab then
        baseSpeed = Fade.kStabSpeed        
    end

    // Take into account crouching
    return ( 1 - self:GetCrouchAmount() * Player.kCrouchSpeedScalar ) * baseSpeed * self:GetSlowSpeedModifier()

end

function Fade:GetIsFadeLeaping()
	if (Shared.GetTime() - self.lastFadeLeap) < (self.kFadeLeapDuration) then
		return true
	else
		return false
	end
end

function Fade:GetMass()
    return Fade.kMass 
end

function Fade:GetJumpHeight()
    return Fade.kJumpHeight
end

function Fade:GetHasSpecialAbility()
    return false
end

// For special ability, return an array of energy, energy cost, tex x offset, tex y offset, 
// visibility (boolean), command name
function Fade:GetSpecialAbilityInterfaceData()

    local vis = self:GetInactiveVisible() or (self:GetEnergy() ~= Ability.kMaxEnergy)

    // Show minimum energy assuming we ran out of energy while blinking (kBlinkEnergyCost * Blink.kMinEnterEtherealTime)
    return { self:GetEnergy()/Ability.kMaxEnergy, kBlinkEnergyCost * Blink.kMinEnterEtherealTime/Ability.kMaxEnergy, 0, kAbilityOffset.SwipeBlink, vis, GetDescForMove(Move.MovementModifier) }
    
end

function Fade:GetIsBlinking()

    local isBlinking = false
    
    local weapon = self:GetActiveWeapon()
    
    if weapon ~= nil and weapon:isa("Blink") then
        isBlinking = weapon:GetIsBlinking()
    end
    
    return isBlinking
    
end

function Fade:SetAnimAndMode(animName, mode)

    Alien.SetAnimAndMode(self, animName, mode)
    
    if mode == kPlayerMode.FadeStab then
    
        local velocity = self:GetVelocity()
        velocity:Scale(.1)
        self:SetVelocity(velocity)

        self.modeTime = Shared.GetTime() + StabBlink.kStabDuration 
        
    end
    
end

function Fade:AdjustMove(input)

    PROFILE("Fade:AdjustMove")

    Alien.AdjustMove(self, input)

    if self.mode == kPlayerMode.FadeStab then
    
        // Don't move much
        input.move:Scale(0.00001)
        
    end
    
    // Remember our desired move for blink
    VectorCopy(input.move, self.desiredMove)
    
    return input

end

function Fade:UpdateHelp()

    if self:AddTooltipOnce("You are now a Fade! Left-click to swipe and right-click to blink.") then
        return true
    elseif self:AddTooltipOnce("Use stab (weapon #2) to inflict mega damage.") then
        return true
    end
    
    return false
    
end

function Fade:GetBlinkTime()
    return math.max(self:GetAnimationLength(Fade.kBlinkInAnim), self:GetAnimationLength(Fade.kBlinkOutAnim))
end

Shared.LinkClassToMap( "Fade", Fade.kMapName, Fade.networkVars )
