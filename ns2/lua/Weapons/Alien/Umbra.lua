// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\Umbra.lua
//
//    Created by:   
//                  Andreas Urwalek (a_urwa@sbox.tugraz.at)
// 
// leap is secondary.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/UmbraCloud.lua")

class 'Umbra' (Ability)

Umbra.kMapName = "umbra"

Umbra.kDelayUmbra = kUmbraFireDelay
Umbra.kEnergyCost = kUmbraEnergyCost

Umbra.kCooldown = 3

local networkVars =
{
    lastUmbra      = "float"
}

// All two hive skulks have leap - but it goes away as soon as the second hive does
function Umbra:GetHasSecondary(player)
    return player.GetHasTwoHives and player:GetHasTwoHives()
end

function Umbra:GetSecondaryEnergyCost(player)
    return self:ApplyEnergyCostModifier(Umbra.kEnergyCost, player)
end

function Umbra:OnCFreate()

	Ability.OnCreate(self)
	self.lastUmbra = 0

end

function Umbra:GetSecondaryAttackDelay()
	return Umbra.kDelayUmbra
end

function Umbra:PerformSecondaryAttack(player)

	if self:GetHasSecondary(player) then
	
		if Shared.GetTime() - self.lastUmbra < Umbra.kCooldown then
			return false
		end
	
	    // Trace instant line to where it should hit
	    local viewAngles = player:GetViewAngles()
	    local viewCoords = viewAngles:GetCoords()    
	    local startPoint = player:GetEyePos()
	
	    local trace = Shared.TraceRay(startPoint, startPoint + viewCoords.zAxis * kLerkUmbraShootRange, PhysicsMask.AllButPCs, EntityFilterOne(player))
	    
	    if Client then
	    
	    	self:TriggerEffects("umbra_attack")
	    
	    end
	    
	    // Create umbra cloud that will protect players
	    if Server then
	   
	        local spawnPoint = trace.endPoint + (trace.normal * 0.5)
	        local spores = CreateEntity(UmbraCloud.kMapName, spawnPoint, player:GetTeamNumber())
	        spores:SetOwner(player)
	
	        self:TriggerEffects("umbra_cloud", {effecthostcoords = Coords.GetTranslation(spawnPoint) })
	
	    end
	    
	    player:SetActivityEnd(player:AdjustFuryFireDelay(self:GetSecondaryAttackDelay()))
	    
	    self.lastUmbra = Shared.GetTime()
	    
	    return true
    end
    
    return false
end

Shared.LinkClassToMap("Umbra", Umbra.kMapName, networkVars )
