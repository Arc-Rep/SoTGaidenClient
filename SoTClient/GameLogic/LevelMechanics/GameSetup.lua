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
    
    unit_table.AddUnit(unit1)
    unit_table.AddUnit(unit2)
}

function SetupInitPlacements(game_map, player_units)

    local last_placement_x, last_placement_y = game_map["entrance_x"], game_map["entrance_y"]

    for k, character in ipairs(player_units) do
        last_placement_x, last_placement_y = FindClosestEmptySpace(game_map, last_placement_x, last_placement_y)
        game_map[last_placement_x][last_placement_y]["Actor"] = character
        player_units[k]["x"] = last_placement_x
        player_units[k]["y"] = last_placement_y
    end
end


return GameSetup