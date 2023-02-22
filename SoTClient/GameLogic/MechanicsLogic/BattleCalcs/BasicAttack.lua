local stat_calcs = require "SoTClient.GameLogic.MechanicsLogic.BattleCalcs.StatCalcs"
local infusion = require "SoTClient.GameLogic.MechanicsLogic.InfusionSystem.Infusion"
local battle_logic = require "SoTClient.GameLogic.MechanicsLogic.BattleCalcs.BattleLogic"

local BasicAttack = {}

local base_attack_skill = {}

base_attack_skill["DmgBase"] = 10
base_attack_skill["DmgIncrement"] = {"Str", 1.5}
base_attack_skill["Element"] = {}


function BasicAttack.doAttack(game_map, atk_char, def_char)
    local top_infusion = infusion.checkTopInfusion(def_char["Infusion"])

    if top_infusion ~= nil then
        if top_infusion["Type"] == "Elemental" then
            infusion.removeInfusion(def_char["Infusion"])
            atk_char["Essence"] = atk_char["Essence"] + 10
        end
    end

    PerformSkill(game_map, atk_char, def_char, base_attack_skill)

end

return BasicAttack