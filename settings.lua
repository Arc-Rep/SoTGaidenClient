local composer = require( "composer" )
local scene = composer.newScene()
local transition = require("transition")
local audio = require("audio")
local widget = require("widget")


local grpSett,background,slider,music,backbtn,backlbl

local function goToMainMenu(event)
	composer.gotoScene("loginmenu")
end

local function sliderListener( event )
    audio.setVolume( 1-event.value*0.01, { channel=1 } )
end


function scene:create( event )
	grpSett = display.newGroup()
    self.view:insert(grpSett)
    
    background = display.newImage(grpSett, "GameResources/loginbackground.png")
    background:translate(150,750)
    background:rotate(90)

    music = display.newText("Music:",290,670,450,0,"Arial",40)
    music.fill = { 1, 1, 1 }
    music:rotate(90)
    grpSett:insert(music)

    local slider = widget.newSlider(
    {
        x = display.contentCenterX,
        y = display.contentCenterY,
        orientation = "vertical",
        height = 200,
        value = 90,  -- Starts slider at 10% 
        listener = sliderListener
    })
    grpSett:insert(slider)

    backbtn = display.newRoundedRect(grpSett,120,250,260,80,20)
    backbtn.fill =  {1,1,1}
    backbtn.alpha = 0.4;
    backbtn:rotate(90)
    grpSett:insert(backbtn)

    backlbl = display.newText("BACK", 120,250, "GameResources/Fonts/Oswald-Bold.ttf", 30)
    backlbl:rotate(90)
    grpSett:insert(backlbl)

    backbtn:addEventListener("tap", goToMainMenu)

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then

	elseif phase == "did" then

	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if event.phase == "will" then
	elseif phase == "did" then

	end
end

function scene:destroy( event )
	local sceneGroup = self.view

end
---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene