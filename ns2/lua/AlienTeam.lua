// ======= Copyright � 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\AlienTeam.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// This class is used for teams that are actually playing the game, e.g. Marines or Aliens.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/TechData.lua")
Script.Load("lua/Skulk.lua")
Script.Load("lua/PlayingTeam.lua")
Script.Load("lua/UpgradeStructureManager.lua")

class 'AlienTeam' (PlayingTeam)

// Innate alien regeneration
AlienTeam.kAutoHealInterval = 2
AlienTeam.kAutoHealPercent = .02
AlienTeam.kInfestationUpdateRate = 2
AlienTeam.kInfestationHurtInterval = 2

AlienTeam.kSupportingStructureClassNames = {[kTechId.Hive] = {"Hive"} }
AlienTeam.kUpgradeStructureClassNames = {[kTechId.Crag] = {"Crag", "MatureCrag"}, [kTechId.Shift] = {"Shift", "MatureShift"}, [kTechId.Shade] = {"Shade", "MatureShift"} }
AlienTeam.kUpgradedStructureTechTable = {[kTechId.Crag] = {kTechId.MatureCrag}, [kTechId.Shift] = {kTechId.MatureShift}, [kTechId.Shade] = {kTechId.MatureShade}}

AlienTeam.kTechTreeIdsToUpdate = { kTechId.Crag, kTechId.MatureCrag, kTechId.Shift, kTechId.MatureShift, kTechId.Shade, kTechId.MatureShade }

function AlienTeam:GetTeamType()
    return kAlienTeamType
end

function AlienTeam:GetIsAlienTeam()
    return true
end

function AlienTeam:Initialize(teamName, teamNumber)

    PlayingTeam.Initialize(self, teamName, teamNumber)
    
    self.respawnEntity = Skulk.kMapName
    
    self.upgradeStructureManager = UpgradeStructureManager()
    self.upgradeStructureManager:Initialize(AlienTeam.kSupportingStructureClassNames, AlienTeam.kUpgradeStructureClassNames, AlienTeam.kUpgradedStructureTechTable)
    
end

function AlienTeam:OnInit()

    // (re)create upgrade structure manager before OnInit(), so AddStructure(Hive) is called
    self.upgradeStructureManager = UpgradeStructureManager()
    self.upgradeStructureManager:Initialize(AlienTeam.kSupportingStructureClassNames, AlienTeam.kUpgradeStructureClassNames, AlienTeam.kUpgradedStructureTechTable)

    PlayingTeam.OnInit(self)    

end

function AlienTeam:SpawnInitialStructures(teamLocation)

    PlayingTeam.SpawnInitialStructures(self, teamLocation)
    
    // Aliens start the game with all their eggs
    local nearestTechPoint = GetNearestTechPoint(teamLocation:GetOrigin(), self:GetTeamType(), false)
    if(nearestTechPoint ~= nil) then
    
        local attached = nearestTechPoint:GetAttached()
        if(attached ~= nil) then

            if attached:isa("Hive") then
                attached:SpawnInitial()
            else
                Print("AlienTeam:SpawnInitialStructures(): Hive not attached to tech point, %s instead.", attached:GetClassName())
            end
            
        end
        
    end
    
end

function AlienTeam:GetHasAbilityToRespawn()
    
    local hives = GetEntitiesForTeam("Hive", self:GetTeamNumber())
    return table.count(hives) > 0
    
end

function AlienTeam:Update(timePassed)

    PROFILE("AlienTeam:Update")

    PlayingTeam.Update(self, timePassed)

    self:UpdateAutoBuild(timePassed)
    
    self:UpdateTeamAutoHeal(timePassed)
    
    self:UpdateHiveSight()
    
    self:UpdateAlienResearchProgress()
    
end

function AlienTeam:UpdateAutoBuild(timePassed)

    PROFILE("AlienTeam:UpdateTeamAutoBuild")

    // Update build fraction every tick to be smooth
    for index, structureId in ipairs(self.structures) do
        local structure = Shared.GetEntity(structureId)          
        if (structure ~= nil) and (not structure:GetIsBuilt()) then        
            // Account for metabolize game effects
            local autoBuildTime = GetAlienEvolveResearchTime(timePassed, structure)
            structure:Construct(autoBuildTime)
        
        end
        
    end
    
end

// Small and silent innate health and armor regeneration for all alien players, similar to the 
// innate regeneration of all alien structures. NS1 healed 2% of alien max health every 2 seconds.
function AlienTeam:UpdateTeamAutoHeal(timePassed)

    PROFILE("AlienTeam:UpdateTeamAutoHeal")

    local time = Shared.GetTime()
    
    if self.timeOfLastAutoHeal == nil or (time > (self.timeOfLastAutoHeal + AlienTeam.kAutoHealInterval)) then
    
        // Heal all players by this amount
        local teamEnts = GetEntitiesForTeam("LiveScriptActor", self:GetTeamNumber())
        
        for index, entity in ipairs(teamEnts) do
        
            if entity:GetIsAlive() then
            
                if entity:isa("Drifter") or (entity:isa("Alien") and entity:GetGameEffectMask(kGameEffect.OnInfestation)) then
            
                    // Entities always get at least 1 point back
                    local healthBack = math.max(entity:GetMaxHealth() * AlienTeam.kAutoHealPercent, 1)
                    entity:AddHealth(healthBack, true)
                    
                end
                
            end
            
        end
        
        self.timeOfLastAutoHeal = time
        
    end
    
    // Hurt structures if they require infestation and aren't on it
    if self.timeOfLastInfestationHurt == nil or (time > (self.timeOfLastInfestationHurt + AlienTeam.kInfestationHurtInterval)) then
    
        for index, structureId in ipairs(self.structures) do
            local structure = Shared.GetEntity(structureId)
            if (structure ~= nil) then
              if LookupTechData(structure:GetTechId(), kTechDataRequiresInfestation) and not structure:GetGameEffectMask(kGameEffect.OnInfestation) then            
                // Take damage!
                local damage = structure:GetMaxHealth() * kBalanceInfestationHurtPercentPerSecond/100 * AlienTeam.kInfestationHurtInterval               
                structure:TakeDamage(damage, nil, nil, structure:GetOrigin(), nil)                
              end
            end         
        end
        
        self.timeOfLastInfestationHurt = time
        
    end
    
end

// Returns blipType if we should add a hive sight blip for this entity. Returns kBlipType.Undefined if 
// we shouldn't add one.
function AlienTeam:GetBlipType(entity)

    local blipType = kBlipType.Undefined
    
    if entity:isa("LiveScriptActor") and entity:GetIsVisible() and entity:GetIsAlive() and not entity:isa("Infestation") then
    
        if entity:GetTeamNumber() == self:GetTeamNumber() then
        
            blipType = kBlipType.Friendly
            
            local underAttack = false
            
            local damageTime = entity:GetTimeOfLastDamage()
            if damageTime ~= nil and (Shared.GetTime() < (damageTime + kHiveSightDamageTime)) then
            
                // Draw blip as under attack
                blipType = kBlipType.FriendlyUnderAttack
                
                underAttack = true
                
            end
            
            // If it's a hive or harvester, add special icon to show how important it is
            if entity:isa("Hive") or entity:isa("Harvester") then

                if not underAttack then            
                    blipType = kBlipType.TechPointStructure
                end
                
            end
            
        elseif(entity:GetTeamNumber() == GetEnemyTeamNumber(self:GetTeamNumber()) and (entity.sighted or entity:GetGameEffectMask(kGameEffect.Parasite) or entity:GetGameEffectMask(kGameEffect.OnInfestation))) then
            blipType = kBlipType.Sighted
        end
        
        // Only send other structures if they are under attack or parasited
        if ((blipType == kBlipType.Sighted) or (blipType == kBlipType.Friendly)) and entity:isa("Structure") and (not underAttack) and not entity:GetGameEffectMask(kGameEffect.Parasite) then
            blipType = kBlipType.Undefined
        end
        
    end

    return blipType
    
end

function AlienTeam:UpdateHiveSight()

    PROFILE("AlienTeam:UpdateHiveSight")
    
    if(GetGamerules():GetGameStarted() and self:GetIsAlienTeam()) then
    
        // Loop through enemy entities, creating blips for ones that are sighted. Each entry is a pair with the entity and it's blip type
        local time = Shared.GetTime()
        
        local blips = EntityListToTable(Shared.GetEntitiesWithClassname("Blip"))
        
        local allScriptActors = Shared.GetEntitiesWithClassname("ScriptActor")
        for entIndex, entity in ientitylist(allScriptActors) do
        
            local blipType = self:GetBlipType(entity)
            
            if(blipType ~= kBlipType.Undefined) then
            
                CreateUpdateBlip(blips, entity, blipType, time)
                
            end        
            
        end
        
        // Now sync the sighted entities with the blip entities, creating or deleting them
        self:DeleteOldBlips(time)
        
    end
    
end


/**
 * Compute the research precent based on the research percent of all prerequisites for all the alien types.
 */
function AlienTeam:UpdateAlienResearchProgress()

    PROFILE("AlienTeam:UpdateAlienResearchProgress")
    
    // Skulk doesn't need to be researched. Onos will need to be added.
    local aliensTechUpgradeData = { { TechId = kTechId.Fade, UpgradeNode = kTechId.TwoHives },
                                    { TechId = kTechId.Gorge, UpgradeNode = kTechId.Crag },
                                    { TechId = kTechId.Lerk, UpgradeNode = kTechId.Whip } }
    
    for index, alienTechUpgradeData in pairs(aliensTechUpgradeData) do
    
        local alienTechNode = self.techTree:GetTechNode(alienTechUpgradeData.TechId)
        if alienTechNode then
        
            local previousPrereqResearchProgress = alienTechNode:GetPrereqResearchProgress()
            local prereqNode = self.techTree:GetTechNode(alienTechUpgradeData.UpgradeNode)
            if prereqNode /*and prereqNode:GetAvailable()*/ then

                local progress = 0
                
                if prereqNode:GetIsResearch() or prereqNode:GetIsBuy() or prereqNode:GetIsUpgrade() then
                    progress = prereqNode:GetResearchProgress()
                elseif prereqNode:GetIsBuild() then
                    local buildTechId = prereqNode:GetTechId()
                    local entsMatchingTechId = GetEntitiesWithFilter(Shared.GetEntitiesWithClassname("Structure"), function(entity) return entity:GetTechId() == buildTechId end)
                    local highestBuiltFraction = 0
                    for k, ent in ipairs(entsMatchingTechId) do
                        highestBuiltFraction = (ent:GetBuiltFraction() > highestBuiltFraction and ent:GetBuiltFraction()) or highestBuiltFraction
                    end
                    progress = highestBuiltFraction
                end
                
                if progress ~= previousPrereqResearchProgress then
                    alienTechNode:SetPrereqResearchProgress(progress)
                    self.techTree:SetTechNodeChanged(alienTechNode)
                end
                
            end
            
        end
        
    end

end

function AlienTeam:DeleteOldBlips(time)

    PROFILE("AlienTeam:DeleteOldBlips")

    // We need to convert the EntityList to a table as we are destroying the entities
    // inside the EntityList.
    local entityTable = EntityListToTable(Shared.GetEntitiesWithClassname("Blip"))
    for index, blip in ipairs(entityTable) do
    
        if blip.timeOfUpdate < time then
        
            DestroyEntity(blip)
            
        end
        
    end
    
end

function AlienTeam:GetUmbraClouds()

    local clouds = GetEntitiesForTeam("UmbraCloud", self:GetTeamNumber())
    
    local umbraClouds = {}    

    for index, cloud in ipairs(clouds) do
    
       table.insert(umbraClouds, cloud)
        
    end
    
    return umbraClouds

end

function AlienTeam:GetFuryWhips()

    local whips = GetEntitiesForTeam("Whip", self:GetTeamNumber())
    
    local FuryWhips = {}    
    
    // Get furying whips
    for index, whip in ipairs(whips) do
    
        if whip:GetIsFuryActive() then
        
            table.insert(FuryWhips, whip)
            
        end
        
    end
    
    return FuryWhips

end

function AlienTeam:GetShades()

	local shades = GetEntitiesForTeam("Shade", self:GetTeamNumber())
	local mini_shade = GetEntitiesForTeam("MiniShade", self:GetTeamNumber())
	
	for k, v in pairs(mini_shade) do
        table.insert(shades, v)
    end
	
    return shades
    
end

// Adds the InUmbra game effect to all specified entities within range of active umbra clouds. Returns
// the number of entities affected.
function AlienTeam:UpdateUmbraGameEffects(entities)

    local umbraClouds = self:GetUmbraClouds()
    
    if table.count(umbraClouds) > 0 then
    
        for index, entity in ipairs(entities) do
        
            // Get distance to crag
            for cloudIndex, cloud in ipairs(umbraClouds) do
            
                if (entity:GetOrigin() - cloud:GetOrigin()):GetLengthSquared() < cloud:GetRadius()*cloud:GetRadius() then
                
                    entity:SetGameEffectMask(kGameEffect.InUmbra, true)
                
                end
                
            end
            
        end
    
    end

end

function AlienTeam:UpdateFuryGameEffects(entities)

    local FuryWhips = self:GetFuryWhips()
    
    if table.count(FuryWhips) > 0 then
    
        for index, entity in ipairs(entities) do
        
            // Live script actors (players, structures)
            if entity.SetFuryLevel then

                // Get distance to whip
                for index, whip in ipairs(FuryWhips) do
                
                    if (entity:GetOrigin() - whip:GetOrigin()):GetLengthSquared() < Whip.kFuryRadius*Whip.kFuryRadius then
                    
                        entity:SetGameEffectMask(kGameEffect.Fury, true)
                    
                        entity:AddStackableGameEffect(kFuryGameEffect, kFuryTime, whip)
                        
                    end
                    
                end
                
            end
            
        end
    
    end

end

// Update cloaking for friendlies and disorientation for enemies
function AlienTeam:UpdateShadeEffects(teamEntities, enemyPlayers)

    local shades = self:GetShades()
    local time = Shared.GetTime()
    local range = 0
    
    if self.lastUpdateShadeTime == nil or (Shared.GetTime() > self.lastUpdateShadeTime + .3) then
    
        // Update disorient flag on players
        for index, entity in ipairs(enemyPlayers) do
            
            local disoriented = false

    
            if table.count(shades) > 0 then

        
                if not entity:isa("Commander") then


                    for index, shade in ipairs(shades) do

						if shade:isa("MiniShade") then
							range = MiniShade.kDistortRadius
						else
							range = Shade.kCloakRadius
						end
                    	
                        if (entity:GetOrigin() - shade:GetOrigin()):GetLengthSquared() < range*range then
                        
                            disoriented = true
                        
                        end

                    end
                    
                end
                
            end
            
            entity:SetGameEffectMask(kGameEffect.Disorient, disoriented)
            
        end

        self.lastUpdateShadeTime = time
        
    end
    
end

function AlienTeam:InitTechTree()
   
    PlayingTeam.InitTechTree(self)
    
    // Add special alien menus
    self.techTree:AddMenu(kTechId.MarkersMenu)
    self.techTree:AddMenu(kTechId.UpgradesMenu)
    self.techTree:AddMenu(kTechId.ShadePhantasmMenu)
    self.techTree:AddMenu(kTechId.EggMenu)
    
    // Add egg types
    
    self.techTree:AddBuyNode(kTechId.GorgeEgg,                     kTechId.None,                 kTechId.None)
    self.techTree:AddBuyNode(kTechId.LerkEgg,                      kTechId.LerkTech,             kTechId.Morpher)
    self.techTree:AddBuyNode(kTechId.FadeEgg,                      kTechId.FadeTech,             kTechId.Morpher)
    self.techTree:AddBuyNode(kTechId.OnosEgg,                      kTechId.OnosTech,          	 kTechId.Morpher)
    
    // Add markers (orders)
    self.techTree:AddOrder(kTechId.ThreatMarker)
    self.techTree:AddOrder(kTechId.LargeThreatMarker)
    self.techTree:AddOrder(kTechId.NeedHealingMarker)
    self.techTree:AddOrder(kTechId.WeakMarker)
    self.techTree:AddOrder(kTechId.ExpandingMarker)
    
    // Commander abilities
    self.techTree:AddEnergyBuildNode(kTechId.Cyst,           kTechId.None,           kTechId.None)
    self.techTree:AddResearchNode(kTechId.MetabolizeTech,       kTechId.TwoHives,       kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.Metabolize,     kTechId.MetabolizeTech, kTechId.None)
           
    // Tier 1
    self.techTree:AddBuildNode(kTechId.Hive,                      kTechId.None,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.Harvester,                 kTechId.None,                kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.HarvesterUpgrade,        kTechId.Harvester,           kTechId.None)
    self.techTree:AddEnergyManufactureNode(kTechId.Drifter,       kTechId.None,                kTechId.None)
    
    // Drifter tech
    self.techTree:AddResearchNode(kTechId.DrifterFlareTech,       kTechId.TwoHives,                kTechId.None)
    self.techTree:AddActivation(kTechId.DrifterFlare,                 kTechId.DrifterFlareTech)
    
    self.techTree:AddResearchNode(kTechId.DrifterParasiteTech,    kTechId.None,                kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DrifterParasite,      kTechId.DrifterParasiteTech, kTechId.None)

    // Whips
    self.techTree:AddBuildNode(kTechId.Whip,                      kTechId.None,                kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeWhip,             kTechId.None,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.MatureWhip,                 kTechId.TwoHives,                kTechId.None)
    self.techTree:AddActivation(kTechId.WhipAcidStrike,            kTechId.None,                kTechId.None)    
    self.techTree:AddActivation(kTechId.WhipFury,                 kTechId.None,          kTechId.None)
    
    self.techTree:AddActivation(kTechId.WhipUnroot)
    self.techTree:AddActivation(kTechId.WhipRoot)
    
    self.techTree:AddResearchNode(kTechId.LerkTech,             kTechId.Morpher,                kTechId.None)
    self.techTree:AddResearchNode(kTechId.FadeTech,             kTechId.Morpher,                kTechId.None)
    self.techTree:AddResearchNode(kTechId.OnosTech,             kTechId.Morpher,                kTechId.None)
    
    self.techTree:AddResearchNode(kTechId.Melee1Tech,             kTechId.None,                kTechId.None)
    self.techTree:AddResearchNode(kTechId.Melee2Tech,             kTechId.Melee1Tech,                kTechId.None)
    self.techTree:AddResearchNode(kTechId.Melee3Tech,             kTechId.Melee2Tech,                kTechId.None)
    
    self.techTree:AddTargetedActivation(kTechId.WhipBombard,                  kTechId.MatureWhip, kTechId.None)

    self.techTree:AddBuildNode(kTechId.Morpher,                 	kTechId.Hive,                kTechId.None)
    
    // Tier 1 lifeforms
    self.techTree:AddBuildNode(kTechId.Egg,                 	kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Skulk,                     kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Gorge,                     kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Lerk,                      kTechId.LerkTech,                kTechId.Morpher)
    self.techTree:AddBuyNode(kTechId.Fade,                      kTechId.FadeTech,            	 kTechId.Morpher)
    self.techTree:AddBuyNode(kTechId.Onos,                      kTechId.OnosTech,          		 kTechId.Morpher)
    
    // Special alien upgrade structures. These tech nodes are modified at run-time, depending when they are built, so don't modify prereqs.
    self.techTree:AddBuildNode(kTechId.Crag,                      kTechId.None,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.Shift,                     kTechId.None,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.Shade,                     kTechId.None,          kTechId.None)
    
    // Crag
    self.techTree:AddUpgradeNode(kTechId.UpgradeMiniCrag,            kTechId.MiniCrag,                kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeCrag,            kTechId.Crag,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.MatureCrag,                kTechId.TwoHives,                kTechId.None)
    self.techTree:AddActivation(kTechId.CragHeal,                    kTechId.None,          kTechId.None)
    self.techTree:AddActivation(kTechId.CragUmbra,                    kTechId.Crag,          kTechId.None)
    self.techTree:AddResearchNode(kTechId.BabblerTech,            kTechId.MatureCrag,          kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.CragBabblers,     kTechId.BabblerTech,         kTechId.MatureCrag)

    // Shift    
    self.techTree:AddUpgradeNode(kTechId.UpgradeMiniShift,            kTechId.MiniShift,               kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeShift,            kTechId.Shift,               kTechId.None)
    self.techTree:AddBuildNode(kTechId.MatureShift,               kTechId.TwoHives,          kTechId.None)
    self.techTree:AddActivation(kTechId.ShiftRecall,              kTechId.None, kTechId.None)
    self.techTree:AddResearchNode(kTechId.EchoTech,               kTechId.MatureShift,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.ShiftEcho,        kTechId.EchoTech,            kTechId.MatureShift)    
    self.techTree:AddActivation(kTechId.ShiftEnergize,            kTechId.None,         kTechId.None)

    // Shade
    self.techTree:AddUpgradeNode(kTechId.UpgradeMiniShade,           kTechId.MiniShade,               kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeShade,           kTechId.Shade,               kTechId.None)
    self.techTree:AddBuildNode(kTechId.MatureShade,               kTechId.None,          kTechId.None)
    self.techTree:AddActivation(kTechId.ShadeDisorient,               kTechId.None,         kTechId.None)
    self.techTree:AddActivation(kTechId.ShadeCloak,                   kTechId.None,         kTechId.None)
    
    // Shade targeted abilities - treat phantasms as build nodes so we show ghost and attach points for fake hive
    self.techTree:AddResearchNode(kTechId.PhantasmTech,             kTechId.MatureShade,         kTechId.None)
    self.techTree:AddBuildNode(kTechId.ShadePhantasmFade,           kTechId.PhantasmTech,        kTechId.MatureShade)
    self.techTree:AddBuildNode(kTechId.ShadePhantasmOnos,           kTechId.None,        kTechId.None)
    self.techTree:AddBuildNode(kTechId.ShadePhantasmHive,           kTechId.PhantasmTech,        kTechId.MatureShade)


    // Crag upgrades
    self.techTree:AddResearchNode(kTechId.AlienArmor1Tech,        kTechId.None,                kTechId.None)
    self.techTree:AddResearchNode(kTechId.AlienArmor2Tech,        kTechId.AlienArmor1Tech,          kTechId.None)
    self.techTree:AddResearchNode(kTechId.AlienArmor3Tech,        kTechId.AlienArmor2Tech,          kTechId.None)
    
    // Tier 2
    self.techTree:AddSpecial(kTechId.TwoHives)
    self.techTree:AddResearchNode(kTechId.BileBombTech,           kTechId.TwoHives,                kTechId.None,    kTechId.MatureWhip)
    self.techTree:AddResearchNode(kTechId.LeapTech,               kTechId.TwoHives,                kTechId.None)
    self.techTree:AddResearchNode(kTechId.BlinkTech,              kTechId.TwoHives,                kTechId.None)
    
    // Tier 3
    self.techTree:AddSpecial(kTechId.ThreeHives)    
    
    // Global alien upgrades. Make sure the first prerequisite is the main tech required for it, as this is 
    // what is used to display research % in the alien evolve menu.
    self.techTree:AddResearchNode(kTechId.CarapaceTech, kTechId.Crag, kTechId.None)
    self.techTree:AddBuyNode(kTechId.Carapace, kTechId.CarapaceTech, kTechId.None, kTechId.AllAliens)    
    
    self.techTree:AddResearchNode(kTechId.RegenerationTech, kTechId.Crag, kTechId.None)
    self.techTree:AddBuyNode(kTechId.Regeneration, kTechId.RegenerationTech, kTechId.None, kTechId.AllAliens)

    self.techTree:AddResearchNode(kTechId.RedemptionTech, kTechId.Crag, kTechId.None)
    self.techTree:AddBuyNode(kTechId.Redemption, kTechId.RedemptionTech, kTechId.None, kTechId.AllAliens)

    self.techTree:AddResearchNode(kTechId.FrenzyTech,             kTechId.Whip,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Frenzy,             kTechId.FrenzyTech,                kTechId.None,     kTechId.AllAliens)
    
    self.techTree:AddResearchNode(kTechId.SwarmTech,              kTechId.Whip,                kTechId.None)   
    self.techTree:AddBuyNode(kTechId.Swarm,              kTechId.SwarmTech,                kTechId.None,     kTechId.AllAliens)

    self.techTree:AddResearchNode(kTechId.CamouflageTech,             kTechId.Shade,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Camouflage,             kTechId.CamouflageTech,                kTechId.None,     kTechId.AllAliens)

    // Specific alien upgrades
    self.techTree:AddBuildNode(kTechId.Hydra,               kTechId.None,               kTechId.None)
    self.techTree:AddBuildNode(kTechId.MiniCrag,               kTechId.Crag,               kTechId.None)
    self.techTree:AddBuildNode(kTechId.MiniShift,               kTechId.Shift,               kTechId.None)
    self.techTree:AddBuildNode(kTechId.MiniShade,               kTechId.Shade,               kTechId.None)
    self.techTree:AddBuyNode(kTechId.BileBomb,              kTechId.BileBombTech,       kTechId.TwoHives,               kTechId.Gorge)
    self.techTree:AddBuyNode(kTechId.Leap,                  kTechId.LeapTech,           kTechId.TwoHives,               kTechId.Skulk)
    self.techTree:AddBuyNode(kTechId.Blink,                 kTechId.BlinkTech,          kTechId.TwoHives,               kTechId.Fade)
    
    // Alien upgrades   
    self.techTree:AddResearchNode(kTechId.AdrenalineTech, kTechId.TwoHives, kTechId.Shift)
    self.techTree:AddBuyNode(kTechId.Adrenaline, kTechId.AdrenalineTech, kTechId.None, kTechId.AllAliens)
    
    self.techTree:AddResearchNode(kTechId.FeintTech, kTechId.TwoHives, kTechId.Shift)
    self.techTree:AddBuyNode(kTechId.Feint, kTechId.FeintTech, kTechId.TwoHives, kTechId.Fade)
    self.techTree:AddResearchNode(kTechId.SapTech, kTechId.TwoHives, kTechId.Shift)
    self.techTree:AddBuyNode(kTechId.Sap, kTechId.SapTech, kTechId.TwoHives, kTechId.Fade)
    
    self.techTree:AddResearchNode(kTechId.BoneShieldTech, kTechId.Crag, kTechId.TwoHives)
    self.techTree:AddBuyNode(kTechId.BoneShield, kTechId.BoneShieldTech, kTechId.None, kTechId.Onos)
    self.techTree:AddResearchNode(kTechId.StompTech, kTechId.ThreeHives, kTechId.None)
    self.techTree:AddBuyNode(kTechId.Stomp, kTechId.StompTech, kTechId.None, kTechId.Onos)

    self.techTree:SetComplete()
    
end

function AlienTeam:StructureCreated(entity)

    PlayingTeam.StructureCreated(self, entity)
    
    // When creating a new upgrade structure, assign it to a hive.
    if self.upgradeStructureManager:AddStructure(entity) then
        self.updateTechTreeAndHives = true        
    end
    
end

function AlienTeam:TechAdded(entity)

    PlayingTeam.TechAdded(self, entity)
    
    // When creating a new upgrade structure, assign it to a hive.
    if self.upgradeStructureManager:AddStructure(entity) then
        self.updateTechTreeAndHives = true        
    end
    
end

function AlienTeam:TechRemoved(entity)

    PlayingTeam.TechRemoved(self, entity)

    // When deleting an upgrade structure, remove it from hive if it was the last one
    if self.upgradeStructureManager:RemoveStructure(entity) then
        self.updateTechTreeAndHives = true
    end
    
end

// As upgrade structure and hives are created and destroyed, modify alien tech tree on the fly. Ie, if a Crag is built when we have 1 hive,
// Shifts and Shades now require 2 hives as a prereq. 
function AlienTeam:UpdateTechTreeAndHives()

    // For each tech in AlienTeam.kTechTreeIdsToUpdate, if not supported already, change it to be supported 
    // with 1 more hive than we currently hive
    for index, techId in pairs(AlienTeam.kTechTreeIdsToUpdate) do

        // Get prereq
        local prereq = self.upgradeStructureManager:GetPrereqForTech(techId)
        
        // Update tech tree
        local node = self.techTree:GetTechNode(techId)
        ASSERT(node)        

        if node:GetPrereq1() ~= prereq then
        
            node:SetPrereq1(prereq)        
            self.techTree:SetTechNodeChanged(node)
            
        end 
       
    end
    
    // Assign upgrade structures to hives so players can see what they support
    // {entity id, supporting tech id} pairs. kTechId.None when supporting nothing.
    for index, hive in ipairs(GetEntitiesForTeam("Hive", self:GetTeamNumber())) do
    
        if hive:GetIsBuilt() and hive:GetIsAlive() then
        
            local supportingTechId = kTechId.None
            
            for index, pair in ipairs(self.upgradeStructureManager:GetSupportingStructures()) do
            
                if hive:GetId() == pair[1] then
                
                    supportingTechId = pair[2]
                    break
                    
                end
                
            end
            
            hive:SetSupportingUpgradeTechId(supportingTechId)
            
        end
        
    end
    
end

function AlienTeam:ProcessGeneralHelp(player)

    if(GetGamerules():GetGameStarted() and player:AddTooltipOncePer("HOWTO_EVOLVE_TOOLTIP", 45)) then
        return true
    end
    
    return PlayingTeam.ProcessGeneralHelp(self, player)
    
end

function AlienTeam:UpdateTeamSpecificGameEffects(teamEntities, enemyPlayers)

    PROFILE("AlienTeam:UpdateTeamSpecificGameEffects")
    
    PlayingTeam.UpdateTeamSpecificGameEffects(self, teamEntities, enemyPlayers)

    // Update tech tree and hives from main loop, after entity lists 
    // have been updated.   
    if self.updateTechTreeAndHives then
    
        self:UpdateTechTreeAndHives()
        self.updateTechTreeAndHives = false
        
    end
    
    // Clear gameplay effect we're processing
    for index, entity in ipairs(teamEntities) do
    
        entity:SetGameEffectMask(kGameEffect.InUmbra, false)
        entity:SetGameEffectMask(kGameEffect.Cloaked, false)
                    
    end
    
    // Update umbra
    self:UpdateUmbraGameEffects(teamEntities)
    
    // Update Fury
    self:UpdateFuryGameEffects(teamEntities)
    
    // Update shades
    self:UpdateShadeEffects(teamEntities, enemyPlayers)

end

function AlienTeam:GetNumWorkers()
	local drifters = GetEntitiesForTeam("Drifter", self:GetTeamNumber())
	return table.count(drifters)
end

function AlienTeam:GetNumMaxWorkers()
	local hives = GetEntitiesForTeam("Hive", self:GetTeamNumber())
	return table.count(hives) * kDriftersPerHive
end
