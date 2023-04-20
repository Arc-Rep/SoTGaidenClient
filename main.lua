-- show default status bar (iOS)
display.setStatusBar( display.HiddenStatusBar )

-- include Corona's "widget" library
local composer = require "composer"
local Player = require "SoTClient.GameLogic.PlayerLogic.Player"
local sqlite3 = require( "sqlite3" )

local datapath = "D:/GameDev/SoT Gaiden/UserData/gamedata.db"
DB = sqlite3.open(datapath)

--composer.gotoScene("loginmenu")

-- event listeners for tab buttons:
local function onFirstView( event )
	composer.gotoScene( "view1" )
end

local function onSecondView( event )
	composer.gotoScene( "view2" )
end


-- create a tabBar widget with two buttons at the bottom of the screen

-- table to setup buttons
--local tabButtons = {
--	{ label="First", defaultFile="button1.png", overFile="button1-down.png", width = 32, height = 32, onPress=onFirstView, selected=true },
--	{ label="Second", defaultFile="button2.png", overFile="button2-down.png", width = 32, height = 32, onPress=onSecondView },
--}

-- create the actual tabBar widget
--[[local tabBar = widget.newTabBar{
	top = display.contentHeight - 50,	-- 50 is default height for tabBar widget
	buttons = tabButtons
}]]--

display.setDefault("anchorX", 0)
display.setDefault("anchorY", 0)

onFirstView()	-- invoke first tab button's onPress event manually
