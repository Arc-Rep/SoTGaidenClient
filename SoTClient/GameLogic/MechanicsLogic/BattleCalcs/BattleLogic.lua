
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


function PerformSkill(game_map, atk_char, def_char, skill)
    local base_attack_damage = DamageSkillCalculation(skill, atk_char, def_char)

    print(atk_char["Actor"] .. " attacked " .. def_char["Actor"] .. " for " .. base_attack_damage .. " damage.\n")

    ApplyDamage(game_map, def_char, base_attack_damage)
end