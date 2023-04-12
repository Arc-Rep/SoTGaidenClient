local composer = require( "composer" )
local scene = composer.newScene()
local transition = require("transition")
local json = require("json")
local network = require("network")

local background,usernameField,passwordField,userName,password,email,emailField,regInbtn,regInlbl,backbtn,backlbl,grpReg,reguser,regemail,regpass

--ERRORS
local regError = display.newText("Not a valid registration",390,370,450,0,"Arial",20)
regError.alpha=0
---------------------------------------------------------------------------------

local function usernameListener( event )
    if ( event.phase == "editing" ) then
		reguser = event.target.text
	end
end

local function passwordListener( event )
    if ( event.phase == "editing" ) then
		regpass = event.target.text
    end
end

local function emailListener( event )
    if ( event.phase == "editing" ) then
        regemail = event.target.text
    end
end

local function handleResponse( event )
    if not event.isError then
        --local response = json.decode( event.response )
        if(event.status==400 or event.status==500 or event.isError) then
            transition.to(regError,{time=500,alpha=1})
            transition.to(regError,{delay=1000,time=500,alpha=0})
        else
            display.remove(grpReg.userName)
            display.remove(grpReg.password)
            display.remove(grpReg.email)
            composer.gotoScene("loginmenu")
        end
    else
        print( "Error!" )
    end
    return
end

local function registerUserRequest(event)
    --Do a POST (create user)
    local headers = {}
    headers["Content-Type"] = "application/json"
    local body = {}
    body.userName = reguser
    body.password = regpass
    body.email = regemail
    body.serverMap = 1

    local params = {}
    params.headers = headers
    params.body = json.encode(body)

    network.request("https://localhost:7126/users","POST", handleResponse, params)
    reguser = nil
    regpass = nil
    regemail = nil
end


local function goToMainMenu(event)
    display.remove(grpReg.userName)
    display.remove(grpReg.password)
    display.remove(grpReg.email)
	composer.gotoScene("loginmenu")
end


function scene:create( event )
    grpReg = display.newGroup()

    self.view:insert(grpReg)

    background = display.newImage(grpReg, "GameResources/loginbackground.png")
    background:translate(150,750)
    
    userName = display.newText("Username:",290,670,450,0,"Arial",40)
    userName.fill = { 1, 1, 1 }
    password = display.newText("Password:",190,670,450,0,"Arial",40)
    password.fill = {  1, 1, 1 }
    email = display.newText("Email:",390,670,450,0,"Arial",40)
    email.fill = {  1, 1, 1 }
    grpReg:insert(userName)
    grpReg:insert(password)
    grpReg:insert(email)

    regInbtn = display.newRoundedRect(grpReg,120,850,260,80,20)
    regInbtn.fill =  {1,1,1}
    regInbtn.alpha = 0.4;
    grpReg:insert(regInbtn)

    regInlbl = display.newText("APPLY", 120,850, "GameResources/Fonts/Oswald-Bold.ttf", 30)
    regInlbl.fill = {  1, 1, 1 }
    grpReg:insert(regInlbl)

    regInbtn:addEventListener("tap", registerUserRequest)

    backbtn = display.newRoundedRect(grpReg,120,250,260,80,20)
    backbtn.fill =  {1,1,1}
    backbtn.alpha = 0.4;
    grpReg:insert(backbtn)

    backlbl = display.newText("BACK", 120,250, "GameResources/Fonts/Oswald-Bold.ttf", 30)
    grpReg:insert(backlbl)

    backbtn:addEventListener("tap", goToMainMenu)
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then

	elseif phase == "did" then
        usernameField = native.newTextField( 550, 140, 200, 50 )
        usernameField:addEventListener( "userInput", usernameListener )
        passwordField = native.newTextField( 550, 240, 200, 50 )
        passwordField:addEventListener( "userInput", passwordListener )
        emailField = native.newTextField( 550, 340, 200, 50 )
        emailField:addEventListener( "userInput", emailListener )
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if event.phase == "will" then
        usernameField:removeSelf()
        passwordField:removeSelf()
        emailField:removeSelf()
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