local graphics = require ("graphics")
local widget = require("widget")
local MapRender = require "SotClient.Visuals.RenderMap"
local GameOverseer = require "SotClient.GameLogic.LevelMechanics.GameOverseer"
local MapData = require "SoTClient.GameLogic.Scenarios.MissionMap"
local Player = require "SoTClient.GameLogic.PlayerLogic.Player"

local CombatUI = {}

local PlayerUI = display.newGroup()
local AbilityUI = display.newGroup()
local DpadUI = display.newGroup()

local hpprogressView = nil
local essenceprogressView = nil

local active_skill = nil
---------------------------------------------------------------------------------
local last_click = system.getTimer()
local touchListener = function(event, dpad)
	if (last_click + 300 > system.getTimer() or active_skill ~= nil) then
		return false
	end
	last_click = system.getTimer()
    local relative_x, relative_y = dpad.x - event.x, dpad.y - event.y

	if (relative_x > relative_y) then
        if (relative_x + relative_y < dpad.contentWidth) then
		    GameOverseer.SendCommand("pressDown")
        elseif (relative_x + relative_y > dpad.contentWidth) then
            GameOverseer.SendCommand("pressLeft")
        else
            return false
        end
	elseif (relative_x < relative_y) then
        if (relative_x + relative_y < dpad.contentWidth) then
		    GameOverseer.SendCommand("pressRight")
        elseif (relative_x + relative_y > dpad.contentWidth) then
            GameOverseer.SendCommand("pressUp")
        else
            return false
        end
    else
        return false
	end
	MapRender.UpdateTilemap(MapData.GetMap())

	--Move where you wanna call cutscenes
	--if cutscene[1] == false then
	--	composer.gotoScene("GameResources.Cutscenes.cutscene1",{time=2000, effect="fade"})
	--	cutscene[1] = true
	--end

    return true
end

local function skill_performer(tile_x, tile_y)
    return function(event)
        if(last_click + 300 > system.getTimer()) then
            return false
        end

        local click_result = GameOverseer.SendCommand(active_skill, tile_x, tile_y)

        if(click_result == true) then
            MapRender.ClearSkillRangeOverlay(GetGameMap())
            active_skill = nil
            MapRender.UpdateTilemap(GetGameMap())
        end
    end
end


local function skillTapListener(event, skill) 
    if(last_click + 300 > system.getTimer()) then
		return false
	end

    local skill_map, skill_clicked, temp_skill

    skill_clicked = "press" .. skill
    temp_skill = "perform" .. skill

    if(temp_skill == active_skill) then
        MapRender.ClearSkillRangeOverlay(GetGameMap())
        active_skill = nil
        return
    end
  
    skill_map = GameOverseer.SendCommand(skill_clicked)
    if(MapRender.ShowSkillRangeOverlay(GetGameMap(), skill_map, skill_performer) == true) then
        active_skill = temp_skill
    end

end

function CombatUI.createPlayerUI(UIGroup)
   
    --ABILITIES UI
    local AbilityPanelW = display.contentWidth * 0.40
    local AbilityPanelH = AbilityPanelW * 0.25
    local UIAbilitiesPanel = display.newRect(0, display.contentHeight, AbilityPanelW, AbilityPanelH)
    UIAbilitiesPanel.anchorX = 0
    UIAbilitiesPanel.anchorY = 1
    UIAbilitiesPanel.alpha = 0.5
    -- CREATE DEFAULT UI OPTIONS
    -- Each ability block occupies 1/5 of the Panel width.
    -- Last 1/5 is for spacing
    local AbilityW = AbilityPanelW/5 
    -- Each ability block occupies 80% of the panel's height
    local AbilityH = AbilityPanelH * 0.8
    local AbilitySpacingW = AbilityW/5
    local AbilityY = display.contentHeight - AbilityH/10
    local AbilitySquares = {}
    for square_idx = 1, 4, 1 do
        AbilitySquares[square_idx] = 
            display.newRect(AbilitySpacingW * square_idx + AbilityW * (square_idx - 1), AbilityY, AbilityW, AbilityH)
        AbilitySquares[square_idx].anchorX = 0
        AbilitySquares[square_idx].anchorY = 1
        AbilitySquares[square_idx]:addEventListener("tap",function(event) skillTapListener(event, "Skill" .. square_idx) end)
        AbilityUI:insert(AbilitySquares[square_idx])
    end
    AbilityUI:insert(UIAbilitiesPanel)

    ---------------------------------------------------------------------------------

    --PLAYER UI
    local UIPlayerPanelW = display.contentWidth * 0.50
    local UIPlayerPanelH = UIPlayerPanelW * 0.20
    local UIPlayerPanel = display.newRect(0, 0, UIPlayerPanelW, UIPlayerPanelH)
    UIPlayerPanel.alpha = 0.5
    PlayerUI:insert(UIPlayerPanel)

    -- Define inter-component spacing
    UIPlayerSpacingX = UIPlayerPanelW * 0.02
    UIPlayerSpacingY = UIPlayerPanelH * 0.1

    -- Create and position image to be masked
    local UIPlayerPortraitW = UIPlayerPanelW * 0.15
    local UIPlayerPortraitH = UIPlayerPanelH - (UIPlayerSpacingY * 2)
    local UIPlayerPortrait = display.newImageRect( "GameResources/ToBeRemoved/andre.png", UIPlayerPortraitW, UIPlayerPortraitH)
    local UIPlayerPortraitX = UIPlayerSpacingX 
    local UIPlayerPortraitY = UIPlayerSpacingY
    UIPlayerPortrait:translate( UIPlayerPortraitX, UIPlayerPortraitY )
    -- Create mask and apply to image
    local mask  = graphics.newMask( "GameResources/ToBeRemoved/circ_mask.png" )
    UIPlayerPortrait:setMask( mask )
    -- Transform mask
    UIPlayerPortrait.maskScaleX, UIPlayerPortrait.maskScaleY = 0.20, 0.25
    PlayerUI:insert(UIPlayerPortrait)

    -- UI Companion Variables
    local UICompanionPanelW = UIPlayerPanelW * 0.3
    local UICompanionPanelH = UIPlayerPanelH
    local UICompanionPanelX = UIPlayerPortraitX + UIPlayerPortraitW
    local UICompanionPanelY = 0
    local UICompanionIconH  = UIPlayerPanelH * 0.5
    local UICompanionIconW  = UICompanionIconH
    local UICompanionMaskScaleX = 0.10
    local UICompanionMaskScaleY = 0.12

    local UICompanionIcon1X = UICompanionPanelX
    local UICompanionIcon1Y = UICompanionPanelY
    local UICompanionIcon1  = display.newImageRect( "GameResources/ToBeRemoved/joao.png", UICompanionIconW, UICompanionIconH )
    UICompanionIcon1:translate( UICompanionIcon1X, UICompanionIcon1Y )
    local mask = graphics.newMask( "GameResources/ToBeRemoved/circ_mask.png" )
    UICompanionIcon1:setMask( mask )
    UICompanionIcon1.maskScaleX, UICompanionIcon1.maskScaleY = UICompanionMaskScaleX, UICompanionMaskScaleY
    PlayerUI:insert(UICompanionIcon1)

    local UICompanionIcon2 = display.newImageRect( "GameResources/ToBeRemoved/joao.png", UICompanionIconW, UICompanionIconH )
    local UICompanionIcon2X = UICompanionIcon1X
    local UICompanionIcon2Y = UICompanionPanelH - UICompanionPanelY
    UICompanionIcon2.anchorY = 1
    UICompanionIcon2:translate( UICompanionIcon2X, UICompanionIcon2Y )
    UICompanionIcon2:setMask( mask )
    UICompanionIcon2.maskScaleX, UICompanionIcon2.maskScaleY = UICompanionMaskScaleX, UICompanionMaskScaleY
    PlayerUI:insert(UICompanionIcon2)

    local UICompanionIcon3 = display.newImageRect( "GameResources/ToBeRemoved/joao.png", UICompanionIconW, UICompanionIconH )
    local UICompanionIcon3X = UICompanionIcon1X + UICompanionIconW * 0.7
    local UICompanionIcon3Y = UIPlayerPanelH/2
    UICompanionIcon3.anchorY = 0.5
    UICompanionIcon3:translate( UICompanionIcon3X, UICompanionIcon3Y )
    UICompanionIcon3:setMask( mask )
    UICompanionIcon3.maskScaleX, UICompanionIcon3.maskScaleY = UICompanionMaskScaleX, UICompanionMaskScaleY
    PlayerUI:insert(UICompanionIcon3)

    local hpTextX    = UIPlayerPanelW * 0.98
    local hpTextY    = UIPlayerPanelH * 0.001
    local hpTextSize = UIPlayerPanelH * 0.25
    local hpText = display.newText( Player.currenthp.."/"..Player.maxhp.."HP", hpTextX, hpTextY, native.systemFont, hpTextSize )
    hpText.anchorX = 1
    hpText:setFillColor( 1, 0, 0 )
    PlayerUI:insert(hpText)

    -- UI status registers
    local hpoptions = {
        width = 72,
        height = 72,
        numFrames = 6
    }
    
    local hpprogressSheet = graphics.newImageSheet( "GameResources/ToBeRemoved/health-bar.png", hpoptions )

    hpprogressView = widget.newProgressView(
        {
            sheet = hpprogressSheet,
            fillWidth = UIPlayerPanelW * 0.05,
            fillHeight = UIPlayerPanelH * 0.2,
            fillOuterWidth = UIPlayerPanelW * 0.05,
            fillOuterHeight = UIPlayerPanelH * 0.2,
            left = UIPlayerPanelW * 0.31,
            top = hpTextY + hpTextSize,
            width = UIPlayerPanelW * 0.70,
            fillOuterLeftFrame = 1,
            fillOuterMiddleFrame = 2,
            fillOuterRightFrame = 3,
            fillInnerLeftFrame = 4,
            fillInnerMiddleFrame = 5,
            fillInnerRightFrame = 6,
            isAnimated = true
        }
    )
    hpprogressView:setProgress(1)
    PlayerUI:insert(hpprogressView)

    local essenceTextX    = UIPlayerPanelW * 0.98
    local essenceTextY    = hpTextY + hpTextSize + UIPlayerPanelH * 0.2
    local essenceTextSize = UIPlayerPanelH * 0.25
    local essenceText = display.newText( Player.currentessence.."/"..Player.maxessence.."AP", essenceTextX, essenceTextY, native.systemFont, essenceTextSize )
    essenceText:setFillColor( 0, 0, 1 )
    essenceText.anchorX = 1
    essenceText.anchorY = 0
    PlayerUI:insert(essenceText)

    
    local essenceoptions = {
        width = 72,
        height = 72,
        numFrames = 6
    }

    local essenceprogressSheet = graphics.newImageSheet( "GameResources/ToBeRemoved/mana-bar.png", essenceoptions )
    
    essenceprogressView = widget.newProgressView(
        {
            sheet = essenceprogressSheet,
            fillWidth = UIPlayerPanelW * 0.05,
            fillHeight = UIPlayerPanelH * 0.2,
            fillOuterWidth = UIPlayerPanelW * 0.05,
            fillOuterHeight = UIPlayerPanelH * 0.2,
            left = UIPlayerPanelW * 0.31,
            top = essenceTextY + hpTextSize,
            width = UIPlayerPanelW * 0.70,
            fillOuterLeftFrame = 1,
            fillOuterMiddleFrame = 2,
            fillOuterRightFrame = 3,
            fillInnerLeftFrame = 4,
            fillInnerMiddleFrame = 5,
            fillInnerRightFrame = 6,
            isAnimated = true
        }
    )
    essenceprogressView:setProgress(1)
    PlayerUI:insert(essenceprogressView)
    ---------------------------------------------------------------------------------

    --DIRECTIONAL PAD
    local dpad  = display.newImage( "GameResources/ToBeRemoved/directionalpad.png" )
    dpad.alpha = 0.5
    dpad:scale(0.35,0.35)
    dpad.anchorX = 1
    dpad.anchorY = 1
    local dpadSpacingRatioX = 0.01
    local dpadSpacingRatioY = 0.01
    dpad:translate( display.contentWidth * (1 - dpadSpacingRatioX), display.contentHeight * (1 - dpadSpacingRatioY))
    DpadUI:insert(dpad)
    DpadUI:addEventListener("tap", function(event) touchListener(event, dpad) end)

    --GLOBAL UI
    UIGroup:insert(PlayerUI)
    UIGroup:insert(AbilityUI)
    UIGroup:insert(DpadUI)
end

function CombatUI.setHP()
    hpprogressView:setProgress(Player.currenthp/Player.maxhp)
end

function CombatUI.setEssence()
    essenceprogressView:setProgress(Player.currentessence/Player.maxessence)
end

function CombatUI.setAbility1()
end

function CombatUI.setAbility2()
end

function CombatUI.setAbility3()
end

function CombatUI.setAbility4()
end


return CombatUI