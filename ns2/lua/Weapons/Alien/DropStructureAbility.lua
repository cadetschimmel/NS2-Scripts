// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\DropStructureAbility.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//					Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/CystAbility.lua")
Script.Load("lua/Weapons/Alien/HydraAbility.lua")
Script.Load("lua/Weapons/Alien/MiniCragAbility.lua")
Script.Load("lua/Weapons/Alien/MiniShadeAbility.lua")
Script.Load("lua/Weapons/Alien/MiniShiftAbility.lua")

class 'DropStructureAbility' (Ability)

DropStructureAbility.kMapName = "dropstructureability"
DropStructureAbility.kCircleModelName = PrecacheAsset("models/misc/circle/circle_alien.model")
DropStructureAbility.kPlacementDistance = 6.0
DropStructureAbility.kIterateStructureDelay = .3
DropStructureAbility.kDropStructureDelay = .5
DropStructureAbility.kSupportedStructures = { CystStructureAbility, HydraStructureAbility, MiniCragStructureAbility, MiniShadeStructureAbility, MiniShiftStructureAbility }
DropStructureAbility.networkVars =
{
    // When true, show ghost (on deploy and after attacking)
    activeStructure			= string.format("integer (1 to %d)", table.count(DropStructureAbility.kSupportedStructures)),
    showGhost               = "boolean",
    healthSprayPoseParam    = "compensated float",
    chamberPoseParam        = "compensated float"
}

function DropStructureAbility:IterateStructure(player)

	for index, structureAbility in pairs(DropStructureAbility.kSupportedStructures) do
	
		if self.activeStructure == table.count(DropStructureAbility.kSupportedStructures) then
			self.activeStructure = 1
			break
		else
			self.activeStructure = self.activeStructure + 1
			if DropStructureAbility.kSupportedStructures[self.activeStructure]:IsAllowed() then
				break
			end
		end
	
	end

end

function DropStructureAbility:GetSecondaryEnergyCost(player)
    return 0
end

function DropStructureAbility:GetActiveStructure()
	return DropStructureAbility.kSupportedStructures[self.activeStructure]
end

// Iterate through structures
function DropStructureAbility:PerformSecondaryAttack(player)

    if(player:GetCanNewActivityStart()) then
    
        self:IterateStructure(player)
                
        player:SetActivityEnd(player:AdjustFuryFireDelay(DropStructureAbility.kIterateStructureDelay))
        
        return true
        
    end
    
    return false
    
end

function DropStructureAbility:GetHasSecondary(player)
	return true
end

function DropStructureAbility:OnInit()
    Ability.OnInit(self)
    self.showGhost = false
    self.healthSprayPoseParam = 0
    self.chamberPoseParam = 0
    self.activeStructure = 1
end

function DropStructureAbility:OnDraw(player, prevWeapon)

    Ability.OnDraw(self, player, prevWeapon)
    self.showGhost = true
    self.activeStructure = 1
    
end

function DropStructureAbility:GetEnergyCost(player)
    return self:GetActiveStructure().GetEnergyCost(player)
end

function DropStructureAbility:GetIconOffsetY(secondary)
	if self.activeStructure ~= 1 then 
	return kAbilityOffset.Hydra
	else
    return kAbilityOffset.Infestation
    end
end

function DropStructureAbility:GetHUDSlot()
    return 4
end

// Check before energy is spent if a Hydra can be built in the current location.
function DropStructureAbility:OnPrimaryAttack(player)

    // Ensure the current location is valid for placement.
    local coords, valid = self:GetPositionForStructure(player)
    if valid then
        // Ensure they have enough resources.
        local cost = GetCostForTech(self:GetActiveStructure().GetDropStructureId())
        if player:GetResources() >= cost then
            Ability.OnPrimaryAttack(self, player)
        else
            player:AddTooltip(string.format("Not enough resources to create %s.", self:GetActiveStructure().GetDropClassName()))
        end
    else
        player:AddTooltip(string.format("Could not place %s in that location.", self:GetActiveStructure().GetDropClassName()))
    end
    
end

function DropStructureAbility:GetPrimaryAttackDelay()

	return DropStructureAbility.kDropStructureDelay
	
end

// Create structure
function DropStructureAbility:PerformPrimaryAttack(player)
    local success = true
    // Make ghost disappear
    if self.showGhost then
    
        player:SetAnimAndMode(Gorge.kCreateStructure, kPlayerMode.GorgeStructure)
            
        player:SetActivityEnd(player:AdjustFuryFireDelay(self:GetPrimaryAttackDelay()))
        success = self:DropStructure(player)
    end
    
    return success
    
end

function DropStructureAbility:DropStructure(player)

    // If we have enough resources
    if Server then
        
        local cost = LookupTechData(self:GetActiveStructure().GetDropStructureId(), kTechDataCostKey)

        local coords, valid = self:GetPositionForStructure(player)
    
        local cost = LookupTechData(self:GetActiveStructure().GetDropStructureId(), kTechDataCostKey)
        if valid and (player:GetResources() >= cost) then
        
            // Create structure
            local structure = self:CreateStructure(coords, player)
            if structure then
            
                structure:SetOwner(player)
                
                // Check for space
                if structure:SpaceClearForEntity(coords.origin) then
                
                    local angles = Angles()
                    angles:BuildFromCoords(coords)
                    structure:SetAngles(angles)
                    
                    //player:TriggerEffects("create_" .. self:GetActiveStructure().GetSuffixName())

    				self:TriggerEffects("gorge_create")
                    
                    player:AddResources( -cost )
                    
                    player:SetActivityEnd(.5)
                    
                    
                    
                    // Jackpot
                    return true                    
                else
                    
                    player:AddTooltip(string.format("Not enough space for %s in that location.", self:GetActiveStructure().GetDropClassName()))
                    DestroyEntity(structure)            
                end

            else
                player:AddTooltip(string.format("Create %s failed.", self:GetActiveStructure().GetDropClassName()))                
            end            
            
        else        
            if not valid then
                player:AddTooltip(string.format("Could not place %s in that location.", self:GetActiveStructure().GetDropClassName()))
            else
                player:AddTooltip(string.format("Not enough resources to create %s.", self:GetActiveStructure().GetDropClassName()))
            end                        
        end
        
    end
    
    return false
    
end

function DropStructureAbility:CreateStructure(coords, player)
	local created_structure = self:GetActiveStructure():CreateStructure(coords, player)
	if created_structure then 
		return created_structure
	else
    	return CreateEntity( self:GetActiveStructure().GetDropMapName(), coords.origin, player:GetTeamNumber() )
    end
end

// Given a gorge player's position and view angles, return a position and orientation
// for structure. Used to preview placement via a ghost structure and then to create it.
// Also returns bool if it's a valid position or not.
function DropStructureAbility:GetPositionForStructure(player)

    local validPosition = false
    
    local origin = player:GetEyePos() + player:GetViewAngles():GetCoords().zAxis * DropStructureAbility.kPlacementDistance

    // Trace short distance in front
    local trace = Shared.TraceRay(player:GetEyePos(), origin, PhysicsMask.AllButPCsAndRagdolls, EntityFilterTwo(player, self))
    
    local displayOrigin = trace.endPoint
    
    // If we hit nothing, trace down to place on ground
    if trace.fraction == 1 then
    
        origin = player:GetEyePos() + player:GetViewAngles():GetCoords().zAxis * DropStructureAbility.kPlacementDistance
        trace = Shared.TraceRay(origin, origin - Vector(0, DropStructureAbility.kPlacementDistance, 0), PhysicsMask.AllButPCsAndRagdolls, EntityFilterTwo(player, self))
        
    end
    
    // If it hits something, position on this surface (must be the world or another structure)
    if trace.fraction < 1 then
    
        if trace.entity == nil then
            validPosition = true
        elseif trace.entity:isa("Infestation") or (not trace.entity:isa("LiveScriptActor") and not trace.entity:isa(self:GetActiveStructure().GetDropClassName())) then
            validPosition = true
        end
        
        displayOrigin = trace.endPoint
        
    end
    
    // Can only be built on infestation
    local requiresInfestation = LookupTechData(self:GetActiveStructure().GetDropStructureId(), kTechDataRequiresInfestation)
    if requiresInfestation and not GetIsPointOnInfestation(displayOrigin) then
        validPosition = false
    end
    
    // Don't allow placing above or below us and don't draw either
    local structureFacing = player:GetViewAngles():GetCoords().zAxis
    local coords = BuildCoords(trace.normal, structureFacing, displayOrigin)    
    
    return coords, validPosition

end

if Client then
function DropStructureAbility:OnUpdate(deltaTime)

    Ability.OnUpdate(self, deltaTime)
    
    if not Shared.GetIsRunningPrediction() then

        local player = self:GetParent()
        
        if not self:GetActiveStructure():IsAllowed() then
        	self:IterateStructure()
    	end
        
        if player == Client.GetLocalPlayer() and player:GetActiveWeapon() == self then
        
            // Show ghost if we're able to create structure
            self.showGhost = player:GetCanNewActivityStart()
            
            // Create ghost
            if not self.ghostStructure and self.showGhost then
            
                self.ghostStructure = Client.CreateRenderModel(RenderScene.Zone_Default)
                self.ghostStructure:SetCastsShadows(false)
                
                // Create build circle to show hydra range
                self.circle = Client.CreateRenderModel(RenderScene.Zone_Default)
                self.circle:SetModel( Shared.GetModelIndex(DropStructureAbility.kCircleModelName) )
                
            end

            // Update ghost model every frame in case it changes
            if self.ghostStructure then
                local modelName = self:GetActiveStructure():GetGhostModelName(self)
                self.ghostStructure:SetModel( Shared.GetModelIndex(modelName) )
            end
            
            // Destroy ghost
            if self.ghostStructure and not self.showGhost then
                self:DestroyStructureGhost()
            end
            
            // Update ghost position 
            if self.ghostStructure then
            
                local coords, valid = self:GetPositionForStructure(player)
                
                if valid then
                    self.ghostStructure:SetCoords(coords)
                end
                self.ghostStructure:SetIsVisible(valid)
                
                // Check resources
                if player:GetResources() < LookupTechData(self:GetActiveStructure():GetDropStructureId(), kTechDataCostKey) then
                
                    valid = false
                    
                end
                
                // Scale and position circle to show range
                if self.circle then
                
                    local coords = BuildCoords(Vector(0, 1, 0), Vector(1, 0, 0), coords.origin + Vector(0, .01, 0), 2 * Hydra.kRange)
                    self.circle:SetCoords(coords)
                    self.circle:SetIsVisible(valid)
                    
                end
                
                // TODO: Set color of structure according to validity
                
            end
          
        end
        
    end
    
end

function DropStructureAbility:DestroyStructureGhost()

    if Client then
    
        if self.ghostStructure ~= nil then
        
            Client.DestroyRenderModel(self.ghostStructure)
            self.ghostStructure = nil
            
        end
        
        if self.circle ~= nil then
        
            Client.DestroyRenderModel(self.circle)
            self.circle = nil
            
        end
        
    end
    
end

function DropStructureAbility:OnDestroy()
    self:DestroyStructureGhost()
    Ability.OnDestroy(self)
end

function DropStructureAbility:OnHolster(player)
    Ability.OnHolster(self, player)
    self:DestroyStructureGhost()
end

end

function DropStructureAbility:UpdateViewModelPoseParameters(viewModel, input)

    Ability.UpdateViewModelPoseParameters(self, viewModel, input)

    // Move away from health spray
    self.healthSprayPoseParam = Clamp(Slerp(self.healthSprayPoseParam, 0, .5 * input.time), 0, 1)
    viewModel:SetPoseParam("health_spray", self.healthSprayPoseParam)
    
    // Move away from chamber 
    self.chamberPoseParam = Clamp(Slerp(self.chamberPoseParam, 0, .5 * input.time), 0, 1)
    viewModel:SetPoseParam("chamber", self.chamberPoseParam)
    
end

Shared.LinkClassToMap("DropStructureAbility", DropStructureAbility.kMapName, DropStructureAbility.networkVars )