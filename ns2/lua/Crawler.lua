// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Crawler.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Skulk.lua")
Script.Load("lua/Weapons/Alien/BurstEvolve.lua")

/**
* behave like a skulk, but reduced speed and no jumping
*/
class 'Crawler' (Skulk)

Crawler.kMapName = "crawler"
Crawler.kMaxSpeed = 3.5
Crawler.kMaxArmor = 0
Crawler.kMaxHealth = 800
Crawler.kDamageToEnergyScalar = .15
Crawler.kLoseEnergyPerSecond = 1.5

// once we fall under this amount, we die
Crawler.kEnergyLifeLimit = 5

Crawler.kModelName = PrecacheAsset("models/alien/drifter/drifter.model")
Crawler.kViewModelName = PrecacheAsset("models/alien/skulk/skulk_view.model")

Crawler.kBurstSound = PrecacheAsset("sound/ns2.fev/alien/common/hatch")
Crawler.kBurstCinematic = PrecacheAsset("cinematics/alien/crawler/burstcorpse.cinematic")

if Server then

	function Crawler:InitWeapons()
	
	    Alien.InitWeapons(self)
	    
	    self:GiveItem(BurstEvolve.kMapName)
	    
	    self:SetActiveWeapon(BurstEvolve.kMapName)
	    
	end
	
	// store data about last lifeform serverside, we need it in case we evolve back
	function Crawler:SetLastLifeForm(techid)		
		//Print("last lifeform stored")
		self.lastLifeFormTechId = techid		
	end
	
	function Crawler:GetLastLifeForm(techid)		
		return self.lastLifeFormTechId		
	end
	
	// evolves to last lifeform
	function Crawler:EvolveToLastLifeForm()
	
		//Print("evolving to last lifeform")
		
		local techid = self:GetLastLifeForm()
		
		if techid ~= nil and self:GetGameEffectMask(kGameEffect.OnInfestation) then
		
			// disables all upgrades and abilities
			self:RemoveChildren()
			
	        local newPlayer = self:Replace(Embryo.kMapName)
	        //local position = self:GetOrigin()
	        //position.y = position.y + Embryo.kEvolveSpawnOffset
	        newPlayer:SetOrigin(self:GetOrigin())
	        
	        // Clear angles, in case we were wall-walking or doing some crazy alien thing
	        local angles = Angles(self:GetAngles())
	        angles.roll = 0.0
	        angles.pitch = 0.0
	        newPlayer:SetAngles(angles)
	        
	        // Eliminate velocity so that we don't slide or jump as an egg
	        newPlayer:SetVelocity(Vector(0, 0, 0))
	        
	        newPlayer:DropToFloor()
	        
	        newPlayer:SetGestationData( { techid }, { kTechId.Skulk } , 1, 1)
	        newPlayer.evolveTime = newPlayer:GetEvolutionTime() / 2
	        
	        newPlayer:SetHealth(Egg.kHealth / 2)
			newPlayer:SetArmor(Egg.kArmor / 2)
	        
	        success = true
			
		end
	
	end
	
	// set and get last attacker to handle kill reward
	function Crawler:SetLastAttacker(attacker)
		
		if attacker and attacker.GetId then
			self.lastAttacker = attacker:GetId()
		end
		
	end
	
	function Crawler:GetLastAttacker()
	
		if self.lastAttacker ~= nil then
			return Shared.GetEntity(self.lastAttacker)
		else
			return self
		end
		
	end

end

function Crawler:GetCanBuyOverride()
	return false
end

function Crawler:PlayBurstEffects()

	Shared.PlaySound(self, Crawler.kBurstSound)	
	Shared.CreateEffect(self, Crawler.kBurstCinematic, self)

end

// crawlers cannot jump, otherwise we should call them in another way?!
function Crawler:HandleJump(input, velocity)
	return
end

function Crawler:GetMaxSpeed()
	return Crawler.kMaxSpeed
end

// crawlers translate damage taken to their energy treshhold, not a very beautiful hack :)
function Crawler:TakeDamage(damage, attacker, doer, point, direction)

	if Server then
		if damage > 0 then
			local energytodrain = damage * Crawler.kDamageToEnergyScalar
			self:DeductAbilityEnergy(energytodrain)
			Print("drained energy: (%s)", energytodrain)
			
			if Server then
				self:SetLastAttacker(attacker)
			end
		end
	end

end

function Crawler:OnUpdate(deltaTime)

	// calling here alien since we don't need to update skulk related stuff
	Alien.OnUpdate(self, deltaTime)

	if Server and self:GetIsAlive() then
		if self:GetEnergy() < Crawler.kEnergyLifeLimit then
			Alien.OnKill(self, nil, self:GetLastAttacker(), nil, nil, nil)
		end
	end

end

function Crawler:GetRecuperationRate()
	return -5
end

Shared.LinkClassToMap( "Crawler", Crawler.kMapName, { } )