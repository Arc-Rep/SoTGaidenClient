

BATTLE_DEFENCES = {}
BATTLE_DEFENCES["Str"] = "Def"
BATTLE_DEFENCES["Mag"] = "Res"


function DamageSkillCalculation(skill, dmg_type, atk_char, def_char)
    local damage_total = 0
    
    if skill[dmg_type] == nil or skill["DmgIncrement"] == nil then
       return "Error: Could not read skill" 
    end

    for i = 1, skill["DmgIncrement"], 2 do
        local base_damage = skill["DmgBase"] + atk_char[skill["DmgIncrement"][i]] * skill["DmgIncrement"][i + 1]
        local base_damage_ward = def_char[BATTLE_DEFENCES[atk_char[skill]["DmgIncrement"][i]]]
        damage_total = damage_total + (base_damage - base_damage_ward)
    end

    local elem_res = 0

    for i = 1, skill["Element"], 1 do
        elem_res = elem_res + def_char["elem_res"][skill["Element"]]
    end

    elem_res = elem_res / #skill["Element"]

    if elem_res >= 1 then
        return 1
    end

    return damage_total * (1 - elem_res)
end