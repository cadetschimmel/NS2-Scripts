// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\PowerPack.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// A buildable, potentially portable, marine power source.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Structure.lua")

class 'PowerPack' (Structure)

PowerPack.kMapName = "powerpack"

PowerPack.kModelName = PrecacheAsset("models/marine/portable_node/portable_node.model")

PowerPack.kRange = 12

PowerPack.kShockRange = 6
PowerPack.kElectrifiedThinkTime = .1
PowerPack.kChargeTimeTime = 1
PowerPack.kEnergyPerShock = 10
PowerPack.kDamage = 20

PowerPack.kMode = enum( {'Charging', 'Shocking', 'Default' } )

local networkVars =
{
    mode = "enum PowerPack.kMode"
}

if Server then
    Script.Load("lua/PowerPack_Server.lua")
end

function PowerPack:OnInit()

    self:SetModel(PowerPack.kModelName)
    
    Structure.OnInit(self)
    
    self.mode = PowerPack.kMode.Default
    
end



function PowerPack:GetIsPowered()
    return self:GetIsAlive()
end

// Temporarily don't use "target" attach point
function PowerPack:GetEngagementPoint()
    return LiveScriptActor.GetEngagementPoint(self)
end

function PowerPack:GetTechButtons(techId)

    if(techId == kTechId.RootMenu) then
    
        local techButtons = {   kTechId.None, kTechId.None, kTechId.None, kTechId.None, 
                                kTechId.None, kTechId.None, kTechId.None, kTechId.None }
                                
        if(self:GetTechId() == kTechId.PowerPack) then
            techButtons[1] = kTechId.PowerPackElectrify
        end
        return techButtons
        
    end
    
    return nil
    
end

function PowerPack:GetRequiresPower()
    return false
end

Shared.LinkClassToMap("PowerPack", PowerPack.kMapName, networkVars)

class 'ElectrifiedPowerPack' (PowerPack)

ElectrifiedPowerPack.kMapName = "electrifiedpowerpack"

Shared.LinkClassToMap("ElectrifiedPowerPack", ElectrifiedPowerPack.kMapName, networkVars)

