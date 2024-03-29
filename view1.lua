-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local RenderBroker = require "SotClient.Visuals.RenderBroker"
local GameOverseer = require "SotClient.GameLogic.LevelMechanics.GameOverseer"
local MapData = require "SoTClient.GameLogic.Scenarios.MissionMap"
local Player = require "SoTClient.GameLogic.PlayerLogic.Player"
local seed1, seed2 = 14638, 3533
local cutscene = {false}

function scene:create( event )
	local sceneGroup = self.view
	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	
	-- create a white background to fill screen
	--local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	--background:setFillColor( 1 )	-- white

	
	--local newTextParams = { text = "Loaded by the first tab's\n\"onPress\" listener\nspecified in the 'tabButtons' table", 
	--					x = display.contentCenterX + 10,
	--					y = display.contentCenterX + 50,
	--					width = 310, height = 310, 
	--					font = native.systemFont, fontSize = 14, 
	--					align = "center" }
	--local summary = display.newText( newTextParams )
	--summary:setFillColor( 0 ) -- black

	
	GameOverseer.SetupGame(MapData, nil, nil, seed1, seed2)

	Player.readPlayer()

	RenderBroker.SetRenderBattle(MapData.GetMap(), GameOverseer.GetPlayerParty(), nil, sceneGroup)
	RenderBroker.UpdateRender()

	GameOverseer.StartGame()

	
	-- all objects must be added to group (e.g. self.view)
	--sceneGroup:insert( background )
	--sceneGroup:insert( title )
	--sceneGroup:insert( summary )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	RenderBroker.UpdateRender()
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene