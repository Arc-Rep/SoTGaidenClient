-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local MapData = require "SotClient.GameLogic.Scenarios.MissionMap"
local MapRender = require "SotClient.Visuals.RenderMap"
local map_data = {}
local map_render = {}
local game_overseer = require "SotClient.GameLogic.LevelMechanics.GameOverseer"
local last_click = system.getTimer()

local touchListener = function( event )

	if(last_click + 300 > system.getTimer()) then
		return false
	end

	last_click = system.getTimer()

    local x, y = event.x, event.y
	if( y < display.contentHeight/ 5) then
		print(map_data[1][1])
		game_overseer.SendCommand(map_data,"pressUp")
		print("Up")
	elseif (y > display.contentHeight * (4/5)) then
		game_overseer.SendCommand(map_data,"pressDown")
		print("Down")
	elseif (x < display.contentWidth / 4) then
		game_overseer.SendCommand(map_data,"pressLeft")
		print("Left")
	elseif (x > display.contentWidth * (3 / 4)) then
		game_overseer.SendCommand(map_data,"pressRight")
		print("Right")
	end
	map_render = MapRender.UpdateTilemap(map_render, map_data)
    return true
end

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

	map_data = MapData.generateMap(0, 14638, 3526, 0)
	
	game_overseer.StartGame(map_data, nil, nil)
	map_render = MapRender.setVisualMap(map_data)
	MapRender.UpdateTilemap(map_render, map_data)
	sceneGroup:addEventListener("touch", touchListener)

	for i = 1, #map_render, 1 do
		for j = 1, #map_render[i], 1 do
			sceneGroup:insert(map_render[i][j])
		end
	end
	-- all objects must be added to group (e.g. self.view)
	--sceneGroup:insert( background )
	--sceneGroup:insert( title )
	--sceneGroup:insert( summary )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	MapRender.UpdateTilemap(map_render,map_data)
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