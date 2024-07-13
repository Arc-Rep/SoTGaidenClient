
local GameOverseer = {}

local Audio = require "SoTClient.Audio.AudioHandler"
local GameSetup = require "SoTClient.GameLogic.LevelMechanics.GameSetup"
local CharAction = require "SoTClient.GameLogic.CharacterLogic.CharAction"
local BattleLogic = require "SoTClient.GameLogic.MechanicsLogic.BattleCalcs.BattleLogic"
local AnimationQueue = require "SoTClient.Visuals.Animations.Basic.AnimationQueue"
local missionmaputils = require "SoTClient.GameLogic.Scenarios.MissionMapUtils"
local UnitTable = "SoTClient.GameLogic.CharacterLogic.UnitBase.UnitTable"
local MapRender = require "SotClient.Visuals.RenderMap"

local Infusion = require "SoTClient.GameLogic.MechanicsLogic.InfusionSystem.Infusion"

-- 0 = Enemies, 1 = Player1 & Allies, 2 = Player2 & Allies, ...
local global_turns = 1

local unit_table = {}
local Squads = {}
local squad_team_num = 0
local LocalBattles = {}

-- Returns number of character actions to await before starting burst
local burst_await_amount = 0

-- Returns number of character actions to perform before stopping burst
local burst_turn_total = 0

-- Returns number of characters mid-burst that finished their actions
local current_turn_player_index = 1

local DoActionEnd

function GameOverseer.getPlayerCharStats()
    return Squads[1][1]
end

function GameOverseer.GetPlayerParty()
    return Squads[1]
end

function GameOverseer.GetUnitList()
    return unit_table
end


function GameOverseer.SetNextBurst()
    burst_turn_total          = #Squads[global_turns]
    burst_await_amount        = 0
    current_turn_player_index = 1

    for index, character in pairs(Squads[global_turns]) do
        if (character["ControlType"] == "Player") then
            burst_await_amount = burst_await_amount + 1
        end
    end
end

function GameOverseer.PerformBurst()
    while (current_turn_player_index <= burst_turn_total) do
        print("Performing turn of " .. current_turn_player_index .. " of team " .. global_turns)
        local character = Squads[global_turns][current_turn_player_index]
        if character["ControlType"] == "Player" then
            -- Stop and await player to act
        elseif (not CheckIfDead(character)) then
            DoCharAction(GetGameMap(), unit_table, character)
        end
        current_turn_player_index = current_turn_player_index + 1
    end
    -- TO DO: Change DoTurnEnd with DoBurstEnd
    AnimationQueue.StartAnimations(GameOverseer.DoTurnEnd)
end

--function GameOverseer.DoActionEnd()
--    print("User is now in")
--    print(Squads[1][1]["x"])
--    print(Squads[1][1]["y"])
--    current_turn_player_index = current_turn_player_index + 1
--    if (current_turn_player_index > burst_turn_total) then
--        GameOverseer.DoTurnEnd()
--    elseif (current_turn_player_index > burst_await_amount) then
--        GameOverseer.PerformBurst()
--    end
--end


function GameOverseer.DoTurnEnd()
    for _,char in pairs(Squads[global_turns]) do

        if (not CheckIfDead(char)) then
            Infusion.checkTurnEndTrigger(GetGameMap(), char)
        elseif(char["ControlType"] == "Player") then
            return -- End of game
        end

    end

    global_turns = global_turns + 1

    if(global_turns >= squad_team_num) then
        global_turns = 0
    end

    GameOverseer.DoTurnStart()
end

function GameOverseer.DoTurnStart()
    MapRender.UpdateTilemap()
    GameOverseer.SetNextBurst()
    AnimationQueue.ResetQueue()
    AnimationQueue.SetNewCycle()

    if burst_await_amount == 0 then
        GameOverseer.PerformBurst()
    end
end

function GameOverseer.SendCommand(command, focus_x, focus_y)
    local move_done, skill_activated = false, nil

    print(current_turn_player_index)
    if (global_turns ~= 1) then
        return
    end

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
        move_done = PlayerMoveEvent(GetGameMap(), Squads[1][1], 0, -1)
    elseif (command == "pressDown") then
        move_done = PlayerMoveEvent(GetGameMap(), Squads[1][1], 0, 1)
    elseif (command == "pressLeft") then
        move_done = PlayerMoveEvent(GetGameMap(), Squads[1][1], -1, 0)
    elseif (command == "pressRight") then
        move_done = PlayerMoveEvent(GetGameMap(), Squads[1][1], 1, 0)
    elseif (command == "pressSkill1") then
        return GetSkillMapRange(GetGameMap(), Squads[1][1], Squads[1][1]["Skill1"])
    elseif (command == "pressSkill2") then
        return GetSkillMapRange(GetGameMap(), Squads[1][1], Squads[1][1]["Skill2"])
    elseif (command == "pressSkill3") then
        return GetSkillMapRange(GetGameMap(), Squads[1][1], Squads[1][1]["Skill3"])
    elseif (command == "pressSkill4") then
        return GetSkillMapRange(GetGameMap(), Squads[1][1], Squads[1][1]["Skill4"])
    elseif (command == "performSkill1") then
        if (CheckValidTarget(GetGameMap(), Squads[1][1], Squads[1][1]["Skill1"], focus_x, focus_y)) then
            skill_activated = "Skill1"
        end
    elseif (command == "performSkill2") then
        if (CheckValidTarget(GetGameMap(), Squads[1][1], Squads[1][1]["Skill2"], focus_x, focus_y)) then
            skill_activated = "Skill2"
        end
    elseif (CheckValidTarget(GetGameMap(), Squads[1][1], Squads[1][1]["Skill3"], focus_x, focus_y))  then
        if(GetGameMap()[focus_x][focus_y]["Actor"] ~= nil) then
            skill_activated = "Skill3"
        end
    elseif (CheckValidTarget(GetGameMap(), Squads[1][1], Squads[1][1]["Skill4"], focus_x, focus_y))  then
        if(GetGameMap()[focus_x][focus_y]["Actor"] ~= nil) then
            skill_activated = "Skill4"
        end
    end

    if(skill_activated ~= nil) then
        DoCharActionSkill(GetGameMap(), Squads[1][1], Squads[1][1][skill_activated], focus_x, focus_y)
        move_done = true
    end

    if(move_done == true) then
        GameOverseer.PerformBurst()
    end

    return move_done
end

function GameOverseer.SetupGame(MapData, player_squads, team_squads, seed1, seed2)
    MapData.generateMap(0, seed1, seed2, 0)
    SetupPlayerUnits(unit_table, Squads)
    SetupPlayerInitPlacements(GetGameMap(), Squads[1])
    SetupEnemyInitPlacements(GetGameMap(), Squads[0], seed1, seed2)
    LoadLevelAudio()
    squad_team_num = 2
end

function GameOverseer.StartGame()
    global_turns = 1
    GameOverseer.DoTurnStart()
end

return GameOverseer