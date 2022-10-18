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


return MissionMapUtils