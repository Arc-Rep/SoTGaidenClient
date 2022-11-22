local CameraMap = {}

local math = require "math"

local camera_x, camera_y = 0, 0
local camera_start_x, camera_start_y = 1, 1
local camera_width_base, camera_height_base = 0, 0
local camera_tile_width, camera_tile_height = 1, 1
local camera_tile_pixel_conversion = 1
local TILE_OUT_BOUNDS = 4

local CAMERA_ZOOM_VALUES = [0.75, 0.875, 1, 1.125, 1.25]
local zoom_index = 3
local camera_tile_pixel_zoomed = 1

local focus_element_queue = []


function CameraMap.updateFocus()

    local focus_move_x = focus_element_queue[1]["x"] - camera_x
    local focus_move_y = focus_element_queue[1]["x"] - camera_y

    camera_x = focus_element_queue[1]["x"]
    camera_y = focus_element_queue[1]["y"] 
    camera_start_x = camera_x - camera_tile_width/2
    camera_start_y = camera_y - camera_tile_height/2

    return focus_move_x, focus_move_y
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
    zoom_index -= 1
    zoomSetup()
end

function CameraMap.zoomIncrease()
    if(zoom_index == 5) then
        return false
    end
    zoom_index += 1
    zoomSetup()
end


function CameraMap.addFocus(focus)
    focus_element_queue.add(focus, 1)
    updateFocus()
end

function CameraMap.popFocus()
    if (#focus_element_queue ~= 0) then
        focus_element_queue.remove(focus, 1)
    end
    updateFocus()
end

function CameraMap.getFocus()
    return focus_element_queue[1]["x"], focus_element_queue[1]["y"]
end


function CameraMap.getX()
    return camera_x
end

function CameraMap.getY()
    return camera_y
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

function CameraMap.setup(Map, screen_info, focus)
    if type(screen_info.width) ~= "number" then
        return "Error has occured: No width read"
    elseif type(screen_info.height) ~= "number" then
        return "Error has occured: No height read"
    elseif type(screen_info.tile_pixel_conversion) ~= "number"
        return "Error has occured: Could not read render info"
    end

    camera_width_base, camera_height_base = camera_info.width, camera_info.height
    camera_tile_pixel_conversion = camera_info.tile_pixel_conversion
    zoomSetup()
    cameraAddFocus(focus)

    return true
end

    
return CameraMap 