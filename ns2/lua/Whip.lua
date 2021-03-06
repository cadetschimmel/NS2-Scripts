// ======= Copyright � 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Whip.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Alien structure that provides attacks nearby players with area of effect ballistic attack.
// Also gives attack/hurt capabilities to the commander. Range should be just shorter than 
// marine sentries.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Structure.lua")
Script.Load("lua/DoorMixin.lua")
Script.Load("lua/InfestationMixin.lua")
Script.Load("lua/WhipBomb.lua")

class 'Whip' (Structure)

PrepareClassForMixin(Whip, InfestationMixin)

Whip.kMapName = "whip"

Whip.kModelName = PrecacheAsset("models/alien/whip/whip.model")

Whip.kScanThinkInterval = .3
Whip.kROF = 2.0
Whip.kFov = 360
Whip.kTargetCheckTime = .3
Whip.kRange = 6
Whip.kAreaEffectRadius = 3
Whip.kDamage = 50
Whip.kMoveSpeed = 1.2

// Fury
Whip.kFuryRadius = 6
Whip.kFuryDuration = 6
Whip.kFuryDamageBoost = .1          // 10% extra damage

// Movement state - for uprooting and moving!
Whip.kMode = enum( {'Rooted', 'Unrooting', 'UnrootedStationary', 'Rooting', 'StartMoving', 'Moving', 'EndMoving', 'Bombarding' } )

local networkVars =
{
    attackYaw = "integer (0 to 360)",
    
    mode = "enum Whip.kMode",
    desiredMode = "enum Whip.kMode",
    bombTarget = "vector"
}

if Server then
    Script.Load("lua/Whip_Server.lua")
end

function Whip:OnCreate()

    Structure.OnCreate(self)
    
    self.attackYaw = 0
    
    self.mode = Whip.kMode.Rooted
    self.desiredMode = Whip.kMode.Rooted
    self.modeAnimation = ""
    
end

function Whip:OnInit()

    InitMixin(self, DoorMixin)
    InitMixin(self, InfestationMixin)   
    
    Structure.OnInit(self)
    self:SetUpdates(true)
 
    if Server then    
        self.targetSelector = Server.targetCache:CreateSelector(
                self,
                Whip.kRange,
                true, 
                TargetCache.kAmtl, 
                TargetCache.kAstl)
    end
   
end

// Used for targeting
function Whip:GetFov()
    return Whip.kFov
end

function Whip:GetIsAlienStructure()
    return true
end

function Whip:GetDeathIconIndex()
    return kDeathMessageIcon.Whip
end

function Whip:GetStatusDescription()
	local text, scalar = Structure.GetStatusDescription(self)
	if self.mode == Whip.kMode.Bombarding then
		text = "Reloading"
	end

	return text, scalar
end

function Whip:GetTechButtons(techId)

    local techButtons = nil
    
    if(techId == kTechId.RootMenu) then
    
    	techButtons = { kTechId.None, kTechId.None, kTechId.None, kTechId.None,
    					kTechId.None, kTechId.None, kTechId.None, kTechId.None,
    					kTechId.None, kTechId.None, kTechId.None, kTechId.None  }
    					
    	if(self:GetTechId() == kTechId.Whip) then
            techButtons[1] = kTechId.UpgradeWhip
        else
        	techButtons[1] = kTechId.WhipBombard   
        end
    
    	techButtons[2] = kTechId.WhipFury
    	techButtons[3] = kTechId.Attack
    	
    	if self.mode == Whip.kMode.Rooted then
	    	techButtons[9] = kTechId.FrenzyTech
	        techButtons[10] = kTechId.SwarmTech
        end
        
        if self.mode == Whip.kMode.Rooted or self.mode == Whip.kMode.Bombarding then        
            techButtons[5] = kTechId.WhipUnroot
        elseif self.mode == Whip.kMode.UnrootedStationary or self.mode == Whip.kMode.StartMoving or self.mode == Whip.kMode.Moving or self.mode == Whip.kMode.EndMoving then
            techButtons[5] = kTechId.WhipRoot
        end
        
    end
    
    return techButtons
    
end

function Whip:GetActivationTechAllowed(techId)

    if techId == kTechId.WhipRoot then
        return self:GetIsBuilt() and self:GetGameEffectMask(kGameEffect.OnInfestation)
    elseif techId == kTechId.WhipUnroot then
        return self:GetIsBuilt() and (self.mode == Whip.kMode.Rooted)
    elseif techId == kTechId.UpgradeWhip then
        return self:GetIsBuilt() and not self:isa("MatureWhip") and (self.mode == Whip.kMode.Rooted)
    else 
		return self:GetIsBuilt() and (self.mode == Whip.kMode.Rooted)
	end
        
end

function Whip:UpdatePoseParameters(deltaTime)

    Structure.UpdatePoseParameters(self, deltaTime)
    
    self:SetPoseParam("attack_yaw", self.attackYaw)
    
end

function Whip:GetCanDoDamage()
    return true
end

function Whip:GetIsRooted()
    return self.mode == Whip.kMode.Rooted
end

function Whip:OnOverrideDoorInteraction(inEntity)
    // Do not open doors when rooted.
    if (self:GetIsRooted()) then
        return false, 0
    end
    return true, 4
end

Shared.LinkClassToMap("Whip", Whip.kMapName, networkVars)

class 'MatureWhip' (Whip)

MatureWhip.kMapName = "maturewhip"


Shared.LinkClassToMap("MatureWhip", MatureWhip.kMapName, networkVars)