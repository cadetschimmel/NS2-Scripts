//=============================================================================
//
// lua\Weapons\Marine\Flame.lua
//
// Created by Andreas Urwalek (a_urwa@sbox.tugraz.at)
// Copyright (c) 2011, Unknown Worlds Entertainment, Inc.
//
//=============================================================================
Script.Load("lua/Weapons/Projectile.lua")

class 'Flame' (Projectile)

Flame.kMapName            = "flame"
//Flame.kImpactCinematic 	  = PrecacheAsset("cinematics/marine/flamethrower/impact.cinematic")
Flame.kFlameSmallCinematic 	  = PrecacheAsset("cinematics/flame_small.cinematic")
Flame.kFlameMiddleCinematic 	  = PrecacheAsset("cinematics/flame_middle.cinematic")
Flame.kFlameNormalCinematic 	  = PrecacheAsset("cinematics/flame_normal.cinematic")
Flame.kFlameEndCinematic 	  = PrecacheAsset("cinematics/flame_end.cinematic")

Flame.kDamageRadius       = kFlameRadius
Flame.kLifetime           = .30
Flame.kThinkTime 		  = .05
Flame.kDamage             = kFlamethrowerDamage / (Flame.kLifetime / Flame.kThinkTime)
Flame.kFullDamage		  = kFlamethrowerDamage
Flame.radius 			  = kFlameRadius
Flame.mass				  = 100
Flame.kLightningChance	  = 0.2

Flame.kClientThinkTime	= .01

function Flame:OnCreate()

    Projectile.OnCreate(self)
    
    // intervall of dealing damage
    self:SetNextThink(0.05)
    
    if Server then    
    	self:Detonate(nil)

    end
    
end

function Flame:OnDestroy()

	if Client then	
	
		if(NetworkRandom() < 0.3 ) then
			self:TriggerEffects("flame_end", { effecthostcoords = Coords.GetTranslation(self:GetOrigin()) })
		end
	
	end

	if Server then
		
		if self.kLifeTime then
			// deal remaining amount of damage
			self.kDamage = Flame.kFullDamage / (Flame.kLifetime / Flame.kThinkTime)
			self:Detonate(nil)
		end
		
		Shared.DestroyCollisionObject(self.physicsBody)
    	self.physicsBody = nil
    	
	end
	
	Projectile.OnDestroy(self)

end

function Flame:GetDeathIconIndex()
    return kDeathMessageIcon.Flame
end

function Flame:GetDamageType()
    return kFlameLauncherDamageType
end

if Client then
	function Flame:OnThink()
		
		self. kLifetime = self.kLifetime - self.kClientThinkTime
		if self.kLifetime > 0 then
		
			if self.kLifetime > 0.20 then
				self:TriggerEffects("flames_small", { effecthostcoords = Coords.GetTranslation(self:GetOrigin()) })
			elseif self.kLifetime > 0.16 then
				self:TriggerEffects("flames_middle", { effecthostcoords = Coords.GetTranslation(self:GetOrigin()) })
			else
				self:TriggerEffects("flames_normal", { effecthostcoords = Coords.GetTranslation(self:GetOrigin()) })
			end				
		end
	    
	    self:SetNextThink(Flame.kClientThinkTime)
	    
	end
end

if Server then

    function Flame:OnCollision(targetHit)
    
	    if(NetworkRandom() < 0.3 ) then
			self:TriggerEffects("flame_bounce", { effecthostcoords = Coords.GetTranslation(self:GetOrigin()) })
		end
		
		if(NetworkRandom() < 0.65 ) then
			self:TriggerEffects("flames_normal", { effecthostcoords = Coords.GetTranslation(self:GetOrigin()) })
		end	

        if targetHit ~= nil then
    		self.kDamage = Flame.kFullDamage / (Flame.kLifetime / Flame.kThinkTime)
    		self:Detonate(targetHit)
    		self.kLifetime = 0
    		DestroyEntity(self)
        end
        
        
    end
    
    function Flame:OnThink()
    
    	Projectile.OnThink(self)
    	
    	self.kLifetime = self.kLifetime - self.kThinkTime
        
		if self.kLifetime < 0 then
	    	self.kDamage = self.kFullDamage
	    	self:Detonate(nil)
	    	DestroyEntity(self)
	    end
	    
	    if self:GetVelocity():GetLength() < 15 then
	    	DestroyEntity(self)
	    else	    
	    	self:Detonate(nil) // bottleneck, uncomment this if server perfomance is too bad	    
	    end
	    
	    self:SetNextThink(Flame.kThinkTime)
	    
    end
    
    function Flame:GetDamageType()
    	return kFlameThrowerDamageType
    end
    
    function Flame:Detonate(targetHit)    	
    
    	local player = self:GetOwner()
	    local ents = GetEntitiesWithinRange("LiveScriptActor", self:GetOrigin(), self.kDamageRadius)
	    
	    if targetHit ~= nil then
	    	table.insert(ents, targetHit)
	    end
	    
	    for index, ent in ipairs(ents) do
	    
	        if ent ~= player then
	        
	            local toEnemy = GetNormalizedVector(ent:GetModelOrigin() - player:GetOrigin())
	        
                if GetGamerules():CanEntityDoDamageTo(player, ent) then

                    local health = ent:GetHealth()

                    // Do damage to them and catch them on fire
                    ent:TakeDamage(Flame.kDamage, player, self, ent:GetModelOrigin(), toEnemy)
                    
                    // Only light on fire if we successfully damaged them
                    if ent:GetHealth() ~= health then
                    
                        ent:SetOnFire(player, self)
                    
                        // Impact should not be played for the player that is on fire (if it is a player).
                        local entIsPlayer = ConditionalValue(ent:isa("Player"), ent, nil)
                        // Play on fire cinematic
                        //Shared.CreateEffect(entIsPlayer, Flame.kImpactCinematic, ent, Coords.GetIdentity())

                    end
                    
	            end
	            
	        end
	    end
        
    end

end

Shared.LinkClassToMap("Flame", Flame.kMapName)