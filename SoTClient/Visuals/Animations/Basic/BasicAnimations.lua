local Camera = require "SoTClient.Visuals.CameraMap"
local MapData = require "SoTClient.GameLogic.Scenarios.MissionMap"
local MapRender = require "SotClient.Visuals.RenderMap"
local timer = require "timer"
local math = require "math"

local focus_initial_x, focus_initial_y
local current_object
local start_timer = 0

function ElementMove(animation)
    char = animation.object
    game_map = animation.map
    params = animation.params
    end_function = animation.params.end_function

    local desired_x, desired_y = char["x"] + params["x"], char["y"] + params["y"]
    local cur_tile, desired_tile = game_map[char["x"]][char["y"]],
                                    game_map[desired_x][desired_y]

    local AnimationEnd =
        function()
            cur_tile["Actor"] = nil
            desired_tile["Actor"] = char
            char["x"] = desired_x
            char["y"] = desired_y
            char["animation"] = nil
            if animation.object == Camera.getFocus() then
                return end_function 
            else
                end_function()
            end
        end

    params.onComplete = AnimationEnd
    params.onCancel = AnimationEnd

    animation.object["animation"] = params
    current_object = animation.object
    if animation.object == Camera.getFocus() then
        Camera.StartFocusAnimation(params)
        return MapRender.PerformAnimation(animation.object)
    else
        Camera.MoveElement(animation.object.Texture, animation.params)
    end
end

    