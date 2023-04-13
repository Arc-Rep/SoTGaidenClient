
local GameOverseer = {}

-- 0 = Enemies, 1 = Player1 & Allies, 2 = Player2 & Allies, ...
local global_turns = 1
local GameSetup = require "SoTClient.GameLogic.LevelMechanics.GameSetup"
local CharAction = require "SoTClient.GameLogic.CharacterLogic.CharAction"
local BattleLogic = require "SoTClient.GameLogic.MechanicsLogic.BattleCalcs.BattleLogic"

local missionmaputils = require "SoTClient.GameLogic.Scenarios.MissionMapUtils"
local UnitTable = "SoTClient.GameLogic.CharacterLogic.UnitBase.UnitTable.lua"

local unit_table = {}
local Squads = {}
local squad_team_num = 0

local LocalBattles = {}


function GameOverseer.getPlayerCharStats()
    return Squads[1][1]
end

function DoTurn()
    for char_index, char in ipairs(Squads[global_turns]) do
        if char["ControlType"] ~= "Player" and char["currentHP"] > 0 then
            CharAction.DoCharAction(GetGameMap(), unit_table, char)
        end
    end

    global_turns = global_turns + 1

    if (global_turns == 1) then
        return
    elseif(global_turns >= squad_team_num) then
        global_turns = 0
    end

    return DoTurn()

end

function GameOverseer.SendCommand(command, focus_x, focus_y)
    local move_done, skill_activated = false, nil

    if global_turns ~= 1 then
        return
    end
    --print("Player is in " .. Squads[1][1]["x"] .. " and " .. Squads[1][1]["y"])
    --print("Tile above is " .. game_map[Squads[1][1]["x"]][Squads[1][1]["y"] - 1]["Tile"])
    --print("Tile below is " .. game_map[Squads[1][1]["x"]][Squads[1][1]["y"] + 1]["Tile"])
    --print("Tile left is " .. game_map[Squads[1][1]["x"] - 1][Squads[1][1]["y"]]["Tile"])
    --print("Tile right is " .. game_map[Squads[1][1]["x"] + 1][Squads[1][1]["y"]]["Tile"])

    if(command == "pressUp") then
        move_done = CharAction.PlayerMoveEvent(GetGameMap(), Squads[1][1], 0, -1)
    elseif (command == "pressDown") then
        move_done = CharAction.PlayerMoveEvent(GetGameMap(), Squads[1][1], 0, 1)
    elseif (command == "pressLeft") then
        move_done = CharAction.PlayerMoveEvent(GetGameMap(), Squads[1][1], -1, 0)
    elseif (command == "pressRight") then
        move_done = CharAction.PlayerMoveEvent(GetGameMap(), Squads[1][1], 1, 0)
    elseif (command == "pressSkill1") then
        return GetSkillMapRange(GetGameMap(), Squads[1][1], Squads[1][1]["Skill1"])
    elseif (command == "pressSkill2") then
        return GetSkillMapRange(GetGameMap(), Squads[1][1], Squads[1][1]["Skill2"])
    elseif (command == "pressSkill3") then
        return GetSkillMapRange(GetGameMap(), Squads[1][1], Squads[1][1]["Skill3"])
    elseif (command == "pressSkill4") then
        return GetSkillMapRange(GetGameMap(), Squads[1][1], Squads[1][1]["Skill4"])
    elseif (command == "performSkill1") then
        if(GetGameMap()[focus_x]["y"]["Actor"] ~= nil) then
            skill_activated = "Skill1"
        end
    elseif (command == "performSkill2") then
        if(GetGameMap()[focus_x][focus_y]["Actor"] ~= nil) then
            skill_activated = "Skill2"
        end
    elseif (command == "performSkill3") then
        if(GetGameMap()[focus_x][focus_y]["Actor"] ~= nil) then
            skill_activated = "Skill3"
        end
    elseif (command == "performSkill4") then
        if(GetGameMap()[focus_x][focus_y]["Actor"] ~= nil) then
            skill_activated = "Skill4"
        end
    end

    if(skill_activated ~= nil) then
        PerformSkill(GetGameMap(), Squads[1][1], GetGameMap()[focus_x][focus_y]["Actor"], Squads[1][1][skill_activated])
        move_done = true
    end

    if(move_done == true) then
        DoTurn()
    end
    
    return move_done
end

function GameOverseer.StartGame(MapData, player_squads, team_squads, seed1, seed2)
    MapData.generateMap(0, seed1, seed2, 0)
    GameSetup.SetupPlayerUnits(unit_table, Squads)
    GameSetup.SetupPlayerInitPlacements(GetGameMap(), Squads[1])
    GameSetup.SetupEnemyInitPlacements(GetGameMap(), Squads[0], seed1, seed2)
    squad_team_num = 2
    global_turns = 1
end

return GameOverseer