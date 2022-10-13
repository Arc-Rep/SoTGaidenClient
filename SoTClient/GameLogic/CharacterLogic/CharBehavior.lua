local CharBehavior = {}

local math = require "math"

local UP, LEFT, UNDIRECTED, DOWN, RIGHT  = -1, -1, 0, 1, 1
local MAX_FOLLOW_RANGE = 5

local follow_map, direct_queue, semi_direct_queue, side_queue, back_queue = {}, {}, {}, {}, {}
local start_x, start_y = 0, 0
local destination_x, destination_y = 0, 0
local follow_map_max_x, follow_map_max_y = 0, 0
local grid_start_x, grid_start_y = 0,0

function GreedySearch(map, current_space_x, current_space_y)

    if(current_space_x < 1 or current_space_x > follow_map_max_x or
        current_space_y < 1 or current_space_y > follow_map_max_y) then
        return
    end

    local x_dif, y_dif = 0, 0

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
    print("Begun with " .. x_dif .. " " .. y_dif)
    for i = LEFT, RIGHT, 1 do
        for j = UP, DOWN, 1 do
            if((i ~= UNDIRECTED or j ~= UNDIRECTED) and map.checkEmptySpace(grid_start_x + current_space_x + i, grid_start_y + current_space_y + j)) then
                if(follow_map[current_space_x + i][current_space_y + j][1] > follow_map[current_space_x][current_space_y][1]) then

                    follow_map[current_space_x + i][current_space_y + j] = {follow_map[current_space_x][current_space_y][1] + 1, i, j}

                    if(destination_x == current_space_x + i and destination_y == current_space_y + j) then
                        return
                    end

                    local local_dif = math.abs(i - x_dif) + math.abs(j - y_dif)
                    if(local_dif == 0) then
                        direct_queue[#direct_queue+1] = {current_space_x+i, current_space_y+j}
                    elseif(local_dif == 1) then
                        semi_direct_queue[#semi_direct_queue+1] = {current_space_x+i, current_space_y+j}
                    elseif(local_dif == 2) then
                        side_queue[#side_queue+1] = {current_space_x+i, current_space_y+j}
                    else
                        back_queue[#back_queue+1] = {current_space_x+i, current_space_y+j}
                    end

                end
            end
        end
    end
end

function ReconstructFollowPath()
    local current_space_x, current_space_y = destination_x, destination_y
    while follow_map[current_space_x][current_space_y][1] ~= 1 do
        current_space_x = current_space_x - follow_map[current_space_x][current_space_y][2]
        current_space_y = current_space_y - follow_map[current_space_x][current_space_y][3]
    end
    return follow_map[current_space_x][current_space_y][2], follow_map[current_space_x][current_space_y][3]
end

function CharBehavior.DoFollow(map, begin_space_x, begin_space_y, desired_space_x, desired_space_y)
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

    print("Start " .. start_x .. " " .. start_y)
    print("Destination" .. destination_x .. " " .. destination_y)
    print("Follow max " .. follow_map_max_x .. " " .. follow_map_max_y)

    direct_queue[#direct_queue+1] = {start_x, start_y}
    follow_map[start_x][start_y] = {0, UNDIRECTED, UNDIRECTED}

    while ((follow_map[destination_x][destination_y][1] == MAX_FOLLOW_RANGE) and
            (#direct_queue ~= 0 or #semi_direct_queue ~= 0 or #side_queue ~= 0 or #back_queue ~= 0)) do
        
        local next_space
        print("Total remaining " .. #direct_queue + #semi_direct_queue + #side_queue + #back_queue)
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

    if(follow_map[destination_x][destination_y] ~= MAX_FOLLOW_RANGE) then
        return ReconstructFollowPath()
    end
    return 0,0
end

return CharBehavior