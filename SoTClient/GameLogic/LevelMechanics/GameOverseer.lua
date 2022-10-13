
local GameOverseer = {}

local global_turns = 0
local CharBehavior = require "SoTClient.GameLogic.CharacterLogic.CharBehavior"

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

function DoMovement(game_map, char, m_up_down, m_left_right)
    local cur_tile, desired_tile = game_map[char["x"]][char["y"]],
                                    game_map[char["x"] + m_up_down][char["y"] + m_left_right]

    if(desired_tile["Tile"] ~= 1 or desired_tile["Actor"] ~= "") then
        return
    end

    cur_tile["Actor"] = ""
    char["x"] = char["x"] + m_up_down
    char["y"] = char["y"] + m_left_right
    desired_tile["Actor"] = char

end

function DoTurn(game_map)
    DoMovement(game_map, Squad["Player"][2],
        CharBehavior.DoFollow(game_map, Squad["Player"][2]["x"], Squad["Player"][2]["y"], Squad["Player"][1]["x"], Squad["Player"][1]["y"]))
end

function GameOverseer.SendCommand(game_map, command)
    print("Player is in " .. Squad["Player"][1]["x"] .. " and " .. Squad["Player"][1]["y"])
    print("Tile above is " .. game_map[Squad["Player"][1]["x"]][Squad["Player"][1]["y"] - 1]["Tile"])
    print("Tile below is " .. game_map[Squad["Player"][1]["x"]][Squad["Player"][1]["y"] + 1]["Tile"])
    print("Tile left is " .. game_map[Squad["Player"][1]["x"] - 1][Squad["Player"][1]["y"]]["Tile"])
    print("Tile right is " .. game_map[Squad["Player"][1]["x"] + 1][Squad["Player"][1]["y"]]["Tile"])

    if(command == "pressUp") then
        DoMovement(game_map, Squad["Player"][1], 0, -1)
    elseif (command == "pressDown") then
        DoMovement(game_map, Squad["Player"][1], 0, 1)
    elseif (command == "pressLeft") then
        DoMovement(game_map, Squad["Player"][1], -1, 0)
    elseif (command == "pressRight") then
        DoMovement(game_map, Squad["Player"][1], 1, 0)
    end

    DoTurn(game_map)
    
    return game_map
end

function GameOverseer.StartGame(game_map, player_squads, team_squads)
    player_squads = {}
    player_squads["Players"] = {}
    player_squads["Players"]["Player1"] = {}
    player_squads["Players"]["Player1"][1] = {}
    player_squads["Players"]["Player1"][2] = {}
    player_squads["Players"]["Player1"][1]["Actor"] = "Law"
    player_squads["Players"]["Player1"][2]["Actor"] = "Dylan"

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