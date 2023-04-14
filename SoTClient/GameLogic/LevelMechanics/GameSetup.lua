local GameSetup = {}
local missionmaputils = require "SoTClient.GameLogic.Scenarios.MissionMapUtils"
local levelgen = require "SoTClient.GameLogic.Scenarios.LevelGen"
local Infusion = require "SoTClient.GameLogic.MechanicsLogic.InfusionSystem.Infusion"
local Law_SkillSet = require "SoTClient.GameLogic.CharacterLogic.CharSkillSets.Law"

function GameSetup.SetupPlayerUnits(unit_table, Squads)
    
    local unit1, unit2 = {}, {}
    unit1["Actor"] = "Law"
    unit1["ID"] = 92475
    unit1["Status"] = "Player"
    unit1["Focus"] = "Manual"
    unit1["Team"] = 1
    Law_SkillSet.InitializeChar(unit1, nil)
    -- temp stats for unit1 (to be removed)
    unit1["Str"] = 4
    unit1["Mag"] = 6
    unit1["Def"] = 2
    unit1["currentHP"] = 30
    unit1["ControlType"] = "Player"
    unit2["Actor"] = "Dylan"
    unit2["ID"] = 321475
    unit2["Status"] = "Follower"
    unit2["Focus"] = unit1
    unit2["Team"] = 1
    unit2["ControlType"] = "CPU-F"
    unit2["Str"] = 3
    unit2["Def"] = 1
    unit2["currentHP"] = 30

    local unitenemy1 = {}
    unitenemy1["Actor"] = "Enemy"
    unitenemy1["ID"] = -146
    unitenemy1["Status"] = "Standby"
    unitenemy1["Team"] = 0
    unitenemy1["ControlType"] = "CPU-H"
    unitenemy1["Focus"] = nil
    unitenemy1["Str"] = 3
    unitenemy1["Def"] = 1
    unitenemy1["Res"] = 3
    unitenemy1["elem_res"] = {}
    unitenemy1["elem_res"]["Light"] = 0.3
    unitenemy1["currentHP"] = 30
    
    
    Squads[unit1["Team"]] = {}
    table.insert(unit_table, unit1)
    table.insert(unit_table, unit2)
    table.insert(Squads[unit1["Team"]], unit1)
    table.insert(Squads[unit1["Team"]], unit2)

    Squads[unitenemy1["Team"]] = {}
    table.insert(unit_table, unitenemy1)
    table.insert( Squads[unitenemy1["Team"]], unitenemy1)
end

function GameSetup.SetupPlayerInitPlacements(game_map, player_units)

    local last_placement_x, last_placement_y = game_map["entrance_x"], game_map["entrance_y"]

    for k, character in ipairs(player_units) do
        character["Infusion"] = Infusion.setup()
        last_placement_x, last_placement_y = missionmaputils.FindClosestEmptySpace(game_map, last_placement_x, last_placement_y)
        game_map[last_placement_x][last_placement_y]["Actor"] = character
        character["x"] = last_placement_x
        character["y"] = last_placement_y
    end
end

function GameSetup.SetupEnemyInitPlacements(game_map, enemy_units, seed1, seed2)

    for index, enemy in ipairs(enemy_units) do
        enemy["Infusion"] = Infusion.setup()
        local chosen_room = game_map["rooms"][levelgen.generateRandomBetween(1, #game_map["rooms"])]
        --print("Chosen room has " .. chosen_room["columns"] .. " and " .. chosen_room["rows"])
        enemy["x"], enemy["y"] = 
            missionmaputils.FindClosestEmptySpace(game_map, 
                chosen_room["x"] + levelgen.generateRandomBetween(1, chosen_room["columns"]),
                chosen_room["y"] + levelgen.generateRandomBetween(1, chosen_room["rows"]))
        game_map[enemy["x"]][enemy["y"]]["Actor"] = enemy
    end
    
end

return GameSetup