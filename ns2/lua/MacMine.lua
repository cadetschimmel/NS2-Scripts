// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\MACMine.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Structure.lua")

class 'MACMine' (Structure)

MACMine.kMapName = "mac_mine"

MACMine.kModelName = PrecacheAsset("models/marine/mine/mine.model")
MACMine.kThinkTime = .5
MACMine.kTriggerRange = 3
MACMine.kArmingTime = 3
MACMine.kDamageRadius = 4
MACMine.kMaxDamage = 120
    
local networkVars =
    {
        active     = "boolean",
        createTime = "float"
    }


function MACMine:OnInit()

    self:SetModel(MACMine.kModelName)
    
    Structure.OnInit(self)
    
    self:SetNextThink(MACMine.kArmingTime)
    
    self.active = false
    
    self.createTime = Shared.GetTime()
    
end

function MACMine:OnKill(targetEntity, damage, killer, doer, point, direction)

	self:Detonate(nil)
	Structure.OnKill(self, targetEntity, damage, killer, doer, point, direction)

end

function MACMine:OnThink()

	if Server then
		if not self.active then
			self.active = true
			// TODO: play funky cinematic and sound?
		end	
		
		if self.active and self:GetIsEnemyNearby() then
	
	    		self:Detonate(nil) // triggers detonation
	    		self.active = false
	
		else
			self:SetNextThink(MACMine.kThinkTime)	
		end
	end

end

function MACMine:GetRequiresPower()
    return false
end


function MACMine:GetTechButtons(techId)

    local techButtons = nil
    
    if(techId == kTechId.RootMenu) then 
    
        techButtons = { kTechId.None, kTechId.None, kTechId.None, kTechId.None, 
                        kTechId.None, kTechId.None, kTechId.None, kTechId.None }
    
        
    end
    
    return techButtons
    
end

function MACMine:Detonate(targetHit)

    // Do damage to targets TODO: GetGamerules():CanEntityDoDamageTo(player, target)?
    local hitEntities = GetEntitiesForTeamWithinRange("LiveScriptActor", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), Grenade.kDamageRadius)
    
    // Remove grenade and add firing player
    table.removevalue(hitEntities, self)
    //table.insertunique(hitEntities, self:GetOwner())
    
    RadiusDamage(hitEntities, self:GetOrigin(), MACMine.kDamageRadius, MACMine.kMaxDamage, self)
    
    local surface = GetSurfaceFromEntity(targetHit)        
    local params = {surface = surface}
    if not targetHit then
        params[kEffectHostCoords] = BuildCoords(Vector(0, 1, 0), self:GetCoords().zAxis, self:GetOrigin(), 1)
    end
    
    self:TriggerEffects("grenade_explode", params)
    
    DestroyEntity(self)
    
end

function MACMine:GetIsEnemyNearby()

    local enemyPlayers = GetEntitiesForTeam("Player", GetEnemyTeamNumber(self:GetTeamNumber()))
    
    for index, player in ipairs(enemyPlayers) do                
    
        if player:GetIsVisible() and not player:isa("Commander") and player:GetIsAlive() then
            local dist = (player:GetOrigin() - self:GetOrigin()):GetLength()
            if dist < MACMine.kTriggerRange then
        
                return true
                
            end
            
        end
        
    end

    return false
    
end


Shared.LinkClassToMap("MACMine", MACMine.kMapName, networkVars)
