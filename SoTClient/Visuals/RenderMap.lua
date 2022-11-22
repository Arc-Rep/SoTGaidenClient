
local RenderMap = {}

local Camera = require "SoTClient.Visuals.CameraMap"
local ScreenInfo = require "SoTClient.Visuals.ScreenInfo"

local visual_tile_width, visual_tile_height

local tilemap = {}

function RenderMap.setCamera(map, focus)
    Camera.setup(map, ScreenInfo, focus)

    for tile_x = 1, map["x"], 1 do
        tilemap[tile_x] = {}
        for tile_y = 1, map["y"], 1 do
            tilemap[tile_x][tile_y] = nil
        end
    end
end

function RenderMap.clearRow(row, start_y, end_y)
    for tile_y = start_y, end_y, 1 do
        if tilemap[row][tile_y] ~= nil then
            tilemap[row][tile_y]:removeSelf()
            tilemap[row][tile_y] = nil
        end
    end
end

function RenderMap.clearColumn(column, start_x, end_x)
    for tile_x = start_x, end_x, 1 do
        if tilemap[tile_x][column] ~= nil then
            tilemap[tile_x][column]:removeSelf()
            tilemap[tile_x][column] = nil
        end
    end
end

function RenderMap.updateTilemap(map)

    local move_x, move_y = Camera.updateFocus()

    if((Camera.getStartTileX() + move_x) // 1 < Camera.getStartTileX() // 1) then 
        clearRow(Camera.getStartTileX() // 1, 
            Camera.getStartTileY() // 1, (Camera.getStartTileY() + Camera.getTileHeight()) // 1)

    else if ((Camera.getStartTileX() + move_x) // 1 > Camera.getStartTileX() // 1) then
        clearRow((Camera.getStartTileX() + Camera.getTileWidth()) // 1, 
            Camera.getStartTileY() // 1, (Camera.getStartTileY() + Camera.getTileHeight()) // 1)
    end

    if((Camera.getStartTileY() + move_y) // 1 < Camera.getStartTileY() // 1) then 
        clearColumn(Camera.getStartTileY() // 1, 
            Camera.getStartTileX(), Camera.getStartTileX() + Camera.getTileWidth())

    else if ((Camera.getStartTileY() + move_y) // 1 > Camera.getStartTileX() // 1) then
        clearColumn((Camera.getStartTileY() + Camera.getTileHeight()) // 1, 
            Camera.getStartTileX() // 1, (Camera.getStartTileX() + Camera.getTileWidth()) // 1)
    end

    for x = Camera.getStartTileX(),Camera.getStartTileX() + Camera.getTileWidth(), 1 do
        local tile_x = x // 1

        if(map[tile_x] ~= nil) then
            for y = Camera.getStartTileY(), Camera.getStartTileY() + Camera.getTileHeight(), 1 do
                local tile_y = y // 1

                if(map[tile_x][tile_y] ~= nil) then
                        
                    if(tilemap[tile_x][tile_y] ~= nil) then
                        tilemap[tile_x][tile_y]:translate(move_x * Camera.getRealTileSize(), move_y * Camera.getRealTileSize())
                    else
                        tilemap[tile_x][tile_y] = display.newRect(
                            render_start_x + Camera.getRealTileSize() * (x - 1),
                            render_start_y + Camera.getRealTileSize() * (y - 1),
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
                    end
                end
            end
        end
    end
    return tilemap
end


return RenderMap