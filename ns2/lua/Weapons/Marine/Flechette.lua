//=============================================================================
//
// lua\Weapons\Marine\Flechette.lua
//
// Created by Andreas Urwalek (a_urwa@sbox.tugraz.at)
// Copyright (c) 2011, Unknown Worlds Entertainment, Inc.
//
// Flechette projectile
//
//=============================================================================
Script.Load("lua/Weapons/Projectile.lua")

class 'Flechette' (Projectile)

Flechette.kMapName            = "flechette"
Flechette.kModelName          = PrecacheAsset("models/marine/shotgun/flechette.model")

// The max amount of time a Flechette can last for
Flechette.kLifetime = .16
Flechette.kSpeed = 55
Flechette.kMinSpeed = Flechette.kSpeed * .65
Flechette.kNumFlechettesPerShot = kFlechettesPerShot
Flechette.kDamagePerFlechette = kFlechetteDamage
Flechette.kConeDegrees = Math.Radians(40)
Flechette.kRange = kFlechetteSpreadRange

function Flechette:OnCreate()

    Projectile.OnCreate(self)
    
    self:SetModel( Flechette.kModelName )    

end

function Flechette:OnInit()

    Projectile.OnInit(self)
    
    if Server then
        self:AddTimedCallback(Flechette.TimeUp, Flechette.kLifetime)
    end

end

function Flechette:GetDeathIconIndex()
    return kDeathMessageIcon.SporeCloud
end

if (Server) then

    function Flechette:OnCollision(targetHit)

        // if we hit geometry, check the speed and detonate if its too low
        if targetHit == nil and self:GetVelocity():GetLength() < Flechette.kMinSpeed then
        
            self:ShootFlechettes()

            DestroyEntity(self)
                
        elseif targetHit and self:GetOwner() ~= targetHit then
    		
            self:ShootFlechettes()

            DestroyEntity(self)
        
        end
        
    end
    
    function Flechette:TimeUp(currentRate)
    
    	self:ShootFlechettes()
        DestroyEntity(self)
        // Cancel the callback.
        return false
    
    end
    
    function Flechette:ShootFlechettes()
    	
	    local viewAngles = self:GetAngles()
	    local viewCoords = viewAngles:GetCoords()
	    local startPoint = self:GetOrigin() - viewCoords.zAxis *.5
    	
    	local player = self:GetOwner()
    	local spreadAngle = nil
    	local randomAngle = nil
    	local randomRadius = nil
    	local fireDirection = nil
    	local endPoint = nil
    	local trace = nil
    	local target = nil
    	
    	self:TriggerEffects("flechette_detonate", {effecthostcoords = BuildCoordsFromDirection(viewCoords.zAxis, startPoint), false})
    	
	    for bullet = 1, Flechette.kNumFlechettesPerShot do
	    
	        // Calculate spread for each shot, in case they differ
	        spreadAngle = Flechette.kConeDegrees
	        
	        randomAngle  = NetworkRandom() * math.pi * 2
	        randomRadius = NetworkRandom() * NetworkRandom() * math.tan(spreadAngle)
	        
	        fireDirection = viewCoords.zAxis + (viewCoords.xAxis * math.cos(randomAngle) + viewCoords.yAxis * math.sin(randomAngle)) * randomRadius
	        fireDirection:Normalize()
	       
	        endPoint = startPoint + fireDirection * Flechette.kRange
	        
	        trace = Shared.TraceRay(startPoint, endPoint, PhysicsMask.Bullets, filter)
	        
	        if Server then
	            Server.dbgTracer:TraceBullet(player, startPoint, trace)  
	        end
	        
	        if (trace.fraction < 1) then
	        
	            local blockedByUmbra = GetBlockedByUmbra(trace.entity)
	            
	            // Create local tracer effect, and send to other players
	            if (NetworkRandom(string.format("%s:FireBullet():TracerCheck", self:GetClassName())) < .3) then
	            
	                local tracerStart = startPoint + player:GetViewAngles():GetCoords().zAxis
	                local tracerVelocity = GetNormalizedVector(trace.endPoint - tracerStart) * 45
	                TriggerTracer(player, tracerStart, trace.endPoint, tracerVelocity)
	                
	            end
	            
	            //DebugLine(startPoint, trace.endPoint, 15, ConditionalValue(trace.entity, 1, 0), ConditionalValue(trace.entity, 0, 1), ConditionalValue(trace.entity, 0, 0), 1)
	            
	            if not blockedByUmbra then
	            
	            	
	            	local impactPoint = trace.endPoint - GetNormalizedVector(endPoint - startPoint) * Weapon.kHitEffectOffset
                	local surfaceName = trace.surface
                	
                	local tableParams = {}
                	
                	
                	
                	self:TriggerHitEffect(trace.entity, impactPoint, surfaceName, false)
	            	
	                if trace.entity then
	                
	                	target = trace.entity
	                    local direction = (trace.endPoint - startPoint):GetUnit()
				        if target:isa("LiveScriptActor") and GetGamerules():CanEntityDoDamageTo(player, target) then
				        
				            local damage = Flechette.kDamagePerFlechette
				            
				            if target.GetZoneDamage then
				                damage = target:GetZoneDamage(damage, endPoint)
				            end
				    
				            target:TakeDamage(damage, player, self, endPoint, direction)
				            
				            if target.TriggerFlechetteEffect then
				            	target:TriggerFlechetteEffect()
			            	end
				            
				        end
				    
				        player:SetTimeTargetHit()
	
	                end
	                
	            end
	                        
	            // TODO: Account for this
	            // Play ricochet sound for player locally for feedback, but not necessarily for every bullet
	            //local effectFrequency = 2
	            
	            if not blockedByUmbra then // and ((bullet % effectFrequency) == 0) then
	            
	                local impactPoint = trace.endPoint - GetNormalizedVector(endPoint - startPoint) * Weapon.kHitEffectOffset
	                local surfaceName = trace.surface
	                TriggerHitEffects(doer, trace.entity, impactPoint, surfaceName, false)
	                
	                // If we are far away from our target, trigger a private sound so we can hear we hit something
	                if surfaceName and string.len(surfaceName) > 0 and (trace.endPoint - player:GetOrigin()):GetLength() > 5 then
	                    
	                    player:TriggerEffects("hit_effect_local", {surface = surfaceName})
	                    
	                end
	                
	            end
	            
	        end
	
	    end
    
    end
    
end

function Flechette:TriggerHitEffect(target, origin, surface)

    local tableParams = {}

    if target and target.GetClassName then
        tableParams[kEffectFilterClassName] = target:GetClassName()
        tableParams[kEffectFilterIsAlien] = target:GetTeamType() == kAlienTeamType
    end
    
    tableParams[kEffectSurface] = ConditionalValue(type(surface) == "string" and surface ~= "", surface, "metal")
    
    if origin then
        tableParams[kEffectHostCoords] = Coords.GetTranslation(origin)
    else
        tableParams[kEffectHostCoords] = Coords.GetIdentity()
    end
    
	tableParams[kEffectFilterDoerName] = "ClipWeapon"

    GetEffectManager():TriggerEffects("hit_effect", tableParams)
  
end

function Flechette:OnUpdate(deltaTime)

    Projectile.OnUpdate(self, deltaTime)
    
    if Server then
        self:SetOrientationFromVelocity()
    end
    
end

Shared.LinkClassToMap("Flechette", Flechette.kMapName, {})