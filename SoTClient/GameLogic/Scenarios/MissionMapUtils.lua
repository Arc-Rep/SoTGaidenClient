local math = require "math"

function CheckIfDead(char)
    return (char["x"] == nil or char["y"] == nil or char["currentHP"] == 0)
end

function CheckIfEnemy(char1, char2)
    return (char1["Team"] > 0) ~= (char2["Team"] > 0)
end

function CheckCardinalDistance(tile1_x, tile1_y, tile2_x, tile2_y)
    return math.abs(tile1_x - tile2_x) + math.abs(tile1_y - tile2_y)
end

function CheckDirectWalkDistance(tile1_x, tile1_y, tile2_x, tile2_y)
    return math.max(math.abs(tile1_x - tile2_x), math.abs(tile1_y - tile2_y))
end

function CheckGeneralDirection(tile1_x, tile1_y, tile2_x, tile2_y)
    local tile_dist_x, tile_dist_y = tile2_x - tile1_x, tile2_y - tile1_y

    if (tile_dist_x > 0) then
        tile_dist_x = 1
    elseif (tile_dist_x < 0) then
        tile_dist_x = -1
    end

    if (tile_dist_y > 0) then
        tile_dist_y = 1
    elseif (tile_dist_y < 0) then
        tile_dist_y = -1
    end

    return tile_dist_x, tile_dist_y
end

function CheckRoomCardinalDist(room1, room2)
    local dist_x, dist_y

    if(room1["x"] >= room2["x"] + room2["columns"]) then
        dist_x = room1["x"] - (room2["x"] + room2["columns"])

    elseif(room2["x"] >= room1["x"] + room1["columns"]) then
        dist_x = room2["x"] - (room1["x"] + room1["columns"])
    else
        dist_x = 0
    end

    if(room1["y"] >= room2["y"] + room2["rows"]) then
        dist_y = room1["y"] - (room2["y"] + room2["rows"])

    elseif(room2["y"] >= room1["y"] + room1["rows"]) then
        dist_y = room2["y"] - (room1["y"] + room1["rows"])
    else
        dist_y = 0
    end

    return dist_x, dist_y
end

function CheckRoomRealDistance(room1, room2)
    local room_dist_x, room_dist_y = CheckRoomCardinalDist(room1, room2)
    return math.sqrt(room_dist_x^2 + room_dist_y^2)
end

function CheckEmptySpace(map, x, y)
    if(x > map["x"] or y > map["y"]) then
        return false
    end

    if(map[x][y]["Tile"] == 1 and map[x][y]["Actor"] == nil) then
        return true
    end

    return false
end

-- Provided a range, it returns the in-bound section of such range 
function CheckValidMapRange(map, x_start, y_start, x_end, y_end)

    if(x_start > map["x"] or y_start > map["y"] or x_end < 1 or y_end < 1) then
        return nil, nil, nil, nil
    end

    local x_real_start, y_real_start, x_real_end, y_real_end

    if (x_start < 1) then
        x_real_start = 1
    else 
        x_real_start = x_start
    end

    if (y_start < 1) then
        y_real_start = 1
    else
        y_real_start = y_start
    end

    if(x_end > map["x"]) then
        x_real_end = map["x"]
    else
        x_real_end = x_end
    end

    if(y_end > map["y"]) then
        y_real_end = map["y"]
    else
        y_real_end = y_end
    end

    return x_real_start, y_real_start, x_real_end, y_real_end
end

function CheckWallCollision(map, x, y, move_x, move_y)

    if(move_x ~= 0 and map[x + move_x][y]["Tile"] ~= 1) then
        return true
    end

    if(move_y ~= 0 and map[x][y + move_y]["Tile"] ~= 1) then
        return true
    end
    return false
end

function CheckLegalMovement(map, x, y, move_x, move_y)
    return CheckEmptySpace(map, x + move_x, y + move_y) and not(CheckWallCollision(map, x, y, move_x, move_y))
end

function FindClosestEmptySpace(game_map, center_x, center_y)

    if(CheckEmptySpace(game_map, center_x, center_y) == true) then return center_x, center_y end

    local dist, deviation, max_dist = 1, nil, nil
    local side_placement, square_sides = nil, 4
    local min_dev, max_dev

    max_dist = math.max(center_x, center_y, game_map["x"] - center_x, game_map["y"] - center_y)

    repeat

        min_dev = math.max(dist - game_map["x"] - center_x, 0)
        max_dev = math.min(game_map["y"] - center_y, dist)

        for deviation = min_dev, max_dev, 1 do
                if(CheckEmptySpace(game_map,center_x + (dist - deviation), center_y + deviation) == true) then
                    return center_x + (dist - deviation), center_y + deviation
                end
        end

        min_dev = math.max(dist - center_x, 0)
        max_dev = math.min(center_y, dist)

        for deviation = min_dev, max_dev, 1 do
            if(CheckEmptySpace(game_map, center_x - (dist - deviation), center_y - deviation) == true) then
                return center_x - (dist - deviation), center_y - deviation
            end
        end


        dist = dist + 1
    until dist > max_dist

    return nil, nil
    
end

function GetCurrentRoom(game_map, x, y)
    for index, room in ipairs(game_map["rooms"]) do
        if(x <= room["x"] + room["columns"] and x >= room["x"]) then
            if(y <= room["y"] + room["rows"] and y >= room["y"]) then
                return room
            end
        end
    end 

    return nil
end

function GetCharInSpace(map_tile)
    return map_tile["Actor"]
end

-- TO ADD: for now, only check if enemies are hittable by basic, add to list hittable skills

function CheckHittableEnemies(game_map, char, char_list)
    local hittable_enemies = {}
    
    for index, other_char in ipairs(char_list) do
        if(CheckIfEnemy(char, other_char) == true and CheckIfDead(other_char) == false) then
            if(CheckDirectWalkDistance(char["x"], char["y"], other_char["x"], other_char["y"]) == 1) then
                table.insert(hittable_enemies, other_char)
            end
        end
    end

    return hittable_enemies
end