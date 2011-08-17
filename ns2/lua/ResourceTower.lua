// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ResourceTower.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Generic resource structure that marine and alien structures inherit from.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Structure.lua")

class 'ResourceTower' (Structure)

ResourceTower.kMapName = "resourcetower"

ResourceTower.kResourcesInjection = kPlayerResPerInterval
ResourceTower.kTeamResourcesInjection = 1
ResourceTower.kMaxUpgradeLevel = 3
ResourceTower.kMaxTechPointMultiplier = 4
ResourceTower.kTechNodeValue = .8

// Don't start generating resources right away, wait a short time
// (but not too long or it will feel like a bug). This is to 
// make it less advantageous for a team to build every nozzle
// they find. Same as in NS1.
ResourceTower.kBuildDelay = 4

local networkVars = 
{
    upgradeLevel = string.format("integer (0 to %d)", ResourceTower.kMaxUpgradeLevel)
}

if (Server) then
    Script.Load("lua/ResourceTower_Server.lua")
end

function ResourceTower:OnInit()

    Structure.OnInit(self)
    
    self.playingSound = false
    self.upgradeLevel = 0
    
end

function ResourceTower:GetUpgradeLevel()
    return self.upgradeLevel
end

function ResourceTower:SetUpgradeLevel(upgradeLevel)
    self.upgradeLevel = Clamp(upgradeLevel, 0, ResourceTower.kMaxUpgradeLevel)
end

function ResourceTower:GetNumCapturedTechPoints()

	local tp = nil
	
	if (self:GetTeamNumber() == kTeam1Index) then
    	tp = GetEntitiesForTeam("CommandStation", self:GetTeamNumber())
	else
		tp = GetEntitiesForTeam("Hive", self:GetTeamNumber())
	end
	
    return Clamp(table.count(tp), 1, ResourceTower.kMaxTechPointMultiplier)

end

function ResourceTower:GiveResourcesToTeam(player)

    local resources = ResourceTower.kResourcesInjection * Clamp(self:GetNumCapturedTechPoints() * ResourceTower.kTechNodeValue, 1, ResourceTower.kMaxTechPointMultiplier)
    player:AddResources(resources, true)

end



/*
function ResourceTower:GetDescription()

    local description = Structure.GetDescription(self)
    
    // Add upgrade level
    local upgradeLevel = self:GetUpgradeLevel()
    description = string.format("%s - +%d of %d", description, self:GetUpgradeLevel(), ResourceTower.kMaxUpgradeLevel)
    
    return description
    
end
*/

Shared.LinkClassToMap("ResourceTower", ResourceTower.kMapName, networkVars)
