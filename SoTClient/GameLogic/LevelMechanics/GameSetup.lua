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
    
    
    Squads[unit1["Team"]] = {}
    table.insert(unit_table, unit1)
    table.insert(unit_table, unit2)
    table.insert(Squads[unit1["Team"]], unit1)
    table.insert(Squads[unit1["Team"]], unit2)

    GameSetup.SetupEnemyUnits(game_map, unit_table, Squads, 1
)
end

function GameSetup.SetupEnemyUnits(game_map, unit_table, Squads, difficulty)
    local map_enemy_number = levelgen.generateRandomBetween(difficulty * 3, difficulty * 5)
    local current_difficulty = (map_enemy_number - difficulty * 3)  / difficulty * 2;

    Squads[0] = {}

    for enemy_index = 1, map_enemy_number, 1 do
        local enemy_unit = {}
        enemy_unit["Actor"] = "Enemy"
        enemy_unit["ID"] = "-" .. enemy_index
        enemy_unit["Status"] = "Standby"
        enemy_unit["Team"] = 0
        enemy_unit["ControlType"] = "CPU-H"
        enemy_unit["Focus"] = nil
        enemy_unit["Str"] = 3
        enemy_unit["Def"] = 1
        enemy_unit["Res"] = 3
        enemy_unit["elem_res"] = {}
        enemy_unit["elem_res"]["Light"] = 0.3
        enemy_unit["currentHP"] = 30

        table.insert(unit_table, enemy_unit)
        table.insert(Squads[enemy_unit["Team"]], enemy_unit)
    end
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