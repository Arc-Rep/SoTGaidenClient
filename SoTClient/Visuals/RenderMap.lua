local RenderMap = {}

local zoom = 1

local visual_tile_width, visual_tile_height
local map_begin_x, map_begin_y = 0,0
local camera_x, camera_y = 0, 0


function RenderMap.setVisualMap(map)
    visual_tile_height, visual_tile_width = display.contentHeight/map["y"], display.contentWidth/map["x"]
    local tilemap = {}
    for i = 1, map["x"], 1 do
        tilemap[i] = {}
        for j = 1, map["y"], 1 do
            tilemap[i][j] = display.newRect(
                            map_begin_x + i * visual_tile_width,
                            map_begin_y + j * visual_tile_height,
                            visual_tile_width,
                            visual_tile_height
            )
        end
    end
    return tilemap
end

function RenderMap.UpdateTilemap(tilemap, map)
    for i = 1, map["x"], 1 do
        for j = 1, map["y"], 1 do
            if(map[i][j]["Tile"] == 0) then
                tilemap[i][j].strokeWidth = 3
                tilemap[i][j]:setFillColor(0.5)
                tilemap[i][j]:setStrokeColor(0, 0, 0)
            elseif(map[i][j]["Tile"] == 1) then
                tilemap[i][j].strokeWidth = 3
                tilemap[i][j]:setFillColor(0.5)
                tilemap[i][j]:setStrokeColor(1, 0, 0)
            elseif(map[i][j]["Tile"] == 2) then
                tilemap[i][j].strokeWidth = 3
                tilemap[i][j]:setFillColor(0.5)
                tilemap[i][j]:setStrokeColor(0, 1, 0)
            elseif(map[i][j]["Tile"] == 3) then
                tilemap[i][j].strokeWidth = 3
                tilemap[i][j]:setFillColor(0.5)
                tilemap[i][j]:setStrokeColor(0, 0, 1)
            else
                tilemap[i][j].strokeWidth = 3
                tilemap[i][j]:setFillColor(0.5)
                tilemap[i][j]:setStrokeColor(1, 1, 1)
            end

            if(map[i][j]["Actor"] ~= "") then
                tilemap[i][j].strokeWidth = 3
                tilemap[i][j]:setFillColor(0.8)
                tilemap[i][j]:setStrokeColor(0, 1, 1)
            end
        end
    end
    return tilemap
end

return RenderMap