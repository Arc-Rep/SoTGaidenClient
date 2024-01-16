local CameraMap = {}

local math = require "math"
local timer = require "timer"
local EventManager = require "SoTClient.Visuals.Events.EventManager"
local AnimationQueue = require "SoTClient.Visuals.Animations.Basic.AnimationQueue"

local camera_x, camera_y = 0, 0
local camera_start_x, camera_start_y = 1, 1
local camera_width_base, camera_height_base = 0, 0
local camera_tile_width, camera_tile_height = 1, 1
local camera_tile_pixel_conversion = 1
local TILE_OUT_BOUNDS = 6
local CAMERA_MAX_TILE_DRAG = 1
local CAMERA_MAX_MOTION_SPEED = 0.1
local CAMERA_ZOOM_VALUES = {0.75, 0.875, 1, 1.125, 1.25}
local zoom_index = 3
local camera_tile_pixel_zoomed = 1
local camera_drag_begin_x, camera_drag_begin_y = nil, nil
local camera_drag_x, camera_drag_y = 0, 0
local camera_x_animation_offset, camera_y_animation_offset = 0, 0
local camera_x_animation_offset_focus, camera_y_animation_offset_focus = 0, 0
local camera_animation_speed_x, camera_animation_speed_y
local camera_animation_start_time = nil
local camera_animation_time = nil
local camera_animation_ongoing = false
local camera_shift_x = 0
local camera_shift_y = 0
local focus_element_queue = {}

function CameraMap.updateFocusAnimated()
    local camera_x_prev
    local camera_y_prev
    
    if(focus_element_queue[1]["x"] ~= nil and focus_element_queue[1]["y"] ~= nil) then
        camera_focus_x = focus_element_queue[1]["x"]
        camera_focus_y = focus_element_queue[1]["y"]
    end

    if(CameraMap.CheckAnimationExists() == true) then
        camera_x_prev = camera_x
        camera_y_prev = camera_y
        CameraMap.DoCameraAnimation(camera_x_animation_offset_focus, camera_y_animation_offset_focus)
        camera_x = camera_focus_x + camera_x_animation_offset 
        camera_y = camera_focus_y + camera_y_animation_offset
    else
        camera_x = camera_focus_x
        camera_y = camera_focus_y
        camera_x_prev = camera_x
        camera_y_prev = camera_y
    end

    camera_start_x = camera_x - camera_tile_width/2
    camera_start_y = camera_y - camera_tile_height/2

    return camera_x_animation_offset, camera_y_animation_offset
end

function CameraMap.zoomSetup()
    camera_tile_pixel_zoomed = camera_tile_pixel_conversion * CAMERA_ZOOM_VALUES[zoom_index]
    camera_tile_width = camera_width_base / camera_tile_pixel_zoomed + TILE_OUT_BOUNDS
    camera_tile_height = camera_height_base / camera_tile_pixel_zoomed + TILE_OUT_BOUNDS
    camera_start_x = camera_x - camera_tile_width/2
    camera_start_y = camera_y - camera_tile_height/2
end

function CameraMap.zoomDecrease()
    if(zoom_index == 0) then
        return false
    end
    zoom_index = zoom_index - 1
    CameraMap.zoomSetup()
end
 
function CameraMap.zoomIncrease()
    if(zoom_index == 5) then
        return false
    end
    zoom_index = zoom_index + 1
    CameraMap.zoomSetup()
end

function CameraMap.DoCameraAnimation(offset_x, offset_y)
    if camera_animation_start_time == nil then
        camera_animation_speed_x  = (offset_x  - camera_x_animation_offset) / CAMERA_MAX_TILE_DRAG * CAMERA_MAX_MOTION_SPEED
        camera_animation_speed_y  = (offset_y  - camera_y_animation_offset) / CAMERA_MAX_TILE_DRAG * CAMERA_MAX_MOTION_SPEED
    else
        local current_time = system.getTimer()
        if (current_time > camera_animation_start_time + camera_animation_time) then
            camera_animation_ongoing = false
        else
            local relative_time = (current_time - camera_animation_start_time) / camera_animation_time
            camera_x_animation_offset  = camera_x_animation_offset + (offset_x - camera_x_animation_offset) * relative_time
            camera_y_animation_offset  = camera_y_animation_offset + (offset_y - camera_y_animation_offset) * relative_time
        end
        return
    end

    if(camera_animation_speed_x > 0 and camera_animation_speed_x < 0.001) then
        camera_x_animation_offset = camera_x_animation_offset_focus
    elseif(camera_animation_speed_x < 0 and camera_animation_speed_x > -0.001) then
        camera_x_animation_offset = camera_x_animation_offset_focus
    else
        camera_x_animation_offset = camera_x_animation_offset + camera_animation_speed_x
    end

    if(camera_animation_speed_y > 0 and camera_animation_speed_y < 0.001) then
        camera_y_animation_offset = camera_y_animation_offset_focus
    elseif(camera_animation_speed_y < 0 and camera_animation_speed_y > -0.001) then
        camera_y_animation_offset = camera_y_animation_offset_focus
    else
        camera_y_animation_offset = camera_y_animation_offset + camera_animation_speed_y
    end

end

function CameraMap.StartFocusAnimation(animation_data)
    camera_x_animation_offset_focus = animation_data.x
    camera_y_animation_offset_focus = animation_data.y
    print("Animation Starting...")
    print(camera_x_animation_offset)
    print(camera_y_animation_offset)
    camera_animation_start_time = system.getTimer()
    camera_animation_time = animation_data.time
    camera_animation_ongoing = true
end

function CameraMap.ShiftMap(shift_x, shift_y)
    camera_shift_x = shift_x
    camera_shift_y = shift_y
end

function CameraMap.EndFocusAnimation()
    camera_x_animation_offset_focus = 0
    camera_y_animation_offset_focus = 0
    camera_x_animation_offset = camera_x_animation_offset_focus
    camera_y_animation_offset = camera_y_animation_offset_focus
    camera_animation_start_time = nil
    camera_animation_time = nil
    print("Animation Ended")
end

function CameraMap.MoveElement(texture, params)
    params["x"] = (params["x"] + camera_x_animation_offset_focus) * camera_tile_pixel_zoomed
    params["y"] = (params["y"] + camera_y_animation_offset_focus) * camera_tile_pixel_zoomed
    --transition.moveBy(texture, params)

    AnimationQueue.AddAnimation(texture, params)
end

function CameraMap.CameraDrag(event)


    if(event.phase == "moved") then
        camera_drag_x = (event.x - camera_drag_begin_x) / (camera_width_base / 2)
        camera_drag_y = (event.y - camera_drag_begin_y) / (camera_height_base / 2)
    
        if(camera_drag_x < -CAMERA_MAX_TILE_DRAG) then
            camera_drag_x = -CAMERA_MAX_TILE_DRAG
        elseif(camera_drag_x > CAMERA_MAX_TILE_DRAG) then
            camera_drag_x = CAMERA_MAX_TILE_DRAG
        end

        if(camera_drag_y < -CAMERA_MAX_TILE_DRAG) then
            camera_drag_y = -CAMERA_MAX_TILE_DRAG
        elseif(camera_drag_y > CAMERA_MAX_TILE_DRAG) then
            camera_drag_y = CAMERA_MAX_TILE_DRAG
        end

        camera_x_animation_offset = -camera_drag_x
        camera_y_animation_offset = -camera_drag_y

        return
    end

    if(event.phase == "began") then
        camera_animation_ongoing = true
        camera_drag_begin_x = event.x
        camera_drag_begin_y = event.y
    end
end

function CameraMap.CheckAnimationExists()
    return camera_animation_ongoing
end

function CameraMap.addFocus(focus)
    focus_element_queue[#focus_element_queue + 1] = focus
    CameraMap.updateFocusAnimated()
end

function CameraMap.popFocus()
    if (#focus_element_queue ~= 0) then
        table.remove(focus_element_queue, #focus_element_queue)
    end
    CameraMap.updateFocusAnimated()
end

function CameraMap.getFocus()
    return focus_element_queue[1]
end


function CameraMap.getX()
    return camera_x
end

function CameraMap.getY()
    return camera_y
end

function CameraMap.getDeviationX()
    return TILE_OUT_BOUNDS/2
end

function CameraMap.getDeviationY()
    return TILE_OUT_BOUNDS/2
end

function CameraMap.getStartTileX()
    return camera_start_x
end

function CameraMap.getStartTileY()
    return camera_start_y
end

function CameraMap.getTileWidth()
    return camera_tile_width
end

function CameraMap.getTileHeight()
    return camera_tile_height
end

function CameraMap.getRealTileSize()
    return camera_tile_pixel_conversion * CAMERA_ZOOM_VALUES[zoom_index]
end

function CameraMap.getAnimationFocusOffsetX()
    return camera_x_animation_offset_focus
end

function CameraMap.getAnimationFocusOffsetY()
    return camera_x_animation_offset_focus
end

function CameraMap.setup(Map, screen_info, focus)
    if type(screen_info.width) ~= "number" then
        return "Error has occured: No width read"
    elseif type(screen_info.height) ~= "number" then
        return "Error has occured: No height read"
    elseif type(screen_info.tile_pixel_conversion) ~= "number" then
        return "Error has occured: Could not read render info"
    end
    camera_tile_pixel_conversion = screen_info.tile_pixel_conversion
    camera_width_base, camera_height_base = screen_info.width, screen_info.height
    
    CameraMap.zoomSetup()
    CameraMap.addFocus(focus)
    return true
end

    
return CameraMap 