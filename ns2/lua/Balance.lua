// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Balance.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Auto-generated. Copy and paste from balance spreadsheet.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/BalanceHealth.lua")
Script.Load("lua/BalanceMisc.lua")

// MARINE COSTS
kCommandStationCost = 40

kExtractorCost = 15
kResourceUpgradeResearchCost = 5

kPowerPackElectrifyCost = 10
kPowerPackElectrifyTime = 10

kInfantryPortalCost = 10

kArmoryCost = 15
kAmmoPackCost = 1
kMedPackCost = 1
kArmsLabCost = 15

kAdvancedArmoryUpgradeCost = 30

kWeaponsModuleAddonCost = 20
kPrototypeLabCost = 40

kSentryCost = 15
kSentryTechCost = 5
kSentryAmmoCost = 30 // energy
kPowerPackCost = 15

kMACCost = 5
kMACMineCost = 5
kTechMinesResearchCost = 10
kTechEMPResearchCost = 10
kTechMACSpeedResearchCost = 5

kShotgunCost = 20
kShotgunTechResearchCost = 15

kGrenadeLauncherCost = 20
kGrenadeLauncherTechResearchCost = 15 // original: 15, to make 20 as a baseline cost for weapon upgrades
kNerveGasTechResearchCost = 15

kFlamethrowerCost = 25
kFlamethrowerTechResearchCost = 15

kRoboticsFactoryCost = 15
kARCCost = 20
kARCSplashTechResearchCost = 15
kARCArmorTechResearchCost = 15

kJetpackCost = 25
kJetpackTechResearchCost = 20
kJetpackFuelTechResearchCost = 25
kJetpackArmorTechResearchCost = 20

kExoskeletonCost = 15
kExoskeletonTechResearchCost = 20
kExoskeletonLockdownTechResearchCost = 20
kExoskeletonUpgradeTechResearchCost = 20

kMinigunCost = 30
kDualMinigunCost = 25
kDualMinigunTechResearchCost = 20

kWeapons1ResearchCost = 10
kWeapons2ResearchCost = 20
kWeapons3ResearchCost = 40
kArmor1ResearchCost = 10
kArmor2ResearchCost = 20
kArmor3ResearchCost = 40

kCatPackCost = 3
kCatPackTechResearchCost = 10

kExtendedRifleTechResearchCost = 10

kObservatoryCost = 15
kPhaseGateCost = 15
kPhaseTechResearchCost = 10

kHiveCost = 40

kMetabolizeTechCost = 10

kHarvesterCost = 15

kDrifterFlareTechResearchCost = 10

kMorpherCost = 15

kMiniCragCost = 5 // personal res
kCragCost = 10
kMatureCragCost = 10

kMiniShiftCost = 5 // personal res
kShiftCost = 10
kMatureShiftCost = 10

kMiniShadeCost = 5 // personal res
kShadeCost = 10
kMatureShadeCost = 10

kWhipCost = 15
kMatureWhipCost = 10

kGorgeCost = 10
kLerkCost = 30
kFadeCost = 50
kOnosCost = 75

kHydraCost = 10
kMiniCystCost = 3

kFrenzyResearchCost = 10
kSwarmResearchCost = 10
kCamouflageResearchCost = 10

kLeapResearchCost = 10
kBlinkResearchCost = 10

kCarapaceResearchCost = 10
kRegenerationResearchCost = 10

kCorpulenceResearchCost = 5
kBacteriaResearchCost = 5

kAdrenalineResearchCost = 5
kPiercingResearchCost = 5

kFeintResearchCost = 5
kSapResearchCost = 5

kBoneShieldResearchCost = 5
kStompResearchCost = 5

kCarapaceCost = 2
kRegenerationCost = 2
kLeapCost = 2
kFrenzyCost = 2
kSwarmCost = 2
kCamouflageCost = 2
kDropStructureAbilityCost = 2
kBileBombCost = 2
kPiercingCost = 2
kAdrenalineCost = 2
kFeintCost = 2
kSapCost = 2
kStompCost = 2
kBoneShieldCost = 2

kMelee1ResearchCost = 10
kMelee2ResearchCost = 20
kMelee3ResearchCost = 40
kAlienArmor1ResearchCost = 10
kAlienArmor2ResearchCost = 20
kAlienArmor3ResearchCost = 40


kPlayingTeamInitialTeamRes = 50

kPlayerInitialIndivRes = 25

kResourceTowerResourceInterval = 7

kPlayerResPerInterval = 0.18 // original 0.25, changed because of tech point multiplier and smaller interval

kKillRewardMin = 1
kKillRewardMax = 3
kKillReward = 1

kKillTeamReward = 1

kCommanderTax = 0.4



























// MARINE DAMAGE
kRifleDamage = 10
kRifleDamageType = kDamageType.Normal
kRifleFireDelay = 0.0555
kRifleClipSize = 50
kExtendedRifleClipSize = 70

kRifleMeleeDamage = 20
kRifleMeleeDamageType = kDamageType.Normal
kRifleMeleeFireDelay = 0.7


kPistolDamage = 25
kPistolDamageType = kDamageType.Light
kPistolFireDelay = 0.1
kPistolClipSize = 10

kPistolAltDamage = 40
kPistolAltFireDelay = 0.25



kAxeDamage = 40
kAxeDamageType = kDamageType.Structural
kAxeFireDelay = 0.8


kGrenadeLauncherGrenadeDamage = 140
kGrenadeLauncherGrenadeDamageType = kDamageType.Structural
kGrenadeLauncherFireDelay = 0.4
kGrenadeLauncherClipSize = 4
kGrenadeLauncherGrenadeDamageRadius = 8
kGrenadeLifetime = 1.5  // original 3

kShotgunMaxDamage = 16.5 // original 20 in build 180, 18 in build 181
kShotgunMinDamage = 6
kShotgunDamageType = kDamageType.Normal
kShotgunFireDelay = 0.9
kShotgunClipSize = 8
kShotgunBulletsPerShot = 10
kShotgunMinDamageRange = 14
kShotgunMaxDamageRange = 4.5
kShotgunSpreadDegrees = 10 // original 20, decreased because i want to stack it up 4 times

kFlechetteDamageScalar = 1.35 // 35% more damage
kFlechettesPerShot = 15
kFlechetteDamage = 2 // per flechette
kFlechetteSpreadRange = 20
kFlechetteAmmo = 6

kFlamethrowerDamage = 0.2 // original 20, decreased because of stacks
kFlamethrowerDamageType = kDamageType.Flame
kFlamethrowerFireDelay = 0.15
kFlamethrowerClipSize = 70
kFlamethrowerMaxStacks = 90
kFlamethrowerBurnDuration = 5 // seconds
kFlamethrowerStackRate = 0.2 // time for increasing stack
kBurnDamagePerSecond = 2.0 // original: 8, decreased because of stacks
kFlameRadius = 1.8

kMinigunDamage = 25
kMinigunDamageType = kDamageType.Normal
kMinigunFireDelay = 0.06
kMinigunClipSize = 250

kMACAttackDamage = 5
kMACAttackDamageType = kDamageType.Normal
kMACAttackFireDelay = 0.6


kSentryAttackDamage = 13
kSentryAttackDamageType = kDamageType.Light
kSentryAttackBaseROF = 0.20 // original 8
kSentryAttackRandROF = 0.04
kSentryAttackBulletsPerSalvo = 1
kSentryMaxAmmo = 110 // originally 250, we need less bullets since rof is lower

kARCDamage = 400
kARCDamageType = kDamageType.StructuresOnly
kARCFireDelay = 3
kARCRange = 26

kWeapons1DamageScalar = 1.1
kWeapons2DamageScalar = 1.2
kWeapons3DamageScalar = 1.3



















// ALIEN DAMAGE
kBiteDamage = 75
kBiteDamageType = kDamageType.Normal
kBiteFireDelay = 0.45
kBiteEnergyCost = 5.5

kLeapEnergyCost = 40

kParasiteDamage = 10
kParasiteDamageType = kDamageType.Normal
kParasiteFireDelay = 0.5
kParasiteEnergyCost = 30

kSpitDamage = 25
kSpitDamageType = kDamageType.Normal
kSpitFireDelay = 0.5
kSpitEnergyCost = 7

kHealsprayDamage = 13
kHealsprayDamageType = kDamageType.Light
kHealsprayFireDelay = 0.8
kHealsprayEnergyCost = 15

kBileBombDamage = 320
kBileBombDamageType = kDamageType.StructuresOnly
kBileBombFireDelay = 1
kBileBombEnergyCost = 26

kSpikesMaxZoomFaktor = 3 // = 3 seconds to achieve max zoom damage modifier
kSpikeMaxDamage = 15 // original: 30
kSpikeMinDamage = 3
kSpikeMaxRange = 1
kSpikeMinRange = 8
kSpikeDamageType = kDamageType.Light
kSpikeFireDelay = 0.1
kSpikeEnergyCost = 1.35
kPiercingDamageScalar = 1.4

kSpikesAltDamage = 106 // 2 sniper shots + 1 parasite will kill a marine
kSpikesAltDamageType = kDamageType.Normal
kSpikesAltFireDelay = 1
kSpikesAltEnergyCost = 38 // 3 sniper shots in a row

kSporesDamagePerSecond = 8
kSporesDamageType = kDamageType.Normal
kSporesFireDelay = 0.7
kSporesEnergyCost = 20
kSporeMineEnergyCost = 45
kSporeMineFireDelay = 1.2
kSporeMineTriggerRange = 2.7
kSporeMineLivingTime = 30

kUmbraEnergyCost = 35
kUmbraFireDelay = 0.8

kSwipeDamage = 70
kSwipeDamageType = kDamageType.Puncture
kSwipeFireDelay = 0.75
kSwipeEnergyCost = 10

kStabDamage = 160
kStabDamageType = kDamageType.Puncture
kStabFireDelay = 1.9
kStabEnergyCost = 30

kBlinkEnergyCost = 18
kBlinkInitialEnergyCost = 25

kFetchEnergyCost = 24
kFetchInitialEnergyCost = 16

kGoreDamage = 90
kGoreDamageType = kDamageType.Normal
kGoreFireDelay = 0.7
kGoreEnergyCost = 2

kChargeMaxDamage = 4
kChargeMinDamage = 1



kHydraSpikeDamage = 20
kHydraSpikeDamageType = kDamageType.Normal



kDrifterAttackDamage = 5
kDrifterAttackDamageType = kDamageType.Normal
kDrifterAttackFireDelay = 0.6


kMelee1DamageScalar = 1.1
kMelee2DamageScalar = 1.2
kMelee3DamageScalar = 1.3










// SPAWN TIMES
kMarineRespawnTime = 10
kAlienRespawnTime = 13

// BUILD/RESEARCH TIMES
kRecycleTime = 8
kArmoryBuildTime = 15
kAdvancedArmoryResearchTime = 60
kWeaponsModuleAddonTime = 40
kPrototypeLabBuildTime = 20
kArmsLabBuildTime = 19

kMACBuildTime = 5
kExtractorBuildTime = 15
kResourceUpgradeResearchTime = 30
kResourceUpgradeAmount = 0.3333

kInfantryPortalBuildTime = 10
kInfantryPortalTransponderTechResearchTime = 30
kInfantryPortalTransponderTechResearchCost = 10
kInfantryPortalTransponderUpgradeTime = 30
kInfantryPortalTransponderUpgradeCost = 10

kExtendedRifleTechResearchTime = 20
kShotgunTechResearchTime = 25
kDualMinigunTechResearchTime = 20
kGrenadeLauncherTechResearchTime = 20

kCommandStationBuildTime = 15

kPowerPointBuildTime = 15
kPowerPackBuildTime = 13

kRoboticsFactoryBuildTime = 30
kARCBuildTime = 20
kARCSplashTechResearchTime = 30
kARCArmorTechResearchTime = 30

kSentryTechResearchTime = 15
kSentryBuildTime = 10

kTechMinesResearchTime = 20
kTechEMPResearchTime = 20
kTechMACSpeedResearchTime = 15

kJetpackTechResearchTime = 60
kJetpackFuelTechResearchTime = 90
kJetpackArmorTechResearchTime = 60
kExoskeletonTechResearchTime = 90
kExoskeletonLockdownTechResearchTime = 60
kExoskeletonUpgradeTechResearchTime = 60

kFlamethrowerTechResearchTime = 60
kFlamethrowerAltTechResearchTime = 60

kNerveGasTechResearchTime = 60

kDualMinigunTechResearchTime = 60
kCatPackTechResearchTime = 15

kObservatoryBuildTime = 15
kPhaseTechResearchCost = 15
kPhaseTechResearchTime = 45
kPhaseGateBuildTime = 12

kWeapons1ResearchTime = 60
kWeapons2ResearchTime = 90
kWeapons3ResearchTime = 120
kArmor1ResearchTime = 60
kArmor2ResearchTime = 90
kArmor3ResearchTime = 120


kHiveBuildTime = 180

kDrifterBuildTime = 4
kHarvesterBuildTime = 20

kDrifterFlareTechResearchTime = 25

kMorpherBuildTime = 20

kMiniCragBuildTime = 10
kUpgradeMiniCragResearchTime = 10
kCragBuildTime = 20
kMatureCragResearchTime = 10

kWhipBuildTime = 20
kMatureWhipResearchTime = 10

kUpgradeMiniShiftResearchTime = 10
kMiniShiftBuildTime = 10
kShiftBuildTime = 20
kMatureShiftResearchTime = 10

kUpgradeMiniShadeResearchTime = 10
kMiniShadeBuildTime = 10
kShadeBuildTime = 20
kMatureShadeResearchTime = 10

kHydraBuildTime = 12
kCystBuildTime = 1
kMiniCystBuildTime = 1

kSkulkGestateTime = 3
kGorgeGestateTime = 6
kLerkGestateTime = 9
kFadeGestateTime = 12
kOnosGestateTime = 15

kEvolutionGestateTime = 3
kMetabolizeTechResearchTime = 15
kMetabolizeTime = 10
kMetabolizeResearchScalar = 0.2
kFuryTime = 6

kFrenzyResearchTime = 25
kSwarmResearchTime = 25
kLeapResearchTime = 20
kBlinkResearchTime = 20
kCarapaceResearchTime = 20
kRegenerationResearchTime = 20
kCamouflageResearchTime = 20

kCorpulenceResearchTime = 10
kBacteriaResearchTime = 10

kAdrenalineResearchTime = 15
kPiercingResearchTime = 15

kFeintResearchTime = 15
kSapResearchTime = 15

kBoneShieldResearchTime = 20
kStompResearchTime = 20

kLerkResearchTime = 25
kFadeResearchTime = 30
kOnosResearchTime = 40

kLerkResearchCost = 20
kFadeResearchCost = 30
kOnosResearchCost = 40

kMelee1ResearchTime = 20
kMelee2ResearchTime = 30
kMelee3ResearchTime = 40
kAlienArmor1ResearchTime = 20
kAlienArmor2ResearchTime = 30
kAlienArmor3ResearchTime = 40



















// ENERGY COSTS
kCommandStationInitialEnergy = 50  kCommandStationMaxEnergy = 200
kCommandCenterNanoGridCost = 50  

kHiveInitialEnergy = 80  kHiveMaxEnergy = 100
kCystCost = 20
kMetabolizeCost = 25  

kObservatoryInitialEnergy = 25  kObservatoryMaxEnergy = 100
kObservatoryScanCost = 20  
kObservatoryDistressBeaconCost = 50  

kDrifterCost = 15  

kMiniCragInitialEnergy = 5	kMiniCragMaxEnergy = 25
kCragInitialEnergy = 25  kCragMaxEnergy = 100
kCragHealCost = 0  
kCragUmbraCost = 30  
kCragBabblersCost = 75  
kMatureCragMaxEnergy = 150

kWhipInitialEnergy = 25  kWhipMaxEnergy = 100
kWhipFuryInitialEnergy = 50  kWhipFuryCost = 50  
kWhipBombardInitialEnergy = 25  
kWhipBombardCost = 15
kMatureWhipMaxEnergy = 150

kMiniShiftInitialEnergy = 5	kMiniShiftMaxEnergy = 25
kShiftInitialEnergy = 25  kShiftMaxEnergy = 100
kShiftEchoCost = 75  
kShiftEnergizeCost = 0 
kMatureShiftMaxEnergy = 150

kMiniShadeInitialEnergy = 5	kMiniShadeMaxEnergy = 25
kShadeInitialEnergy = 25  kShadeMaxEnergy = 100
kShadeCloakCost = 25  
kShadePhantasmFadeCost = 25  
kShadePhantasmOnosCost = 50  
kShadePhantasmCost = 75  
kMatureShadeMaxEnergy = 150

kEnergyUpdateRate = 0.5

















