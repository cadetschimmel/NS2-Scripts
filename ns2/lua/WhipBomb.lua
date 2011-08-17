//=============================================================================
//
// lua\Weapons\Alien\WhipBomb.lua
//
// Created by Andreas Urwalek (a_urwa@sbox.tugraz.at)
// Copyright (c) 2011, Unknown Worlds Entertainment, Inc.
//
// Bile bomb projectile
//
//=============================================================================
Script.Load("lua/Weapons/Projectile.lua")

class 'WhipBomb' (Projectile)

WhipBomb.kMapName            = "whipbomb"
WhipBomb.kModelName          = PrecacheAsset("models/alien/gorge/bilebomb.model")

// The max amount of time a WhipBomb can last for
WhipBomb.kLifetime = 0.7
// 200 inches in NS1 = 5 meters
WhipBomb.kSplashRadius = 5
WhipBomb.kDamage = 450

function WhipBomb:OnCreate()

    Projectile.OnCreate(self)
    
    self:SetModel( WhipBomb.kModelName )    
    
    // Remember when we're created so we can fall off damage
    self.createTime = Shared.GetTime()
        
end

function WhipBomb:OnInit()

    Projectile.OnInit(self)
    
    if Server then
        self:AddTimedCallback(WhipBomb.TimeUp, WhipBomb.kLifetime)
    end

end

function WhipBomb:GetDeathIconIndex()
    return kDeathMessageIcon.BileWhipBomb
end

if (Server) then

	function WhipBomb:OnCollision(targetHit)
	
		if targetHit and (targetHit:GetTeamNumber() == kTeam1Index) then
			self:TimeUp()
		else
			Projectile.OnCollision(self, targetHit)
		end
	
	end
    
    function WhipBomb:TimeUp(currentRate)
    
        // Don't hit owner - shooter
        if targetHit == nil or self:GetOwner() ~= targetHit then
        
            // Do splash damage to structures and ARCs
            local hitEntities = GetEntitiesForTeamWithinRange("Structure", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), WhipBomb.kSplashRadius)
            table.copy(GetEntitiesForTeamWithinRange("ARC", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), WhipBomb.kSplashRadius), hitEntities, true)
            
            // Do damage to every target in range
            RadiusDamage(hitEntities, self:GetOrigin(), WhipBomb.kSplashRadius, WhipBomb.kDamage, self, false)
            
            self:TriggerEffects("bilebomb_hit")

            DestroyEntity(self)
                
        end  
    
        DestroyEntity(self)
        return false
    
    end
    
end

function WhipBomb:OnUpdate(deltaTime)

    Projectile.OnUpdate(self, deltaTime)
    
    if Server then
        self:SetOrientationFromVelocity()
    end
    
end

Shared.LinkClassToMap("WhipBomb", WhipBomb.kMapName, {})