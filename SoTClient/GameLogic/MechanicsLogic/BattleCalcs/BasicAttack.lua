local stat_calcs = require "SoTClient.GameLogic.MechanicsLogic.BattleCalcs.StatCalcs"
local infusion = require "SoTClient.GameLogic.MechanicsLogic.InfusionSystem.Infusion"

local BasicAttack = {}

local base_attack_skill = {}

base_attack_skill["Element"] = nil
base_attack_skill["DmgBase"] = 10
base_attack_skill["DmgIncrement"] = {"Str", 1.5}


function BasicAttack.doAttack(atk_char, def_char)

    local dmg = stat_calcs.DamageSkillCalculation(base_attack_skill, atk_char, def_char)
    if infusion.checkTopInfusion(def_char["Infusion"])["Type"] == "Elemental" then
        infusion.removeInfusion(def_char["Infusion"])
        atk_char["Essence"] = atk_char["Essence"] + 10
    end

end

return BasicAttack