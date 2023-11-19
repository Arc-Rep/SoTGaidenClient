
local GameOverseer = {}

-- 0 = Enemies, 1 = Player1 & Allies, 2 = Player2 & Allies, ...
local global_turns = 1
local current_turn_player_index = 1

local Audio = require "SoTClient.Audio.AudioHandler"
local GameSetup = require "SoTClient.GameLogic.LevelMechanics.GameSetup"
local CharAction = require "SoTClient.GameLogic.CharacterLogic.CharAction"
local BattleLogic = require "SoTClient.GameLogic.MechanicsLogic.BattleCalcs.BattleLogic"

local missionmaputils = require "SoTClient.GameLogic.Scenarios.MissionMapUtils"
local UnitTable = "SoTClient.GameLogic.CharacterLogic.UnitBase.UnitTable.lua"

local Infusion = require "SoTClient.GameLogic.MechanicsLogic.InfusionSystem.Infusion"

local unit_table = {}
local Squads = {}
local squad_team_num = 0
local current_turn_player_index = 1
local LocalBattles = {}

function GameOverseer.getPlayerCharStats()
    return Squads[1][1]
end

function GameOverseer.GetPlayerParty()
    return Squads[1]
end

function GameOverseer.GetUnitList()
    return unit_table
end

function GameOverseer.DoTurnEnd()
    -- Get current character index
    local char = Squads[global_turns][current_turn_player_index]
    -- Clear animations
    char["animation"] = nil

    Infusion.checkTurnEndTrigger(GetGameMap(), char)

    current_turn_player_index = current_turn_player_index + 1

    if (current_turn_player_index > #Squads[global_turns]) then
        global_turns = global_turns + 1
        current_turn_player_index = 1
    end

    if(global_turns >= squad_team_num) then
        global_turns = 0
    end

    return GameOverseer.DoTurn()
end

function GameOverseer.DoTurn()
    -- Get current character index
    local char = Squads[global_turns][current_turn_player_index]

    if CheckIfDead(char) then
        if (char["ControlType"] == "Player") then
            return -- End of game
        end
        return GameOverseer.DoTurnEnd()
    elseif char["ControlType"] ~= "Player" then
        print("Turn of:")
        print(global_turns)
        print(current_turn_player_index)
        if(DoCharAction(GetGameMap(), unit_table, char, GameOverseer.DoTurnEnd) == true) then
            return GameOverseer.DoTurnEnd()
        end
    end
    
end

function GameOverseer.SendCommand(command, focus_x, focus_y)
    local move_done, skill_activated = false, nil
    local current_char = Squads[global_turns][current_turn_player_index]

    if current_char["ControlType"] ~= "Player" or CheckIfDead(current_char) then
        return
    end

    --print("Player is in " .. Squads[1][1]["x"] .. " and " .. Squads[1][1]["y"])
    --print("Tile above is " .. game_map[Squads[1][1]["x"]][Squads[1][1]["y"] - 1]["Tile"])
    --print("Tile below is " .. game_map[Squads[1][1]["x"]][Squads[1][1]["y"] + 1]["Tile"])
    --print("Tile left is " .. game_map[Squads[1][1]["x"] - 1][Squads[1][1]["y"]]["Tile"])
    --print("Tile right is " .. game_map[Squads[1][1]["x"] + 1][Squads[1][1]["y"]]["Tile"])

    if(command == "pressUp") then
        move_done = PlayerMoveEvent(GetGameMap(), Squads[1][1], 0, -1, GameOverseer.DoTurnEnd)
    elseif (command == "pressDown") then
        move_done = PlayerMoveEvent(GetGameMap(), Squads[1][1], 0, 1, GameOverseer.DoTurnEnd)
    elseif (command == "pressLeft") then
        move_done = PlayerMoveEvent(GetGameMap(), Squads[1][1], -1, 0, GameOverseer.DoTurnEnd)
    elseif (command == "pressRight") then
        move_done = PlayerMoveEvent(GetGameMap(), Squads[1][1], 1, 0, GameOverseer.DoTurnEnd)
    elseif (command == "pressSkill1") then
        return GetSkillMapRange(GetGameMap(), Squads[1][1], Squads[1][1]["Skill1"])
    elseif (command == "pressSkill2") then
        return GetSkillMapRange(GetGameMap(), Squads[1][1], Squads[1][1]["Skill2"])
    elseif (command == "pressSkill3") then
        return GetSkillMapRange(GetGameMap(), Squads[1][1], Squads[1][1]["Skill3"])
    elseif (command == "pressSkill4") then
        return GetSkillMapRange(GetGameMap(), Squads[1][1], Squads[1][1]["Skill4"])
    elseif (command == "performSkill1") then
        if(GetGameMap()[focus_x][focus_y]["Actor"] ~= nil) then
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
        doCharActionSkill(GetGameMap(), Squads[1][1], Squads[1][1][skill_activated], focus_x, focus_y)
        move_done = true
    end

    if(move_done == true) then
        GameOverseer.DoTurnEnd()
    end

    return move_done
end

function GameOverseer.StartGame(MapData, player_squads, team_squads, seed1, seed2)
    MapData.generateMap(0, seed1, seed2, 0)
    SetupPlayerUnits(unit_table, Squads)
    SetupPlayerInitPlacements(GetGameMap(), Squads[1])
    SetupEnemyInitPlacements(GetGameMap(), Squads[0], seed1, seed2)
    LoadLevelAudio()
    squad_team_num = 2
    global_turns = 1
end

return GameOverseer