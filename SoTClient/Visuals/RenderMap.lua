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

function RenderMap.UpdateTilemap(map)

    local move_x, move_y = Camera.updateFocus()

    local tile_x, tile_y = math.floor(Camera.getStartTileX()), math.floor(Camera.getStartTileY())
    local moved_tile_x, moved_tile_y = math.floor(Camera.getStartTileX() - move_x), math.floor(Camera.getStartTileY() - move_y)

    print("Entered Tilemap")
    print()
    print(tile_x)
    print(tile_y)
    print(moved_tile_x)
    print(moved_tile_y)

    if(moved_tile_x < tile_x) then
        ClearRow(moved_tile_x, tile_y, math.floor(Camera.getStartTileY() - move_y + Camera.getTileHeight()))

    elseif (moved_tile_x > tile_x) then
        ClearRow(math.floor(Camera.getStartTileX() - move_x + Camera.getTileWidth()),
            tile_y, math.floor(Camera.getStartTileY() - move_y + Camera.getTileHeight()))
    end

    if(moved_tile_y < tile_y) then
        ClearColumn(moved_tile_y, tile_x, math.floor(Camera.getStartTileX() - move_x + Camera.getTileWidth()))

    elseif (moved_tile_y > tile_y) then
        ClearColumn(math.floor(Camera.getStartTileY() - move_y + Camera.getTileHeight()),
            tile_x, math.floor(Camera.getStartTileX() - move_x + Camera.getTileWidth()))
    end

    for x = Camera.getStartTileX(), Camera.getStartTileX() + Camera.getTileWidth(), 1 do
        print("Begin x")
        print(Camera.getStartTileX())
        print(Camera.getStartTileX() + Camera.getTileWidth())
        print(x)
        tile_x = math.floor(x)

        if(map[tile_x] ~= nil) then
            for y = Camera.getStartTileY(), Camera.getStartTileY() + Camera.getTileHeight(), 1 do
                print("Begin y")
                print(Camera.getStartTileY())
                print(Camera.getStartTileY() + Camera.getTileHeight())
                print(y)
                tile_y = math.floor(y)

                if(map[tile_x][tile_y] ~= nil) then
                        
                    if(tilemap[tile_x][tile_y] ~= nil) then
                        print("Already rendered with move" .. move_x * Camera.getRealTileSize() .. "," .. move_y * Camera.getRealTileSize())
                        tilemap[tile_x][tile_y]:translate( -move_x * Camera.getRealTileSize(), -move_y * Camera.getRealTileSize())
                        if(tilemap[tile_x][tile_y]["Actor"] == nil and map[tile_x][tile_y]["Actor"] ~= "") then
                            tilemap[tile_x][tile_y].strokeWidth = 3
                            tilemap[tile_x][tile_y]:setFillColor(0.8)
                            tilemap[tile_x][tile_y]:setStrokeColor(0, 1, 1)
                            tilemap[tile_x][tile_y]["Actor"] = map[tile_x][tile_y]["Actor"]
                        
                        elseif(tilemap[tile_x][tile_y]["Actor"] ~= nil and map[tile_x][tile_y]["Actor"] == "") then
                            tilemap[tile_x][tile_y].strokeWidth = 3
                            tilemap[tile_x][tile_y]:setFillColor(0.5)
                            tilemap[tile_x][tile_y]:setStrokeColor(1, 0, 0)
                            tilemap[tile_x][tile_y]["Actor"] = nil
                        end 
                    else
                        tilemap[tile_x][tile_y] = display.newRect(
                            (-Camera.getStartTileX() + tile_x) * Camera.getRealTileSize(),
                            (-Camera.getStartTileY() + tile_y) * Camera.getRealTileSize(),
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
                        local n = display.newRect(1893.25, 1587.1640625, 64, 64)
                        n.strokeWidth = 3
                        n:setFillColor(0)
                        n:setStrokeColor(1, 0, 0)
                        RenderSurface:insert(n)
                        RenderSurface:insert(tilemap[tile_x][tile_y])
                    end
                end
            end
        end
    end
    return tilemap
end


return RenderMap