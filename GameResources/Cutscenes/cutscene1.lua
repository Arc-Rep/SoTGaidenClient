local composer = require( "composer" )
local TextData = require "SoTClient.Visuals.Dialog"
local MapRender = require "SotClient.Visuals.RenderMap"
local MapData = require "SoTClient.GameLogic.Scenarios.MissionMap"
local system = require("system")
local scene = composer.newScene()
local map_render = {}
local dialogArray = {}
local diaoptions



local function tapListener(event) 
    if next(dialogArray) then
        if dialogArray[1].position == "right" then
            if diaoptions~=nil and diaoptions.character == dialogArray[1].character then
                TextData.RemoveTextBox(diaoptions)
            else
                TextData.RemoveCharOnRight(diaoptions)
                TextData.RemoveTextBox(diaoptions)
            end
            diaoptions = table.remove(dialogArray,1)
            TextData.ShowCharOnRight(diaoptions)
            TextData.TextBox(diaoptions)

        elseif dialogArray[1].position == "left" then
            if diaoptions~=nil and diaoptions.character == dialogArray[1].character then
                TextData.RemoveTextBox(diaoptions)
            else
                TextData.RemoveCharOnLeft(diaoptions)
                TextData.RemoveTextBox(diaoptions)
            end
            diaoptions = table.remove(dialogArray,1)
            TextData.ShowCharOnLeft(diaoptions)
            TextData.TextBox(diaoptions)
        end
    else
        scene:destroy()
    end
end


function scene:create( event )
    local sceneGroup = self.view
    
    --SECURITY REASONS = system.DocumentsDirectory
    local optionsArray = TextData.loadTable("cutscene.json",system.DocumentsDirectory)

    table.insert(dialogArray,optionsArray.options)
    table.insert(dialogArray,optionsArray.options2)
    table.insert(dialogArray,optionsArray.options4)
    table.insert(dialogArray,optionsArray.options3)
    ---------------------------------------------------------------------------------
    map_render = MapRender.setVisualMap(MapData.GetMap())
    sceneGroup:addEventListener("tap",tapListener)
    for i = 1, #map_render, 1 do
		for j = 1, #map_render[i], 1 do
			sceneGroup:insert(map_render[i][j])
		end
	end
    TextData.ShowBackground("GameResources/ToBeRemoved/background.jpg")
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
        
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
    TextData.RemoveEverything()
end


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene