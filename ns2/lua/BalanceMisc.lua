// ======= Copyright � 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\BalanceMisc.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// Time spawning alien player must be in egg before hatching
kAlienSpawnTime = 2
kInitialMACs = 0
// Construct at a slower rate than players
kMACConstructEfficacy = .3
kStopFireProbability = .10       // 10% chance per second
kFlamethrowerAltTechResearchCost = 20
kDefaultFOV = 90
kStructureWarmupTime = 1.5
kDefaultStructureCost = 10
kStructureCircleRange = 4
kInfantryPortalUpgradeCost = 10
kInfantryPortalAttachRange = 10
kArmoryWeaponAttachRange = 10
// Minimum distance that initial IP spawns away from team location
kInfantryPortalMinSpawnDistance = 4
kWeaponStayTime = 30    // NS1
kInfestCost = 10
// For power points
kMarineRepairHealthPerSecond = 150
// The base weapons need to cost a small amount otherwise they can
// be spammed.
kRifleCost = 0
kExtendedRifleCost = 10
kPistolCost = 0
kAxeCost = 0
// % use per second
kJetpackUseFuelRate = 0.1
kJetpackReduceUseFuelRate = 0.02
kJetpackUpgradeAcceleration = 8
// % gain every second when not in use
kJetpackReplenishFuelRate = .25
kInitialDrifters = 3
kSkulkCost = 0
kEggCost = 5
kBuildHydraDelay = .5
kLerkWeaponSwitchTime = .5
kMACSpeedAmount = .5
// How close should MACs/Drifters fly to operate on target
kCommandStationEngagementDistance = 4
kInfantryPortalEngagementDistance = 2
kArmoryEngagementDistance = 3
kExtractorEngagementDistance = 2
kObservatoryEngagementDistance = 1
kPhaseGateEngagementDistance = 2
kRoboticsFactorEngagementDistance = 5
kARCEngagementDistance = 2
kSentryEngagementDistance = 2
kPlayerEngagementDistance = 1
kHeavyEngagementDistance = 1.5
kOnosEngagementDistance = 2
kLerkSporeShootRange = 9
kLerkUmbraShootRange = 1.5

// Marine buy costs
kFlamethrowerAltCost = 5

// Scanner sweep
kScanDuration = 10
kScanRadius = 20

// Distress Beacon (from NS1)
kDistressBeaconRange = 15
kDistressBeaconTime = 4

kEnergizeRange = 10
kEnergizeDuration = 6
kEnergizeEnergyIncrease = .2

// Rate of fire increase per level
kFuryROFIncrease = .15

kSprayDouseOnFireChance = .2

// Players and structures get energy back at this rate when on fire 
kOnFireEnergyRecuperationScalar = .1
// multiply the energy cost when on fire
kOnFireEnergyCostScalar = 1.7
// reduce the energy cost when affected primal scream
kOnPrimalScreamEnergyCostScalar = .3

// Infestation
kStructureInfestationRadius = 2
kHiveInfestationRadius = 20
kInfestationRadius = 7.5 // should be kMiniCystParentRange/2
kGorgeInfestationLifetime = 60

// Alien upgrades
kFrenzyMinHealth = 10
kSwarmInterval = 2
kSwarmDamageBonus = 1.25

kDamageVelocityScalar = 2.5

// Each upgrade costs this much extra evolution time
kUpgradeGestationTime = 2

// Cyst parent ranges, how far a cyst can support another cyst
//
// NOTE: I think the range is a bit long for kCystParentRange, there will be gaps between the
// infestation patches if the range is > kInfestationRadius * 1.75 (about).
// 
kHiveCystParentRange = 20 // distance from a hive a cyst can be connected
kCystParentRange = 20 // distance from a cyst another cyst (or minicyst) can be placed
kMiniCystParentRange = 15 // distance from a minicyst a cyst can be placed

// Damage over time that all cysts take when not connected
kCystUnconnectedDamage = 12