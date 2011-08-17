// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIMinimap.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
// Modded by: feha
//
// Manages displaying the minimap and icons on the minimap.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScanlines.lua")
Script.Load("lua/FunctionContracts.lua")

class 'GUIMinimap' (GUIScript)

GUIMinimap.kModeMini = 0
GUIMinimap.kModeBig = 1

GUIMinimap.kMapBackgroundXOffset = 10
GUIMinimap.kMapBackgroundYOffset = 10

GUIMinimap.kBackgroundTextureAlien = "ui/alien_commander_background.dds"
GUIMinimap.kBackgroundTextureMarine = "ui/marine_commander_background.dds"
GUIMinimap.kBackgroundTextureCoords = { X1 = 473, Y1 = 0, X2 = 793, Y2 = 333 }

GUIMinimap.kBigSizeScale = 2
GUIMinimap.kBackgroundSize = GUIScale(300)
GUIMinimap.kBackgroundWidth = GUIMinimap.kBackgroundSize
GUIMinimap.kBackgroundHeight = GUIMinimap.kBackgroundSize

//------------------------------------------------------------------------------------------------
// A variable to be able to scale the minmap easyer for spectators
GUIMinimap.kSmallSpectatorSizeScale = 1
// The blips are very small on the small minimap, so I want them slightly bigger
GUIMinimap.kSpectatorSmallBlipScale = GUIMinimap.kSmallSpectatorSizeScale * 1.15
// This is the variable for minimaps small size as spectator
GUIMinimap.kMinimapSmallSpectatorSize = Vector(GUIMinimap.kBackgroundWidth * GUIMinimap.kSmallSpectatorSizeScale, GUIMinimap.kBackgroundHeight * GUIMinimap.kSmallSpectatorSizeScale, 0)
// Spectator team dont have its own color sadly, lets give it one temporary
GUIMinimap.kSpectatorTeamColor = kNeutralTeamColor
// How transparent do you want the map? A value of 1 is solid, and 0 isinvisible
GUIMinimap.kBigSizeAlpha = 0.5
GUIMinimap.kSmallSpectatorSizeAlpha = 1
// Should the self-icon show for spectators? NS2HD didnt want it, but I prefer it. True/False
GUIMinimap.kSpectatorShowSelfIcon = true
//------------------------------------------------------------------------------------------------

local kStaticPriorityBlips = {}

kStaticPriorityBlips["CommandStation"] = true
kStaticPriorityBlips["Extractor"] = true
kStaticPriorityBlips["Hive"] = true
kStaticPriorityBlips["Harvester"] = true

GUIMinimap.kMapMinMax	= 55
GUIMinimap.kMapRatio = function() return ConditionalValue(Client.minimapExtentScale.z > Client.minimapExtentScale.x, Client.minimapExtentScale.z / Client.minimapExtentScale.x, Client.minimapExtentScale.x / Client.minimapExtentScale.z) end

GUIMinimap.kMinimapSmallSize = Vector(GUIMinimap.kBackgroundWidth, GUIMinimap.kBackgroundHeight, 0)
GUIMinimap.kMinimapBigSize = Vector(GUIMinimap.kBackgroundWidth * GUIMinimap.kBigSizeScale, GUIMinimap.kBackgroundHeight * GUIMinimap.kBigSizeScale, 0)

GUIMinimap.kBlipSize = GUIScale(30)
GUIMinimap.kUnpoweredNodeBlipSize = GUIScale(32)

GUIMinimap.kTeamColors = { }
GUIMinimap.kTeamColors[kMinimapBlipTeam.Friendly] = Color(0, 1, 0, 1)
GUIMinimap.kTeamColors[kMinimapBlipTeam.Enemy] = Color(1, 0, 0, 1)
GUIMinimap.kTeamColors[kMinimapBlipTeam.Neutral] = Color(0.5, 0.5, 0.5, 1)
GUIMinimap.kTeamColors[4] = ColorIntToColor(kMarineTeamColor)
GUIMinimap.kTeamColors[5] = ColorIntToColor(kAlienTeamColor)

GUIMinimap.kUnpoweredNodeColor = Color(1, 0, 0)

GUIMinimap.kIconFileName = "ui/minimap_blip.dds"
GUIMinimap.kIconWidth = 32
GUIMinimap.kIconHeight = 32

GUIMinimap.kUnpoweredNodeFileName = "ui/power_node_off.dds"
GUIMinimap.kUnpoweredNodeIconWidth = 32
GUIMinimap.kUnpoweredNodeIconHeight = 32

GUIMinimap.kStaticBlipsLayer = 0
GUIMinimap.kStaticBlipsLayerPriority = 1 // Sometimes some important blips get drawn below stuff
GUIMinimap.kPlayerIconLayer = 2
GUIMinimap.kDynamicBlipsLayer = 3
GUIMinimap.kTextLayer = 4 // We want text to be drawn over everything else (I think)

GUIMinimap.kBlipTexture = "ui/blip.dds"

GUIMinimap.kBlipTextureCoordinates = { }
GUIMinimap.kBlipTextureCoordinates[kAlertType.Attack] = { X1 = 0, Y1 = 0, X2 = 64, Y2 = 64 }

GUIMinimap.kAttackBlipMinSize = Vector(GUIScale(25), GUIScale(25), 0)
GUIMinimap.kAttackBlipMaxSize = Vector(GUIScale(100), GUIScale(100), 0)
GUIMinimap.kAttackBlipPulseSpeed = 6
GUIMinimap.kAttackBlipTime = 5
GUIMinimap.kAttackBlipFadeInTime = 4.5
GUIMinimap.kAttackBlipFadeOutTime = 1

// The different font-sizes for the big and the small minimap
GUIMinimap.kLocationFontSize = 12
GUIMinimap.kLocationFontSizeSmall = 10

local ClassToGrid = { }

ClassToGrid["TechPoint"] = { 1, 1 }
ClassToGrid["ResourcePoint"] = { 2, 1 }
ClassToGrid["Door"] = { 3, 1 }
ClassToGrid["DoorLocked"] = { 4, 1 }
ClassToGrid["DoorWelded"] = { 5, 1 }
ClassToGrid["Grenade"] = { 6, 1 }
ClassToGrid["PowerPoint"] = { 7, 1 }

ClassToGrid["ReadyRoomPlayer"] = { 1, 2 }
ClassToGrid["Marine"] = { 1, 2 }
ClassToGrid["Heavy"] = { 2, 2 }
ClassToGrid["Jetpack"] = { 3, 2 }
ClassToGrid["MAC"] = { 4, 2 }
ClassToGrid["CommandStationOccupied"] = { 5, 2 }
ClassToGrid["CommandStationL2Occupied"] = { 6, 2 }
ClassToGrid["CommandStationL3Occupied"] = { 7, 2 }
ClassToGrid["Death"] = { 8, 2 }

ClassToGrid["Skulk"] = { 1, 3 }
ClassToGrid["Gorge"] = { 2, 3 }
ClassToGrid["Lerk"] = { 3, 3 }
ClassToGrid["Fade"] = { 4, 3 }
ClassToGrid["Onos"] = { 5, 3 }
ClassToGrid["Drifter"] = { 6, 3 }
ClassToGrid["HiveOccupied"] = { 7, 3 }
ClassToGrid["Kill"] = { 8, 3 }

ClassToGrid["CommandStation"] = ClassToGrid["TechPoint"] //{ 1, 4 }
ClassToGrid["CommandStationL2"] = { 2, 4 }
ClassToGrid["CommandStationL3"] = { 3, 4 }
ClassToGrid["Extractor"] = ClassToGrid["ResourcePoint"] //{ 4, 4 }
ClassToGrid["Sentry"] = { 5, 4 }
ClassToGrid["ARC"] = { 6, 4 }
ClassToGrid["ARCDeployed"] = { 7, 4 }

ClassToGrid["InfantryPortal"] = { 1, 5 }
ClassToGrid["Armory"] = { 2, 5 }
ClassToGrid["AdvancedArmory"] = { 3, 5 }
ClassToGrid["AdvancedArmoryModule"] = { 4, 5 }
ClassToGrid["Observatory"] = { 6, 5 }

ClassToGrid["HiveBuilding"] = { 1, 6 }
ClassToGrid["Hive"] = ClassToGrid["TechPoint"] //{ 2, 6 }
ClassToGrid["HiveL2"] = { 3, 6 }
ClassToGrid["HiveL3"] = { 4, 6 }
ClassToGrid["Harvester"] = ClassToGrid["ResourcePoint"] //{ 5, 6 }
ClassToGrid["Hydra"] = { 6, 6 }
ClassToGrid["Egg"] = { 7, 6 }

ClassToGrid["Crag"] = { 1, 7 }
ClassToGrid["MatureCrag"] = { 2, 7 }
ClassToGrid["Whip"] = { 3, 7 }
ClassToGrid["MatureWhip"] = { 4, 7 }

ClassToGrid["WaypointMove"] = { 1, 8 }
ClassToGrid["WaypointDefend"] = { 2, 8 }
ClassToGrid["PlayerFOV"] = { 4, 8 }

/**
 * Returns Column and Row to find the minimap icon for the passed in class.
 */
local function GetSpriteGridByClass(class)

    // This really shouldn't happen but lets return something just in case.
    if not ClassToGrid[class] then
        return 8, 1
    end
    
    return unpack(ClassToGrid[class])
    
end
AddFunctionContract(GetSpriteGridByClass, { Arguments = { "string" }, Returns = { "number", "number" } })

local function PlotToMap(posX, posZ, comMode)

    local adjustedX = posX - Client.minimapExtentOrigin.x
    local adjustedZ = posZ - Client.minimapExtentOrigin.z
    
    local xFactor = 4
    local zFactor = xFactor / GUIMinimap.kMapRatio()

    local plottedX = (adjustedX / (Client.minimapExtentScale.x / xFactor)) * GUIMinimap.kBackgroundSize
    local plottedY = (adjustedZ / (Client.minimapExtentScale.z / zFactor)) * GUIMinimap.kBackgroundSize
    
	// The X/Y is currently for a minimap with a scale of 2, lets divide it by 2 for a scale of 1
	// Dividing with kBigSizeScale is the wrong way to do it UWE, try it your way with it set to 3
	plottedX = plottedX / 2
	plottedY = plottedY / 2
	
	// This makes it rescale to another size if 
	local sizeScale = GUIMinimap:GetSizeScale(comMode)
	plottedX = plottedX * sizeScale
	plottedY = plottedY * sizeScale
	
    // The world space is oriented differently from the GUI space, adjust for that here.
    // Return 0 as the third parameter so the results can easily be added to a Vector.
    return plottedY, -plottedX, 0

end
AddFunctionContract(PlotToMap, { Arguments = { "number", "number", "number" }, Returns = { "number", "number", "number" } })

function GUIMinimap:Initialize()

    self:InitializeBackground()
    self:InitializeScanlines()
    
    self.minimap = GUIManager:CreateGraphicItem()
    
    self:InitializeLocationNames()
    
    self.comMode = nil
    self:SetBackgroundMode(GUIMinimap.kModeMini)
    self.minimap:SetTexture("maps/overviews/" .. Shared.GetMapName() .. ".tga")
    self.minimap:SetColor(PlayerUI_GetTeamColor())
    
    self.background:AddChild(self.minimap)
    
    // Used for commander.
	self:InitializeCameraLines()
	
    // Used for normal players.
    self:InitializePlayerIcon()
	
	//Used for waypoints
	self:InitializeWaypointIcon()
	
    self.staticBlips = { }
    
    self.reuseDynamicBlips = { }
    self.inuseDynamicBlips = { }
    
    self.mousePressed = { LMB = { Down = nil, X = 0, Y = 0 }, RMB = { Down = nil, X = 0, Y = 0 } }
    
end

function GUIMinimap:InitializeBackground()

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(GUIMinimap.kBackgroundWidth, GUIMinimap.kBackgroundHeight, 0))
    self.background:SetPosition(Vector(0, -GUIMinimap.kBackgroundHeight, 0))
    GUISetTextureCoordinatesTable(self.background, GUIMinimap.kBackgroundTextureCoords)

    self.background:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.background:SetLayer(kGUILayerMinimap)
    
    // Non-commander players assume the map isn't visible by default.
    if not PlayerUI_IsACommander() then
        self.background:SetIsVisible(false)
    end

end

function GUIMinimap:InitializeScanlines()

    local settingsTable = { }
    settingsTable.Width = GUIMinimap.kBackgroundWidth
    settingsTable.Height = GUIMinimap.kBackgroundHeight
    // The amount of extra scanline space that should be above the minimap.
    settingsTable.ExtraHeight = 0
    self.scanlines = GUIScanlines()
    self.scanlines:Initialize(settingsTable)
    self.scanlines:GetBackground():SetInheritsParentAlpha(true)
    self.background:AddChild(self.scanlines:GetBackground())
    
end

function GUIMinimap:InitializeCameraLines()

    self.cameraLines = GUIManager:CreateLinesItem()
    self.cameraLines:SetAnchor(GUIItem.Center, GUIItem.Middle)
	self.cameraLines:SetLayer(GUIMinimap.kPlayerIconLayer)
	self.minimap:AddChild(self.cameraLines)
    
end

function GUIMinimap:InitializePlayerIcon()
	
    self.playerIcon = GUIManager:CreateGraphicItem()
    self.playerIcon:SetSize(Vector(GUIMinimap.kBlipSize, GUIMinimap.kBlipSize, 0))
	self.playerIcon:SetAnchor(GUIItem.Middle, GUIItem.Center)
	self.playerIcon:SetTexture(GUIMinimap.kIconFileName)
	iconCol, iconRow = GetSpriteGridByClass(PlayerUI_GetPlayerClass())
    self.playerIcon:SetTexturePixelCoordinates(GUIGetSprite(iconCol, iconRow, GUIMinimap.kIconWidth, GUIMinimap.kIconHeight))
    self.playerIcon:SetIsVisible(false)
	self.playerIcon:SetLayer(GUIMinimap.kPlayerIconLayer)
	self.playerIcon:SetColor(Color(0, 1, 0, 1))
    self.minimap:AddChild(self.playerIcon)
    
    self.playerIconFov = GUIManager:CreateGraphicItem()
	self.playerIconFov:SetSize(Vector(GUIMinimap.kBlipSize*2, GUIMinimap.kBlipSize, 0))
	self.playerIconFov:SetAnchor(GUIItem.Middle, GUIItem.Top)
	self.playerIconFov:SetPosition(Vector(-GUIMinimap.kBlipSize, -GUIMinimap.kBlipSize, 0))
	self.playerIconFov:SetTexture(GUIMinimap.kIconFileName)
	local iconCol, iconRow = GetSpriteGridByClass('PlayerFOV')
	local gridPosX, gridPosY, gridWidth, gridHeight = GUIGetSprite(iconCol, iconRow, GUIMinimap.kIconWidth, GUIMinimap.kIconHeight)
	self.playerIconFov:SetTexturePixelCoordinates(gridPosX-GUIMinimap.kIconWidth, gridPosY, gridWidth, gridHeight)
	self.playerIconFov:SetIsVisible(false)
	self.playerIconFov:SetLayer(GUIMinimap.kPlayerIconLayer)
	self.playerIcon:AddChild(self.playerIconFov)

end

function GUIMinimap:InitializeWaypointIcon()
	
    self.waypoint = GUIManager:CreateGraphicItem()
    self.waypoint:SetSize(Vector(GUIMinimap.kBlipSize, GUIMinimap.kBlipSize, 0))
	self.waypoint:SetAnchor(GUIItem.Middle, GUIItem.Center)
	self.waypoint:SetTexture(GUIMinimap.kIconFileName)
	iconCol, iconRow = GetSpriteGridByClass("WaypointMove")
    self.waypoint:SetTexturePixelCoordinates(GUIGetSprite(iconCol, iconRow, GUIMinimap.kIconWidth, GUIMinimap.kIconHeight))
    self.waypoint:SetIsVisible(false)
    self.waypoint:SetLayer(GUIMinimap.kPlayerIconLayer)
	self.waypoint:SetColor(Color(1, 1, 1, 1))
    self.minimap:AddChild(self.waypoint)

end

function GUIMinimap:InitializeLocationNames()

    self.locationItems = { }
    local locationData = PlayerUI_GetLocationData()
    
    // Average the position of same named locations so they don't display
    // multiple times.
    local multipleLocationsData = { }
    for i, location in ipairs(locationData) do
    
        // Filter out the ready room.
        if location.Name ~= "Ready Room" then
        
            local locationTable = multipleLocationsData[location.Name]
            if locationTable == nil then
            
                locationTable = { }
                multipleLocationsData[location.Name] = locationTable
                
            end
            table.insert(locationTable, location.Origin)
            
        end
        
    end
	
	self.uniqueLocationsData = { }
    for name, origins in pairs(multipleLocationsData) do
    
        local averageOrigin = Vector(0, 0, 0)
        table.foreachfunctor(origins, function (origin) averageOrigin = averageOrigin + origin end)
        table.insert(self.uniqueLocationsData, { Name = name, Origin = averageOrigin / table.count(origins) })
        
    end
    
    for i, location in ipairs(self.uniqueLocationsData) do
    
        local locationItem = GUIManager:CreateTextItem()
        locationItem:SetFontSize(GUIMinimap.kLocationFontSize)
        locationItem:SetFontIsBold(true)
        locationItem:SetAnchor(GUIItem.Middle, GUIItem.Center)
        locationItem:SetTextAlignmentX(GUIItem.Align_Center)
        locationItem:SetTextAlignmentY(GUIItem.Align_Center)

	    local posX, posY = PlotToMap(location.Origin.x, location.Origin.z, self.comMode)

        // Locations only supported on the big mode.
        locationItem:SetPosition(Vector(posX, posY, 0))
        locationItem:SetColor(Color(1, 1, 1, 1))
        locationItem:SetText(location.Name)
		locationItem:SetLayer(GUIMinimap.kTextLayer)
        self.minimap:AddChild(locationItem)
        table.insert(self.locationItems, locationItem)
        
    end

end

function GUIMinimap:Uninitialize()

    // The ItemMask is the parent of the Item so this will destroy both.
    for i, blip in ipairs(self.reuseDynamicBlips) do
        GUI.DestroyItem(blip["ItemMask"])
    end
    self.reuseDynamicBlips = { }
    for i, blip in ipairs(self.inuseDynamicBlips) do
        GUI.DestroyItem(blip["ItemMask"])
    end
    self.inuseDynamicBlips = { }
    
    if self.scanlines then
        self.scanlines:Uninitialize()
        self.scanlines = nil
    end
    
    if self.minimap then
        GUI.DestroyItem(self.minimap)
    end
    self.minimap = nil
    
    if self.background then
        GUI.DestroyItem(self.background)
        self.background = nil
    end
    
    // The staticBlips are children of the background so will be cleaned up with it.
    self.staticBlips = { }
    
end

function GUIMinimap:SetButtonsScript(setButtonsScript)

    self.buttonsScript = setButtonsScript
	
end

// We need to make a function to see if a player is spectator, as player_client.lua doesnt.
local function PlayerUI_IsASpectator()
	
    local player = Client.GetLocalPlayer()
    if player ~= nil then
        return player:GetTeamNumber() ==  kSpectatorIndex
    end
    
    return false
    
end

// We need a function to see if player changed team
function GUIMinimap:PlayerChangedTeam()

    local player = Client.GetLocalPlayer()
    if player ~= nil then
        local team = player:GetTeamNumber()
		if team ~= self.lastTeam then
			self.lastTeam = team
			return team
		end
    end
    
    return
    
end

function GUIMinimap:Update(deltaTime)
 
    // Commander always sees the minimap.
    if PlayerUI_IsACommander() then
        self.background:SetIsVisible(true)
        if CommanderUI_IsAlienCommander() then
            self.background:SetTexture(GUIMinimap.kBackgroundTextureAlien)
        else
            self.background:SetTexture(GUIMinimap.kBackgroundTextureMarine)
        end
	elseif PlayerUI_IsASpectator() then
		// We want spectators to always see minimap, like a commander can.
		self.background:SetIsVisible(true)
    elseif self.comMode == GUIMinimap.kModeMini then
        // No minimap for non-commaders
        self.background:SetIsVisible(false)
    end
	
	// if the players change team, we want to update some stuff for the minimap
	local changedTeam = self:PlayerChangedTeam()
	if changedTeam then
		// We make sure comMode is not same as current size, so SetBackgroundMode actually runs
		local currentMode = self.comMode
		self.comMode = nil
		self:SetBackgroundMode(currentMode)
		
		// Set color for the own player icon to be opposite teams color as we want contrast with the
		// minimaps bg, which is own teams color, and as we want a color no other blip uses.
		local color = 1 // This makes it green if player is not in a normal team
		if changedTeam == kTeam1Index then
			color = 5
		elseif changedTeam == kTeam2Index then
			color = 4
		end
		self.playerIcon:SetColor(GUIMinimap.kTeamColors[color])
		self.waypoint:SetColor(GUIMinimap.kTeamColors[color])
	end
	
    self:UpdateIcon()
	
	self:UpdateWaypoint()
	
    self:UpdateStaticBlips(deltaTime)
    
    self:UpdateDynamicBlips(deltaTime)
    
    self:UpdateInput()
    
    if self.minimap:GetIsVisible() then
        // The color cannot be attained right away in some cases so
        // we need to make sure it is the correct color.
		
		if PlayerUI_IsASpectator() then
			// Colors the minimap itself, not the bg
			self.minimap:SetColor(ColorIntToColor(GUIMinimap.kSpectatorTeamColor))
		else
			self.minimap:SetColor(PlayerUI_GetTeamColor())
		end
		
		local color = self.minimap:GetColor()
		if self.comMode == GUIMinimap.kModeBig then
			color.a = GUIMinimap.kBigSizeAlpha
		elseif PlayerUI_IsASpectator() then
			color.a = GUIMinimap.kSmallSpectatorSizeAlpha
		end
		self.minimap:SetColor(color)
    end
    
    if self.scanlines then
        self.scanlines:Update(deltaTime)
    end
    
end

function GUIMinimap:UpdateIcon()

    if PlayerUI_IsACommander() then

		self.playerIcon:SetIsVisible(false)
		self.playerIconFov:SetIsVisible(false)
		self.cameraLines:SetIsVisible(true)
		
        local topLeftPoint, topRightPoint, bottomLeftPoint, bottomRightPoint = CommanderUI_ViewFarPlanePoints()
        if topLeftPoint == nil then
            return
        end
		
		topLeftPoint = Vector(PlotToMap(topLeftPoint.x, topLeftPoint.z, self.comMode))
        topRightPoint = Vector(PlotToMap(topRightPoint.x, topRightPoint.z, self.comMode))
        bottomLeftPoint = Vector(PlotToMap(bottomLeftPoint.x, bottomLeftPoint.z, self.comMode))
        bottomRightPoint = Vector(PlotToMap(bottomRightPoint.x, bottomRightPoint.z, self.comMode))
        
        self.cameraLines:ClearLines()
        local lineColor = Color(1, 1, 1, 1)
        self.cameraLines:AddLine(topLeftPoint, topRightPoint, lineColor)
        self.cameraLines:AddLine(topRightPoint, bottomRightPoint, lineColor)
        self.cameraLines:AddLine(bottomRightPoint, bottomLeftPoint, lineColor)
        self.cameraLines:AddLine(bottomLeftPoint, topLeftPoint, lineColor)
		
    elseif PlayerUI_IsAReadyRoomPlayer() or (not self.kSpectatorShowSelfIcon and PlayerUI_IsASpectator()) then
    
        // No icons for ready room players.
        self.cameraLines:SetIsVisible(false)
        self.playerIcon:SetIsVisible(false)
		self.playerIconFov:SetIsVisible(false)

    else
    
        // Draw a player icon representing this player's position.
		local playerOrigin = PlayerUI_GetOrigin()
		local playerRotation = PlayerUI_GetMinimapPlayerDirection()
		local posX, posY = PlotToMap(playerOrigin.x, playerOrigin.z, self.comMode)
		
        self.cameraLines:SetIsVisible(false)
        self.playerIcon:SetIsVisible(true)
        // Disabled until rotation is correct.
		self.playerIconFov:SetIsVisible(true)
		
		local sizeScale = GUIMinimap:GetSizeScale(self.comMode)
		
		// kIconWidth and such are bigger than kBlipSize for some reason
		// GUIMinimap.kIconWidth
		// GUIMinimap.kIconHeight
		local blipSize = GUIMinimap.kBlipSize
		local width = (GUIMinimap.kBlipSize/2)*sizeScale
		local height = (GUIMinimap.kBlipSize/2)*sizeScale
		
		posX = posX - (width / 2)
		posY = posY - (height / 2)
		
		self.playerIcon:SetSize(Vector(width, height, 0))
        self.playerIcon:SetPosition(Vector(posX, posY, 0))
		self.playerIcon:SetRotation(Vector(0, 0, playerRotation))
		
		/*
		* UWE decided that the XZ-plane is the horizontal plane, but just like in
		* games where the XY-plane is horizontal, they decided to keep the screen
		* in a XY-plane. This means you can't imagine the screen as a sheet of paper
		* lying on the table, where rotations happen around an upwards axis (the
		* yaw component of 3D angles). Instead, as the screen is the XY-plane like
		* in many other games, but the XY-plane is vertical in spark engine, we have
		* to imagine the paper beign vertical, with its thin edge directed towards us,
		* and the rotations happening around the z-axis (pitch in 3D angles).
		*
		* BUT, it seems as if angles is different in spark engine as well, as pitching
		* seemed to rotate around the forward axis, which should be roll. Rolling
		* however worked like I expected pitching to work, except that playerRotation
		* goes counterclockwise, and rolling seems to rotate clockwise. That means I
		* had to invert playerRotation for the rolling.
		*
		* I think I understand now, Z is the forward-vector, not X, which seems to be
		* the right-vector. This means the screen can actually be imagined as a
		* screen like the one in front of you, where the Z-axis apparently is the
		* forward/depth axis. As said in the first paragraph, rotation on the XY
		* plane happens around the Z-axis, but now we know that means a rotation
		* around the forward-axis, not right-axis (roll in 3D-angles, not pitch or yaw).
		*/
		// I imagine the screen like mentioned above, and rotate x-dir around z to get eyeDir.
		local eyeDir = Angles(0,0,-playerRotation):GetCoords().xAxis
		
		// As the rotation seems to be bugged, I have to align the rotation-anchors of the icons.
		// Then I move FOV in the direction you look as far as it was moved to align the anchors.
		self.playerIconFov:SetPosition(Vector(-height, 0, 0) + eyeDir * height)
		self.playerIconFov:SetRotation(Vector(0, 0, playerRotation))
		self.playerIconFov:SetSize(Vector(2*width, height, 0))
		
		local playerClass = PlayerUI_GetPlayerClass()
		if (PlayerUI_IsASpectator()) then playerClass = "Marine" end //Spectators dont have an icon for their class
		if GUIMinimap.playerClass ~= playerClass then
			
			local iconCol, iconRow = GetSpriteGridByClass(playerClass)
			self.playerIcon:SetTexturePixelCoordinates(GUIGetSprite(iconCol, iconRow, GUIMinimap.kIconWidth, GUIMinimap.kIconHeight))
			
			GUIMinimap.playerClass = playerClass
			
		end
		
    end
    
end

function GUIMinimap:UpdateWaypoint()
	
	local nextWaypointActive = PlayerUI_GetNextWaypointActive()
	
    if not nextWaypointActive then
		
        self.waypoint:SetIsVisible(false)
		
    else
		
		local waypointOrigin = Vector(player:GetVisibleWaypoint())
		local waypointSize = GUIMinimap.kBlipSize/2
		// Sin goes from -1 to 1, so lets add 1 to get 0-2 instead
		local sine = (1+math.sin(Shared.GetTime()*math.pi))
		waypointSize = waypointSize * (1+sine/10)

		local screenX, screenY = PlotToMap(waypointOrigin.x, waypointOrigin.z, self.comMode)
		
		local sizeScale = GUIMinimap:GetSizeScale(self.comMode)
		waypointSize = waypointSize * sizeScale
		
		screenX = screenX - (waypointSize / 2)
		screenY = screenY - (waypointSize / 2)
		
		self.waypoint:SetIsVisible(true)
		self.waypoint:SetSize(Vector(waypointSize, waypointSize, 0))
        self.waypoint:SetPosition(Vector(screenX, screenY, 0))

    end
    
end

function GUIMinimap:UpdateStaticBlips(deltaTime)

    // First hide all previous static blips.
    for index, oldBlip in ipairs(self.staticBlips) do
        oldBlip:SetIsVisible(false)
    end
	
	//I dont want to edit Player_Client, so to keep all edits in this file, I get the blips
	local blips = Shared.GetEntitiesWithClassname("MapBlip")
	
    local staticBlips = PlayerUI_GetStaticMapBlips()
    local blipItemCount = 7
    local numBlips = table.count(staticBlips) / blipItemCount
    local currentIndex = 1
    while numBlips > 0 do
		local xPos, yPos = PlotToMap(staticBlips[currentIndex], staticBlips[currentIndex + 1], self.comMode)
		local rotation = staticBlips[currentIndex + 2]
        local xTexture = staticBlips[currentIndex + 3]
        local yTexture = staticBlips[currentIndex + 4]
        local blipType = staticBlips[currentIndex + 5]
        local blipTeam = staticBlips[currentIndex + 6]
		
		//We want spectators to see what team the blips belong to
		local blipTeamColor = blipTeam
		blipTeam = blips:GetEntityAtIndex(currentIndex/blipItemCount):GetTeamNumber()
		if (PlayerUI_IsASpectator() or PlayerUI_IsAReadyRoomPlayer()) then
			if blipTeam == kTeam1Index then
				blipTeamColor = 4
			elseif blipTeam == kTeam2Index then
				blipTeamColor = 5
			else
				blipTeamColor = kMinimapBlipTeam.Neutral
			end
		end
		
        self:SetStaticBlip(xPos, yPos, rotation, xTexture, yTexture, blipType, blipTeamColor)
        currentIndex = currentIndex + blipItemCount
        numBlips = numBlips - 1
    end
    
end

function GUIMinimap:SetStaticBlip(xPos, yPos, rotation, xTexture, yTexture, blipType, blipTeamColor)
    
    // Find a free static blip to reuse or create a new one.
    local foundBlip = nil
    for index, oldBlip in ipairs(self.staticBlips) do
        if not oldBlip:GetIsVisible() then
            foundBlip = oldBlip
            break
        end
    end
    
    if not foundBlip then
        foundBlip = self:AddStaticBlip()
    end
    
    local textureName = GUIMinimap.kIconFileName
    local iconWidth = GUIMinimap.kIconWidth
    local iconHeight = GUIMinimap.kIconHeight
	local iconCol = 0
	local iconRow = 0
    local blipColor = GUIMinimap.kTeamColors[blipTeamColor]
    local blendTechnique = GUIItem.Default
    local blipSize = GUIMinimap.kBlipSize
	
    // Special case for PowerPoint.
    if blipType == kMinimapBlipType.PowerPoint then
		
        // Only unpowered node blips are sent.
        blipColor = GUIMinimap.kUnpoweredNodeColor
        local pulseAmount = (math.sin(Shared.GetTime()) + 1) / 2
        blipColor.a = 0.5 + (pulseAmount * 0.5)
		
		iconCol, iconRow = GetSpriteGridByClass('PowerPoint')
		
	// Ignore eggs
	elseif blipType == kMinimapBlipType.Egg then
		return
		
    // Everything else is handled here.
    elseif table.contains(kMinimapBlipType, blipType) ~= nil then
		
		iconCol, iconRow = GetSpriteGridByClass(EnumToString(kMinimapBlipType, blipType))
		
	end
	
	local sizeScale = GUIMinimap:GetSizeScale(self.comMode)
	blipSize = (blipSize/2) * sizeScale
	
	foundBlip:SetTexture(textureName)
	foundBlip:SetTexturePixelCoordinates(GUIGetSprite(iconCol, iconRow, iconWidth, iconHeight))
    foundBlip:SetIsVisible(true)
    foundBlip:SetSize(Vector(blipSize, blipSize, 0))
	foundBlip:SetPosition(Vector(xPos - (blipSize / 2), yPos - (blipSize / 2), 0))
	foundBlip:SetRotation(Vector(0, 0, rotation))
    foundBlip:SetColor(blipColor)
    foundBlip:SetBlendTechnique(blendTechnique)
	
	
	local layer = GUIMinimap.kStaticBlipsLayer
	if kStaticPriorityBlips[blipType] == true then
		layer = GUIMinimap.kStaticBlipsLayerPriority
	end
	foundBlip:SetLayer(layer)
	
	
    
end

function GUIMinimap:AddStaticBlip()

    addedBlip = GUIManager:CreateGraphicItem()
	addedBlip:SetAnchor(GUIItem.Center, GUIItem.Middle)
    addedBlip:SetLayer(GUIMinimap.kStaticBlipsLayer)
    self.minimap:AddChild(addedBlip)
    table.insert(self.staticBlips, addedBlip)
    return addedBlip

end

function GUIMinimap:UpdateDynamicBlips(deltaTime)

    if PlayerUI_IsACommander() then
        local newDynamicBlips = CommanderUI_GetDynamicMapBlips()
        local blipItemCount = 3
        local numBlips = table.count(newDynamicBlips) / blipItemCount
        local currentIndex = 1
        while numBlips > 0 do
            local blipType = newDynamicBlips[currentIndex + 2]
            self:AddDynamicBlip(newDynamicBlips[currentIndex], newDynamicBlips[currentIndex + 1], blipType)
			
            currentIndex = currentIndex + blipItemCount
            numBlips = numBlips - 1
        end
    end
    
    local removeBlips = { }
    for i, blip in ipairs(self.inuseDynamicBlips) do
        if blip["Type"] == kAlertType.Attack then
            if self:UpdateAttackBlip(blip, deltaTime) then
                table.insert(removeBlips, blip)
            end
        end
    end
    for i, blip in ipairs(removeBlips) do
        self:RemoveDynamicBlip(blip)
    end

end

function GUIMinimap:UpdateAttackBlip(blip, deltaTime)

    blip["Time"] = blip["Time"] - deltaTime
    
    // Fade in.
    if blip["Time"] >= GUIMinimap.kAttackBlipFadeInTime then
        local fadeInAmount = ((GUIMinimap.kAttackBlipTime - blip["Time"]) / (GUIMinimap.kAttackBlipTime - GUIMinimap.kAttackBlipFadeInTime))
        blip["Item"]:SetColor(Color(1, 1, 1, fadeInAmount))
    else
        blip["Item"]:SetColor(Color(1, 1, 1, 1))
    end
    
    // Fade out.
    if blip["Time"] <= GUIMinimap.kAttackBlipFadeOutTime then
        if blip["Time"] <= 0 then
            // Done animating.
            return true
        end
        blip["Item"]:SetColor(Color(1, 1, 1, blip["Time"] / GUIMinimap.kAttackBlipFadeOutTime))
    end
    
    local timeLeft = GUIMinimap.kAttackBlipTime - blip["Time"]
    local pulseAmount = (math.sin(timeLeft * GUIMinimap.kAttackBlipPulseSpeed) + 1) / 2
    local blipSize = LerpGeneric(GUIMinimap.kAttackBlipMinSize, GUIMinimap.kAttackBlipMaxSize / 2, pulseAmount)
    
    blip["Item"]:SetSize(blipSize)
    // Make sure it is always centered.
    local sizeDifference = GUIMinimap.kAttackBlipMaxSize - blipSize
    local minimapSize = self:GetMinimapSize()
    local xOffset = (sizeDifference.x / 2) - GUIMinimap.kAttackBlipMaxSize.x / 2
    local yOffset = (sizeDifference.y / 2) - GUIMinimap.kAttackBlipMaxSize.y / 2
    local plotX, plotY = PlotToMap(blip["X"], blip["Y"], self.comMode)
	blip["Item"]:SetPosition(Vector(plotX + xOffset, plotY + yOffset, 0))
    
    // Not done yet.
    return false

end

function GUIMinimap:AddDynamicBlip(xPos, yPos, blipType)

    /**
     * Blip types - kAlertType
     * 
     * 0 - Attack
     * Attention-getting spinning squares that start outside the minimap and spin down to converge to point 
     * on map, continuing to draw at point for a few seconds).
     * 
     * 1 - Info
     * Research complete, area blocked, structure couldn't be built, etc. White effect, not as important to
     * grab your attention right away).
     * 
     * 2 - Request
     * Soldier needs ammo, asking for order, etc. Should be yellow or green effect that isn't as 
     * attention-getting as the under attack. Should draw for a couple seconds.)
     */

    if blipType == kAlertType.Attack then
        if self.scanlines then
            // Disrupt should probably be a global function that disrupts all scanlines at the same time.
            self.scanlines:Disrupt()
        end
        addedBlip = self:GetFreeDynamicBlip(xPos, yPos, blipType)
        addedBlip["Item"]:SetSize(Vector(0, 0, 0))
        addedBlip["Time"] = GUIMinimap.kAttackBlipTime
    end
    
end

function GUIMinimap:RemoveDynamicBlip(blip)

    blip["Item"]:SetIsVisible(false)
    table.removevalue(self.inuseDynamicBlips, blip)
    table.insert(self.reuseDynamicBlips, blip)
    
end

function GUIMinimap:GetFreeDynamicBlip(xPos, yPos, blipType)

    local returnBlip = nil
    if table.count(self.reuseDynamicBlips) > 0 then
    
        returnBlip = self.reuseDynamicBlips[1]
        table.removevalue(self.reuseDynamicBlips, returnBlip)
        table.insert(self.inuseDynamicBlips, returnBlip)
        
    else
    
        returnBlip = { }
        returnBlip["Item"] = GUIManager:CreateGraphicItem()
        // Make sure these draw a layer above the minimap so they are on top.
        returnBlip["Item"]:SetLayer(GUIMinimap.kDynamicBlipsLayer)
        returnBlip["Item"]:SetTexture(GUIMinimap.kBlipTexture)
        returnBlip["Item"]:SetBlendTechnique(GUIItem.Add)
		returnBlip["Item"]:SetAnchor(GUIItem.Center, GUIItem.Middle)
        self.minimap:AddChild(returnBlip["Item"])
        table.insert(self.inuseDynamicBlips, returnBlip)
        
    end
    
    returnBlip["X"] = xPos
    returnBlip["Y"] = yPos
    
    returnBlip["Type"] = blipType
    returnBlip["Item"]:SetIsVisible(true)
    returnBlip["Item"]:SetColor(Color(1, 1, 1, 1))
    local minimapSize = self:GetMinimapSize()
    local plotX, plotY = PlotToMap(xPos, yPos, self.comMode)
	returnBlip["Item"]:SetPosition(Vector(plotX, plotY, 0))
    GUISetTextureCoordinatesTable(returnBlip["Item"], GUIMinimap.kBlipTextureCoordinates[blipType])
    return returnBlip
    
end

function GUIMinimap:UpdateInput()

    if PlayerUI_IsACommander() then
        local mouseX, mouseY = Client.GetCursorPosScreen()
        if self.mousePressed["LMB"]["Down"] then
            local containsPoint, withinX, withinY = GUIItemContainsPoint(self.minimap, mouseX, mouseY)
            if containsPoint then
                local minimapSize = self:GetMinimapSize()
                local backgroundScreenPosition = self.minimap:GetScreenPosition(Client.GetScreenWidth(), Client.GetScreenHeight())
				
                local cameraPosition = Vector(mouseX, mouseY, 0)
                
                cameraPosition.x = cameraPosition.x - backgroundScreenPosition.x
                cameraPosition.y = cameraPosition.y - backgroundScreenPosition.y

                local horizontalScale = CommanderUI_MapLayoutHorizontalScale()
                local verticalScale = CommanderUI_MapLayoutVerticalScale()

                local moveX = (cameraPosition.x / minimapSize.x) * horizontalScale
                local moveY = (cameraPosition.y / minimapSize.y) * verticalScale

                CommanderUI_MapMoveView(moveX, moveY)
            end
        end
    end

end

function GUIMinimap:UpdateLocationNames(modeIsMini)
    
    for i, location in ipairs(self.uniqueLocationsData) do
		
	    local posX, posY = PlotToMap(location.Origin.x, location.Origin.z, self.comMode)
		
		local locationItem = self.locationItems[i]
		
        // "Locations only supported on the big mode." NOT CORRECT ANYMORE!!! mwahaha :P
		if modeIsMini then
			locationItem:SetFontSize(self.kLocationFontSizeSmall)
		else
			locationItem:SetFontSize(self.kLocationFontSize)
		end
		
        locationItem:SetPosition(Vector(posX, posY, 0))
		
    end

end

function GUIMinimap:SetBackgroundMode(setMode)

    if self.comMode ~= setMode then
    
        self.comMode = setMode
        local modeIsMini = self.comMode == GUIMinimap.kModeMini
		
        // Locations only visible in the big mode (or as spectator)
		self:UpdateLocationNames(modeIsMini)
        table.foreachfunctor(self.locationItems, function (item) item:SetIsVisible(PlayerUI_IsASpectator() or not modeIsMini) end)
		
        local modeSize = self:GetMinimapSize()
        
        if self.background then
            if modeIsMini then
                self.background:SetAnchor(GUIItem.Left, GUIItem.Bottom)
                self.background:SetPosition(Vector(GUIMinimap.kMapBackgroundXOffset, -GUIMinimap.kBackgroundHeight - GUIMinimap.kMapBackgroundYOffset, 0))
				
				if PlayerUI_IsASpectator() then
					// Make the bg transparent for spectators, so you only see the minimap
					self.background:SetColor(Color(1, 1, 1, 0))
					// We want the minimap in bottom right corner as a spectator (i think)
					self.background:SetPosition(Vector(Client.GetScreenWidth() - GUIMinimap.kBackgroundWidth * GUIMinimap.kSmallSpectatorSizeScale - GUIMinimap.kMapBackgroundXOffset, 0-GUIMinimap.kBackgroundHeight * GUIMinimap.kSmallSpectatorSizeScale - GUIMinimap.kMapBackgroundYOffset, 0))
				else 
					// If player is not a spectator, they may see the bg
					self.background:SetColor(Color(1, 1, 1, 1))
				end
            else
                self.background:SetAnchor(GUIItem.Center, GUIItem.Middle)
                self.background:SetPosition(Vector(-modeSize.x / 2, -modeSize.y / 2, 0))
                self.background:SetColor(Color(1, 1, 1, 0))
            end
        end
        self.minimap:SetSize(modeSize)
        
        // We want the background to sit "inside" the border so move it up and to the right a bit.
        local borderExtraWidth = ConditionalValue(self.background, GUIMinimap.kBackgroundWidth - self:GetMinimapSize().x, 0)
        local borderExtraHeight = ConditionalValue(self.background, GUIMinimap.kBackgroundHeight - self:GetMinimapSize().y, 0)
        local defaultPosition = Vector(borderExtraWidth / 2, borderExtraHeight / 2, 0)
        local modePosition = ConditionalValue(modeIsMini, defaultPosition, Vector(0, 0, 0))
        self.minimap:SetPosition(Vector(0, 0, 0))
        
    end
    
end

function GUIMinimap:GetMinimapSize()

    return ConditionalValue(self.comMode == GUIMinimap.kModeMini, ConditionalValue(PlayerUI_IsASpectator(),GUIMinimap.kMinimapSmallSpectatorSize,GUIMinimap.kMinimapSmallSize), GUIMinimap.kMinimapBigSize)
    
end

function GUIMinimap:GetSizeScale(comMode) 
	
	// For some reason, GUIMinimap.comMode is nil in this function. No idea why.
	if comMode == self.kModeBig then
        return self.kBigSizeScale
    elseif PlayerUI_IsASpectator() then
		return self.kSmallSpectatorSizeScale
	end
	return 1
	
end

function GUIMinimap:GetPositionOnBackground(xPos, yPos, currentSize)

    local backgroundScreenPosition = self.minimap:GetScreenPosition(Client.GetScreenWidth(), Client.GetScreenHeight())
    local inBackgroundPosition = Vector((xPos * self:GetMinimapSize().x) - (currentSize.x / 2), (yPos * self:GetMinimapSize().y) - (currentSize.y / 2), 0)
    return backgroundScreenPosition + inBackgroundPosition

end

// Shows or hides the big map.
function GUIMinimap:ShowMap(showMap)
    
    // Non-commander/spectator players only see the map when the key is held down.
    if not PlayerUI_IsACommander() and not PlayerUI_IsASpectator() then
        self.background:SetIsVisible(showMap)
    end
    
    local previousComMode = self.comMode
    
    self:SetBackgroundMode(ConditionalValue(showMap, GUIMinimap.kModeBig, GUIMinimap.kModeMini))

    // Only call Update when the state changes 
    if previousComMode ~= self.comMode then
        // Make sure everything is in sync in case this function is called after GUIMinimap:Update() is called.
        self:Update(0)
    end

end

function GUIMinimap:SendKeyEvent(key, down)
    
    if PlayerUI_IsACommander() then
        if key == InputKey.MouseButton0 and self.mousePressed["LMB"]["Down"] ~= down then
            self.mousePressed["LMB"]["Down"] = down
            local mouseX, mouseY = Client.GetCursorPosScreen()
            local containsPoint, withinX, withinY = GUIItemContainsPoint(self.minimap, mouseX, mouseY)
            if down and containsPoint then
                local buttonIndex = nil
                if self.buttonsScript then
                    buttonIndex = self.buttonsScript:GetTargetedButton()
                end
                if buttonIndex then
                    CommanderUI_ActionCancelled()
                    self.buttonsScript:SetTargetedButton(nil)
                    CommanderUI_MapClicked(withinX / self:GetMinimapSize().x, withinY / self:GetMinimapSize().y, 0, buttonIndex)
                    // The down event is considered "captured" at this point and shouldn't be processed in UpdateInput().
                    self.mousePressed["LMB"]["Down"] = false
                end
                return true
            end
        elseif key == InputKey.MouseButton1 and self.mousePressed["RMB"]["Down"] ~= down then
            self.mousePressed["RMB"]["Down"] = down
            local mouseX, mouseY = Client.GetCursorPosScreen()
            local containsPoint, withinX, withinY = GUIItemContainsPoint(self.minimap, mouseX, mouseY)
            if down and containsPoint then
                if self.buttonsScript then
                    // Cancel just in case the user had a targeted action selected before this press.
                    CommanderUI_ActionCancelled()
                    self.buttonsScript:SetTargetedButton(nil)
                end
                CommanderUI_MapClicked(withinX / self:GetMinimapSize().x, withinY / self:GetMinimapSize().y, 1, nil)
                return true
            end
        end
    end
    
    return false

end

function GUIMinimap:GetBackground()

    return self.background

end

function GUIMinimap:ContainsPoint(pointX, pointY)

    return GUIItemContainsPoint(self:GetBackground(), pointX, pointY) or GUIItemContainsPoint(self.minimap, pointX, pointY)

end
