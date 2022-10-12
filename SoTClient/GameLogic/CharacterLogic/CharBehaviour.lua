local CharBehavior = {}

local NOT_FOUND, FOUND = 5, 6
local MAX_FOLLOW_RANGE = 5

local follow_map = {}
local start_x, start_y
local destination_x, destination_y

function GreedySearch(map, current_space_x, current_space_y, desired_space_x, desired_space_y, follow_step)

    local result

    if(follow_step > follow_map[current_space_x][current_space_y]) then 
        return NOT_FOUND;
    end

    if(current_space_x == desired_space_x and current_space_y == desired_space_y) then
        return {}
    end
    
    follow_map[current_space_x][current_space_y] = follow_step;

    for i = -1, 1, 1 do
        for j = -1, 1, 1 do
            if(map.checkEmptySpace(start_x + current_space_x + i, start_y + current_space_y + j)) then
                result = GreedySearch(map, current_space_x + i, current_space_y + j, desired_space_x, desired_space_y, follow_step + 1)
                if(result ~= NOT_FOUND)
                    return result[follow_step] = (i,j)
                end
            end
        end
    end
    return NOT_FOUND;
end



function DoFollow(map, begin_space_x, begin_space_y, desired_space_x, desired_space_y)
    start_x, start_y = begin_space_x, begin_space_y
    destination_x, destination_y = desired_space_x, desired_space_y

    for i = 1, MAX_FOLLOW_RANGE, 1 do 
        follow_map[i] = {}
        for j = 1, MAX_FOLLOW_RANGE, 1 do
            follow_map[i][j] = MAX_FOLLOW_RANGE
        end
    end
    return GreedySearch(map, 0, 0, desired_space_x-begin_space_x, desired_space_y-begin_space_y, 1);
end
