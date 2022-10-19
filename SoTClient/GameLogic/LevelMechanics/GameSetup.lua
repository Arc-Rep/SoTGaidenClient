local GameSetup = {}

function GameSetup.SetupPlayerUnits(unit_table){

    unit1 = {}
    unit2 = {}
    unit1["Actor"] = "Law"
    unit1["Status"] = "Player"
    unit1["Focus"] = "Manual"
    unit1["Team"] = 1
    unit1["ControlType"] = "Player"
    unit2["Actor"] = "Dylan"
    unit2["Status"] = "Follower"
    unit2["Focus"] = unit1
    unit2["Team"] = 1
    unit2["ControlType"] = "CPU-F"

    unitenemy1 = {}
    unitenemy1["Actor"] = "Enemy"
    unitenemy1["Status"] = "Standby"
    unitenemy1["Team"] = -1
    unitenemy1["ControlType"] = "CPU-H"
    unitenemy1["Focus"] = nil
    
    unit_table.AddPlayerUnit(unit1)
    unit_table.AddPlayerUnit(unit2)

    unit_table.AddEnemyUnit(unitenemy1)
}

function SetupPlayerInitPlacements(game_map, player_units)

    local last_placement_x, last_placement_y = game_map["entrance_x"], game_map["entrance_y"]

    for k, character in ipairs(player_units) do
        last_placement_x, last_placement_y = FindClosestEmptySpace(game_map, last_placement_x, last_placement_y)
        game_map[last_placement_x][last_placement_y]["Actor"] = character
        player_units[k]["x"] = last_placement_x
        player_units[k]["y"] = last_placement_y
    end
end

function SetupEnemyInitPlacements(game_map, enemy_units, seed1, seed2)

    for index, enemy in ipairs(enemy_units) do
        local chosen_room = levelgen.generateRandomBetween(1, #game_map["rooms"])
        local enemy_x, enemy_y = 
            FindClosestEmptySpace(game_map, 
                chosen_room["x"] + levelgen.levelgengenerateRandomBetween(1, chosen_room["columns"]),
                chosen_room["y"] + levelgen.levelgengenerateRandomBetween(1, chosen_room["rows"]))
        game_map[enemy_x][enemy_y]["Actor"] = enemy
        
    end

end

return GameSetup