// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\SporeBomb.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// projectile part of sporemine attack
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Projectile.lua")

class 'SporeBomb' (Projectile)

SporeBomb.kMapName            = "sporebomb"
SporeBomb.kModelName          = PrecacheAsset("models/alien/gorge/bilebomb.model") // TODO: change

// The max amount of time a SporeBomb can last for
SporeBomb.kLifetime = 5
// 200 inches in NS1 = 5 meters
SporeBomb.kSplashRadius = 5
SporeBomb.radius = .01
SporeBomb.mass = .01

function SporeBomb:OnCreate()

    Projectile.OnCreate(self)
    
    self:SetModel( SporeBomb.kModelName )    
    
    // Remember when we're created so we can fall off damage
    self.createTime = Shared.GetTime()
        
end

function SporeBomb:OnInit()

    Projectile.OnInit(self)
    
    if Server then
        self:AddTimedCallback(SporeBomb.TimeUp, SporeBomb.kLifetime)
        
    end

end

function SporeBomb:GetDeathIconIndex()
    return kDeathMessageIcon.SporeCloud
end

if (Server) then

    function SporeBomb:OnCollision(targetHit)

        // stick only to geometry, not to actors      
        if targetHit == nil then
        
	        local spawnPoint = self:GetOrigin()
	        local sporemine = CreateEntity(SporeMine.kMapName, spawnPoint, self:GetOwner():GetTeamNumber())
	        sporemine:SetOwner(self:GetOwner())
	
	        self:TriggerEffects("bilebomb_hit")
            DestroyEntity(self)
                
        end
        
    end
    
    function SporeBomb:TimeUp(currentRate)
    
        DestroyEntity(self)
        // Cancel the callback.
        return false
    
    end
    
end

function SporeBomb:OnUpdate(deltaTime)

    Projectile.OnUpdate(self, deltaTime)
    
    if Server then
        self:SetOrientationFromVelocity()
    end
    
end

Shared.LinkClassToMap("SporeBomb", SporeBomb.kMapName, {})