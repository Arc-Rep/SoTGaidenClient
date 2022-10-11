
local GameOverseer = {}

local global_turns = 0

local Squad = {}

Squad["CPU-Enemy"] = {}
Squad["Player"] = {}
Squad["Neutral"] = {}
Squad["Human-F"] = {}
Squad["CPU-F"] = {}


local LocalBattles = {}

function FindClosestEmptySpace(game_map, center_x, center_y)

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

function SetupInitPlacements(game_map, player_units)

    local last_placement_x, last_placement_y = game_map["entrance_x"], game_map["entrance_y"]

    for k, character in ipairs(player_units) do
        last_placement_x, last_placement_y = FindClosestEmptySpace(game_map, last_placement_x, last_placement_y)
        game_map[last_placement_x][last_placement_y]["Actor"] = character
        player_units[k]["x"] = last_placement_x
        player_units[k]["y"] = last_placement_y
    end
end

function GameOverseer.SendCommand(game_map, command)
    print("Player is in " .. Squad["Player"][1]["x"] .. " and " .. Squad["Player"][1]["y"])
    print("Tile above is " .. game_map[Squad["Player"][1]["x"]][Squad["Player"][1]["y"] - 1]["Tile"])
    print("Tile below is " .. game_map[Squad["Player"][1]["x"]][Squad["Player"][1]["y"] + 1]["Tile"])
    print("Tile left is " .. game_map[Squad["Player"][1]["x"] - 1][Squad["Player"][1]["y"]]["Tile"])
    print("Tile right is " .. game_map[Squad["Player"][1]["x"] + 1][Squad["Player"][1]["y"]]["Tile"])

    if(command == "pressUp" and game_map[Squad["Player"][1]["x"]][Squad["Player"][1]["y"] - 1]["Tile"] == 1 ) then
        print("Entered")
        game_map[Squad["Player"][1]["x"]][Squad["Player"][1]["y"]]["Actor"] = ""
        Squad["Player"][1]["y"] = Squad["Player"][1]["y"] - 1
        game_map[Squad["Player"][1]["x"]][Squad["Player"][1]["y"]]["Actor"] = Squad["Player"][1]
    elseif (command == "pressDown" and game_map[Squad["Player"][1]["x"]][Squad["Player"][1]["y"] + 1]["Tile"] == 1) then
        game_map[Squad["Player"][1]["x"]][Squad["Player"][1]["y"]]["Actor"] = ""
        Squad["Player"][1]["y"] = Squad["Player"][1]["y"] + 1
        game_map[Squad["Player"][1]["x"]][Squad["Player"][1]["y"]]["Actor"] = Squad["Player"][1]
    elseif (command == "pressLeft" and game_map[Squad["Player"][1]["x"] - 1][Squad["Player"][1]["y"]]["Tile"] == 1) then
        game_map[Squad["Player"][1]["x"]][Squad["Player"][1]["y"]]["Actor"] = ""
        Squad["Player"][1]["x"] = Squad["Player"][1]["x"] - 1
        game_map[Squad["Player"][1]["x"]][Squad["Player"][1]["y"]]["Actor"] = Squad["Player"][1]
    elseif (command == "pressRight" and game_map[Squad["Player"][1]["x"] + 1][Squad["Player"][1]["y"]]["Tile"] == 1) then
        game_map[Squad["Player"][1]["x"]][Squad["Player"][1]["y"]]["Actor"] = ""
        Squad["Player"][1]["x"] = Squad["Player"][1]["x"] + 1
        game_map[Squad["Player"][1]["x"]][Squad["Player"][1]["y"]]["Actor"] = Squad["Player"][1]
    end

    return game_map
end

function GameOverseer.StartGame(game_map, player_squads, team_squads)
    player_squads = {}
    player_squads["Players"] = {}
    player_squads["Players"]["Player1"] = {}
    player_squads["Players"]["Player1"][1] = {}
    player_squads["Players"]["Player1"][1]["Actor"] = "Law"

    Squad["Player"] = player_squads["Players"]["Player1"]

    for k_squad, squad in ipairs(Squad["Player"]) do
        print("Entered...")
        if(k_squad ~= 1) then
            Squad["CPU-F"] = squad
        end
    end
    if(team_squads ~= nil) then
        for k_player, k_squads in ipairs(team_squads) do
            Squad["Human-F"][k_player] = k_squads["main"]
            for squad_index, squad in ipairs(k_squads) do
                if(squad_index ~= "main") then
                    Squad["CPU-F"] = squad
                end
            end
        end
    end
    SetupInitPlacements(game_map, Squad["Player"])
end

return GameOverseer