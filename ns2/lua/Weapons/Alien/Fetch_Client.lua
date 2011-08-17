// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\Fetch_Client.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Draw ghost version of Fade showing where you'll Fetch.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function Fetch:GetShowingGhost()
    return self.showingGhost
end

function Fetch:SetFadeGhostAnimation(animName)

    if self.fadeGhostAnimModel then
    
        local currentAnim = self.fadeGhostAnimModel:GetAnimation()
        
        if currentAnim == Fade.kFetchInAnim then
        
            self.fadeGhostAnimModel:SetQueuedAnimation(animName)
            
        elseif currentAnim ~= animName then
        
            self.fadeGhostAnimModel:SetAnimation(animName)
            
        end
        
    end
    
end

function Fetch:OnUpdate(deltaTime)

    Ability.OnUpdate(self, deltaTime)
    
    if not Shared.GetIsRunningPrediction() then

        local player = self:GetParent()
        
        if player == Client.GetLocalPlayer() and player:GetActiveWeapon() == self then
        
            if not self.fadeGhostAnimModel and self.showingGhost then

                // Create ghost Fade in random dramatic attack pose
                self.fadeGhostAnimModel = CreateAnimatedModel(Fade.kModelName)
                self.fadeGhostAnimModel:SetAnimation(Fade.kFetchInAnim)
                self.fadeGhostAnimModel:SetCastsShadows(false)
                
            end
            
            // Destroy ghost
            if self.fadeGhostAnimModel and not self.showingGhost then
                self:DestroyGhost()
            end
            
            // Update ghost position 
            if self.fadeGhostAnimModel then
            
                local coords, valid, FetchType = self:GetFetchPosition(player)
                
                self.fadeGhostAnimModel:SetCoords(coords)
                self.fadeGhostAnimModel:SetIsVisible(valid)                    
                self.fadeGhostAnimModel:SetPoseParam("crouch", player:GetCrouchAmount())
                
                if FetchType == kFetchType.InAir then
                
                    self:SetFadeGhostAnimation(Player.kAnimJump)
                    
                elseif FetchType == kFetchType.Attack then
                
                    if NetworkRandom() < .1 then
                        self:SetFadeGhostAnimation(Player.kAnimTaunt)
                    else
                        self:SetFadeGhostAnimation(chooseWeightedEntry(Fade.kAnimSwipeTable))
                    end

                else
                    self:SetFadeGhostAnimation("idle")
                end

                self.fadeGhostAnimModel:OnUpdate(deltaTime)

                if self.FetchPreviewEffect then
                
                    if not valid then
                        Client.DestroyCinematic(self.FetchPreviewEffect)
                        self.FetchPreviewEffect = nil
                    else
                        self.FetchPreviewEffect:SetCoords(coords)
                    end
                    
                elseif valid then
                
                    // Create Fetch preview effect
                    self.FetchPreviewEffect = Client.CreateCinematic(RenderScene.Zone_Default)
                    self.FetchPreviewEffect:SetCinematic(Fetch.kFetchPreviewEffect)
                    self.FetchPreviewEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
                    self.FetchPreviewEffect:SetCoords(coords)

                end
                
            end
          
        end
        
        // Expire model once animation finishes    
        if self.FetchOutModel ~= nil and Shared.GetTime() >= self.FetchOutExpireTime then
            self:DestroyFetchOutModel()
        end
        
    end
    
end

function Fetch:CreateFetchOutEffect(player)

    // Create render model of fade vanishing
    self:DestroyFetchOutModel()
    
    self.FetchOutModel = CreateAnimatedModel(Fade.kModelName)
    self.FetchOutModel:SetAnimation(Fade.kFetchOutAnim)
    self.FetchOutModel:SetCoords(player:GetViewAngles():GetCoords())
    
    self.FetchOutExpireTime = Shared.GetTime() + self.FetchOutModel:GetAnimationLength()

end

function Fetch:DestroyFetchOutModel()

    if self.FetchOutModel then
    
        self.FetchOutModel:OnDestroy()
        self.FetchOutModel = nil
        
        self.FetchEndTime = nil
        
    end

end

function Fetch:OnDestroy()

    self:DestroyFetchOutModel()
    
    self:DestroyGhost()
    
    Ability.OnDestroy(self)
    
end


function Fetch:DestroyGhost()

    if self.fadeGhostAnimModel ~= nil then
    
        self.fadeGhostAnimModel:OnDestroy()
        self.fadeGhostAnimModel = nil
        
    end
    
    if Client and self.FetchPreviewEffect then
    
        Client.DestroyCinematic(self.FetchPreviewEffect)
        self.FetchPreviewEffect = nil
        
    end
        
end

// Perform cool camera transition effect while Fetching
function Fetch:GetCameraCoords()

    local time = Shared.GetTime()
    
    if self.FetchStartTime ~= nil and self.FetchTransitionTime ~= nil then
    
        if (time >= self.FetchStartTime) and (time <= (self.FetchStartTime + self.FetchTransitionTime)) then
        
            local timeScalar = Clamp((time - self.FetchStartTime) / self.FetchTransitionTime, 0, 1)
            
            timeScalar = math.sin( timeScalar * math.pi / 2 )
            
            // Interpolate between z axis in start/end view coords
            return true, Shared.SlerpCoords(self.cameraStart, self.cameraEnd, timeScalar)
            
        end
        
    end
    
    return false, nil
    
end

function Fetch:SetFetchCamera(startCoords, endCoords, cameraTransitionTime) 

    self.cameraStart = startCoords
    self.cameraEnd = endCoords
    
    self.FetchTransitionTime = cameraTransitionTime
    
    self.FetchStartTime = Shared.GetTime()
    
end
