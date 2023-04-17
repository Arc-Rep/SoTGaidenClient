local RenderMap = {}

local math = require "math"

local Camera = require "SoTClient.Visuals.CameraMap"
local ScreenInfo = require "SoTClient.Visuals.ScreenInfo"
local RenderTiles = require "SoTClient.Visuals.RenderTile"
local LazyEval = require "SoTClient.Utils.LazyEval"

local visual_tile_width, visual_tile_height
local map_created = false

local tilemap = {}
local charmap = {}
local inbound_characters = {}
local skill_tilemap_area = {}

local RenderSurfaceMap = nil

function RenderMap.SetCamera(map, focus)
    Camera.setup(map, ScreenInfo, focus)

    for tile_x = 1, map["x"], 1 do
        tilemap[tile_x] = {}
        for tile_y = 1, map["y"], 1 do
            tilemap[tile_x][tile_y] = nil
        end
    end
end

function RenderMap.SetRenderMap(map, map_type, unit_list, focus, surface_map, surface_characters)
    RenderTiles.SetRenderTiles(map, map_type)

    RenderSurfaceMap   = surface_map
    RenderSurfaceChars = surface_characters

    RenderMap.SetCamera(map, focus)
    RenderSurfaceMap:addEventListener("touch", 
        function(event) 
            Camera.CameraDrag(event) 
            if(event.phase ~= "ended") then
                RenderMap.UpdateTilemap(map)
            else
                local function iter_animation() 
                    RenderMap.UpdateTilemap(map)
                    if(Camera.CheckAnimationExists() == true) then 
                        timer.performWithDelay(10, function() iter_animation() end)
                    end
                end
                iter_animation()
            end
        end)
    inbound_characters = unit_list
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

function RenderMap.UpdateCharacters(move_x, move_y)
    for i = 1, #inbound_characters, 1 do
        local char_id = inbound_characters[i]["ID"]
        if(inbound_characters[i]["x"] == nil) then
            if(charmap[char_id] ~= nil) then
                charmap[char_id]:removeSelf()
                charmap[char_id] = nil
            end
        elseif(inbound_characters[i]["x"] >= Camera.getStartTileX() and
           inbound_characters[i]["x"] < Camera.getStartTileX() + Camera.getTileWidth() and
           inbound_characters[i]["y"] >= Camera.getStartTileY() and
           inbound_characters[i]["y"] < Camera.getStartTileY() + Camera.getTileHeight()) then
            if(charmap[char_id] ~= nil) then
                charmap[char_id]:translate(
                    ((-Camera.getStartTileX() + inbound_characters[i]["x"]) - Camera.getDeviationX()) * Camera.getRealTileSize() - charmap[char_id]["x"], 
                    ((-Camera.getStartTileY() + inbound_characters[i]["y"]) - Camera.getDeviationY()) * Camera.getRealTileSize() - charmap[char_id]["y"])
            else
                charmap[char_id] = display.newRect(0, 0, Camera.getRealTileSize(),Camera.getRealTileSize())
                charmap[char_id].x =
                    ((-Camera.getStartTileX() + inbound_characters[i]["x"]) - Camera.getDeviationX()) * Camera.getRealTileSize()
                charmap[char_id].y =
                    ((-Camera.getStartTileY() + inbound_characters[i]["y"]) - Camera.getDeviationY()) * Camera.getRealTileSize()
                charmap[char_id].strokeWidth = 3
                charmap[char_id]:setFillColor(0.8)
                charmap[char_id]:setStrokeColor(0, 1, 1)
                RenderSurfaceChars:insert(charmap[char_id])
            end
        end
    end
end

function RenderMap.UpdateTilemap(map)

    local move_x, move_y = Camera.updateFocusAnimated()

    if(move_x == 0 and move_y == 0 and map_created == true) then
        return
    end

    local tile_x, tile_y = math.floor(Camera.getStartTileX()), math.floor(Camera.getStartTileY())
    local moved_tile_x, moved_tile_y = math.floor(Camera.getStartTileX() - move_x), math.floor(Camera.getStartTileY() - move_y)

--[[print("Entered Tilemap")
    print()
    print(tile_x)
    print(tile_y)
    print(moved_tile_x)
    print(moved_tile_y)]]--

    if(moved_tile_x < tile_x) then
        ClearRow(moved_tile_x, moved_tile_y, math.floor(moved_tile_y + Camera.getTileHeight()))

    elseif (moved_tile_x > tile_x) then
        ClearRow(math.floor(moved_tile_x + Camera.getTileWidth()),
            moved_tile_y, math.floor(moved_tile_y + Camera.getTileHeight()))
    end

    if(moved_tile_y < tile_y) then
        ClearColumn(moved_tile_y, moved_tile_x, math.floor(moved_tile_x + Camera.getTileWidth()))

    elseif (moved_tile_y > tile_y) then
        ClearColumn(math.floor(moved_tile_y + Camera.getTileHeight()),
        moved_tile_x, math.floor(moved_tile_x + Camera.getTileWidth()))
    end

    for x = Camera.getStartTileX(), Camera.getStartTileX() + Camera.getTileWidth(), 1 do
        tile_x = math.floor(x)

        if(map[tile_x] ~= nil) then
            for y = Camera.getStartTileY(), Camera.getStartTileY() + Camera.getTileHeight(), 1 do
                tile_y = math.floor(y)

                if(map[tile_x][tile_y] ~= nil) then
                        
                    if(tilemap[tile_x][tile_y] == nil) then
                        --tilemap[tile_x][tile_y]:translate( -move_x * Camera.getRealTileSize(), -move_y * Camera.getRealTileSize())
                           
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

                        RenderSurfaceMap:insert(tilemap[tile_x][tile_y])
                    end
                    
                    tilemap[tile_x][tile_y].x = 
                    ((-Camera.getStartTileX() + tile_x) - Camera.getDeviationX()) * Camera.getRealTileSize()
                    tilemap[tile_x][tile_y].y = 
                    ((-Camera.getStartTileY() + tile_y) - Camera.getDeviationY()) * Camera.getRealTileSize()
                end
            end
        end
    end
    map_created = true

    RenderMap.UpdateCharacters(move_x, move_y)

    return tilemap
end

function RenderMap.ClearSkillRangeOverlay(map)
    while (#skill_tilemap_area ~= 0) do
        tile = table.remove(skill_tilemap_area, 1)
        tile:removeSelf()
        tile = nil
    end

    RenderMap.UpdateTilemap(map)
end

function RenderMap.ShowSkillRangeOverlay(map, skill_tile_list, event_function)

    RenderMap.ClearSkillRangeOverlay(map)

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

end

return RenderMap