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
    local AbilityPanelH = display.contentHeight * 0.20
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
    local UIPlayerPanelH = display.contentHeight * 0.25
    local UIPlayerPanel = display.newRect(0, 0, UIPlayerPanelW, UIPlayerPanelH)
    UIPlayerPanel.alpha = 0.5
    PlayerUI:insert(UIPlayerPanel)
    -- Create and position image to be masked
    local UIPlayerPortraitW = UIPlayerPanelH * 0.7
    local UIPlayerPortraitH = UIPlayerPortraitW * 1.2
    local UIPlayerPortrait = display.newImageRect( "GameResources/ToBeRemoved/andre.png", UIPlayerPortraitW, UIPlayerPortraitH)
    local UIPlayerPortraitX = UIPlayerPanelW * 0.02
    local UIPlayerPortraitY = UIPlayerPanelH * 0.08
    UIPlayerPortrait:translate( UIPlayerPortraitX, UIPlayerPortraitY )
    -- Create mask and apply to image
    local mask = graphics.newMask( "GameResources/ToBeRemoved/circ_mask.png" )
    UIPlayerPortrait:setMask( mask )
    -- Transform mask
    UIPlayerPortrait.maskScaleX, UIPlayerPortrait.maskScaleY = 0.20,0.25
    PlayerUI:insert(UIPlayerPortrait)

    -- UI Companion Variables
    local UICompanionPanelW = UIPlayerPanelH * 0.5
    local UICompanionPanelH = UICompanionPanelW
    local UICompanionPanel1X = UIPlayerPortraitX + UIPlayerPortraitW
    local UICompanionPanel1Y = -UIPlayerPortraitY
    local UICompanionPanel1 = display.newImageRect( "GameResources/ToBeRemoved/joao.png", UICompanionPanelW, UICompanionPanelH )
    UICompanionPanel1:translate( UICompanionPanel1X, UICompanionPanel1Y)
    local mask = graphics.newMask( "GameResources/ToBeRemoved/circ_mask.png" )
    UICompanionPanel1:setMask( mask )
    UICompanionPanel1.maskScaleX, UICompanionPanel1.maskScaleY = 0.08,0.1
    PlayerUI:insert(UICompanionPanel1)

    local UICompanionPanel2 = display.newImageRect( "GameResources/ToBeRemoved/joao.png", UICompanionPanelW, UICompanionPanelH )
    local UICompanionPanel2X = UICompanionPanel1X
    local UICompanionPanel2Y = UIPlayerPanelH - UIPlayerPortraitY
    UICompanionPanel2.anchorY = 0.7
    UICompanionPanel2:translate( UICompanionPanel2X, UICompanionPanel2Y )
    UICompanionPanel2:setMask( mask )
    UICompanionPanel2.maskScaleX, UICompanionPanel2.maskScaleY = 0.08,0.1
    PlayerUI:insert(UICompanionPanel2)

    local UICompanionPanel3 = display.newImageRect( "GameResources/ToBeRemoved/joao.png", UICompanionPanelW, UICompanionPanelH )
    local UICompanionPanel3X = UICompanionPanel1X + UICompanionPanelW * 0.50
    local UICompanionPanel3Y = UIPlayerPanelH/2
    UICompanionPanel3.anchorY = 0.5
    UICompanionPanel3:translate( UICompanionPanel3X, UICompanionPanel3Y )
    UICompanionPanel3:setMask( mask )
    UICompanionPanel3.maskScaleX, UICompanionPanel3.maskScaleY = 0.08,0.1
    PlayerUI:insert(UICompanionPanel3)

    local hpTextX    = UIPlayerPanelW * 0.98
    local hpTextY    = UIPlayerPanelH * 0.01
    local hpTextSize = 24
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
    local essenceTextY    = UIPlayerPanelH / 2
    local essenceTextSize = 24
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