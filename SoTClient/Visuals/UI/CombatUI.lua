local graphics = require ("graphics")
local widget = require("widget")
local MapRender = require "SotClient.Visuals.RenderMap"
local MapData = require "SoTClient.GameLogic.Scenarios.MissionMap"
local Player = require "SoTClient.GameLogic.PlayerLogic.Player"
local LazyEval = require "SoTClient.Utils.LazyEval"
local EventManager = require "SoTClient.Visuals.Events.EventManager"

local CombatUI = {}

local PlayerUI = display.newGroup()
local AbilityUI = display.newGroup()
local DpadUI = display.newGroup()

local hpprogressView = nil
local hpText = nil
local essenceprogressView = nil
local essenceText = nil

local active_skill = nil
---------------------------------------------------------------------------------
local last_click = system.getTimer()


function CombatUI.createPlayerUI(GameOverseer, Player_Squad, UIGroup)
    if(LOR(Player_Squad == nil, #Player_Squad == 0)) then
        return nil
    end

    local touchListener = function(event, dpad)

        if (last_click + 300 > system.getTimer() or active_skill ~= nil) then
            return true
        end

        last_click = system.getTimer()
        local relative_x, relative_y = dpad.x - event.x, dpad.y - event.y

        if (relative_x > relative_y) then
            if (relative_x + relative_y < dpad.contentWidth) then
                GameOverseer.SendCommand("pressDown")
            elseif (relative_x + relative_y > dpad.contentWidth) then
                GameOverseer.SendCommand("pressLeft")
            else
                return true
            end
        elseif (relative_x < relative_y) then
            if (relative_x + relative_y < dpad.contentWidth) then
                GameOverseer.SendCommand("pressRight")
            elseif (relative_x + relative_y > dpad.contentWidth) then
                GameOverseer.SendCommand("pressUp")
            else
                return true
            end
        else
            return true
        end
    
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
                MapRender.ClearSkillRangeOverlay()
                active_skill = nil
                MapRender.UpdateTilemap()
            end
            return true
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

        if (skill_map == nil) then
            return false
        end

        if(MapRender.ShowSkillRangeOverlay(skill_map, skill_performer) == true) then
            active_skill = temp_skill
        end
        return true
    end
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
        AbilitySquares[square_idx]:addEventListener("tap",function(event) skillTapListener(event, "Skill" .. square_idx) return true end)
        AbilitySquares[square_idx]:addEventListener("touch",function(event) EventManager.PerformEvent(event) return true end)
        AbilityUI:insert(AbilitySquares[square_idx])
    end
    AbilityUI:insert(UIAbilitiesPanel)

    ---------------------------------------------------------------------------------

    --PLAYER UI
    local UIPlayerPanelW = display.contentWidth * 0.35
    local UIPlayerPanelH = UIPlayerPanelW * 0.3
    local UIPlayerPanel = display.newRect(0, 0, UIPlayerPanelW, UIPlayerPanelH)
    UIPlayerPanel.alpha = 0.5
    PlayerUI:insert(UIPlayerPanel)

    -- Define inter-component spacing
    UIPlayerSpacingX = UIPlayerPanelW * 0.02
    UIPlayerSpacingY = UIPlayerPanelH * 0.1

    -- Create and position image to be masked
    local UIPlayerPortraitW = UIPlayerPanelH - (UIPlayerSpacingY * 2)
    local UIPlayerPortraitH = UIPlayerPanelH - (UIPlayerSpacingY * 2)
    local UIPlayerPortrait = display.newImageRect( "GameResources/ToBeRemoved/andre.png", UIPlayerPortraitW, UIPlayerPortraitH)
    local UIPlayerPortraitX = UIPlayerSpacingX 
    local UIPlayerPortraitY = UIPlayerSpacingY
    UIPlayerPortrait:translate( UIPlayerPortraitX, UIPlayerPortraitY )
    -- Create mask and apply to image
    local mask  = graphics.newMask( "GameResources/ToBeRemoved/circ_mask.png" )
    UIPlayerPortrait:setMask( mask )
    -- Transform mask
    UIPlayerPortrait.maskScaleX, UIPlayerPortrait.maskScaleY = 0.18, 0.18
    PlayerUI:insert(UIPlayerPortrait)

    local hpTextX    = UIPlayerPanelW * 0.90
    local hpTextY    = UIPlayerPanelH * 0.40
    local hpTextSize = UIPlayerPanelH * 0.10
    hpText = display.newText(Player_Squad[1]["currentHP"].."/".. Player_Squad[1]["maxHP"].."HP", hpTextX, hpTextY, native.systemFont, hpTextSize )
    hpText.anchorX = 1
    hpText.anchorY = 1
    hpText:setFillColor( 1, 0, 0 )
    Player_Squad[1]["HPText"] = hpText
    PlayerUI:insert(hpText)

    -- UI status registers
    local hpoptions = {
        width = 64,
        height = 64,
        numFrames = 6
    }
    
    local hpprogressSheet = graphics.newImageSheet( "GameResources/UI/Main_Char_Health.png", hpoptions )

    hpprogressView = widget.newProgressView(
        {
            sheet = hpprogressSheet,
            fillWidth = UIPlayerPortraitH,
            fillHeight = UIPlayerPortraitH,
            fillOuterWidth = UIPlayerPortraitH,
            fillOuterHeight = UIPlayerPortraitH,
            left = UIPlayerPortraitX,
            top = UIPlayerPortraitY,
            width = (UIPlayerPanelW + UIPlayerPortraitH) * 0.9, -- this is due to the edge of the bar occupying the value of a "tile"
            fillOuterLeftFrame = 1,
            fillOuterMiddleFrame = 2,
            fillOuterRightFrame = 3,
            fillInnerLeftFrame = 4,
            fillInnerMiddleFrame = 5,
            fillInnerRightFrame = 6,
            isAnimated = true
        }
    )
    Player_Squad[1]["HPBar"] = hpprogressView
    hpprogressView:setProgress(1)
    PlayerUI:insert(hpprogressView)

    local essenceTextX    = UIPlayerPanelW * 0.90
    local essenceTextY    = UIPlayerPanelH * 0.60
    local essenceTextSize = UIPlayerPanelH * 0.10
    essenceText = display.newText( Player_Squad[1]["currentEssence"].."/".. Player_Squad[1]["maxEssence"].."AP", essenceTextX, essenceTextY, native.systemFont, essenceTextSize )
    essenceText:setFillColor( 0.2 , 1, 0.2)
    essenceText.anchorX = 1
    essenceText.anchorY = 0
    Player_Squad[1]["APText"] = essenceText
    PlayerUI:insert(essenceText)

    
    local essenceoptions = {
        width = 64,
        height = 64,
        numFrames = 6
    }

    local essenceprogressSheet = graphics.newImageSheet( "GameResources/UI/Main_Char_Essence.png", essenceoptions )
    
    essenceprogressView = widget.newProgressView(
        {
            sheet = essenceprogressSheet,
            fillWidth = UIPlayerPortraitH,
            fillHeight = UIPlayerPortraitH,
            fillOuterWidth = UIPlayerPortraitH,
            fillOuterHeight = UIPlayerPortraitH,
            left = UIPlayerPortraitX,
            top = UIPlayerPortraitY,
            width = (UIPlayerPanelW + UIPlayerPortraitH) * 0.9, -- this is due to the edge of the bar occupying the value of a "tile"
            fillOuterLeftFrame = 1,
            fillOuterMiddleFrame = 2,
            fillOuterRightFrame = 3,
            fillInnerLeftFrame = 4,
            fillInnerMiddleFrame = 5,
            fillInnerRightFrame = 6,
            isAnimated = true
        }
    )
    Player_Squad[1]["APBar"] = essenceprogressView
    essenceprogressView:setProgress(1)
    PlayerUI:insert(essenceprogressView)

    ---------------------------------------------------------------------------------

    -- Companion Panel

    -- UI Companion Variables

    local UICompanionPanelW = UIPlayerPanelW * 0.3
    local UICompanionPanelH = UIPlayerPanelH
    local UICompanionPanelX = UIPlayerPortraitX + UIPlayerPortraitW
    local UICompanionPanelY = 0
    local UICompanionIconH  = UIPlayerPanelH * 0.6
    local UICompanionIconW  = UICompanionIconH
    local UICompanionMaskScaleX = 0.10
    local UICompanionMaskScaleY = 0.12

    -- UI status register
    local AllyOptions = {
        width = 43,
        height = 42,
        numFrames = 6,
        sheetContentWidth = 258,
        sheetContentHeight = 42
    }
    

    local hpAllySheet = graphics.newImageSheet( "GameResources/UI/Minion_Health.png", AllyOptions )

    local essenceAllySheet = graphics.newImageSheet( "GameResources/UI/Minion_Essence.png", AllyOptions )

    local UICompanionIcon  = display.newImageRect( "GameResources/ToBeRemoved/joao.png", UICompanionIconW, UICompanionIconH )

    for char_i = 2, #Player_Squad, 1 do
        local UICompanionIconX = UIPlayerSpacingX
        local UICompanionIconY = UIPlayerPanelH + UIPlayerSpacingY + (UICompanionIconH + UIPlayerSpacingY) * (char_i - 2)
            
        UICompanionIcon:translate( UICompanionIconX, UICompanionIconY )
        local mask = graphics.newMask( "GameResources/ToBeRemoved/circ_mask.png" )
        UICompanionIcon:setMask( mask )
        UICompanionIcon.maskScaleX, UICompanionIcon.maskScaleY = UICompanionMaskScaleX, UICompanionMaskScaleY
        PlayerUI:insert(UICompanionIcon)

        Player_Squad[char_i]["HPBar"] = widget.newProgressView(
            {
                sheet = hpAllySheet,
                fillWidth = UICompanionIconH,
                fillHeight = UICompanionIconH,
                fillOuterWidth = UICompanionIconH,
                fillOuterHeight = UICompanionIconH,
                left = UICompanionIconX,
                top = UICompanionIconY,
                width = (UIPlayerPanelW/2 + UIPlayerPortraitH) * 0.9, -- this is due to the edge of the bar occupying the value of a "tile"
                fillOuterLeftFrame = 1,
                fillOuterMiddleFrame = 2,
                fillOuterRightFrame = 3,
                fillInnerLeftFrame = 4,
                fillInnerMiddleFrame = 5,
                fillInnerRightFrame = 6,
                isAnimated = true
            }
        )

        Player_Squad[char_i]["HPBar"]:setProgress(1)

        local companionHpTextX = UIPlayerPanelW/2 -- bar width + left
        local companionHpTextY = UICompanionIconY + UICompanionIconH * 0.4
        local companionHpTextSize = UICompanionIconH * 0.2
        Player_Squad[char_i]["HPText"] = display.newText( Player_Squad[char_i]["currentHP"].."/".. Player_Squad[char_i]["maxHP"].."AP", companionHpTextX, companionHpTextY, native.systemFont, companionHpTextSize )
        Player_Squad[char_i]["HPText"]:setFillColor( 1 , 0, 0)
        Player_Squad[char_i]["HPText"].anchorX = 1
        Player_Squad[char_i]["HPText"].anchorY = 1

        Player_Squad[char_i]["APBar"] = widget.newProgressView(
            {
                sheet = essenceAllySheet,
                fillWidth = UICompanionIconH,
                fillHeight = UICompanionIconH,
                fillOuterWidth = UICompanionIconH,
                fillOuterHeight = UICompanionIconH,
                left = UICompanionIconX,
                top = UICompanionIconY,
                width = (UIPlayerPanelW/2 + UIPlayerPortraitH) * 0.9, -- this is due to the edge of the bar occupying the value of a "tile"
                fillOuterLeftFrame = 1,
                fillOuterMiddleFrame = 2,
                fillOuterRightFrame = 3,
                fillInnerLeftFrame = 4,
                fillInnerMiddleFrame = 5,
                fillInnerRightFrame = 6,
                isAnimated = true
            }
        )

        Player_Squad[char_i]["APBar"]:setProgress(1)

        local companionEssenceTextX = UIPlayerPanelW/2 -- bar width + left
        local companionEssenceTextY = UICompanionIconY + UICompanionIconH * 0.6
        local companionEssenceTextSize = UICompanionIconH * 0.2
        Player_Squad[char_i]["APText"] = display.newText( Player_Squad[char_i]["currentEssence"].."/".. Player_Squad[char_i]["maxEssence"].."AP", companionEssenceTextX, companionEssenceTextY, native.systemFont, essenceTextSize )
        Player_Squad[char_i]["APText"]:setFillColor( 0.2 , 1, 0.2)
        Player_Squad[char_i]["APText"].anchorX = 1
        Player_Squad[char_i]["APText"].anchorY = 0
    end
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
    DpadUI:addEventListener("tap", function(event) touchListener(event, dpad) return true end)
    DpadUI:addEventListener("touch", 
        function(event)
            if (EventManager.GetActiveEventID() ~= nil) then 
                EventManager.PerformEvent(event) 
            end 
                return true 
        end
    )

    --GLOBAL UI
    UIGroup:insert(PlayerUI)
    UIGroup:insert(AbilityUI)
    UIGroup:insert(DpadUI)
end

function CombatUI.setHP(Character)
    Character["HPBar"]:setProgress(Character["currentHP"]/Character["maxHP"])
    Character["HPText"].text = Character["currentHP"].."/".. Character["maxHP"].."HP"
end

function CombatUI.setEssence(Character)
    Character["APBar"]:setProgress(Character["currentAP"]/Character["maxAP"])
    Character["APText"].text = Character["currentAP"].."/".. Character["maxAP"].."AP"
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