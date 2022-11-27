local RenderMap = {}

local math = require "math"

local Camera = require "SoTClient.Visuals.CameraMap"
local ScreenInfo = require "SoTClient.Visuals.ScreenInfo"

local visual_tile_width, visual_tile_height

local tilemap = {}
local RenderSurface = nil

function RenderMap.SetCamera(map, focus, surface)
    Camera.setup(map, ScreenInfo, focus)
    RenderSurface = surface

    for tile_x = 1, map["x"], 1 do
        tilemap[tile_x] = {}
        for tile_y = 1, map["y"], 1 do
            tilemap[tile_x][tile_y] = nil
        end
    end
end

function ClearRow(row, start_y, end_y)
    for tile_y = start_y, end_y, 1 do
        if tilemap[row][tile_y] ~= nil then
            tilemap[row][tile_y]:removeSelf()
            tilemap[row][tile_y] = nil
        end
    end
end

function ClearColumn(column, start_x, end_x)
    for tile_x = start_x, end_x, 1 do
        if tilemap[tile_x][column] ~= nil then
            tilemap[tile_x][column]:removeSelf()
            tilemap[tile_x][column] = nil
        end
    end
end

function RenderMap.UpdateTilemap(map)

    local move_x, move_y = Camera.updateFocus()

    local tile_x, tile_y = math.floor(Camera.getStartTileX()), math.floor(Camera.getStartTileY())
    local moved_tile_x, moved_tile_y = math.floor(Camera.getStartTileX() + move_x), math.floor(Camera.getStartTileY())

    if(moved_tile_x < tile_x) then
        ClearRow(tile_x, tile_y, math.floor(Camera.getStartTileY() + Camera.getTileHeight()))

    elseif (moved_tile_x > tile_x) then
        ClearRow(math.floor(Camera.getStartTileX() + Camera.getTileWidth()),
            tile_y, math.floor(Camera.getStartTileY() + Camera.getTileHeight()))
    end

    if(moved_tile_y < tile_y) then
        ClearColumn(tile_y, tile_x, math.floor(Camera.getStartTileX() + Camera.getTileWidth()))

    elseif (moved_tile_y > tile_y) then
        ClearColumn(math.floor(Camera.getStartTileY() + Camera.getTileHeight()),
            tile_x, math.floor(Camera.getStartTileX() + Camera.getTileWidth()))
    end

    for x = Camera.getStartTileX(), Camera.getStartTileX() + Camera.getTileWidth(), 1 do
        tile_x = math.floor(x)

        if(map[tile_x] ~= nil) then
            for y = Camera.getStartTileY(), Camera.getStartTileY() + Camera.getTileHeight(), 1 do
                tile_y = math.floor(y)

                if(map[tile_x][tile_y] ~= nil) then
                        
                    if(tilemap[tile_x][tile_y] ~= nil) then
                        tilemap[tile_x][tile_y]:translate(move_x * Camera.getRealTileSize(), move_y * Camera.getRealTileSize())
                    else
                        tilemap[tile_x][tile_y] = display.newRect(
                            Camera.getStartTileX() + Camera.getRealTileSize() * (x - 1),
                            Camera.getStartTileY() + Camera.getRealTileSize() * (y - 1),
                            Camera.getRealTileSize(),
                            Camera.getRealTileSize()
                        )

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

                        if(map[tile_x][tile_y]["Actor"] ~= "") then
                            tilemap[tile_x][tile_y].strokeWidth = 3
                            tilemap[tile_x][tile_y]:setFillColor(0.8)
                            tilemap[tile_x][tile_y]:setStrokeColor(0, 1, 1)
                        end

                        RenderSurface:insert(tilemap[tile_x][tile_y])
                    end
                end
            end
        end
    end
    return tilemap
end


return RenderMap