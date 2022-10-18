local MissionMapUtils = {}
local math = require "math"


function MissionMapUtils.CheckCardinalDistance(tile1_x, tile1_y, tile2_x, tile2_y)
    return math.abs(tile1_x - tile2_x) + math.abs(tile1_y - tile2_y)
end


function MissionMapUtils.checkEmptySpace(map, x, y)
    if(x > map["x"] or y > map["y"]) then
        return false
    end

    if(map[x][y]["Tile"] == 1 and map[x][y]["Actor"] == "") then
        return true
    end

    return false
end


function MissionMapUtils.CheckWallCollision(map, x, y, move_x, move_y)

    if(move_x ~= 0 and map[x + move_x][y]["Tile"] ~= 1) then
        return true
    end

    if(move_y ~= 0 and map[x][y + move_y]["Tile"] ~= 1) then
        return true
    end
    return false
end

function MissionMapUtils.CheckLegalMovement(map, x, y, move_x, move_y)
    return MissionMapUtils.checkEmptySpace(map, x + move_x, y + move_y) and not(MissionMapUtils.CheckWallCollision(map, x, y, move_x, move_y))
end


function MissionMapUtils.FindClosestEmptySpace(game_map, center_x, center_y)

    local dist, deviation, max_dist = 1, nil, nil
    local side_placement, square_sides = nil, 4
    local min_dev, max_dev

    max_dist = math.max(center_x, center_y, game_map["x"] - center_x, game_map["y"] - center_y)

    repeat

        min_dev = math.max(dist - game_map["x"] - center_x, 0)
        max_dev = math.min(game_map["y"] - center_y, dist)

        for deviation = min_dev, max_dev, 1 do
                if(game_map[center_x + (dist - deviation)][center_y + deviation]["Tile"] == 1) then
                    return center_x + (dist - deviation), center_y + deviation
                end
        end

        min_dev = math.max(dist - center_x, 0)
        max_dev = math.min(center_y, dist)

        for deviation = min_dev, max_dev, 1 do
            if(game_map[center_x - (dist - deviation)][center_y - deviation]["Tile"] == 1) then
                return center_x - (dist - deviation), center_y - deviation
            end
        end


        dist = dist + 1
    until dist > max_dist

    return nil, nil
    
end

return MissionMapUtils