local RenderMap = {}

local math = require "math"

local Camera = require "SoTClient.Visuals.CameraMap"
local ScreenInfo = require "SoTClient.Visuals.ScreenInfo"
local RenderTiles = require "SoTClient.Visuals.RenderTile"
local LazyEval = require "SoTClient.Utils.LazyEval"
local EventManager = require "SoTClient.Visuals.Events.EventManager"

local visual_tile_width, visual_tile_height
local camera_timer = 0
local map_created = false

local tilemap = {}
local charmap = {}
local inbound_characters = {}
local skill_tilemap_area = {}

local RenderSurfaceMap = nil
local RenderSurfaceChars = nil
local RenderSurfaceFocus = nil
local RenderSurfaceNonFocus = nil

function RenderMap.SetCamera(focus)

    local map = GetGameMap()
    Camera.setup(map, ScreenInfo, focus)

    local camera_tile_width = math.floor(Camera.getTileWidth()) + 1
    local camera_tile_height = math.floor(Camera.getTileHeight()) + 1

    if (Camera.getFocus() ~= nil and charmap[Camera.getFocus()] ~= nil) then
        RenderSurfaceFocus:remove(charmap[Camera.getFocus()["ID"]])
    end

    if (charmap[focus["ID"]] ~= nil) then
        RenderSurfaceNonFocus:remove(charmap[focus["ID"]])
        RenderSurfaceFocus:insert(charmap[focus["ID"]])
    end

    for tile_x = -camera_tile_width, map["x"] + camera_tile_width, 1 do
        tilemap[tile_x] = {}
        for tile_y = -camera_tile_height, map["y"] + camera_tile_height, 1 do
            tilemap[tile_x][tile_y] = nil
        end
    end
end


function ClearRow(row, start_y, end_y)
    for tile_y = start_y, end_y, 1 do
        if tilemap[row] ~= nil then
            if tilemap[row][tile_y] ~= nil then
                tilemap[row][tile_y]:removeSelf()
                tilemap[row][tile_y] = nil
            end
        end
    end
end

function ClearColumn(column, start_x, end_x)
    for tile_x = start_x, end_x, 1 do
        if tilemap[tile_x] ~= nil then
            if tilemap[tile_x][column] ~= nil then
                tilemap[tile_x][column]:removeSelf()
                tilemap[tile_x][column] = nil
            end
        end
    end
end

function RenderMap.PerformAnimation(object, params)

    if Camera.CheckAnimationExists() == false then
        local onAnimationCompleteFunction = object.animation.onComplete
        local afterAnimationFunction = nil

        if onAnimationCompleteFunction ~= nil then
            afterAnimationFunction = onAnimationCompleteFunction()
        end
        Camera.EndFocusAnimation()
        RenderMap.UpdateTilemap()
        if afterAnimationFunction ~= nil then
            afterAnimationFunction()
        end
    else
        RenderMap.UpdateTilemap()
        timer.performWithDelay(20, function() RenderMap.PerformAnimation(object, params) end)    
    end
end


function RenderMap.MoveTileMap(params)

    local moved_tile_x, moved_tile_y = params["x"], params["y"]
    local time1 = params["time"]
    local start_x, start_y, end_x, end_y

    if (moved_tile_x > 0) then
        start_x = Camera.getStartTileX() 
        end_x   = Camera.getStartTileX() + Camera.getTileWidth() + moved_tile_x
    else
        start_x = Camera.getStartTileX() - moved_tile_x
        end_x   = Camera.getStartTileX() + Camera.getTileWidth()
    end

    if (moved_tile_y > 0) then
        start_y = Camera.getStartTileY()
        end_y   = Camera.getStartTileY() + Camera.getTileHeight() + moved_tile_y
    else
        start_y = Camera.getStartTileY() - moved_tile_y
        end_y   = Camera.getStartTileY() + Camera.getTileHeight()
    end


    local map_cleanup = 
        function(next_function)
            if (moved_tile_x < 0) then
                for i=0, moved_tile_x, -1 do
                    ClearRow(Camera.getStartTileX() + Camera.getTileWidth() + i, moved_tile_y, math.floor(moved_tile_y + Camera.getTileHeight()))
                end
        
            elseif (moved_tile_x > 0) then
                for i=0, moved_tile_x, 1 do
                    ClearRow(Camera.getStartTileX() + i, moved_tile_y, math.floor(moved_tile_y + Camera.getTileHeight()))
                end
            end
        
            if (moved_tile_y < 0) then
                for i=0, moved_tile_y, -1 do
                    ClearColumn(Camera.getStartTileY() + Camera.getTileHeight() + i, moved_tile_x, math.floor(moved_tile_x + Camera.getTileWidth()))
                end
        
            elseif (moved_tile_y > 0) then
                for i=0, moved_tile_y, 1 do
                    ClearColumn(Camera.getStartTileY() + i, moved_tile_x, math.floor(moved_tile_x + Camera.getTileWidth()))
                end
            end
            
            return next_function()
        end

    local params1 = {
        x = -moved_tile_x,
        y = -moved_tile_y,
        time = time1,
        end_function = map_cleanup
    }

    params["x"] = -params["x"]
    params["y"] = -params["y"]
    params["end_function"] = map_cleanup

    local params1 = {
        x = params["x"],
        y = params["y"],
        time = params["time"]
    }

    RenderMap.RenderMapBox(
        Camera.getStartTileX(), 
        Camera.getStartTileY(),
        start_x,
        start_y,
        end_x,
        end_y,
        false
    )
    Camera.MoveElement(RenderSurfaceMap, params)
    Camera.MoveElement(RenderSurfaceNonFocus, params1)

end

function RenderMap.UpdateTilemap()

    Camera.updateFocusAnimated()

    RenderMap.RenderMapBox(
        Camera.getStartTileX(), 
        Camera.getStartTileY(), 
        Camera.getStartTileX(), 
        Camera.getStartTileY(), 
        Camera.getStartTileX() + Camera.getTileWidth(),
        Camera.getStartTileY() + Camera.getTileHeight(),
        true
    )

    map_created = true

    return tilemap
end

function RenderMap.RenderCharacterBox(origin_x, origin_y, start_x, start_y, end_x, end_y)

    RenderSurfaceFocus.x = 0
    RenderSurfaceNonFocus.x = 0

    RenderSurfaceFocus.y = 0
    RenderSurfaceNonFocus.y = 0

    for i = 1, #inbound_characters, 1 do
        local char_id = inbound_characters[i]["ID"]
        if(inbound_characters[i]["x"] == nil) then
            if(charmap[char_id] ~= nil) then
                inbound_characters[i]["Texture"] = nil
                charmap[char_id]:removeSelf()
                charmap[char_id] = nil
            end
        elseif(inbound_characters[i]["x"] >= start_x and
           inbound_characters[i]["x"] < end_x and
           inbound_characters[i]["y"] >= start_y and
           inbound_characters[i]["y"] < end_y) then
            if(charmap[char_id] == nil) then
                charmap[char_id] = display.newRect(0, 0, Camera.getRealTileSize(),Camera.getRealTileSize())
                charmap[char_id].strokeWidth = 3
                charmap[char_id]:setFillColor(0.8)
                charmap[char_id]:setStrokeColor(0, 1, 1)
                if (inbound_characters[i] == Camera.getFocus()) then
                    RenderSurfaceFocus:insert(charmap[char_id])
                else
                    RenderSurfaceNonFocus:insert(charmap[char_id])
                end
                inbound_characters[i]["Texture"] = charmap[char_id]
            end
            
            charmap[char_id].x =
                ((-origin_x + inbound_characters[i]["x"]) - Camera.getDeviationX()) * Camera.getRealTileSize()
            charmap[char_id].y =
                ((-origin_y + inbound_characters[i]["y"]) - Camera.getDeviationY()) * Camera.getRealTileSize()

        elseif(charmap[char_id] ~= nil) then
            charmap[char_id]:removeSelf()
            charmap[char_id] = nil
        end
    end
end

function RenderMap.RenderMapBox(origin_x, origin_y, start_x, start_y, end_x, end_y, render_chars)

    RenderSurfaceMap.x = 0
    RenderSurfaceMap.y = 0

    local map = GetGameMap()

    local tile_x, tile_y = math.floor(start_x), math.floor(start_y)

    for x = start_x, end_x, 1 do
        tile_x = math.floor(x)

        for y = start_x, end_y, 1 do
            tile_y = math.floor(y)
            
            if(tilemap[tile_x][tile_y] == nil) then
                if(LOR(map[tile_x] == nil, function() return map[tile_x][tile_y] == nil end)) then
                    tilemap[tile_x][tile_y] = display.newImageRect(
                        RenderTiles.ReturnDefaultEmptyTile().filename,
                        RenderTiles.ReturnDefaultEmptyTile().baseDir,
                        Camera.getRealTileSize(),
                        Camera.getRealTileSize()
                    )                    
                    tilemap[tile_x][tile_y].strokeWidth = 3
                    tilemap[tile_x][tile_y]:setFillColor(0.5)
                    tilemap[tile_x][tile_y]:setStrokeColor(0, 0, 0)

                else
                    
                    if(map[tile_x][tile_y]["Texture"] ~= nil) then
                        tilemap[tile_x][tile_y] = display.newImageRect(
                            map[tile_x][tile_y]["Texture"].filename,
                            map[tile_x][tile_y]["Texture"].baseDir,
                            Camera.getRealTileSize(),
                            Camera.getRealTileSize()
                        )
                    else
                        tilemap[tile_x][tile_y] = display.newImageRect(
                            RenderTiles.ReturnDefaultEmptyTile().filename,
                            RenderTiles.ReturnDefaultEmptyTile().baseDir,
                            Camera.getRealTileSize(),
                            Camera.getRealTileSize()
                        )
                    end
                    
                    if(map[tile_x][tile_y]["Tile"] == 0) then
                        tilemap[tile_x][tile_y].strokeWidth = 3
                        tilemap[tile_x][tile_y]:setFillColor(0.5)
                        tilemap[tile_x][tile_y]:setStrokeColor(0, 0, 0)
                    elseif(map[tile_x][tile_y]["Tile"] == 1) then
                        tilemap[tile_x][tile_y].strokeWidth = 3
                        tilemap[tile_x][tile_y]:setFillColor(0.5)
                        tilemap[tile_x][tile_y]:setStrokeColor(1, 0, 0)
                    elseif(map[tile_x][tile_y]["Tile"] == 2) then
                        tilemap[tile_x][tile_y].strokeWidth = 3
                        tilemap[tile_x][tile_y]:setFillColor(0.5)
                        tilemap[tile_x][tile_y]:setStrokeColor(0, 1, 0)
                    elseif(map[tile_x][tile_y]["Tile"] == 3) then
                        tilemap[tile_x][tile_y].strokeWidth = 3
                        tilemap[tile_x][tile_y]:setFillColor(0.5)
                        tilemap[tile_x][tile_y]:setStrokeColor(0, 0, 1)
                    else
                        tilemap[tile_x][tile_y].strokeWidth = 3
                        tilemap[tile_x][tile_y]:setFillColor(0.5)
                        tilemap[tile_x][tile_y]:setStrokeColor(1, 1, 1)
                    end
                end
                
                RenderSurfaceMap:insert(tilemap[tile_x][tile_y])
            end

            tilemap[tile_x][tile_y].x = 
            (((-origin_x) + tile_x) - Camera.getDeviationX()) * Camera.getRealTileSize()
            tilemap[tile_x][tile_y].y = 
            (((-origin_y) + tile_y) - Camera.getDeviationY()) * Camera.getRealTileSize()
        end
    end
    if (render_chars == true) then
        RenderMap.RenderCharacterBox(origin_x, origin_y, start_x, start_y, end_x, end_y)
    end
end

function RenderMap.ClearSkillRangeOverlay()
    while (#skill_tilemap_area ~= 0) do
        tile = table.remove(skill_tilemap_area, 1)
        tile:removeSelf()
        tile = nil
    end

    RenderMap.UpdateTilemap()
end

function RenderMap.ShowSkillRangeOverlay(skill_tile_list, event_function)

    RenderMap.ClearSkillRangeOverlay()

    if(Camera.CheckAnimationExists() == true) then
        return false
    end

    for _, tile in pairs(skill_tile_list) do
        skill_tilemap_area[#skill_tilemap_area + 1] = 
            display.newRect(
                ((-Camera.getStartTileX() + tile["x"]) - Camera.getDeviationX()) * Camera.getRealTileSize(),
                ((-Camera.getStartTileY() + tile["y"]) - Camera.getDeviationY()) * Camera.getRealTileSize(),
                Camera.getRealTileSize(),
                Camera.getRealTileSize()
            )
        
        skill_tilemap_area[#skill_tilemap_area].strokeWidth = 4
        skill_tilemap_area[#skill_tilemap_area]:setFillColor(0.2)
        skill_tilemap_area[#skill_tilemap_area]:setStrokeColor(0, 0.5, 0,5)
        --skill_tilemap_area[#skill_tilemap_area].alpha = 0.3

        skill_tilemap_area[#skill_tilemap_area]:addEventListener("tap", event_function(tile["x"], tile["y"]))

        RenderSurfaceMap:insert(skill_tilemap_area[#skill_tilemap_area])
    end
    return true
end


local function MapTouchEvent(event)
    if(event.phase == "ended") then
        Camera.CameraDrag(event) 
        animation_data = 
        {
            x = 0,
            y = 0,
            time = 700
        }
        local object = {}
        object.animation = animation_data
        Camera.StartFocusAnimation(animation_data)
        RenderMap.PerformAnimation(object)
        return true
    end
    if (camera_timer + 30 > system.getTimer()) then
        return false
    end
    camera_timer = system.getTimer()
    Camera.CameraDrag(event)
    RenderMap.UpdateTilemap()
    return true
end

function RenderMap.SetRenderMap(map, map_type, unit_list, focus, surface_map, surface_characters)

    RenderTiles.SetRenderTiles(map, map_type)
    RenderSurfaceMap      = surface_map
    RenderSurfaceChars    = surface_characters
    RenderSurfaceFocus    = display.newGroup()
    RenderSurfaceNonFocus = display.newGroup()

    RenderSurfaceChars:insert(RenderSurfaceFocus)
    RenderSurfaceChars:insert(RenderSurfaceNonFocus)

    RenderMap.SetCamera(focus)

    RenderSurfaceMap:addEventListener("touch", 
        function(event)

            if(#skill_tilemap_area ~= 0) then
                return false
            end

            if (event.phase == "began") then
                EventManager.SetActiveEvent(EventManager.DRAG_MAP, MapTouchEvent)
            end
            if (EventManager.GetActiveEventID() ~= nil) then
                EventManager.PerformEvent(event)
            end

            return true
        end)
    inbound_characters = unit_list

end

return RenderMap