//=============================================================================
//
// lua\Weapons\Alien\BuildBomb.lua
//
// Created by Charlie Cleveland (charlie@unknownworlds.com)
// Copyright (c) 2011, Unknown Worlds Entertainment, Inc.
//
// Bile bomb projectile
//
//=============================================================================
Script.Load("lua/Weapons/Projectile.lua")

class 'BuildBomb' (Projectile)

BuildBomb.kMapName            = "buildbomb"
BuildBomb.kModelName          = PrecacheAsset("models/alien/gorge/bilebomb.model") // TODO: change

// The max amount of time a BuildBomb can last for
BuildBomb.kLifetime = 5
// 200 inches in NS1 = 5 meters
BuildBomb.kSplashRadius = 5
BuildBomb.radius = .01
BuildBomb.mass = .01

function BuildBomb:OnCreate()

    Projectile.OnCreate(self)
    
    self:SetModel( BuildBomb.kModelName )    
    
    // Remember when we're created so we can fall off damage
    self.createTime = Shared.GetTime()
        
end

function BuildBomb:OnInit()

    Projectile.OnInit(self)
    
    if Server then
        self:AddTimedCallback(BuildBomb.TimeUp, BuildBomb.kLifetime)
        
    end

end

function BuildBomb:GetDeathIconIndex()
    return kDeathMessageIcon.SporeCloud
end

if (Server) then

    function BuildBomb:OnCollision(targetHit)

        // stick only to geometry, not to actors      
        if targetHit == nil then
	
	        self:TriggerEffects("bilebomb_hit")
            DestroyEntity(self)
                
        end
        
    end
    
    function BuildBomb:TimeUp(currentRate)
    
        DestroyEntity(self)
        // Cancel the callback.
        return false
    
    end
    
end

function BuildBomb:OnUpdate(deltaTime)

    Projectile.OnUpdate(self, deltaTime)
    
    if Server then
        self:SetOrientationFromVelocity()
    end
    
end

Shared.LinkClassToMap("BuildBomb", BuildBomb.kMapName, {})