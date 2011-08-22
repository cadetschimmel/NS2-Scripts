// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\Spores.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/SporeCloud.lua")
Script.Load("lua/Weapons/Alien/Umbra.lua")
Script.Load("lua/LoopingSoundMixin.lua")

class 'Spores' (Umbra)

Spores.kMapName = "spores"
Spores.kSwitchTime = .5
Spores.kSporeDustCloudLifetime = 12.0      
Spores.kSporeCloudLifetime = 6.0      // From NS1
Spores.kSporeDustCloudDPS = kSporesDustDamagePerSecond
Spores.kSporeCloudDPS = kSporesDamagePerSecond
Spores.kSporeDustCloudRadius = 2.5
Spores.kSporeCloudRadius = 3    // 5.7 in NS1
Spores.kLoopingDustSound = PrecacheAsset("sound/ns2.fev/alien/lerk/spore_spray")

// Points per second
Spores.kDamage = kSporesDamagePerSecond

local networkVars = {
    sporePoseParam     = "compensated float"
}

PrepareClassForMixin(Spores, LoopingSoundMixin)

function Spores:OnCreate()
    Umbra.OnCreate(self)
    self.sporePoseParam = 0
end

function Spores:OnInit()
    Ability.OnInit(self)
    InitMixin(self, LoopingSoundMixin)
end

function Spores:GetEnergyCost(player)
    return self:ApplyEnergyCostModifier(kSporesDustEnergyCost, player)
end

function Spores:GetPrimaryAttackDelay()
    return kSporesDustFireDelay
end

function Spores:GetIconOffsetY(secondary)
    return kAbilityOffset.Spores
end

local function CreateSporeCloud(origin, player, lifetime, damage, radius)

    local spores = CreateEntity(SporeCloud.kMapName, origin, player:GetTeamNumber())
    
    spores:SetOwner(player)
    spores:SetLifetime(lifetime) 
    spores:SetDamage(damage) 
    spores:SetRadius(radius)  
    
    return spores
    
end

function Spores:PerformPrimaryAttack(player)

    // Create long-lasting spore cloud near player that can be used to prevent marines from passing through an area
    player:SetActivityEnd(player:AdjustFuryFireDelay(self:GetPrimaryAttackDelay()))
    
    local origin = player:GetModelOrigin()
    
    // check for clouds in that area. if there are any clouds already very close with more than 50% of their life-time left don't trigger the attack
    local clouds = GetEntitiesForTeamWithinRange("SporeCloud", self:GetTeamNumber(), origin, Spores.kSporeCloudRadius * .5)
    local doAttack = true
    
    for index, cloud in pairs(clouds) do
    
    	if Shared.GetTime() < (cloud.createTime + cloud.lifetime/2) then
    		doAttack = false
    		break
		end
    
    end
    
    if Server then
        
        if doAttack then
        
	        local sporecloud = CreateSporeCloud(origin, player, Spores.kSporeDustCloudLifetime, Spores.kSporeDustCloudDPS, Spores.kSporeDustCloudRadius)
	        if not self:GetIsLoopingSoundPlaying() then
	            self:PlayLoopingSound(player, Spores.kLoopingDustSound)
	        end
        
       	end
        
    end
    
    return doAttack
    
end

function Spores:OnStopLoopingSound(parent)
end

function Spores:OnPrimaryAttackEnd(player)

    Ability.OnPrimaryAttackEnd(self, player)
    self:StopLoopingSound(player)
    
end

function Spores:GetHUDSlot()
    return 2
end

function Spores:UpdateViewModelPoseParameters(viewModel, input)

    Ability.UpdateViewModelPoseParameters(self, viewModel, input)
    
    self.sporePoseParam = Clamp(Slerp(self.sporePoseParam, 1, (1 / kLerkWeaponSwitchTime) * input.time), 0, 1)
    
    viewModel:SetPoseParam("spore", self.sporePoseParam)
    
end

Shared.LinkClassToMap("Spores", Spores.kMapName, networkVars )
