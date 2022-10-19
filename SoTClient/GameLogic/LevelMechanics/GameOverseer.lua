
local GameOverseer = {}

local global_turns = 0
local GameSetup = require "SoTClient.GameLogic.LevelMechanics.GameSetup"
local CharAction = require "SoTClient.GameLogic.CharacterLogic.CharAction"
local MapData = require "SotClient.GameLogic.Scenarios.MissionMap"
local missionmaputils = require "SoTClient.GameLogic.Scenarios.MissionMapUtils"
local UnitTable = "SoTClient.GameLogic.CharacterLogic.UnitBase.UnitTable.lua"

local unit_table = {}
local Squads = {}

local LocalBattles = {}

function DoTurn(game_map)
    for char_index, char in ipairs(unit_table) do
        CharAction.DoPlayerAction(game_map, char)
    end
end

function GameOverseer.SendCommand(game_map, command)
    local move_done = false
    print("Player is in " .. Squads[1][1]["x"] .. " and " .. Squads[1][1]["y"])
    print("Tile above is " .. game_map[Squads[1][1]["x"]][Squads[1][1]["y"] - 1]["Tile"])
    print("Tile below is " .. game_map[Squads[1][1]["x"]][Squads[1][1]["y"] + 1]["Tile"])
    print("Tile left is " .. game_map[Squads[1][1]["x"] - 1][Squads[1][1]["y"]]["Tile"])
    print("Tile right is " .. game_map[Squads[1][1]["x"] + 1][Squads[1][1]["y"]]["Tile"])

    if(command == "pressUp") then
        move_done = CharAction.DoMovement(game_map, Squads[1][1], 0, -1)
    elseif (command == "pressDown") then
        move_done = CharAction.DoMovement(game_map, Squads[1][1], 0, 1)
    elseif (command == "pressLeft") then
        move_done = CharAction.DoMovement(game_map, Squads[1][1], -1, 0)
    elseif (command == "pressRight") then
        move_done = CharAction.DoMovement(game_map, Squads[1][1], 1, 0)
    end

    if(move_done == true) then
        DoTurn(game_map)
    end
    
    return game_map
end

function GameOverseer.StartGame(game_map, player_squads, team_squads, seed1, seed2)
    game_map = MapData.generateMap(0, seed1, seed2, 0)
    GameSetup.SetupPlayerUnits(unit_table, Squads)
    GameSetup.SetupInitPlacements(game_map, unit_table)
    GameSetup.SetupPlayerInitPlacements(game_map, unit_table)
    GameSetup.SetupEnemyInitPlacements(game_map, unit_table, seed1, seed2)
end

return GameOverseer