local missionmaputils = require "SoTClient.GameLogic.Scenarios.MissionMapUtils"
local levelgen = require "SoTClient.GameLogic.Scenarios.LevelGen"
local Infusion = require "SoTClient.GameLogic.MechanicsLogic.InfusionSystem.Infusion"
local Law_SkillSet = require "SoTClient.GameLogic.CharacterLogic.CharSkillSets.Law"
local CharDatabase = require "SoTClient.GameLogic.CharacterLogic.CharDatabase"

function SetupPlayerUnits(unit_table, Squads)
    
    local unit1, unit2 = {}, {}
    unit1["Actor"] = "Law"
    unit1["ID"] = 92475
    unit1["Status"] = "Player"
    unit1["Focus"] = "Manual"
    unit1["Class"] = "Berserker"
    unit1["Team"] = 1
    Law_SkillSet.InitializeChar(unit1, nil)
    -- temp stats for unit1 (to be removed)
    unit1["Str"] = 4
    unit1["Mag"] = 6
    unit1["Def"] = 2
    unit1["Skl"] = 8
    unit1["maxHP"] = 35
    unit1["currentHP"] = unit1["maxHP"]
    unit1["maxEssence"] = 3
    unit1["currentEssence"] = unit1["maxEssence"]
    unit1["ControlType"] = "Player"
    unit2["Actor"] = "Dylan"
    unit2["ID"] = 321475
    unit2["Status"] = "Follower"
    unit2["Class"] = "Berserker"
    unit2["Focus"] = unit1
    unit2["Team"] = 1
    unit2["ControlType"] = "CPU-F"
    unit2["Str"] = 3
    unit2["Def"] = 1
    unit2["maxHP"] = 30
    unit2["currentHP"] = unit2["maxHP"]
    unit2["maxEssence"] = 3
    unit2["currentEssence"] = unit2["maxEssence"]
    
    
    Squads[unit1["Team"]] = {}
    table.insert(unit_table, unit1)
    table.insert(unit_table, unit2)
    table.insert(Squads[unit1["Team"]], unit1)
    table.insert(Squads[unit1["Team"]], unit2)

    SetupEnemyUnits(game_map, unit_table, Squads, 1)
end

function SetupEnemyUnits(game_map, unit_table, Squads, difficulty)
    local map_enemy_number = levelgen.generateRandomBetween(difficulty * 3, difficulty * 5)
    local current_difficulty = (map_enemy_number - difficulty * 3)  / difficulty * 2;

    Squads[0] = {}
    
    for enemy_index = 1, map_enemy_number, 1 do
        local enemy_unit = {}
        enemy_unit["ID"] = "-" .. enemy_index
        enemy_unit["Focus"] = nil
        enemy_unit["ControlType"] = "CPU-H"
        enemy_unit["Status"] = "Standby"
        enemy_unit["Team"] = 0 
        LoadCharacter("Coblyn", enemy_unit)
        table.insert(unit_table, enemy_unit)
        table.insert(Squads[enemy_unit["Team"]], enemy_unit)
    end
end


function SetupPlayerInitPlacements(game_map, player_units)

    local last_placement_x, last_placement_y = game_map["entrance_x"], game_map["entrance_y"]

    for k, character in ipairs(player_units) do
        character["Infusion"] = Infusion.setup()
        last_placement_x, last_placement_y = FindClosestEmptySpace(game_map, last_placement_x, last_placement_y)
        game_map[last_placement_x][last_placement_y]["Actor"] = character
        character["x"] = last_placement_x
        character["y"] = last_placement_y
    end
end

function SetupEnemyInitPlacements(game_map, enemy_units, seed1, seed2)

    for index, enemy in ipairs(enemy_units) do
        enemy["Infusion"] = Infusion.setup()
        local chosen_room = game_map["rooms"][levelgen.generateRandomBetween(1, #game_map["rooms"])]
        --print("Chosen room has " .. chosen_room["columns"] .. " and " .. chosen_room["rows"])
        enemy["x"], enemy["y"] = 
            FindClosestEmptySpace(game_map, 
                chosen_room["x"] + levelgen.generateRandomBetween(1, chosen_room["columns"]),
                chosen_room["y"] + levelgen.generateRandomBetween(1, chosen_room["rows"]))
        game_map[enemy["x"]][enemy["y"]]["Actor"] = enemy
    end
    
end

return GameSetup