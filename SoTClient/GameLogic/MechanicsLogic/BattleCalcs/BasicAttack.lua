local stat_calcs = require "SoTClient.GameLogic.MechanicsLogic.BattleCalcs.StatCalcs"
local infusion = require "SoTClient.GameLogic.MechanicsLogic.InfusionSystem.Infusion"

local BasicAttack = {}

local base_attack_skill = {}

base_attack_skill["Element"] = nil
base_attack_skill["DmgBase"] = 10
base_attack_skill["DmgIncrement"] = {"Str", 1.5}
base_attack_skill["Element"] = {}


function BasicAttack.doAttack(atk_char, def_char)
    local top_infusion = infusion.checkTopInfusion(def_char["Infusion"])

    if top_infusion ~= nil then
        if top_infusion["Type"] == "Elemental" then
            infusion.removeInfusion(def_char["Infusion"])
            atk_char["Essence"] = atk_char["Essence"] + 10
        end
    end

    local base_attack_damage = DamageSkillCalculation(base_attack_skill, atk_char, def_char)
    print(atk_char["Actor"] .. " attacked " .. def_char["Actor"] .. " for " .. base_attack_damage .. " damage.\n")

    return base_attack_damage
end

return BasicAttack