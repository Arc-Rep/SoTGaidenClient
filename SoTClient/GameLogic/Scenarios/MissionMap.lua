
local MissionMap = {}

local math = require("math")
local mathutils = require("SoTClient.Utils.MathUtils")
local levelgen = require "SoTClient.GameLogic.Scenarios.LevelGen"
local missionmaputils = require "SoTClient.GameLogic.Scenarios.MissionMapUtils"
local map = {}
local empty, walkable, exit, entrance = 0, 1, 2, 3
local min_x, max_x = 40, 50
local min_y, max_y = 40, 50
local min_room_wall_size, max_room_wall_size = 3, 10
local min_room_num, max_room_num = 4, 10

function GetGameMap()
    return map
end

local function SelectFarTile(x, y, size_x, size_y, dist)
    local select_x, select_y
    local fardest_x, fardest_y, fardest_dist, iterations = 0, 0, 0, 1

    repeat
        select_x, select_y = math.random(size_x, size_y), math.random(size_x, size_y)
        fardest_dist = (select_x - x)^2 + (select_y - y)^2
    until  fardest_dist >= dist or iterations >= 30

    return fardest_dist
end

local function CheckRoomSuitability(room)

    if (room["x"] + room["columns"] > map["x"]) then
        room["columns"] = map["x"] - room["x"]
        if (room["columns"] < min_room_wall_size) then
            return false
        end
    end

    if(room["y"] + room["rows"] > map["y"]) then
        room["rows"] = map["y"] - room["y"]
        if(room["rows"] < min_room_wall_size) then
            return false
        end
    end

    for i = room["x"], room["x"] + room["columns"], 1 do
        for j = room["y"], room["y"] + room["rows"], 1 do
            if map[i][j]["Tile"] ~= empty then
                return false
            end
        end
    end

    for i = 1, #map["rooms"], 1 do
        local dist_x, dist_y = CheckRoomCardinalDist(room, map["rooms"][i])

        if(dist_x <= 3 and dist_y <= 3) then
            return false
        end
    end
end

local function ParseRoomToMap(room, room_x, room_y)
    for i=1, room["columns"], 1 do
        for j=1, room["rows"], 1 do
            map[room_x + i][room_y + j]["Tile"] = room[i][j]
        end
    end
end

local function MakeRoom(room_x, room_y, min_room_size, max_room_size, room_type)
    local room = {}
    room["x"] = room_x
    room["y"] = room_y
    room["rows"] = levelgen.generateRandomBetween(
                                min_room_wall_size, math.min(max_room_wall_size, map["x"] - room_x))     -- number of rows the room has
    room["columns"] = levelgen.generateRandomBetween(
                                min_room_wall_size, math.min(max_room_wall_size, map["y"] - room_y))  -- number of columns the room has
    room["type"] = room_type   -- type of room
    io.write("Rows " .. room["rows"] .. "and columns " .. room["columns"] .. "\n")

    if(CheckRoomSuitability(room) == false) then
        return false
    end
    
    for i = 1, room["columns"], 1 do
        room[i] = {}
        for j = 1, room["rows"], 1 do
            room[i][j] = walkable
        end
    end

    if(room_type ~= nil) then  -- add room type specific details
        --SetupCustomRoom(room)
    end

    -- TODO: add random room deformities 
    map["rooms"][#map["rooms"] + 1] = room
    ParseRoomToMap(room, room_x, room_y)

    return true
end

local function MapRoomEssentials(mission_type)
    local entrance_room_index, exit_room_index = levelgen.generateRandomBetween(1, #map["rooms"]), nil
    local entrance_room = map["rooms"][entrance_room_index] -- define entrance room
    local entrance_x, entrance_y = levelgen.generateRandomBetween(1,entrance_room["rows"]),
                                        levelgen.generateRandomBetween(1,entrance_room["columns"])

    entrance_room[entrance_x][entrance_y] = entrance
    map["entrance_x"] = entrance_room["x"] + entrance_x
    map["entrance_y"] = entrance_room["y"] + entrance_y
    map[entrance_room["x"] + entrance_x][entrance_room["y"] + entrance_y]["Tile"] = entrance

    if #map["rooms"] ~= 1 then
        repeat
            exit_room_index = levelgen.generateRandomBetween(1, #map["rooms"])
       until exit_room_index ~= entrance_room_index
    else
        exit_room_index = 1
    end

    local exit_room = map["rooms"][exit_room_index] -- define exit room
    local exit_x, exit_y = levelgen.generateRandomBetween(1,exit_room["rows"]),
                                levelgen.generateRandomBetween(1,exit_room["columns"])

    exit_room[exit_x][exit_y] = exit
    map["exit_x"] = exit_x
    map["exit_y"] = exit_y
    map[exit_room["x"] + exit_x][exit_room["y"] + exit_y]["Tile"] = exit

end

local function AssignClosestRoom(room_index, room)

    local closest_k, min_dist_found = nil, nil

    for k, checkroom in ipairs(map["rooms"]) do
        if(k ~= room_index) then
            local cur_dist = CheckRoomRealDistance(room, checkroom)
            if(min_dist_found == nil) or cur_dist < min_dist_found then
                min_dist_found = cur_dist
                closest_k = k
            end
        end
    end

    map["rooms"][room_index]["closestRoom"] = closest_k

end



local function ConnectRooms(room_1, room_2)

    local tunnel = {}
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
            tunnel[#tunnel + 1] = { x = room_1_center_x + i * x_step, y = room_1_center_y}
        end
    end

    for j=1, math.abs(room_y_diff), 1 do
        if(map[room_1_center_x - room_x_diff][room_1_center_y + j * y_step]["Tile"] == empty) then
            map[room_1_center_x - room_x_diff][room_1_center_y + j * y_step]["Tile"] = walkable
            tunnel[#tunnel + 1] = { x = room_1_center_x - room_x_diff, y = room_1_center_y + j * y_step}
        end
    end

    map["tunnels"][#map["tunnels"] + 1] = tunnel
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
                    temp_dist = CheckRoomRealDistance(map["rooms"][k1], map["rooms"][k2])
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

function MissionMap.GetMap()
    return map
end

function MissionMap.generateMap(mission_type, seed1, seed2, difficulty_level)
    levelgen.setSeed(seed1, seed2)
    local x, y = levelgen.generateRandomBetween(min_x, max_x), levelgen.generateRandomBetween(min_y, max_y)
    --print( "x" .. x .. "\ny" .. y)
    map["x"] = x
    map["y"] = y
    map["rooms"] = {}
    map["tunnels"] = {}

    for i = 1, x, 1 do
        map[i] = {}
        for j = 1, y, 1 do
            map[i][j] = {}
            map[i][j]["Tile"] = empty
            map[i][j]["Actor"] = nil
        end
    end

    local room_num_to_create = levelgen.generateRandomBetween(min_room_num, max_room_num)
    
    while #map["rooms"] < room_num_to_create do
        MakeRoom(levelgen.generateRandomBetween(2, map["x"] - min_room_wall_size), levelgen.generateRandomBetween(2, map["y"] - min_room_wall_size), nil)
    end

    MapRoomEssentials(mission_type)

    ConnectAllRooms()

    return map
end

return MissionMap