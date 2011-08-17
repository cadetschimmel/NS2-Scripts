// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Axe.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/ScriptActor.lua")

class 'Jetpack' (ScriptActor)

Jetpack.kMapName = "jetpack"

Jetpack.kAttachPoint = "JetPack"
Jetpack.kPickupSound = PrecacheAsset("sound/ns2.fev/marine/common/pickup_jetpack")
Jetpack.kModelName = PrecacheAsset("models/marine/jetpack/jetpack.model")

Jetpack.kThinkInterval = .5

function Jetpack:OnCreate ()

    ScriptActor.OnCreate(self)
    
    self:SetPhysicsType(Actor.PhysicsType.DynamicServer)
    self:SetPhysicsGroup(PhysicsGroup.ProjectileGroup)

    self:UpdatePhysicsModel()
    
end

function Jetpack:OnInit()

    ScriptActor.OnInit(self)
    self:SetModel(Jetpack.kModelName) 
    
    if(Server) then
    
    	
        
        self:SetNextThink(Jetpack.kThinkInterval)
        
        // self.timeSpawned = Shared.GetTime()
        
    end         
    
end

function Jetpack:OnTouch(player)

    if( player:GetTeamNumber() == self:GetTeamNumber() ) and not player.hasJetpack then

        player:PlaySound(Jetpack.kPickupSound)
        
        player:GiveJetpack()
        
        if Server then
        	DestroyEntity(self)
    	end
        
    end
    
end

if(Server) then
	function Jetpack:OnThink()
	
	    ScriptActor.OnThink(self)
	
	    // Scan for nearby friendly players that need medpacks because we don't have collision detection yet
	    local players = GetEntitiesForTeamWithinRange("Marine", self:GetTeamNumber(), self:GetOrigin(), 1)
	    local targetplayer = nil
	    
	    for index, player in pairs(players) do
	        
	        if not player.hasJetpack and not player:isa("Exosuit") then
	        
	            targetplayer = player
	            break
	            
	        end
	    
	    end
	
	    if(targetplayer ~= nil) then
	        self:OnTouch(targetplayer)        
	    else
	        self:SetNextThink(Jetpack.kThinkInterval)        
	    end
	    
	end
end

Shared.LinkClassToMap("Jetpack", Jetpack.kMapName, {})


class 'JetpackOnBack' (ScriptActor)

JetpackOnBack.kMapName = "jetpackonback"

JetpackOnBack.kBackModelName = PrecacheAsset("models/marine/jetpack/jetpack_back.model")

function JetpackOnBack:OnCreate()

	ScriptActor.OnCreate(self)

	self:SetModel(JetpackOnBack.kBackModelName)

end

Shared.LinkClassToMap("JetpackOnBack", JetpackOnBack.kMapName, {})