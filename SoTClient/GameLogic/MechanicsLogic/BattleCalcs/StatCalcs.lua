

local Infusion = require "SoTClient.GameLogic.MechanicsLogic.InfusionSystem.Infusion"

BATTLE_DEFENCES = {}
BATTLE_DEFENCES["Str"] = "Def"
BATTLE_DEFENCES["Mag"] = "Res"


function DamageInfuseCalculation(skill_damage, atk_char, def_char)

    local infuse_element = Infusion.retrieveInfusion(atk_char["Infusion"])

    if infuse_element == nil then
        return 0
    end

    if infuse_element["Type"] == "Elemental" then
        return skill["DmgBase"] * (1 - def_char["elem_res"][infuse_element["Name"]])
    end
    
    return 0
end

function DamageSkillCalculation(skill, atk_char, def_char)
    local damage_total = 0
    
    if skill["DmgBase"] == nil then
       return "Error: Could not read skill" 
    end

    for i = 1, #skill["DmgIncrement"], 2 do
        local base_damage = skill["DmgBase"] + atk_char[skill["DmgIncrement"][i]] * skill["DmgIncrement"][i + 1]
        local base_damage_ward = def_char[BATTLE_DEFENCES[atk_char[skill]["DmgIncrement"][i]]]
        damage_total = damage_total + (base_damage - base_damage_ward)
    end

    local elem_res = 0

    for i = 1, #skill["Element"], 1 do
        elem_res = elem_res + def_char["elem_res"][skill["Element"]]
    end

    elem_res = elem_res / #skill["Element"]

    if elem_res >= 1 then
        damage_total = 1
    else 
        damage_total = damage_total * (1 - elem_res)
    end

    return damage_total
end

return Infusion