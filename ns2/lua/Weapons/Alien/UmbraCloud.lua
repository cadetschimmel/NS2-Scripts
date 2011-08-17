// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\UmbraCloud.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'UmbraCloud' (ScriptActor)

// Spores didn't stack in NS1 so consider that
UmbraCloud.kMapName = "umbracloud"

UmbraCloud.kRadius = 5    
UmbraCloud.kLifetime = 8     

// Have damage radius grow to maximum non-instantly


function UmbraCloud:OnInit()

    ScriptActor.OnInit(self)

    self:SetNextThink(UmbraCloud.kLifetime)
    
end

function UmbraCloud:GetRadius()
    
    return UmbraCloud.kRadius
    
end

function UmbraCloud:OnThink()

    ScriptActor.OnThink(self)

    // Expire after a time
     DestroyEntity(self)
     
end

Shared.LinkClassToMap("UmbraCloud", UmbraCloud.kMapName, {} )
