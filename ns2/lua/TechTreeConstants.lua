// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TechTreeConstants.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kTechId = enum({
    
    'None', 
    
    // General orders and actions ("Default" is right-click)
    'Default', 'Move', 'Attack', 'Build', 'Construct', 'Cancel', 'Recycle', 'Weld', 'Stop', 'SetRally', 'SetTarget',
    
    // Commander menus for selected units
    'RootMenu', 'BuildMenu', 'AdvancedMenu', 'AssistMenu', 'MarkersMenu', 'UpgradesMenu', 'EggMenu',
    
    // Life Form Tech
    'LerkTech', 'FadeTech', 'OnosTech', 'Morpher',
    
    // Egg Types
    'GorgeEgg', 'LerkEgg', 'FadeEgg', 'OnosEgg',
    
    // Command station menus
    'CommandStationUpgradesMenu',
    
    // Armory + Arms Lab menus
    'ArmsLabUpgradesMenu',
    
    // Robotics factory menus
    'RoboticsFactoryARCUpgradesMenu', 'RoboticsFactoryMACUpgradesMenu',
    
    // Prototype lab menus
    'PrototypeLabUpgradesMenu',

    'ReadyRoomPlayer', 
    
    // Doors
    'Door', 'DoorOpen', 'DoorClose', 'DoorLock', 'DoorUnlock',

    // Misc
    'ResourcePoint', 'TechPoint', 'Target',
    
    /////////////
    // Marines //
    /////////////
    
    // Marine classes + spectators
    'Marine', 'Heavy', 'MarineCommander', 'Spectator', 'AlienSpectator',
    
    // Marine alerts (specified alert sound and text in techdata if any)
    'MarineAlertAcknowledge', 'MarineAlertNeedMedpack', 'MarineAlertNeedAmmo', 'MarineAlertNeedOrder', 'MarineAlertHostiles', 'MarineCommanderEjected',
    
    'MarineAlertSentryFiring', 'MarineAlertSentryUnderAttack', 'MarineAlertSentryLowAmmo', 'MarineAlertSentryNoAmmo', 'MarineAlertCommandStationUnderAttack', 'MarineAlertInfantryPortalUnderAttack', 'MarineAlertStructureUnderAttack', 'MarineAlertExtractorUnderAttack', 'MarineAlertSoldierLost',
    
    'MarineAlertResearchComplete', 'MarineAlertUpgradeComplete', 'MarineAlertOrderComplete', 'MarineAlertWeldingBlocked', 'MarineAlertMACBlocked', 'MarineAlertNotEnoughResources', 'MarineAlertObjectiveCompleted', 'MarineAlertConstructionComplete',
    
    // Select squads
    'SelectRedSquad', 'SelectBlueSquad', 'SelectGreenSquad', 'SelectYellowSquad', 'SelectOrangeSquad',
    
    // Marine orders 
    'SquadMove', 'SquadAttack', 'SquadDefend', 'SquadSeekAndDestroy', 'SquadHarass', 'SquadRegroup', 
    
    // Marine tech 
    'CommandStation', 'MAC', 'Armory', 'InfantryPortal', 'Extractor', 'ExtractorUpgrade', 'PowerPack', 'ElectrifiedPowerPack', 'SentryTech', 'Sentry', 'ARC', 'InfantryPortalTransponderTech', 'InfantryPortalTransponderUpgrade', 'InfantryPortalTransponder',
    'Scan', 'AmmoPack', 'MedPack', 'CatPack', 'CatPackTech', 'PowerPoint', 'AdvancedArmoryUpgrade', 'Observatory', 'ObservatoryEnergy', 'DistressBeacon', 'PhaseGate', 'RoboticsFactory', 'ArmsLab',
    'WeaponsModule', 'PrototypeLab', 'AdvancedArmory', 'SentryAmmo',
    
    // Marine direct Supply
    'SupplyMed', 'SupplyAmmo', 'SupplyCat',
    
    // Weapon tech
    'ExtendedRifleTech', 'ShotgunTech', 'GrenadeLauncherTech', 'FlamethrowerTech', 'NerveGasTech', 'FlamethrowerAltTech', 'DualMinigunTech',
    
    // Marine buys
    'NerveGas', 'FlamethrowerAlt',
    
    // Research 
    'PhaseTech', 'MACWeldingTech', 'MACSpeedTech', 'MACMinesTech', 'MACEMPTech', 'ARCArmorTech', 'ARCSplashTech', 'JetpackTech', 'ExoskeletonTech',
    
    // MAC (build bot) abilities
    'MACMine', 'MACEMP',
    
    // Weapons 
    'Rifle', 'ExtendedRifle', 'Pistol', 'Shotgun', 'Minigun', 'GrenadeLauncher', 'Flamethrower', 'Axe', 'Minigun',
    
    // Armor
    'Jetpack', 'JetpackFuelTech', 'JetpackArmorTech', 'Exoskeleton', 'ExoskeletonLockdownTech', 'ExoskeletonUpgradeTech',
    
    // Marine upgrades
    'Weapons1', 'Weapons2', 'Weapons3', 'Armor1', 'Armor2', 'Armor3',
    
    // Activations
    'ARCDeploy', 'ARCUndeploy',
    
    // Commander abilities
    'NanoDefense', 'ReplicateTech', 'PowerPackElectrify',
    
    // Special tech
    'TwoCommandStations', 'ThreeCommandStations',

    ////////////
    // Aliens //
    ////////////

    // Alien lifeforms 
    'Skulk', 'Gorge', 'Lerk', 'Fade', 'Onos', "AlienCommander", "AllAliens",
    
    // Alien abilities (not all are needed, only ones with damage types)
    'Bite', 'Parasite', 'Spit', 'Spray', 'BileBomb', 'Spikes', 'SpikesAlt', 'Spores', 'HydraSpike', 'SwipeBlink', 'StabBlink', 'SwipeFetch', 'Gore', 
    
    // Alien structures 
    'Hive', 'Harvester', 'HarvesterUpgrade', 'Drifter', 'Egg', 'Cocoon', 'Embryo', 'Hydra', 'Cyst', 'MiniCyst', 'SporeMine', 'MiniCrag', 'MiniShift', 'MiniShade',

    // Upgrade buildings and abilities (mini structure, structure, upgraded structure, passive, triggered, targeted)
    'Whip', 'UpgradeWhip', 'MatureWhip', 'WhipAcidStrike', 'WhipFury', 'WhipBombard',
    'UpgradeMiniCrag', 'Crag', 'UpgradeCrag', 'MatureCrag', 'CragHeal', 'CragUmbra', 'CragBabblers',    
    'UpgradeMiniShift', 'Shift', 'UpgradeShift', 'MatureShift', 'ShiftRecall', 'ShiftEcho', 'ShiftEnergize', 
    'UpgradeMiniShade', 'Shade', 'UpgradeShade', 'MatureShade', 'ShadeDisorient', 'ShadeCloak', 'ShadePhantasmMenu', 'ShadePhantasmFade', 'ShadePhantasmOnos', 'ShadePhantasmHive',
    
    // Whip movement
    'WhipRoot', 'WhipUnroot',
    
    // Alien abilities and upgrades - BabblerTech
    'BabblerTech', 'EchoTech', 'PhantasmTech', 
    'Melee1Tech', 'Melee2Tech', 'Melee3Tech', 'AlienArmor1Tech', 'AlienArmor2Tech', 'AlienArmor3Tech',
    'AdrenalineTech', 'BileBombTech', 'LeapTech', 'BlinkTech', 'BacteriaTech', 'FeintTech', 'SapTech', 'StompTech', 'BoneShieldTech', 'CarapaceTech', 'PiercingTech',
    'FrenzyTech', 'SwarmTech', 'RegenerationTech', 'CamouflageTech',    
    
    // Global upgrades
    'Carapace', 'Regeneration', 'Frenzy', 'Swarm', 'Adrenaline', 'Camouflage',
    
    // Alien-specific upgrades
    'Leap', 'Blink', 'Bacteria', 'Corpulence', 'DropStructureAbility', 'HarvesterAbility', 'Piercing', 'Feint', 'Sap', 'Gore', 'Stomp', 'BoneShield',     
    
    // Drifter tech/abilities
    'DrifterFlareTech', 'DrifterFlare', 'DrifterParasiteTech', 'DrifterParasite', 
    
    // Alien alerts
    'AlienAlertNeedHealing', 'AlienAlertStructureUnderAttack', 'AlienAlertHiveUnderAttack', 'AlienAlertHiveDying', 'AlienAlertHarvesterUnderAttack', 'AlienAlertLifeformUnderAttack', 'AlienAlertGorgeBuiltHarvester', 'AlienCommanderEjected',
    
    'AlienAlertNotEnoughResources', 'AlienAlertResearchComplete', 'AlienAlertUpgradeComplete', 'AlienAlertHiveComplete',
    
    // Hive markers    
    'ThreatMarker', 'LargeThreatMarker', 'NeedHealingMarker', 'WeakMarker', 'ExpandingMarker',
    
    // Special tech
    'TwoHives', 'ThreeHives',
    
    // Infestation
    'Infestation',
    
    // Commander abilities
    'MetabolizeTech', 'Metabolize',
    
    // Voting commands
    'VoteDownCommander1', 'VoteDownCommander2', 'VoteDownCommander3', 

    // Maximum index
    'Max'
    
    })

// Increase techNode network precision if more needed
kTechIdMax  = kTechId.Max

// Tech types
kTechType = enum({ 'Invalid', 'Order', 'Research', 'Upgrade', 'Action', 'Buy', 'Build', 'EnergyBuild', 'Manufacture', 'Activation', 'Menu', 'EnergyManufacture', 'PlasmaManufacture', 'Special' })

// Button indices
kRecycleCancelButtonIndex   = 12
kMarineUpgradeButtonIndex   = 5
kAlienBackButtonIndex       = 8

