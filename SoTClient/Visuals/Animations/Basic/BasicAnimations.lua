local Camera = require "SoTClient.Visuals.CameraMap"
local MapData = require "SoTClient.GameLogic.Scenarios.MissionMap"
local MapRender = require "SotClient.Visuals.RenderMap"
local timer = require "timer"
local math = require "math"


function ElementMove(animation)
    local current_object = animation.object
    local params = animation.params

    if animation.object == Camera.getFocus() then
        MapRender.MoveTileMap(params)
        --Camera.StartFocusAnimation(params)
        --return MapRender.PerformAnimation(animation.object)
    else
        Camera.MoveElement(animation.object.Texture, animation.params)
    end
end

    