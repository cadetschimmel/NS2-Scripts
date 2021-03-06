// ======= Copyright � 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Whip_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Whip.kBombSpeed = 20

function Whip:OnConstructionComplete()

    Structure.OnConstructionComplete(self)
    
    self:SetNextThink(1.0)
    
end

function Whip:AcquireTarget()

    local finalTarget = nil
    
    if(self.timeOfLastTargetAcquisition == nil or (Shared.GetTime() > self.timeOfLastTargetAcquisition + Whip.kTargetCheckTime)) then
    
        finalTarget = self.targetSelector:AcquireTarget();

        if finalTarget ~= nil then
    
            self:GiveOrder(kTechId.Attack, finalTarget:GetId(), nil)
        
        else
        
            self:ClearOrders()
            
        end
        
        self.timeOfLastTargetAcquisition = Shared.GetTime()

    end
    
end


function Whip:AttackTarget()

    local target = self:GetTarget()
    
    if(target ~= nil) then
    
        self:TriggerUncloak()
    
        self:TriggerEffects("whip_attack")
   
        // When attack animation finishes, attack again
        self.attackAnimation = self:GetAnimation()
    
        self.timeOfLastStrikeStart = Shared.GetTime()
        
        self.timeOfNextStrikeHit = Shared.GetTime() + self:AdjustFuryFireDelay(.5)
                
    end

end

function Whip:GetClosestAttackPoint(target)

    ASSERT(target)
    local attackPoint = target:GetEngagementPoint()
    local inRange = false

    local toAttack = target:GetEngagementPoint() - self:GetModelOrigin()
    local length = toAttack:GetLength()
    
    if length <= Whip.kRange then
        inRange = true
    else
        toAttack:Normalize()    
        attackPoint = self:GetModelOrigin() + toAttack * Whip.kRange
    end
    
    return attackPoint, inRange
    
end

function Whip:StrikeTarget()

    local target = self:GetTarget()
    if(target ~= nil) then

        // Hit main target
        self:DamageTarget(target)
        
        // Try to hit other targets close by
        local closestAttackPoint = self:GetClosestAttackPoint(target)
        local nearbyEnts = self.targetSelector:AcquireTargets(1000, Whip.kAreaEffectRadius, closestAttackPoint)
        for index, ent in ipairs(nearbyEnts) do
        
            if ent ~= target then
            
                local direction = ent:GetModelOrigin() - closestAttackPoint
                direction:Normalize()
                
                ent:TakeDamage(Whip.kDamage, self, self, closestAttackPoint, direction)
                
            end
            
        end
        
    end
    
    self.timeOfNextStrikeHit = nil
    
end

function Whip:DamageTarget(target)

    // Do damage to target if still within range
    local attackPoint, inRange = self:GetClosestAttackPoint(target)
    if inRange then
    
        local direction = attackPoint - self:GetOrigin()
        direction:Normalize()
        
        target:TakeDamage(Whip.kDamage, self, self, attackPoint, direction)
        
    end
    
end

function Whip:SetDesiredMode(mode)
    if self.desiredMode ~= mode then
        self.desiredMode = mode
    end
end

function Whip:UpdateMode(deltaTime)

    if self.desiredMode ~= self.mode then
    
        if (self.desiredMode == Whip.kMode.UnrootedStationary) and (self.mode == Whip.kMode.Rooted) then
        
            self:SetMode(Whip.kMode.Unrooting)
            // when we move, our static targets becomes invalid. As we can't attack until we are rooted again,
            // we don't need to do anything further
            self.targetSelector:InvalidateStaticCache()
            
        elseif self.desiredMode == Whip.kMode.Moving and (self.mode == Whip.kMode.UnrootedStationary) then
        
            self:SetMode(Whip.kMode.StartMoving)
            
        elseif (self.desiredMode == Whip.kMode.Rooted) and (self.mode == Whip.kMode.UnrootedStationary or self.mode == Whip.kMode.StartMoving or self.mode == Whip.kMode.Moving or self.mode == Whip.kMode.EndMoving) then
        
            self:SetMode(Whip.kMode.Rooting)
           
        elseif (self.desiredMode == Whip.kMode.Bombarding) and (self.mode == Whip.kMode.Rooted) then
        
        	self:SetMode(Whip.kMode.Bombarding)
        
        end
        
    end
    
end

function Whip:OnDestroyCurrentOrder(currentOrder)

    // Order was stopped or canceled
    if(currentOrder:GetType() == kTechId.Move and self.mode == Whip.kMode.UnrootedStationary) then
        self:SetDesiredMode(Whip.kMode.UnrootedStationary)        
    end
    
end

function Whip:OnOrderComplete(currentOrder)

    if(currentOrder:GetType() == kTechId.Move) then
        self:SetDesiredMode(Whip.kMode.UnrootedStationary)        
    end

end

function Whip:UpdateOrders(deltaTime)

    // If we're moving
    local currentOrder = self:GetCurrentOrder()
    if currentOrder and currentOrder:GetType() == kTechId.Move then
    
        self:SetDesiredMode(Whip.kMode.Moving)
        
        if self.mode == Whip.kMode.Moving then

            // Repeatedly trigger movement effect 
            self:TriggerEffects("whip_moving")
    
    		local moveSpeed = Whip.kMoveSpeed
    		
    		if self:GetGameEffectMask(kGameEffect.OnInfestation) then
    			moveSpeed = moveSpeed * 3
			end
    		
            self:MoveToTarget(PhysicsMask.AIMovement, currentOrder:GetLocation(), moveSpeed, deltaTime)
            if(self:IsTargetReached(currentOrder:GetLocation(), kEpsilon)) then
                self:CompletedCurrentOrder()
            end
            
        end
        
    end

    // Attack on our own
    if self.mode == Whip.kMode.Rooted then
            
        self:UpdateAttack(deltaTime)
            
    end
    
end

function Whip:UpdateAttack(deltaTime)

    // Check if alive because map-placed structures don't die when killed
    if self:GetIsBuilt() and self:GetIsAlive() then
        
        local target = self:GetTarget()
        local targetValid = self.targetSelector:ValidateTarget(target)
        if targetValid then

            // Check to see if it's time to fire again
            local time = Shared.GetTime()
                    
            if not self.timeOfLastAttack or (time > (self.timeOfLastAttack + Whip.kScanThinkInterval)) then
            
                local delay = self:AdjustFuryFireDelay(Whip.kROF)
                if(self.timeOfLastStrikeStart == nil or (time > self.timeOfLastStrikeStart + delay)) then
                
                    self:AttackTarget()
                    
                end
                
                // Update our attackYaw to aim at our current target
                local attackDir = GetNormalizedVector(self:GetClosestAttackPoint(target) - self:GetModelOrigin())
                
                // This is negative because of how model is set up (spins clockwise)
                local attackYawRadians = -math.atan2(attackDir.x, attackDir.z)
                
                // Factor in the orientation of the whip.
                attackYawRadians = attackYawRadians + self:GetAngles().yaw
                
                self.attackYaw = DegreesTo360(math.deg(attackYawRadians))
                
                if self.attackYaw < 0 then
                    self.attackYaw = self.attackYaw + 360
                end
                
                self.timeOfLastAttack = time
                
            end
            
        end
        
        if self.timeOfNextStrikeHit ~= nil then
        
            if Shared.GetTime() > self.timeOfNextStrikeHit then
                self:StrikeTarget()
            end
            
        elseif not targetValid then
        
            self:AcquireTarget()
            
        end
        
    end
    
end

function Whip:SetMode(mode)

    if self.mode ~= mode then

        self.modeAnimation = ""
        
        local triggerEffectName = "whip_" .. string.lower(EnumToString(Whip.kMode, mode))
        self:TriggerEffects(triggerEffectName)

        self.mode = mode
        self.modeAnimation = self:GetAnimation()
        
    end
    
end

function Whip:UpdateRootState()

    // Unroot whips if infestation recedes
    if (self.mode == Whip.kMode.Rooted) and not self:GetGameEffectMask(kGameEffect.OnInfestation) then
        self:SetDesiredMode(Whip.kMode.UnrootedStationary)
    end
    
end

function Whip:OnUpdate(deltaTime)

    PROFILE("Whip:OnUpdate")

    Structure.OnUpdate(self, deltaTime)
    
    self:UpdateRootState()
    
    // Handle sentry state changes
    self:UpdateMode(deltaTime)
    
    self:UpdateOrders(deltaTime)

end

function Whip:OnAnimationComplete(animName)

    Structure.OnAnimationComplete(self, animName)
    
    if animName == self.attackAnimation then
    
        local target = self:GetTarget()
        
        if not self.targetSelector:ValidateTarget(target) then
        
            self:CompletedCurrentOrder()
            
            self:OnIdle()

        end
        
    end

    // Handle whip movement transitions        
    if self.modeAnimation == animName then
        
        if self.mode == Whip.kMode.Unrooting then
        
            self:SetMode(Whip.kMode.UnrootedStationary)        
    
        elseif self.mode == Whip.kMode.Rooting then
        
            self:SetMode(Whip.kMode.Rooted)

        elseif self.mode == Whip.kMode.StartMoving then
        
            self:SetMode(Whip.kMode.Moving)

        elseif self.mode == Whip.kMode.EndMoving then
        
            self:SetMode(Whip.kMode.UnrootedStationary)
            
        elseif self.mode == Whip.kMode.Bombarding then
	
			self:SetMode(Whip.kMode.Rooted)
			self:SetDesiredMode(Whip.kMode.Rooted)
			
		end
        
    end
    
end

function Whip:GetCanIdle()
    local target = self:GetTarget()
    return not target and (self.mode == Whip.kMode.Rooted or (self.mode == Whip.kMode.UnrootedStationary and not self:GetCurrentOrder()))
end

function Whip:GetIsFuryActive()
    return self:GetIsAlive() and self:GetIsBuilt() and (self.timeOfLastFury ~= nil) and (Shared.GetTime() < (self.timeOfLastFury + Whip.kFuryDuration))
end

function Whip:OnResearchComplete(structure, researchId)

    local success = Structure.OnResearchComplete(self, structure, researchId)

    if success then
    
        // Transform into mature whip
        if structure and (structure:GetId() == self:GetId()) and (researchId == kTechId.UpgradeWhip) then
        
            success = self:Upgrade(kTechId.MatureWhip)
            
        end
        
    end
    
    return success    
    
end

function Whip:TriggerFury()

    self:TriggerEffects("whip_trigger_fury")
    
    // Increase damage for players, whips (including self!), etc. in range
    self.timeOfLastFury = Shared.GetTime()
    
    return true
    
end

function Whip:TargetBombard(targetPos)
	
	if self.mode == Whip.kMode.Rooted then
        self:TriggerUncloak()
    	self.bombTarget = targetPos + Vector(0, 0.7, 0)
		local bombStart = self:GetOrigin() + Vector(0, 1.7, 0)
		self.bombTarget.y = bombStart.y
		local direction = self.bombTarget - bombStart
		direction:Normalize()
		bombStart = bombStart + direction * 0.6
		
		SetAnglesFromVector(self, direction)
		
		self:SetDesiredMode(Whip.kMode.Bombarding)
		self.bombardAnimation = self:GetAnimation()
		
	    local bomb = CreateEntity(WhipBomb.kMapName, bombStart, self:GetTeamNumber())
	    SetAnglesFromVector(bomb, direction)
	    
	    bomb:SetOwner(self:GetOwner())
	
	    local startVelocity = direction * Whip.kBombSpeed
	    bomb:SetVelocity(startVelocity)
	
	    return true
    end
    
    return false
	
end

function Whip:PerformActivation(techId, position, normal, commander)

    local success = false
    
    if techId == kTechId.WhipFury then
        success = self:TriggerFury()
    elseif techId == kTechId.WhipBombard then
        success = self:TargetBombard(position)
    elseif techId == kTechId.WhipUnroot then
        self:SetDesiredMode(Whip.kMode.UnrootedStationary)
    elseif techId == kTechId.WhipRoot then
        self:SetDesiredMode(Whip.kMode.Rooted)
    end
    
    return success
    
end

function Whip:OnDestroy()
    Structure.OnDestroy(self)    
    self:ClearInfestation()    
end