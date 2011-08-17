// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\Spikes.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/Spike.lua")
Script.Load("lua/Weapons/Alien/Umbra.lua")

class 'Spikes' (Umbra)

Spikes.kMapName = "spikes"

Spikes.kModelName = PrecacheAsset("models/alien/lerk/lerk_view_spike.model")
Spikes.kImpact = PrecacheAsset("cinematics/alien/lerk/spike_impact.cinematic")

// Lerk spikes (view model)
Spikes.kPlayerAnimAttack = "spikes"

Spikes.kDelay = kSpikeFireDelay
Spikes.kSnipeDelay = kSpikesAltFireDelay
Spikes.kZoomDelay = .3
Spikes.kZoomedFov = 45
Spikes.kZoomedSensScalar = 0.25
Spikes.kSpikeEnergy = kSpikeEnergyCost
Spikes.kSnipeEnergy = kSpikesAltEnergyCost
Spikes.kSnipeDamage = kSpikesAltDamage
Spikes.kSpread2Degrees = Vector( 0.01745, 0.01745, 0.01745 )
Spikes.kRange = 20
Spikes.zoomFaktorScalar = 1

local networkVars =
{
    zoomedIn            = "boolean",
    fireLeftNext        = "boolean",
    timeZoomedIn        = "float",
    sporePoseParam      = "float"
}

function Spikes:OnCreate()

    Umbra.OnCreate(self)

    self.zoomedIn = false
    self.fireLeftNext = true
    self.timeZoomedIn = 0
    self.sporePoseParam = 0
    
end

function Spikes:OnDestroy()

    // Make sure the player doesn't get stuck with scaled sensitivity.
    // Only change this if clientZoomedIn is true (we don't want other
    // Lerks dying causing the local client's Lerk to lose their zoomed
    // in sensitivity).
    if Client and self.clientZoomedIn then
        Client.SetMouseSensitivityScalar(1)
    end
    
    Ability.OnDestroy(self)
    
end

function Spikes:GetEnergyCost(player)
    return self:ApplyEnergyCostModifier(ConditionalValue(self.zoomedIn, Spikes.kSnipeEnergy, Spikes.kSpikeEnergy), player)
end


function Spikes:GetIconOffsetY(secondary)
    return ConditionalValue(not self.zoomedIn, kAbilityOffset.Spikes, kAbilityOffset.Sniper)
end

function Spikes:OnHolster(player)
    self:SetZoomState(player, false)
    Ability.OnHolster(self, player)
end

function Spikes:GetPrimaryAttackDelay()
    return ConditionalValue(self.zoomedIn, Spikes.kSnipeDelay, Spikes.kDelay)
end

function Spikes:GetDeathIconIndex()
    return ConditionalValue(self.zoomedIn, kDeathMessageIcon.SpikesAlt, kDeathMessageIcon.Spikes)
end

function Spikes:GetHUDSlot()
    return 1
end

function Spikes:PerformPrimaryAttack(player)

    // Alternate view model animation to fire left then right
    self.fireLeftNext = not self.fireLeftNext
	self:FireSpikeProjectile(player)        

    player:SetActivityEnd(player:AdjustFuryFireDelay(self:GetPrimaryAttackDelay()))
    
    return true
end

function Spikes:GetSpread()
    return Math.Radians(10)
end

function Spikes:GetInaccuracyScalar()
    return 1
end

function Spikes:GetMaxRange()
    //TODO: take zoom factor into consideration
    return Spikes.kRange
end

// Play ricochet sound/effect every %d bullets
function Spikes:GetRicochetEffectFrequency()
    return 1
end

// To create a tracer 20% of the time, return .2. 0 disables tracers.
function Spikes:GetTracerPercentage()
    return 0
end

function Spikes:FireSpikeProjectile(player)

    // On server, create projectile
    if(Server) then
    
        // trace using view coords, but back off the given distance to make sure we don't miss any walls
        local backOffDist = 0.5
        // fire from one meter in front of the lerk, to avoid the lerk flying into his own projectils (the projectile
        // will only start moving on the NEXT tick, and the lerk might be updated before the projectile. considering that
        // a lerk has a topspeed of 5-10m/sec, and a slow server update might be 100ms, you are looking at a lerk movement
        // per tick of 0.5-1m ... 1m should be good enough.
        local firePointOffs = 1.0
        // seems to be a bug in trace; make sure any entity indicate as hit are inside this range. 
        local maxTraceLen = backOffDist + firePointOffs
        
        local viewCoords = player:GetViewAngles():GetCoords()
        local alternate = (self.fireLeftNext and -.1) or .1
        local firePoint = player:GetEyePos() + viewCoords.zAxis * firePointOffs - viewCoords.yAxis * .1 + viewCoords.xAxis * alternate
        
        // To avoid the lerk butting his face against a wall and shooting blindly, trace and move back the firepoint
        // if hitting a wall
        local startTracePoint = player:GetEyePos() - viewCoords.zAxis * backOffDist + viewCoords.xAxis * alternate
        local trace = Shared.TraceRay(startTracePoint, firePoint, PhysicsMask.Bullets, EntityFilterOne(player))
        if trace.fraction ~= 1 and (trace.entity == nil or (trace.entity:GetOrigin() - startTracePoint):GetLength() < maxTraceLen) then
            local offset = math.max(backOffDist, trace.fraction * maxTraceLen)
            firePoint = startTracePoint + (viewCoords.zAxis * offset)
        end
        
        local spike = CreateEntity(Spike.kMapName, firePoint, player:GetTeamNumber())
        
        // Add slight randomness to start direction. Gaussian distribution.
        local x = (NetworkRandom() - .5) + (NetworkRandom() - .5)
        local y = (NetworkRandom() - .5) + (NetworkRandom() - .5)
        
        local spread = Spikes.kSpread2Degrees 
        local direction = viewCoords.zAxis + x * spread.x * viewCoords.xAxis + y * spread.y * viewCoords.yAxis

        spike:SetVelocity(direction * 40)
        
        spike:SetOrientationFromVelocity()
        
        spike:SetGravityEnabled(false)
        
        // Set spike parent to player so we don't collide with ourselves and so we
        // can attribute a kill to us
        spike:SetOwner(player)
        
        spike:SetIsVisible(true)
        
        spike:SetUpdates(true)
        
        spike:SetDeathIconIndex(self:GetDeathIconIndex())
                
    end
    
    local hitTarget = false
    local viewAngles = player:GetViewAngles()
    local viewCoords = viewAngles:GetCoords()
    local range = self:GetMaxRange()
    local startPoint = player:GetEyePos()
        
    // Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
       
    if Client then
        DbgTracer.MarkClientFire(player, startPoint)
    end
   


    // Calculate spread for each shot, in case they differ
    local spreadAngle = self:GetSpread() * self:GetInaccuracyScalar() / 2
    
    local randomAngle  = NetworkRandom() * math.pi * 2
    local randomRadius = NetworkRandom() * NetworkRandom() * math.tan(spreadAngle)
    
    local fireDirection = viewCoords.zAxis + (viewCoords.xAxis * math.cos(randomAngle) + viewCoords.yAxis * math.sin(randomAngle)) * randomRadius
    fireDirection:Normalize()
   
    local endPoint = startPoint + fireDirection * range
    
    local trace = Shared.TraceRay(startPoint, endPoint, PhysicsMask.Bullets, filter)
    
    if Server then
        Server.dbgTracer:TraceBullet(player, startPoint, trace)  
    end
    
    if (trace.fraction < 1) then
        
        // Create local tracer effect, and send to other players
        if (NetworkRandom(string.format("%s:FireBullet():TracerCheck", self:GetClassName())) < self:GetTracerPercentage()) then
        
            local tracerStart = startPoint + player:GetViewAngles():GetCoords().zAxis
            local tracerVelocity = GetNormalizedVector(trace.endPoint - tracerStart) * 45
            TriggerTracer(player, tracerStart, trace.endPoint, tracerVelocity)
            
        end
        
        //DebugLine(startPoint, trace.endPoint, 15, ConditionalValue(trace.entity, 1, 0), ConditionalValue(trace.entity, 0, 1), ConditionalValue(trace.entity, 0, 0), 1)

        
        if trace.entity then
        
            local direction = (trace.endPoint - startPoint):GetUnit()
            self:ApplyBulletGameplayEffects(player, trace.entity, trace.endPoint, direction)
            hitTarget = true

        end
                    
        // TODO: Account for this
        // Play ricochet sound for player locally for feedback, but not necessarily for every bullet
        local effectFrequency = self:GetRicochetEffectFrequency()
        
        
            local impactPoint = trace.endPoint - GetNormalizedVector(endPoint - startPoint) * Weapon.kHitEffectOffset
            local surfaceName = trace.surface
            TriggerHitEffects(self, trace.entity, impactPoint, surfaceName, false)
            
            // If we are far away from our target, trigger a private sound so we can hear we hit something
            if surfaceName and string.len(surfaceName) > 0 and (trace.endPoint - player:GetOrigin()):GetLength() > 5 then
                
                player:TriggerEffects("hit_effect_local", {surface = surfaceName})
                
            end
        
        // Update accuracy
        //self.accuracy = math.max(math.min(1, self.accuracy - self:GetAccuracyLossPerShot(player)), 0)

    end
    
    return hitTarget 

end

function Spikes:ApplyBulletGameplayEffects(player, target, endPoint, direction)

    if(Server) then
    
        if target:isa("LiveScriptActor") and GetGamerules():CanEntityDoDamageTo(player, target) then
        
            target:TakeDamage(self:GetSpikeDamage(player, target, endPoint), player, self, endPoint, direction)
            
        end
    
        self:GetParent():SetTimeTargetHit()
        
    end
    
end

function Spikes:GetSpikeDamage(player, target, endPoint)
    // TODO: actual damage calculation depending on zoom factor
    local distance = (endPoint - player:GetOrigin()):GetLength()
    
    local maxRange = kSpikeMaxRange * self:GetZoomFactor()
    local minRange = kSpikeMinRange * self:GetZoomFactor()
    
    local damage = kSpikeMaxDamage
    
    if distance > maxRange then
    
        local distanceFactor = (distance - maxRange) / (minRange - maxRange)
        local dmgScalar = 1 - Clamp(distanceFactor, 0, 1) 
        damage = kSpikeMinDamage + dmgScalar * (kSpikeMaxDamage - kSpikeMinDamage)
        
    end
    return damage 
end

function Spikes:PerformZoomedAttack(player)

    // Trace line to attack
    local viewCoords = player:GetViewAngles():GetCoords()    
    local startPoint = player:GetEyePos()
    local endPoint = startPoint + viewCoords.zAxis * 1000

    // Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
        
    local trace = Shared.TraceRay(startPoint, endPoint, PhysicsMask.AllButPCs, filter)
    
    local hasPiercing = player:GetHasUpgrade(kTechId.Piercing)
    
    if Server and trace.fraction < 1 and trace.entity ~= nil and trace.entity:isa("LiveScriptActor")then
    
        local direction = GetNormalizedVector(endPoint - startPoint)
        
        local damageScalar = ConditionalValue(hasPiercing, kPiercingDamageScalar, 1)
        trace.entity:TakeDamage(Spikes.kSnipeDamage * damageScalar, player, self, endPoint, direction)
        
        if hasPiercing then
            trace.entity:TriggerEffects("spikes_snipe_hit")
        end
        
    else
        self:TriggerEffects("spikes_snipe_miss", {kEffectHostCoords = Coords.GetTranslation(trace.endPoint)})
    end
    
    player:SetActivityEnd(player:AdjustFuryFireDelay(Spikes.kSnipeDelay))
    
    
    
end

function Spikes:SetZoomState(player, zoomedIn)

    if zoomedIn ~= self.zoomedIn then
    
        self.zoomedIn = zoomedIn
        self.timeZoomedIn = Shared.GetTime()
        
        if Client and player == Client.GetLocalPlayer() then
        
            // Keep track of the zoomed state here just for the client.
            self.clientZoomedIn = self.zoomedIn
            // Lower mouse sensitivity when zoomed in, only affects the local player.
            Client.SetMouseSensitivityScalar(ConditionalValue(self.zoomedIn, Spikes.kZoomedSensScalar, 1))
            
        end
    end
    
end

function Spikes:UpdateViewModelPoseParameters(viewModel, input)

    Ability.UpdateViewModelPoseParameters(self, viewModel, input)
    
    self.sporePoseParam = Clamp(Slerp(self.sporePoseParam, 0, (1 / kLerkWeaponSwitchTime) * input.time), 0, 1)
    
    viewModel:SetPoseParam("spore", self.sporePoseParam)
    
end

function Spikes:OnUpdate(deltaTime)

    Ability.OnUpdate(self, deltaTime)
    
    // Update fov smoothly but quickly
    local timePassed = Shared.GetTime() - self.timeZoomedIn
    local timeScalar = Clamp(timePassed/.12, 0, 1)
    local transitionScalar = Clamp(math.sin( timeScalar * math.pi / 2 ), 0, 1)
    local player = self:GetParent()

    if player then
    
        if self.zoomedIn then
            player:SetFov( Lerk.kFov + transitionScalar * (Spikes.kZoomedFov - Lerk.kFov))
        else
            player:SetFov( Spikes.kZoomedFov + transitionScalar * (Lerk.kFov - Spikes.kZoomedFov))
        end
        
    end
    
end

function Spikes:GetZoomFactor()
    return Clamp(self.timeZoomedIn * Spikes.zoomFaktorScalar, 1, kSpikesMaxZoomFaktor * Spikes.zoomFaktorScalar )
end    

function Spikes:GetEffectParams(tableParams)

    Ability.GetEffectParams(self, tableParams)
    
    local player = self:GetParent()
    
    // Player may be nil when the spikes are first created.
    if (player ~= nil) then
        tableParams[kEffectFilterFrom] = player:GetHasUpgrade(kTechId.Piercing)
    end    
    
    tableParams[kEffectFilterLeft] = not self.fireLeftNext
    
end

Shared.LinkClassToMap("Spikes", Spikes.kMapName, networkVars )
