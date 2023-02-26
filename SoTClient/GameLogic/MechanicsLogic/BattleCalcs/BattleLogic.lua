
local math = require "math"

function KillCharacter(game_map, char)
    game_map[char["x"]][char["y"]]["Actor"] = ""
    char["x"] = nil
    char["y"] = nil
end

function ApplyDamage(game_map, char, damage)
    if(damage > char["currentHP"]) then
        char["currentHP"] = 0
        KillCharacter(game_map, char)
    else
        char["currentHP"] = char["currentHP"] - damage
    end
end

function GetSkillMapRange(map, atk_char, skill)
    local skill_range_tile_list = {}
    
    for x = -skill["Range"], skill["Range"], 1 do
        for y = -skill["Range"], skill["Range"], 1 do
            if(x == y and skill["TargetType"] == "Diagonal" and map["Tile"] == 1) then
                table.insert(skill_range_tile_list, {x = x, y = y})
            elseif(x ~= 0 and y == 0 and ((skill["TargetType"] == "Horizontal" or skill["TargetType"] == "Rook"))) then
                table.insert(skill_range_tile_list, {x = x, y = y})
            elseif(x == 0 and y ~= 0 and ((skill["TargetType"] == "Vertical" or skill["TargetType"] == "Rook"))) then
                table.insert(skill_range_tile_list, {x = x, y = y})
            elseif(math.abs(x) + math.abs(y) <= skill["Range"] and skill["TargetType"] == "Omni") then
                table.insert(skill_range_tile_list, {x = x, y = y})
            end
        end
    end

    return skill_range_tile_list
end

function PerformSkill(game_map, atk_char, def_char, skill)
    local base_attack_damage = DamageSkillCalculation(skill, atk_char, def_char)

    print(atk_char["Actor"] .. " attacked " .. def_char["Actor"] .. " for " .. base_attack_damage .. " damage.\n")

    ApplyDamage(game_map, def_char, base_attack_damage)

    return true
end