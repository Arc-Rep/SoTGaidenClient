
local MissionMap = {}

local math = require("math")
local mathutils = require("SoTClient.Utils.MathUtils")
local level_gen = require "SoTClient.GameLogic.Scenarios.LevelGen"

local map = {}
local empty, walkable, exit, entrance = 0, 1, 2, 3
local min_x, max_x = 30, 40
local min_y, max_y = 30, 40
local min_room_wall_size, max_room_wall_size = 3, 10
local min_room_num, max_room_num = 4, 10


local function SelectFarTile(x, y, size_x, size_y, dist)
    local select_x, select_y
    local fardest_x, fardest_y, fardest_dist, iterations = 0, 0, 0, 1

    repeat
        select_x, select_y = math.random(size_x, size_y), math.random(size_x, size_y)
        fardest_dist = (select_x - x)^2 + (select_y - y)^2
    until  fardest_dist >= dist or iterations >= 30

    return fardest_dist
end

local function SetupCustomRoom(room)


end 

local function CheckRoomSuitability(room)
    local upper_wall, left_wall, right_wall, down_wall = 0, 0, 0, 0
    if(room["x"] > 1) then
        left_wall = 1
    end

    if(room["x"] + room["columns"] < map["x"]) then
        right_wall = 1
    end

    if(room["y"] > 1) then
        upper_wall = 1
    end

    if(room["y"] + room["rows"] < map["y"]) then
        down_wall = 1
    end
    for i = 1 - upper_wall, room["rows"] + down_wall, 1 do
        for j = 1 - left_wall, room["columns"] + right_wall, 1 do
            if map[room["x"] + (i-1)][room["y"] + (j-1)]["Tile"] ~= empty then
                return false
            end
        end
    end

end

local function ParseRoomToMap(room, room_x, room_y)
    for i=1, room["rows"], 1 do
        for j=1, room["columns"], 1 do
            map[room_x + (i-1)][room_y + (j-1)]["Tile"] = room[i][j]
        end
    end
end

local function MakeRoom(room_x, room_y, min_room_size, max_room_size, room_type)
    local room, added_tiles = {}, 0
    room["x"] = room_x
    room["y"] = room_y
    room["rows"] = level_gen.generateRandomBetween(
                                min_room_wall_size, math.min(max_room_wall_size, map["x"] - room_x))     -- number of rows the room has
    room["columns"] = level_gen.generateRandomBetween(
                                min_room_wall_size, math.min(max_room_wall_size, map["y"] - room_y))  -- number of columns the room has
    room["type"] = room_type   -- type of room
    io.write("Rows " .. room["rows"] .. "and columns " .. room["columns"] .. "\n")
    for i = 1, room["rows"], 1 do
        room[i] = {}
        for j = 1, room["columns"], 1 do
            room[i][j] = walkable
            added_tiles = added_tiles + 1
        end
    end

    if(room_type ~= nil) then  -- add room type specific details
        SetupCustomRoom(room)
    end

    if(CheckRoomSuitability(room) == false) then
        return false
    end
    -- TODO: add random room deformities 
    map["rooms"][#map["rooms"] + 1] = room
    ParseRoomToMap(room, room_x, room_y)

    return true
end

local function MapRoomEssentials(mission_type)
    local entrance_room_index, exit_room_index = level_gen.generateRandomBetween(1, #map["rooms"]), nil
    local entrance_room = map["rooms"][entrance_room_index] -- define entrance room
    local entrance_x, entrance_y = level_gen.generateRandomBetween(1,entrance_room["rows"]),
                                        level_gen.generateRandomBetween(1,entrance_room["columns"])

    entrance_room[entrance_x][entrance_y] = entrance
    map["entrance_x"] = entrance_room["x"] + entrance_x
    map["entrance_y"] = entrance_room["y"] + entrance_y
    ParseRoomToMap(entrance_room, entrance_room["x"], entrance_room["y"])

    if #map["rooms"] ~= 1 then
        repeat
            exit_room_index = level_gen.generateRandomBetween(1, #map["rooms"])
       until exit_room_index ~= entrance_room_index
    else
        exit_room_index = 1
    end

    local exit_room = map["rooms"][exit_room_index] -- define exit room
    local exit_x, exit_y = level_gen.generateRandomBetween(1,exit_room["rows"]),
                                level_gen.generateRandomBetween(1,exit_room["columns"])

    exit_room[exit_x][exit_y] = exit
    map["exit_x"] = exit_x
    map["exit_y"] = exit_y
    ParseRoomToMap(exit_room, exit_room["x"], exit_room["y"])

end

local function CheckRoomDist(room1, room2)
    local rect_x_beg, rect_x_end = math.min(room1["x"], room2["x"]), math.max(room1["columns"] + room1["x"],room2["columns"] + room2["x"])
    local rect_y_beg, rect_y_end = math.min(room1["y"], room2["y"]), math.max(room1["rows"] + room1["y"],room2["rows"] + room2["y"])
    local rect_x_dist, rect_y_dist= rect_x_end - rect_x_beg, rect_y_end - rect_y_beg
    return math.sqrt(rect_x_dist^2 + rect_y_dist^2)
end

local function AssignClosestRoom(room_index, room)

    local closest_k, min_dist_found = nil, nil

    for k, checkroom in ipairs(map["rooms"]) do
        if(k ~= room_index) then
            local cur_dist = CheckRoomDist(room, checkroom)
            if(min_dist_found == nil) or cur_dist < min_dist_found then
                min_dist_found = cur_dist
                closest_k = k
            end
        end
    end

    map["rooms"][room_index]["closestRoom"] = closest_k

end



local function ConnectRooms(room_1, room_2)

    local room_1_center_x, room_1_center_y = room_1["x"] + math.floor(room_1["columns"]/2), room_1["y"] + math.floor(room_1["rows"]/2)
    local room_2_center_x, room_2_center_y = room_2["x"] + math.floor(room_2["columns"]/2), room_2["y"] + math.floor(room_2["rows"]/2)
    local room_x_diff, room_y_diff = room_1_center_x - room_2_center_x, room_1_center_y - room_2_center_y
    local x_step, y_step
    
    if(room_x_diff > 0) then
        x_step = -1
    else
        x_step = 1
    end

    if(room_y_diff > 0) then
        y_step = -1
    else
        y_step = 1
    end
    io.write("X difference " .. room_x_diff .. " starting by " .. room_1_center_x .. "\n")
    io.write("Y difference " .. room_y_diff .. " starting by " .. room_1_center_y .. "\n")
    for i=1, math.abs(room_x_diff), 1 do
        if(map[room_1_center_x + i * x_step][room_1_center_y]["Tile"] == empty) then
            map[room_1_center_x + i * x_step][room_1_center_y]["Tile"] = walkable
        end
    end

    for j=1, math.abs(room_y_diff), 1 do
        if(map[room_1_center_x - room_x_diff][room_1_center_y + j * y_step]["Tile"] == empty) then
            map[room_1_center_x - room_x_diff][room_1_center_y + j * y_step]["Tile"] = walkable
        end
    end
end

local function UnitePartitions(partitions, part1, part2)

    for k, temp_part in ipairs(partitions) do
        if(temp_part == part2) then
            partitions[k] = part1
        end
    end

end

local function ConnectPartitions(room_partitions, part1, part2)
    local room1, room2, min_dist, temp_dist = nil, nil, 0, 0
    for k1, temp_part1 in ipairs(room_partitions) do
        if(part1 == temp_part1) then
            for k2, temp_part2  in ipairs(room_partitions) do
                if(temp_part2 == part2) then
                    temp_dist = CheckRoomDist(map["rooms"][k1], map["rooms"][k2])
                    if((room1 == nil) or (temp_dist < min_dist)) then
                        room1 = k1
                        room2 = k2
                        min_dist = temp_dist
                    end
                end
            end
        end
    end
    if(room1 ~= nil) then
        ConnectRooms(map["rooms"][room1], map["rooms"][room2])
    end
end

local function CorrectDiffPartitions(room_partitions)
    local part_unify = nil
    for k, part_temp in ipairs(room_partitions) do
        if(part_unify == nil) then
            part_unify = part_temp
        elseif (part_temp ~= part_unify) then
            ConnectPartitions(room_partitions, part_unify, part_temp)
            UnitePartitions(room_partitions, part_unify, part_temp)
        end
    end
end

local function ConnectAllRooms()
    local room_partitions, n_partitions = {}, 0

    for k, room in ipairs(map["rooms"]) do
        if(map["rooms"][k]["closestRoom"] == nil) then
            AssignClosestRoom(k, room)
            if(room ~= map["rooms"][room["closestRoom"]]["closestRoom"]) then
                ConnectRooms(room, map["rooms"][room["closestRoom"]])
                if(room_partitions[room["closestRoom"]] ~= nil) then
                    if(room_partitions[k] == nil) then
                        room_partitions[k] = room_partitions[room["closestRoom"]]
                    else
                        UnitePartitions(room_partitions, room_partitions[k], room_partitions[room["closestRoom"]])
                    end
                else
                    if(room_partitions[k] ~= nil) then
                        room_partitions[room["closestRoom"]] = room_partitions[k]
                    else
                        n_partitions = n_partitions + 1
                        room_partitions[room["closestRoom"]] = n_partitions
                        room_partitions[k] = n_partitions
                    end
                end
            end
        end
    end

    CorrectDiffPartitions(room_partitions)
end

function MissionMap.generateMap(mission_type, seed1, seed2, difficulty_level)
    level_gen.setSeed(seed1, seed2)
    local x, y = level_gen.generateRandomBetween(min_x, max_x), level_gen.generateRandomBetween(min_y, max_y)
    print( "x" .. x .. "\ny" .. y)
    map["x"] = x
    map["y"] = y
    map["rooms"] = {}

    for i = 1, x, 1 do
        map[i] = {}
        for j = 1, y, 1 do
            map[i][j] = {}
            map[i][j]["Tile"] = empty
            map[i][j]["Actor"] = ""
        end
    end

    local room_num_to_create = level_gen.generateRandomBetween(min_room_num, max_room_num)
    
    while #map["rooms"] < room_num_to_create do
        MakeRoom(level_gen.generateRandomBetween(2, map["x"] - min_room_wall_size), level_gen.generateRandomBetween(2, map["y"] - min_room_wall_size), nil)
    end

    MapRoomEssentials(mission_type)

    ConnectAllRooms()
    
    return map
end

return MissionMap