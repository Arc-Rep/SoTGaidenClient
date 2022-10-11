local CharBehavior = {}

local UP, DOWN, LEFT, RIGHT = 2, -2, -1, 1
local FOUND = 5
local MAX_FOLLOW_RANGE = 5

function GreedySearch(map, current_space_x, current_space_y, unit_to_follow, follow_map, follow_step)
    if(follow_step == MAX_FOLLOW_RANGE) then 
        return 0;
    end

    if(current_space_x == unit_to_follow["x"] and current_space_y == unit_to_follow["y"]) then
        return FOUND;
    end

    follow_map[current_space_x][current_space_y] = follow_step;

    for i = -1, 1, 1 do
        for j = -1, 1, 1 do
            if(follow_map[current_space_x + i][current_space_y + j] < follow_step + 1 and map[current_space_x][current_space_y] == 1) then
                if(GreedySearch(map, current_space_x + i, current_space_y + j, unit_to_follow, follow_map, follow_step + 1) ~= false) then
                    return i+j*2;
                end
            end
        end
    end
    return false;
end



function DoFollow(map, unit_following, unit_to_follow)
    local sub_map = {};
    for i = unit_following["x"], unit_following["x"] + MAX_FOLLOW_RANGE, 1 do 
        sub_map[i] = {}
        for j = unit_following["y"], unit_following["y"] + MAX_FOLLOW_RANGE, 1 do
            sub_map[i][j] = MAX_FOLLOW_RANGE
        end
    end
    return GreedySearch(map, unit_following["x"], unit_following["y"], unit_to_follow, sub_map, 0);
end
