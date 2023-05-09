local CharFollow = {}

local math = require "math"
local missionmaputils = require "SoTClient.GameLogic.Scenarios.MissionMapUtils"

local UP, LEFT, UNDIRECTED, DOWN, RIGHT  = -1, -1, 0, 1, 1
local DIRECT_ORDER = {-1, 1, 0}
local MAX_FOLLOW_RANGE = 6

local follow_map, direct_queue, semi_direct_queue, side_queue, back_queue = {}, {}, {}, {}, {}
local start_x, start_y = 0, 0
local destination_x, destination_y = 0, 0
local follow_map_max_x, follow_map_max_y = 0, 0
local grid_start_x, grid_start_y = 0,0

local function GreedySearch(map, current_space_x, current_space_y)

    if(current_space_x < 1 or current_space_x > follow_map_max_x or
        current_space_y < 1 or current_space_y > follow_map_max_y) then
        return
    end

    local x_dif, y_dif = 0, 0
    local x_order, y_order

    if(destination_x - current_space_x > 0) then
        x_dif = 1
    elseif(destination_x - current_space_x < 0) then
        x_dif = -1
    end

    if(destination_y - current_space_y > 0) then
        y_dif = 1
    elseif(destination_y - current_space_y < 0) then
        y_dif = -1
    end

    if(x_dif ~= 0) then
        x_order = {x_dif, -x_dif, 0}
    else
        x_order = {0 , 1, -1}
    end

    if(y_dif ~= 0) then
        y_order = {y_dif, -y_dif, 0}
    else
        y_order = {0 , 1, -1}
    end

    for i = 1, #x_order, 1 do
        local move_x = x_order[i]
        if(follow_map[current_space_x + move_x] ~= nil) then
            for j = 1, #y_order, 1 do
                local move_y = y_order[j]
                if(follow_map[current_space_x + move_x][current_space_y + move_y] ~= nil) then
                    if((move_x ~= UNDIRECTED or move_y ~= UNDIRECTED) and (follow_map[current_space_x + move_x][current_space_y + move_y][1] > follow_map[current_space_x][current_space_y][1])) then
                        if(destination_x == current_space_x + move_x and destination_y == current_space_y + move_y and
                                missionmaputils.CheckWallCollision(map, grid_start_x + current_space_x, grid_start_y + current_space_y, move_x, move_y) == false ) then
                            follow_map[destination_x][destination_y] = {follow_map[current_space_x][current_space_y][1] + 1, move_x, move_y}
                            return

                        elseif(missionmaputils.CheckLegalMovement(map, grid_start_x + current_space_x, grid_start_y + current_space_y, move_x, move_y) == true) then
                            follow_map[current_space_x + move_x][current_space_y + move_y] = {follow_map[current_space_x][current_space_y][1] + 1, move_x, move_y}

                            local local_dif = math.abs(move_x - x_dif) + math.abs(move_y - y_dif)
                            if(local_dif == 0) then
                                direct_queue[#direct_queue+1] = {current_space_x + move_x, current_space_y + move_y}
                            elseif(local_dif == 1) then
                                semi_direct_queue[#semi_direct_queue+1] = {current_space_x + move_x, current_space_y + move_y}
                            elseif(local_dif == 2) then
                                side_queue[#side_queue+1] = {current_space_x + move_x, current_space_y + move_y}
                            else
                                back_queue[#back_queue+1] = {current_space_x + move_x, current_space_y + move_y}
                            end

                        end
                    end
                end
            end
        end
    end
end

local function ReconstructFollowPath()
    local current_space_x, current_space_y, temp_x, temp_y = destination_x, destination_y, 0, 0
    while follow_map[current_space_x][current_space_y][1] ~= 1 do
        current_space_x, current_space_y = 
            current_space_x - follow_map[current_space_x][current_space_y][2], 
            current_space_y - follow_map[current_space_x][current_space_y][3]
    end
    return follow_map[current_space_x][current_space_y][2],
            follow_map[current_space_x][current_space_y][3],
            follow_map[destination_x][destination_y][1]
end

local function CheckFollowNecessity(map, begin_space_x, begin_space_y, desired_space_x, desired_space_y)
    local cardinal_dist_x, cardinal_dist_y = desired_space_x - begin_space_x, desired_space_y - begin_space_y

    if((cardinal_dist_x == 0 and math.abs(cardinal_dist_y) == 1) or (math.abs(cardinal_dist_x) == 1 and cardinal_dist_y == 0)) then
        return false
    elseif(math.abs(cardinal_dist_x) == 1 and math.abs(cardinal_dist_y) == 1 and
                missionmaputils.CheckWallCollision(map, begin_space_x, begin_space_y, desired_space_x - begin_space_x, desired_space_y - begin_space_y) == false) then
        return false
    end

    return true
end

function CharFollow.DoFollow(map, begin_space_x, begin_space_y, desired_space_x, desired_space_y)

    if ((CheckFollowNecessity(map, begin_space_x, begin_space_y, desired_space_x, desired_space_y) == false) or
            math.abs(desired_space_x - begin_space_x) >= MAX_FOLLOW_RANGE or math.abs(desired_space_y - begin_space_y) >= MAX_FOLLOW_RANGE)  then
        return 0,0,0
    end
    start_x, start_y = math.min(begin_space_x, MAX_FOLLOW_RANGE), math.min(begin_space_y, MAX_FOLLOW_RANGE)
    destination_x, destination_y = start_x + desired_space_x - begin_space_x, start_y + desired_space_y - begin_space_y
    grid_start_x, grid_start_y = begin_space_x - start_x, begin_space_y - start_y
    follow_map_max_x, follow_map_max_y = math.min(start_x + MAX_FOLLOW_RANGE, start_x + (map["x"]-begin_space_x)),
                                            math.min(start_y + MAX_FOLLOW_RANGE, start_y + (map["y"]-begin_space_y))
    follow_map, direct_queue, semi_direct_queue, side_queue, back_queue = {}, {}, {}, {}, {}

    for i = 1, follow_map_max_x, 1 do
        follow_map[i] = {}
        for j = 1, follow_map_max_y, 1 do
            follow_map[i][j] = {MAX_FOLLOW_RANGE, UNDIRECTED, UNDIRECTED}

        end
    end

    direct_queue[#direct_queue+1] = {start_x, start_y}
    follow_map[start_x][start_y] = {0, UNDIRECTED, UNDIRECTED}
    --print("Check parameters " .. start_y .. " and " .. desired_space_y.. " and ".. begin_space_y .. " and " .. destination_y)
    while ((follow_map[destination_x][destination_y][1] == MAX_FOLLOW_RANGE) and
            (#direct_queue ~= 0 or #semi_direct_queue ~= 0 or #side_queue ~= 0 or #back_queue ~= 0)) do
        --print("Check parameters " .. destination_x .. " and " .. destination_y)
        local next_space
        if(#direct_queue ~= 0) then
            next_space = table.remove(direct_queue, 1)
        elseif(#semi_direct_queue ~= 0) then
            next_space = table.remove(semi_direct_queue, 1)
        elseif(#side_queue ~= 0) then
            next_space = table.remove(side_queue, 1)
        elseif(#back_queue ~= 0) then
            next_space = table.remove(back_queue, 1)
        end

        GreedySearch(map, next_space[1], next_space[2])
    end

    if(follow_map[destination_x][destination_y][1] ~= MAX_FOLLOW_RANGE) then
        --print(follow_map[destination_x][destination_y][1] .. " " .. follow_map[destination_x][destination_y][2] .. " " .. follow_map[destination_x][destination_y][3])
        return ReconstructFollowPath()
    end
    return nil, nil, nil
end

return CharFollow