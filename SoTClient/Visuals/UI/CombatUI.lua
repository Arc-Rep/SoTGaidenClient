local graphics = require ("graphics")
local widget = require("widget")
local MapRender = require "SotClient.Visuals.RenderMap"
local GameOverseer = require "SotClient.GameLogic.LevelMechanics.GameOverseer"
local MapData = require "SoTClient.GameLogic.Scenarios.MissionMap"
local Player = require "SoTClient.GameLogic.PlayerLogic.Player"

local CombatUI = {}

local UIGroup = display.newGroup()
local PlayerUI = display.newGroup()
local AbilityUI = display.newGroup()
local DpadUI = display.newGroup()

-- CREATE DEFAULT UI OPTIONS
local abilityW = display.contentWidth/7
local abilityH = display.contentHeight/14

local hpoptions = {
    width = 110,
    height = 73,
    numFrames = 3,
    sheetContentWidth = 349,
    sheetContentHeight = 73
}
local hpprogressSheet = graphics.newImageSheet( "GameResources/ToBeRemoved/health-bar.png", hpoptions )
local hpprogressView = widget.newProgressView(
    {
        sheet = hpprogressSheet,
        fillWidth = 32,
        fillHeight = 32,
        left = 305,
        top = 320,
        width = 270,
        isAnimated = true
    }
)

local essenceoptions = {
    width = 110,
    height = 73,
    numFrames = 3,
    sheetContentWidth = 349,
    sheetContentHeight = 73
}
local essenceprogressSheet = graphics.newImageSheet( "GameResources/ToBeRemoved/mana-bar.png", essenceoptions )
local essenceprogressView = widget.newProgressView(
    {
        sheet = essenceprogressSheet,
        fillWidth = 32,
        fillHeight = 32,
        left = 245,
        top = 320,
        width = 270,
        isAnimated = true
    }
)
---------------------------------------------------------------------------------
local last_click = system.getTimer()
local touchListener = function(event)
	if(last_click + 300 > system.getTimer()) then
		return false
	end
	last_click = system.getTimer()
    local x, y = event.x, event.y
	if(x > 170 ) then
		print(MapData.GetMap()[1][1])
		GameOverseer.SendCommand(MapData.GetMap(),"pressRight")
	elseif (x < 92) then
		GameOverseer.SendCommand(MapData.GetMap(),"pressLeft")
	elseif (y < 883) then
		GameOverseer.SendCommand(MapData.GetMap(),"pressUp")
	elseif (y > 969) then
		GameOverseer.SendCommand(MapData.GetMap(),"pressDown")
	end
	MapRender.UpdateTilemap(MapData.GetMap())

	--Move where you wanna call cutscenes
	--if cutscene[1] == false then
	--	composer.gotoScene("GameResources.Cutscenes.cutscene1",{time=2000, effect="fade"})
	--	cutscene[1] = true
	--end

    return true
end


local function tapListener(event)
    print(event.type)
end

function CombatUI.createPlayerUI()
   
    --ABILITIES UI
    local UIAbilitiesPanel = display.newRect(display.contentWidth/7.7,display.contentHeight/5,display.contentWidth/4, display.contentHeight/2.5)
    UIAbilitiesPanel.alpha = 0.5
    local square1 = display.newRect(display.contentWidth/7.7,display.contentHeight/100+40,abilityW, abilityH)
    local square2 = display.newRect(display.contentWidth/7.7,display.contentHeight/100*10+50,abilityW, abilityH)
    local square3 = display.newRect(display.contentWidth/7.7,display.contentHeight/100*20+50,abilityW, abilityH)
    local square4 = display.newRect(display.contentWidth/7.7,display.contentHeight/100*30+50,abilityW, abilityH)
    square1:addEventListener("tap",tapListener)
    square2:addEventListener("tap",tapListener)
    square3:addEventListener("tap",tapListener)
    square4:addEventListener("tap",tapListener)
    AbilityUI:insert(square1)
    AbilityUI:insert(square2)
    AbilityUI:insert(square3)
    AbilityUI:insert(square4)
    AbilityUI:insert(UIAbilitiesPanel)

    ---------------------------------------------------------------------------------

    --PLAYER UI
    local UIPlayerPanel = display.newRect(display.contentWidth/1.14,display.contentHeight/4,display.contentWidth/4, display.contentHeight/2)
    UIPlayerPanel.alpha = 0.5
    PlayerUI:insert(UIPlayerPanel)
    -- Create and position image to be masked
    local portrait = display.newImageRect( "GameResources/ToBeRemoved/andre.png", 96, 128 )
    portrait:rotate(90)
    portrait:translate( display.contentWidth/1.14, display.contentHeight/20 )
    -- Create mask and apply to image
    local mask = graphics.newMask( "GameResources/ToBeRemoved/circ_mask.png" )
    portrait:setMask( mask )
    -- Transform mask
    portrait.maskScaleX, portrait.maskScaleY = 0.3,0.3
    PlayerUI:insert(portrait)

    local portrait2 = display.newImageRect( "GameResources/ToBeRemoved/joao.png", 48, 69 )
    portrait2:rotate(90)
    portrait2:translate( display.contentWidth/1.04, display.contentHeight/8 )
    local mask = graphics.newMask( "GameResources/ToBeRemoved/circ_mask.png" )
    portrait2:setMask( mask )
    portrait2.maskScaleX, portrait2.maskScaleY = 0.1,0.1
    PlayerUI:insert(portrait2)

    local portrait3 = display.newImageRect( "GameResources/ToBeRemoved/joao.png", 48, 69 )
    portrait3:rotate(90)
    portrait3:translate( display.contentWidth/1.14, display.contentHeight/7 )
    local mask = graphics.newMask( "GameResources/ToBeRemoved/circ_mask.png" )
    portrait3:setMask( mask )
    portrait3.maskScaleX, portrait3.maskScaleY = 0.1,0.1
    PlayerUI:insert(portrait3)

    local portrait4 = display.newImageRect( "GameResources/ToBeRemoved/joao.png", 48, 69 )
    portrait4:rotate(90)
    portrait4:translate( display.contentWidth/1.27, display.contentHeight/8 )
    local mask = graphics.newMask( "GameResources/ToBeRemoved/circ_mask.png" )
    portrait4:setMask( mask )
    portrait4.maskScaleX, portrait4.maskScaleY = 0.1,0.1
    PlayerUI:insert(portrait4)

    local hpText = display.newText( Player.currenthp.."/"..Player.maxhp.."HP", 467, 450, native.systemFont, 26 )
    hpText:setFillColor( 1, 0, 0 )
    hpText:rotate(90)
    hpprogressView:rotate(90)
    PlayerUI:insert(hpText)
    PlayerUI:insert(hpprogressView)

    local essenceText = display.newText( Player.currentessence.."/"..Player.maxessence.."AP", 410, 450, native.systemFont, 26 )
    essenceText:setFillColor( 0, 0, 1 )
    essenceText:rotate(90)
    essenceprogressView:rotate(90)
    PlayerUI:insert(essenceText)
    PlayerUI:insert(essenceprogressView)
    ---------------------------------------------------------------------------------

    --DIRECTIONAL PAD
    local dpad = display.newImage( "GameResources/ToBeRemoved/directionalpad.png" )
    dpad.alpha = 0.5
    dpad:translate( display.contentWidth/3.6, display.contentHeight/1.15 )
    dpad:scale(0.5,0.5)
    DpadUI:insert(dpad)
    DpadUI:addEventListener("tap", touchListener)

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