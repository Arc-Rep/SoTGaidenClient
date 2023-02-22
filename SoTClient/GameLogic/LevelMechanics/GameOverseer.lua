
local GameOverseer = {}

-- 0 = Enemies, 1 = Player1 & Allies, 2 = Player2 & Allies, ...
local global_turns = 1
local GameSetup = require "SoTClient.GameLogic.LevelMechanics.GameSetup"
local CharAction = require "SoTClient.GameLogic.CharacterLogic.CharAction"

local missionmaputils = require "SoTClient.GameLogic.Scenarios.MissionMapUtils"
local UnitTable = "SoTClient.GameLogic.CharacterLogic.UnitBase.UnitTable.lua"

local unit_table = {}
local Squads = {}

local LocalBattles = {}

function GameOverseer.getPlayerCharStats(game_map)
    return Squads[1][1]
end

function DoTurn(game_map)
    for char_index, char in ipairs(Squads[global_turns]) do
        if char["ControlType"] ~= "Player" and char["currentHP"] ~= 0 then
            CharAction.DoCharAction(game_map, unit_table, char)
        end
    end

    if(global_turns == -1) then
        global_turns = 1
        return
    elseif(global_turns + 1 >= #Squads) then
        global_turns = -1
    else
        global_turns = global_turns + 1
    end

    return DoTurn(game_map)

end

function GameOverseer.SendCommand(game_map, command)
    local move_done = false

    if global_turns ~= 1 then
        return
    end
    --print("Player is in " .. Squads[1][1]["x"] .. " and " .. Squads[1][1]["y"])
    --print("Tile above is " .. game_map[Squads[1][1]["x"]][Squads[1][1]["y"] - 1]["Tile"])
    --print("Tile below is " .. game_map[Squads[1][1]["x"]][Squads[1][1]["y"] + 1]["Tile"])
    --print("Tile left is " .. game_map[Squads[1][1]["x"] - 1][Squads[1][1]["y"]]["Tile"])
    --print("Tile right is " .. game_map[Squads[1][1]["x"] + 1][Squads[1][1]["y"]]["Tile"])

    if(command == "pressUp") then
        move_done = CharAction.PlayerMoveEvent(game_map, Squads[1][1], 0, -1)
    elseif (command == "pressDown") then
        move_done = CharAction.PlayerMoveEvent(game_map, Squads[1][1], 0, 1)
    elseif (command == "pressLeft") then
        move_done = CharAction.PlayerMoveEvent(game_map, Squads[1][1], -1, 0)
    elseif (command == "pressRight") then
        move_done = CharAction.PlayerMoveEvent(game_map, Squads[1][1], 1, 0)
    end

    if(move_done == true) then
        DoTurn(game_map)
    end

    return game_map
end

function GameOverseer.StartGame(MapData, player_squads, team_squads, seed1, seed2)
    MapData.generateMap(0, seed1, seed2, 0)
    GameSetup.SetupPlayerUnits(unit_table, Squads)
    GameSetup.SetupPlayerInitPlacements(MapData.GetMap(), Squads[1])
    GameSetup.SetupEnemyInitPlacements(MapData.GetMap(), Squads[-1], seed1, seed2)
    global_turns = 1
end

return GameOverseer