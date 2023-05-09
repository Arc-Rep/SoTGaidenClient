
local math = require "math"

local MapUtils = require "SoTClient.GameLogic.Scenarios.MissionMapUtils"
local Infusion = require "SoTClient.GameLogic.MechanicsLogic.InfusionSystem.Infusion"
local Essence = require "SoTClient.GameLogic.MechanicsLogic.InfusionSystem.Essence"
local StatCals = require "SoTClient.GameLogic.MechanicsLogic.BattleCalcs.StatCalcs"
local CombatUI = require "SoTClient.Visuals.UI.CombatUI"
local LazyEval = require "SoTClient.Utils.LazyEval"

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

    if(char["HPBar"] ~= nil and char["HPText"] ~= nil) then
        CombatUI.setHP(char)
    end
end

function GetSkillMapRange(map, atk_char, skill)
    local skill_range_tile_list = {}

    --print(skill["Name"])

    if (skill["TargetType"] == "Self") then
        return {{x = atk_char["x"], y = atk_char["y"]}}
    end

    local skill_x_start, skill_y_start, skill_x_end, skill_y_end = 
        MapUtils.CheckValidMapRange(
            map,
            atk_char["x"] - skill["Range"],
            atk_char["y"] - skill["Range"],
            atk_char["x"] + skill["Range"],
            atk_char["y"] + skill["Range"]
        )
        
    local relative_x = -skill["Range"]
    
    --print(atk_char["x"])
    --print(atk_char["y"])

    for x = skill_x_start, skill_x_end, 1 do
        local relative_y = -skill["Range"]

        for y = skill_y_start, skill_y_end, 1 do
            if(map[x][y]["Tile"] ~= 0) then
                if(relative_x == relative_y and skill["TargetType"] == "Diagonal") then
                    table.insert(skill_range_tile_list, {x = x, y = y})
                elseif(relative_x ~= 0 and relative_y == 0 and ((skill["TargetType"] == "Horizontal" or skill["TargetType"] == "Rook"))) then
                    table.insert(skill_range_tile_list, {x = x, y = y})
                elseif(relative_x == 0 and relative_y ~= 0 and ((skill["TargetType"] == "Vertical" or skill["TargetType"] == "Rook"))) then
                    table.insert(skill_range_tile_list, {x = x, y = y})
                elseif(math.abs(relative_x) + math.abs(relative_y) <= skill["Range"] and skill["TargetType"] == "Omni") then
                    table.insert(skill_range_tile_list, {x = x, y = y})
                end
            end

            relative_y = relative_y + 1
        end

        relative_x = relative_x + 1
    end

    return skill_range_tile_list
end

function PerformSkill(game_map, atk_char, def_char, skill)
    local base_attack_damage = DamageSkillCalculation(skill, atk_char, def_char)

    print(atk_char["Actor"] .. " attacked " .. def_char["Actor"] .. " for " .. base_attack_damage .. " damage.\n")

    ApplyDamage(game_map, def_char, base_attack_damage)

    if(atk_char["Class"] == "Berserker" and LAND(skill["Element"] ~= nil, function() return #skill["Element"] > 0 end)) then
        Infusion.addInfusion(atk_char["Infusion"], Essence[skill["Element"][1]])
        Infusion.addInfusion(def_char["Infusion"], Essence[skill["Element"][1]])
    end

    return true
end