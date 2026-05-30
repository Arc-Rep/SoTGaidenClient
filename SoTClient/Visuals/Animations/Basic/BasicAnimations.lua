local Camera = require "SoTClient.Visuals.CameraMap"
local MapData = require "SoTClient.GameLogic.Scenarios.MissionMap"
local MapRender = require "SotClient.Visuals.RenderMap"
local timer = require "timer"
local math = require "math"


function ElementMove(element_data)
    local current_object = element_data.object
    local move_params = element_data.move_params

    if element_data.object == Camera.getFocus() then
        MapRender.MoveTileMap(move_params)
        --Camera.StartFocuselement_data(params)
        --return MapRender.Performelement_data(element_data.object)
    else
        Camera.MoveElement(element_data.object.Texture, move_params, element_data.animation)
    end
end

    