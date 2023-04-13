local RenderTile = {}

local LazyEval = require "SoTClient.Utils.LazyEval"

local MapFiles = {}

local MapPath = "GameResources\\Sprites\\Tilesets\\GarregGawr\\"

local FLOOR_DIRECTIONS = { {0, 2}, {2, 1}, {4, 1}, {5, 1}}
local WALL_DIRECTIONS = { {1, 1}, {2, 2}, {3, 1}, {4, 2}, {6, 2}, {7, 1}, {8, 1}, {9, 1} }
local CORNER_DIRECTIONS = { {1, 1}, {3, 1}, {7, 1}, {9, 1}}
local CEILING_DIRECTIONS = {{0, 2}, {7, 1}, {8, 2}, {9, 1}}
local CORNER_CEILING_DIRECTIONS = {{7, 1}, {9, 1}}

local function LoadTileFiles(map_type)
    MapFiles["floor"]          = {}
    MapFiles["corner"]         = {}
    MapFiles["wall"]           = {}
    MapFiles["ceiling"]        = {}
    MapFiles["corner_ceiling"] = {}

    for dir_idx = 0, 9, 1 do
        if(FLOOR_DIRECTIONS[dir_idx] ~= nil) then
            MapFiles["floor"][FLOOR_DIRECTIONS[dir_idx][1]] = {}
            for i = 1, FLOOR_DIRECTIONS[dir_idx][2], 1 do
                MapFiles["floor"][FLOOR_DIRECTIONS[dir_idx][1]][i] = graphics.newTexture( 
                    { type="image", filename=(MapPath .. "floor_" .. FLOOR_DIRECTIONS[dir_idx][1] .. "_" .. i .. ".png"), baseDir=system.ResourceDirectory } 
                )
            end
        end

        if(CORNER_DIRECTIONS[dir_idx] ~= nil) then
            MapFiles["corner"][CORNER_DIRECTIONS[dir_idx][1]] = {}
            for i = 1, CORNER_DIRECTIONS[dir_idx][2], 1 do
                MapFiles["corner"][CORNER_DIRECTIONS[dir_idx][1]][i] = graphics.newTexture( 
                    { type="image", filename=(MapPath .. "corner_" .. CORNER_DIRECTIONS[dir_idx][1] .. "_" .. i .. ".png"), baseDir=system.ResourceDirectory } 
                )
            end
        end

        if(WALL_DIRECTIONS[dir_idx] ~= nil) then
            MapFiles["wall"][WALL_DIRECTIONS[dir_idx][1]] = {}
            for i = 1, WALL_DIRECTIONS[dir_idx][2], 1 do
                MapFiles["wall"][WALL_DIRECTIONS[dir_idx][1]][i] = graphics.newTexture( 
                    { type="image", filename=(MapPath .. "wall_" .. WALL_DIRECTIONS[dir_idx][1] .. "_" .. i .. ".png"), baseDir=system.ResourceDirectory } 
                )
            end
        end

        if(CEILING_DIRECTIONS[dir_idx] ~= nil) then
            MapFiles["ceiling"][CEILING_DIRECTIONS[dir_idx][1]] = {}
            for i = 1, CEILING_DIRECTIONS[dir_idx][2], 1 do
                MapFiles["ceiling"][CEILING_DIRECTIONS[dir_idx][1]][i] = graphics.newTexture( 
                    { type="image", filename=(MapPath .. "ceiling_" .. CEILING_DIRECTIONS[dir_idx][1] .. "_" .. i .. ".png"), baseDir=system.ResourceDirectory } 
                )
            end
        end

        if(CORNER_CEILING_DIRECTIONS[dir_idx] ~= nil) then
            MapFiles["corner_ceiling"][CORNER_CEILING_DIRECTIONS[dir_idx][1]] = {}
            for i = 1, CORNER_CEILING_DIRECTIONS[dir_idx][2], 1 do
                MapFiles["corner_ceiling"][CORNER_CEILING_DIRECTIONS[dir_idx][1]][i] = graphics.newTexture( 
                    { type="image", filename=(MapPath .. "corner_ceiling_" .. CORNER_CEILING_DIRECTIONS[dir_idx][1] .. "_" .. i .. ".png"), baseDir=system.ResourceDirectory } 
                )
            end
        end
    end
 
end

-- To do: make function that releases textures

local function SetNeighbourTextures(map, tile_x, tile_y)
    print("Tiles")
    print(tile_x)
    print(tile_y)
    print(map["x"])
    print(map["y"])
    if(LAND(tile_x > 1, function () return map[tile_x - 1][tile_y]["Texture"] == nil end)) then
        if(map[tile_x - 1][tile_y]["Tile"] == 0) then

            if(LAND(tile_y > 1, function () return map[tile_x][tile_y - 1]["Tile"] == 0 end)) then
                map[tile_x - 1][tile_y - 1]["Texture"] = MapFiles["wall"][7][1]
                if(tile_y > 2) then
                    map[tile_x - 1][tile_y - 2]["Texture"] = MapFiles["ceiling"][7][1]
                end
            end

            if(LAND(tile_y < map["y"], function () return map[tile_x][tile_y + 1]["Tile"] == 0 end)) then
                map[tile_x + 1][tile_y + 1]["Texture"] = MapFiles["wall"][1][1]
            end

            if(LAND(LOR(tile_y == 1, function () return map[tile_x - 1][tile_y - 1]["Tile"] == 0 end), 
                    LOR(tile_y == map["y"], function () return map[tile_x - 1][tile_y + 1]["Tile"] == 0 end))) then
                map[tile_x - 1][tile_y]["Texture"] = MapFiles["wall"][4][1]
            elseif(LOR(tile_y == 1, function() return map[tile_x - 1][tile_y - 1]["Tile"] == 0 end)) then
                map[tile_x - 1][tile_y]["Texture"]      = MapFiles["corner"][7][1]
                map[tile_x - 1][tile_y - 1]["Texture"]  = MapFiles["corner_ceiling"][7][1]
            elseif(LOR(tile_y < map["y"], function() return map[tile_x - 1][tile_y + 1]["Tile"] == 0 end)) then
                map[tile_x - 1][tile_y]["Texture"]      = MapFiles["corner"][1][1]
            end
        end
    end

    if(LAND(tile_x < map["x"], function () return map[tile_x + 1][tile_y]["Texture"] == nil end)) then
        if(map[tile_x + 1][tile_y]["Tile"] == 0) then

            if(LAND(tile_y > 1, function () return map[tile_x][tile_y - 1]["Tile"] == 0 end)) then
                map[tile_x + 1][tile_y - 1]["Texture"] = MapFiles["wall"][9][1]
                if(tile_y > 2) then
                    map[tile_x + 1][tile_y - 2]["Texture"] = MapFiles["ceiling"][9][1]
                end
            end

            if(LAND(tile_y < map["y"], function () return map[tile_x][tile_y + 1]["Tile"] == 0 end)) then
                map[tile_x + 1][tile_y + 1]["Texture"] = MapFiles["wall"][3][1]
            end

            if(LAND(LOR(tile_y == 1, function () return map[tile_x + 1][tile_y - 1]["Tile"] == 0 end), 
                    LOR(tile_y == map["y"], function () return map[tile_x + 1][tile_y + 1]["Tile"] == 0 end))) then
                map[tile_x + 1][tile_y]["Texture"]  = MapFiles["wall"][6][1]
            elseif(LOR(tile_y == 1, function() return map[tile_x + 1][tile_y - 1]["Tile"] == 0 end)) then
                map[tile_x + 1][tile_y]["Texture"]      = MapFiles["corner"][9][1]
                map[tile_x + 1][tile_y - 1]["Texture"]  = MapFiles["corner_ceiling"][9][1]
            elseif(LOR(tile_y < map["y"], function() return map[tile_x + 1][tile_y + 1]["Tile"] == 0 end)) then
                map[tile_x + 1][tile_y]["Texture"]      = MapFiles["corner"][3][1]
            end
        end
    end

    if(LAND(tile_y > 1, function() return map[tile_x][tile_y - 1]["Texture"] == nil end)) then
        if(map[tile_x][tile_y - 1]["Tile"] == 0) then

            if(LAND(LOR(tile_x == 1, function() return map[tile_x - 1][tile_y - 1]["Tile"] == 0 end), 
                    LOR(tile_x == map["x"], function() return map[tile_x + 1][tile_y - 1]["Tile"] == 0 end))) then
                map[tile_x][tile_y - 1]["Texture"]  = MapFiles["wall"][8][1]
                if(tile_y > 2) then
                    map[tile_x][tile_y - 2]["Texture"]  = MapFiles["ceiling"][8][1]
                end
            end
        end
    end

    if(LAND(tile_y < map["y"], function() return map[tile_x][tile_y + 1]["Texture"] == nil end)) then
        if(map[tile_x][tile_y + 1]["Tile"] == 0) then

            if(LAND(LOR(tile_x == 1, function() return map[tile_x - 1][tile_y + 1]["Tile"] == 0 end),
                    LOR(tile_x == map["x"], function() return map[tile_x + 1][tile_y + 1]["Tile"] == 0 end))) then
                map[tile_x][tile_y + 1]["Texture"]  = MapFiles["wall"][2][1]
            end
        end
    end
end

local function SetRoomTileTexture(map, tile_x, tile_y)
    if(map[tile_x][tile_y]["Tile"] == 1) then
        map[tile_x][tile_y]["Texture"] = MapFiles["floor"][0][1]
    else 
        map[tile_x][tile_y]["Texture"] = MapFiles["ceiling"][0][1]
    end
end

local function SetTunnelTileTexture(map, tile_x, tile_y)
    if(tile_x > 1 and map[tile_x - 1][tile_y]["Tile"] == 1) then
        if(tile_x < map["x"] and map[tile_x + 1][tile_y]["Tile"] == 1) then
            if(tile_y > 1 and map[tile_x][tile_y - 1]["Tile"] == 1) then
                if(tile_y < map["y"] and map[tile_x][tile_y + 1]["Tile"] == 1) then
                    map[tile_x][tile_y]["Texture"] = MapFiles["floor"][5][1]
                else
                    map[tile_x][tile_y]["Texture"] = MapFiles["floor"][5][1] -- wall below, to change
                end
            elseif(tile_y < map["y"] and map[tile_x][tile_y + 1]["Tile"] == 1) then
                map[tile_x][tile_y]["Texture"] = MapFiles["floor"][5][1]    -- wall up, to change
            else
                map[tile_x][tile_y]["Texture"] = MapFiles["floor"][4][1]
            end
        elseif(tile_y > 1 and map[tile_x][tile_y - 1]["Tile"] == 1) then
            map[tile_x][tile_y]["Texture"] = MapFiles["floor"][5][1]    -- wall right and down should be 3
        elseif(tile_y < map["y"] and map[tile_x][tile_y + 1]["Tile"] == 1) then
            map[tile_x][tile_y]["Texture"] = MapFiles["floor"][5][1]    -- wall right and up should be 9
        else
            map[tile_x][tile_y]["Texture"] = MapFiles["floor"][5][1] -- dead end
        end
    elseif(tile_x < map["x"] and map[tile_x + 1][tile_y]["Tile"] == 1) then
        if(tile_y > 1 and map[tile_x][tile_y - 1]["Tile"] == 1) then
            if(tile_y < map["y"] and map[tile_x][tile_y + 1]["Tile"] == 1) then
                map[tile_x][tile_y]["Texture"] = MapFiles["floor"][5][1]  -- wall left, to change
            else
                map[tile_x][tile_y]["Texture"] = MapFiles["floor"][5][1] -- wall left and below, to change to 1
            end
        elseif(tile_y < map["y"] and map[tile_x][tile_y + 1]["Tile"] == 1) then
            map[tile_x][tile_y]["Texture"] = MapFiles["floor"][7][1]
        else
            map[tile_x][tile_y]["Texture"] = MapFiles["floor"][4][1] -- dead end, to change
        end
    elseif(tile_y > 1 and map[tile_x][tile_y - 1]["Tile"] == 1) then
        if(tile_y < map["y"] and map[tile_x][tile_y + 1]["Tile"] == 1) then
            map[tile_x][tile_y]["Texture"] = MapFiles["floor"][2][1]
        else
            map[tile_x][tile_y]["Texture"] = MapFiles["floor"][5][1] -- dead end
        end
    elseif(tile_y < map["y"] and map[tile_x][tile_y + 1]["Tile"] == 1) then
        map[tile_x][tile_y]["Texture"] = MapFiles["floor"][5][1] -- dead end
    else
        map[tile_x][tile_y]["Texture"] = MapFiles["floor"][0][1] -- weird... no possible combination?
    end
end

function RenderTile.ReturnDefaultEmptyTile()
    return MapFiles["ceiling"][0][1]
end

function RenderTile.SetRenderTiles(map, map_type)

    LoadTileFiles(map_type)

    for index, room in ipairs(map["rooms"]) do
        local room_x_start, room_y_start = room["x"] + 1, room["y"] + 1
        local room_x_end, room_y_end = room["x"] + room["rows"], room["y"] + room["columns"]
        for map_x = room_x_start, room_x_end, 1 do
            for map_y = room_y_start, room_y_end, 1 do
                SetRoomTileTexture(map, map_x, map_y)
                SetNeighbourTextures(map, map_x, map_y)
            end
        end
    end

    for tunnel_index, tunnel in ipairs(map["tunnels"]) do
        for tile_index, tile in ipairs(tunnel) do
            if (map[tile["x"]][tile["y"]]["Texture"] == nil) then
                SetTunnelTileTexture(map, tile["x"], tile["y"])
                SetNeighbourTextures(map, tile["x"], tile["y"])
            end
        end
    end
end

return RenderTile   