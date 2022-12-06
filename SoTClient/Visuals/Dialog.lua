local transition = require("transition")
local json = require("json")
local system = require("system")
local graphics = require("graphics")
local composer = require( "composer" )
local timer = require("timer")

local Dialog = {}
local leftchararray = {}
local rightchararray = {}
local myImage
local leftchardir,leftcharacter,rightchardir,rightcharacter
local rectangle,textbox
local sheet_firespin,fireSpin

local defaultLocation = system.DocumentsDirectory

local sheetOptions = {
    width = 100,
    height = 100,
    numFrames = 49
}

local sequence_firespin = {
    {
        name = "loading_ball",
        start = 1,
        count = 49,
        time = 610,
        loopCount = 0,
        loopDirection = "foward"
    }
}

function Dialog.CreateLoading(x,y)
    sheet_firespin = graphics.newImageSheet("6_flamelash_spritesheet.png",system.DocumentsDirectory, sheetOptions)
    fireSpin = display.newSprite(sheet_firespin, sequence_firespin)
    fireSpin.x = x
    fireSpin.y = y
    fireSpin.alpha = 0
    fireSpin:play()
end

local letterLabel
local sentence
local delayTimer

local function displayData(event)
   local letter = string.sub(sentence,event.count, event.count)
   if letterLabel == nil then
        timer.cancel(delayTimer)
   else
        letterLabel.text = letterLabel.text .. letter
   end
end

local function setText(aSentence)
  sentence = aSentence
  letterLabel.text = ""
  delayTimer = timer.performWithDelay(70, displayData, string.len(sentence))
end

function Dialog.setFullText(options)
    display.remove(letterLabel)
    letterLabel = nil
    timer.cancel(delayTimer)
    letterLabel = display.newText(options)
    letterLabel:setFillColor( 1, 1, 1 )
    letterLabel:rotate(90)
end

function Dialog.getStringTime(aSentence)
    return string.len(aSentence)*70
end


function Dialog.ShowBackground(charDir)
    myImage = display.newImage(charDir)
    myImage:translate(500,500)
    myImage:rotate(90)
    myImage.alpha = 0
    transition.to(myImage, { time=2000, alpha=1.0} )
end


function Dialog.ShowCharOnLeft(options)
    if leftchardir ~= nil and leftchardir~=options.character then
        for i=1,#leftchararray do
            leftchararray[i]:removeSelf()
            leftchararray[i] = nil
        end
    end
    leftchardir = options.character
    leftcharacter = display.newImage(options.character)
    leftcharacter:translate(300,300) --Global Values (char always same position)
    leftcharacter:rotate(90)
    leftcharacter.alpha = 0
    transition.to(leftcharacter, { time=500, alpha=1.0} )
    table.insert(leftchararray,1,leftcharacter)
end

function Dialog.RemoveCharOnLeft()
    display.remove(leftcharacter)
    display.remove(fireSpin)
    leftcharacter = nil
    --fireSpin:pause()
end


function Dialog.ShowCharOnRight(options)
    if rightchardir ~= nil and rightchardir~=options.character then
        for i=1,#rightchararray do
            rightchararray[i]:removeSelf()
            rightchararray[i] = nil
        end
    end
    rightchardir = options.character
    rightcharacter = display.newImage(options.character)
    rightcharacter:translate(300,800) --Global Values (char always same position)
    rightcharacter.xScale = -1
    rightcharacter:rotate(90)
    rightcharacter.alpha = 0
    transition.to(rightcharacter, { time=500, alpha=1.0} )
    table.insert(rightchararray,1,rightcharacter)
end

function Dialog.RemoveCharOnRight()
    display.remove(rightcharacter)
    display.remove(fireSpin)
    rightcharacter = nil
end

function Dialog.TextBox(options)
    rectangle = display.newRoundedRect( options.x, options.y, options.height+20, options.width+20, 12 )
    rectangle.strokeWidth = 3
    rectangle:setFillColor( 0.5 )
    rectangle:setStrokeColor( 1, 0, 0 )
    rectangle.alpha = 0
    transition.to(rectangle,{time=500, alpha=1.0})

    letterLabel = display.newText( options )
    letterLabel:setFillColor( 1, 1, 1 )
    letterLabel:rotate(90)
    setText(letterLabel.text)

    if options.position == "left" then
        Dialog.CreateLoading(options.x-options.x/2,options.y+options.y/1.4)
    else
        Dialog.CreateLoading(options.x-options.x/2,options.y+options.y/4.2)
    end 
    transition.to(fireSpin,{time=5000,alpha=1.0})
end

function Dialog.RemoveTextBox()
    display.remove(rectangle)
    rectangle = nil
    display.remove(letterLabel)
    letterLabel = nil
    display.remove(fireSpin)
    fireSpin = nil
end

function Dialog.RemoveEverything()
    display.remove(rectangle)
    display.remove(textbox)
    display.remove(rightcharacter)
    display.remove(fireSpin)
    display.remove(leftcharacter)
    display.remove(myImage)
    rectangle = nil
    textbox = nil
    fireSpin = nil
    rightcharacter = nil
    leftcharacter = nil
    myImage = nil
    composer.gotoScene("view1",{time=2000, effect="fade"})
end

return Dialog