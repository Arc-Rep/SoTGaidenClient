

local Infusion = require "SoTClient.GameLogic.MechanicsLogic.InfusionSystem.Infusion"
local math = require "math"

BATTLE_DEFENCES = {}
BATTLE_DEFENCES["Str"] = "Def"
BATTLE_DEFENCES["Mag"] = "Res"


function DamageInfuseCalculation(skill_damage, atk_char, def_char)

    local infuse_element = Infusion.retrieveInfusion(atk_char["Infusion"])

    if infuse_element == nil then
        return 0
    end

    if infuse_element["Type"] == "Elemental" then
        local infusion_damage = damage_total * (1 - def_char["elem_res"][top_infusion["Name"]])
        if(infusion_damage < 1) then
            infusion_damage = 1
        end
        return math.floor(infusion_damage)
    end

    return 0
end

function DamageSkillCalculation(skill, atk_char, def_char)

    if skill["DmgBase"] == nil then
       return "Error: Could not read skill"
    end

    local base_dmg

    if(skill["Modifiers"]["DmgBase"] ~= nil) then
        base_dmg = skill["Modifiers"]["DmgBase"] * skill["DmgBase"]
    else
        base_dmg = skill["DmgBase"]
    end

    local damage_total = 0

    for i = 1, #skill["DmgIncrement"], 2 do
        print(base_dmg)
        print(skill["DmgIncrement"][i])
        print(skill["DmgIncrement"][i + 1])
        local damage_per_stat = base_dmg + atk_char[skill["DmgIncrement"][i]] * skill["DmgIncrement"][i + 1]
        local damage_ward_per_stat
        
        if (def_char[BATTLE_DEFENCES[skill["DmgIncrement"][i]]] == nil) then
            damage_ward_per_stat = 1
        else
            damage_ward_per_stat = 50 / (50 + def_char[BATTLE_DEFENCES[skill["DmgIncrement"][i]]])
        end

        damage_total = damage_total + (damage_per_stat * damage_ward_per_stat)
    end

    infusion_damage = DamageInfuseCalculation(damage_total, atk_char, def_char)

    if #skill["Element"] ~= 0 then
        
        local elem_res = 0

        for i = 1, #skill["Element"], 1 do
            elem_res = elem_res + def_char["elem_res"][skill["Element"][i]]
        end

        elem_res = elem_res / #skill["Element"]

        if elem_res >= 1 then
            damage_total = 1
        else
            damage_total = damage_total * (1 - elem_res)
        end
    end

    return math.floor(damage_total, infusion_damage)
end

function CalculateHitOrMiss(skill)

    local real_acc

    if(skill["Modifiers"]["Accuracy"] ~= nil) then
        real_acc = skill["Modifiers"]["Accuracy"] * skill["Accuracy"]
    else
        real_acc = skill["Accuracy"]
    end

    local skill_hit_value = math.random()

    if(skill_hit_value < real_acc) then
        return true
    end

    return false
end