local composer = require( "composer" )
local TextData = require "SoTClient.Visuals.Dialog"
local GeneralUtils = require "SoTClient.Utils.GeneralUtils"
local system = require("system")
local scene = composer.newScene()
local dialogArray = {}
local diaoptions

local limitFrameTime = 0
local leftchar = nil
local rightchar = nil

local function tapListener(event)
    local currentFrameTime

    currentFrameTime = system.getTimer()
    if next(dialogArray) then
        if dialogArray[1].position == "right" then
            if system.getTimer()<limitFrameTime+currentFrameTime then
                print("printed everything",system.getTimer())
                TextData.setFullText(diaoptions)
                limitFrameTime = 0
            else
                if diaoptions~=nil and rightchar == dialogArray[1].character then
                    TextData.RemoveTextBox()
                else
                    TextData.RemoveCharOnRight()
                    TextData.RemoveTextBox()
                end
                diaoptions = table.remove(dialogArray,1)
                rightchar = diaoptions.character
                limitFrameTime = TextData.getStringTime(diaoptions.text)
                TextData.ShowCharOnRight(diaoptions)
                TextData.TextBox(diaoptions)
            end

        elseif dialogArray[1].position == "left" then
            if system.getTimer()<limitFrameTime+currentFrameTime then
                print("printed everything",system.getTimer())
                TextData.setFullText(diaoptions)
                limitFrameTime = 0
            else
                if diaoptions~=nil and leftchar == dialogArray[1].character then   
                    TextData.RemoveTextBox()
                    diaoptions = table.remove(dialogArray,1)
                    leftchar = diaoptions.character
                    limitFrameTime = TextData.getStringTime(diaoptions.text)
                    TextData.TextBox(diaoptions)
                else
                    TextData.RemoveCharOnLeft()
                    TextData.RemoveTextBox()
                    diaoptions = table.remove(dialogArray,1)
                    leftchar = diaoptions.character
                    limitFrameTime = TextData.getStringTime(diaoptions.text)
                    TextData.ShowCharOnLeft(diaoptions)
                    TextData.TextBox(diaoptions)
                end
            end
        end
    else
        if system.getTimer()<limitFrameTime+currentFrameTime then
            print("printed everything",system.getTimer())
            TextData.setFullText(diaoptions)
            limitFrameTime = 0
        else
            TextData.RemoveTextBox()
            scene:destroy()
        end
    end
end


function scene:create( event )
    local sceneGroup = self.view

    --SECURITY REASONS = system.DocumentsDirectory
    local optionsArray = TextData.loadTable("cutscene.json",system.DocumentsDirectory)

    --GeneralUtils.PrintTable(optionsArray)
    local myRectangle = display.newRect(300,600,display.contentWidth*2, display.contentHeight*2)
    myRectangle:addEventListener("tap",tapListener)
    for k,v in pairs(optionsArray) do 
        table.insert(dialogArray, v)
    end
    ---------------------------------------------------------------------------------
    sceneGroup:insert(myRectangle)
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
    TextData.RemoveCharOnLeft()
    TextData.RemoveEverything()
end


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene