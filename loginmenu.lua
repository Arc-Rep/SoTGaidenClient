local composer = require( "composer" )
local scene = composer.newScene()
local transition = require("transition")
local json = require("json")
local network = require("network")
local audio = require("audio")


local grpMain,userName,password,background,Title,signInbtn,signInlbl,usernameField,passwordField,settingsbtn,settingslbl,Username,logInbtn,logInlbl
local backgroundMusic = audio.loadStream( "GameResources/Sound/loginmusic.mp3" )
audio.reserveChannels(1)
audio.setVolume( 0.1, { channel=1 } )
audio.play( backgroundMusic, { channel=1, loops=-1 } )
--ERRORS
local loginError = display.newText("Login failed.",390,370,450,0,"Arial",20)
loginError:rotate(90)
loginError.alpha=0

local loginError2 = display.newText("Empty Username",390,370,450,0,"Arial",20)
loginError2:rotate(90)
loginError2.alpha=0
---------------------------------------------------------------------------------

local function goToSettings(event)
	composer.gotoScene("settings")
end

local function goToRegister(event)
	composer.gotoScene("register")
end

local function usernameListener( event )
	if ( event.phase == "editing" ) then
		Username = event.target.text
	end
end

local function passwordListener( event )
	if ( event.phase == "editing" ) then
		password = event.target.text
	end
end
 
local function handleResponse( event )
    if not event.isError then
		--local response = json.decode( event.response )
        if(event.status==404 or event.status==500 or event.isError) then
            transition.to(loginError,{time=500,alpha=1})
            transition.to(loginError,{delay=1000,time=500,alpha=0})
    	else
        	display.remove(grpMain.userName)
            display.remove(grpMain.password)
            composer.gotoScene("view1")
   		end
	else 
		print( "Error!" )
	end
    return
end

local function loginUserRequest(event)
	--DO GET REQUEST (check if user exists)
	--CREATE PASSWORD AUTH
	if(Username==nil) then
		transition.to(loginError2,{time=500,alpha=1})
		transition.to(loginError2,{delay=1000,time=500,alpha=0})
	else
		local get = "?" .. "Username=" .. Username
		network.request("https://localhost:7126/users".. get,"GET", handleResponse)
		Username = nil
	end
end


function scene:create( event )
	grpMain = display.newGroup()
	
	self.view:insert(grpMain)

	background = display.newImage(grpMain, "GameResources/loginbackground.png")
	background:translate(150,750)
	background:rotate(90)
	grpMain:insert(background)

	Title = display.newText("Shards Of Tomorrow",340,570,450,0,"GameResources/Fonts/AlexBrush-Regular.ttf",100)
	Title.fill = {1,1,1}
	Title:rotate(90)
	grpMain:insert(Title)
	
	--LOADING WAITER?
	--[[signInbtn = display.newRoundedRect(grpMain, 120,550,260,80,20)
	signInbtn.fill =  {1,1,1}
	signInbtn.alpha = 0.4;
	signInbtn:rotate(90)

	signInlbl = display.newText("SIGN IN TO CONTINUE", 120,550, "GameResources/Fonts/Oswald-Bold.ttf", 30)
	signInlbl:rotate(90)
	transition.blink(signInlbl, {time=2000})
	grpMain:insert(signInbtn)
	grpMain:insert(signInlbl)]]--
	---------------------------------------------------------------------------------

	display.remove(signInbtn)
	display.remove(signInlbl)

	userName = display.newText("Username:",190,670,450,0,"Arial",40)
	password = display.newText("Password:",90,670,450,0,"Arial",40)
	userName:rotate(90)
	password:rotate(90)
	grpMain:insert(userName)
	grpMain:insert(password)

	signInbtn = display.newRoundedRect(grpMain, 120,850,240,80,20)
	signInbtn.fill =  {1,1,1}
	signInbtn.alpha = 0.4;
	signInbtn:rotate(90)

	signInlbl = display.newText("REGISTER", 120,850, "GameResources/Fonts/Oswald-Bold.ttf", 30)
	signInlbl:rotate(90)
	grpMain:insert(signInlbl)

	signInbtn:addEventListener("tap", goToRegister)

	logInbtn = display.newRoundedRect(grpMain,120,250,260,80,20)
    logInbtn.fill =  {1,1,1}
    logInbtn.alpha = 0.4;
    logInbtn:rotate(90)
    grpMain:insert(logInbtn)

    logInlbl = display.newText("LOGIN", 120,250, "GameResources/Fonts/Oswald-Bold.ttf", 30)
    logInlbl.fill = {  1, 1, 1 }
    logInlbl:rotate(90)
    grpMain:insert(logInlbl)

    logInbtn:addEventListener("tap", loginUserRequest)


	settingslbl = display.newImageRect("GameResources/cogwheel.png",100,100)
	settingslbl.x = 50
	settingslbl.y = 50
	settingslbl.width = 101
	settingslbl.height = 97
	grpMain:insert(settingslbl)

	settingslbl:addEventListener("tap", goToSettings)
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		usernameField = native.newTextField( 550, 340, 200, 50 )
		usernameField:addEventListener( "userInput", usernameListener )
		passwordField = native.newTextField( 550, 440, 200, 50 )
		passwordField:addEventListener( "userInput", passwordListener )
	elseif phase == "did" then

	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if event.phase == "will" then
		usernameField:removeSelf()
        passwordField:removeSelf()
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