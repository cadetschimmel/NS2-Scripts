// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\SporeMine.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Thing that aliens spawn out of.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Structure.lua")

class 'SporeMine' (Structure)
SporeMine.kMapName = "sporemine"

SporeMine.kModelName          = PrecacheAsset("models/alien/gorge/bilebomb.model") // TODO: change
SporeMine.radius = .1
SporeMine.mass = .1

function SporeMine:GetIsAlienStructure()
    return true
end

function SporeMine:GetCanDoDamage()
    return false
end

function SporeMine:OnDestroy()

	Structure.OnDestroy(self)

    // Create spore cloud that will damage players
    if Server then
   
        local spawnPoint = self:GetOrigin()
        local spores = CreateEntity(SporeCloud.kMapName, spawnPoint, self:GetTeamNumber()) // thanks wulf 21
        spores:SetOwner(self:GetOwner())

        self:TriggerEffects("spores", {effecthostcoords = Coords.GetTranslation(spawnPoint) })
        self:TriggerEffects("bilebomb_hit")
        
        Shared.DestroyCollisionObject(self.physicsBody)
        self.physicsBody = nil

    end   
    
end

function SporeMine:OnTakeDamage(damage, attacker, doer, point)
   
    DestroyEntity(self) // triggers spores
end

function SporeMine:GetExtents()
	return Vector(0.1,0.1,0.1)
end

function SporeMine:GetDistanceToTarget(target)
    return target:GetEngagementPoint() - self:GetOrigin()         
end

if Server then

	SporeMine.kThinkInterval 	  = .5
	SporeMine.kLivingTime		  = kSporeMineLivingTime
	SporeMine.kTriggerRange		  = kSporeMineTriggerRange
	SporeMine.StartTime 		  = 0
	
	function SporeMine:CreatePhysics()
	
		if (self.physicsBody == nil) then
			self.physicsBody = Shared.CreatePhysicsSphereBody(true, self.radius, self.mass, self:GetCoords() )
		end
		self.physicsBody:SetGroup( PhysicsGroup.StructuresGroup )
		self.physicsBody:SetEntity( self )
		self.physicsBody:SetPhysicsType( CollisionObject.Static )
	
	end
	
	function SporeMine:GetDistanceToTarget(target)
    	return (target:GetEngagementPoint() - self:GetOrigin()):GetLength()       
	end
	
	function SporeMine:GetIsEnemyNearby()
	
	    local enemyPlayers = GetEntitiesForTeam("Player", GetEnemyTeamNumber(self:GetTeamNumber()))
	    
	    for index, player in ipairs(enemyPlayers) do                
	    
	        if player:GetIsVisible() and not player:isa("Commander") then
	            local dist = self:GetDistanceToTarget(player)
	            if dist < SporeMine.kTriggerRange then
	        
	                return true
	                
	            end
	            
	        end
	        
	    end
	
	    return false
	    
	end
	
	function SporeMine:OnThink()
	
	    Structure.OnThink(self)
	    
	    if self:GetIsEnemyNearby() or ((Shared.GetTime() - self.StartTime) > self.kLivingTime) then
	    	DestroyEntity(self) // triggers spores
	    end
	    
	    self:SetNextThink(SporeMine.kThinkInterval)
	    
	end
	
	function SporeMine:OnInit()
	    
	    Structure.OnInit(self)
	   
	    self:SetNextThink(SporeMine.kThinkInterval)
	    
	    self.StartTime = Shared.GetTime()
	    
	    self.targetSelector = Server.targetCache:CreateSelector(
	            self,
	            SporeMine.kTriggerRange, 
	            true,
	            TargetCache.kAmtl, 
	            TargetCache.kAstl)       
	            
	    self:CreatePhysics()
	    
	end


end

Shared.LinkClassToMap("SporeMine", SporeMine.kMapName)