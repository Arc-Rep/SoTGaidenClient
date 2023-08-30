
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
    print(char["Actor"] .. " suffered " .. damage .. " damage!")
    if(damage > char["currentHP"]) then
        char["currentHP"] = 0
        KillCharacter(game_map, char)
        print(char["Actor"] .. " killed!")
    else
        char["currentHP"] = char["currentHP"] - damage
    end

    if(char["HPBar"] ~= nil and char["HPText"] ~= nil) then
        CombatUI.setHP(char)
    end
end


function GetOmniSkillMapRange(map, atk_char, skill)

    local skill_x_start, skill_y_start, skill_x_end, skill_y_end = 
        MapUtils.CheckValidMapRange(
            map,
            atk_char["x"] - skill["Range"],
            atk_char["y"] - skill["Range"],
            atk_char["x"] + skill["Range"],
            atk_char["y"] + skill["Range"]
        )

    local skill_range_tile_list = {{x = atk_char["x"], y = atk_char["y"]}}

    local SightedTiles = {}
    SightedTiles[atk_char["x"]] = {}
    SightedTiles[atk_char["x"]][atk_char["y"]] = true 

    local current_range = 1
    
    while (current_range <= skill["Range"]) do
        for idx = -current_range, current_range, 1 do
            lower_y, upper_y = 
                atk_char["y"] + (current_range - math.abs(idx)),
                atk_char["y"] - (current_range - math.abs(idx))

            current_x = atk_char["x"] + idx

            x_char_dir, y_char_dir = 
                MapUtils.CheckGeneralDirection(current_x, upper_y, atk_char["x"], atk_char["y"])

            if (not(current_x < skill_x_start or current_x > skill_x_end) and
                SightedTiles[current_x + x_char_dir] ~= nil) 
            then
                -- upper corner
                if (
                    SightedTiles[current_x + x_char_dir][upper_y + y_char_dir] == true
                    and upper_y >= skill_y_start and map[current_x][upper_y]["Tile"] ~= 0
                ) then
                    
                    if (SightedTiles[current_x] == nil) then
                        SightedTiles[current_x] = {}
                    end

                    SightedTiles[current_x][upper_y] = true
                    table.insert(skill_range_tile_list, {x = current_x, y = upper_y})
                end

                x_char_dir, y_char_dir = MapUtils.CheckGeneralDirection(current_x, lower_y, atk_char["x"], atk_char["y"])

                -- lower corner (provided it is different from upper)
                if (
                    SightedTiles[current_x + x_char_dir][lower_y + y_char_dir] == true
                    and lower_y <= skill_y_end and lower_y ~= upper_y
                    and map[current_x][lower_y]["Tile"] ~= 0
                ) then

                    if (SightedTiles[current_x] == nil) then
                        SightedTiles[current_x] = {}
                    end

                    SightedTiles[current_x][lower_y] = true
                    table.insert(skill_range_tile_list, {x = current_x, y = lower_y})

                end
            end

        end
        
        current_range = current_range + 1
    end

    return skill_range_tile_list
end


function GetSkillMapRange(map, atk_char, skill)

    if(skill["TargetType"] == "Omni") then
        return GetOmniSkillMapRange(map, atk_char, skill)
    end

    local skill_range_tile_list = {{x = atk_char["x"], y = atk_char["y"]}}

    if (skill["TargetType"] == "Self") then
        return skill_range_tile_list
    end

    local skill_x_start, skill_y_start, skill_x_end, skill_y_end = 
        MapUtils.CheckValidMapRange(
            map,
            atk_char["x"] - skill["Range"],
            atk_char["y"] - skill["Range"],
            atk_char["x"] + skill["Range"],
            atk_char["y"] + skill["Range"]
        )
            
    --print(atk_char["x"])
    --print(atk_char["y"])

    if(
        skill["TargetType"] == "Horizontal" or skill["TargetType"] == "Rook" or skill["TargetType"] == "Star"
    ) then
        
        for x = atk_char["x"] - 1, skill_x_start, -1 do
            if (LOR(map[x][atk_char["y"]]["Tile"] == 0,
                function() return LAND(
                    skill["Blockable"] == true and map[x][atk_char["y"]]["Actor"] ~= "",
                    function() 
                        local is_enemy = MapUtils.CheckIfEnemy(atk_char, map[x][atk_char["y"]]["Actor"])
                        if (is_enemy == true) then
                            table.insert(skill_range_tile_list, {x = x, y = atk_char["y"]})
                        end
                        return is_enemy
                    end) 
                end)
            ) then
                break
            else
                table.insert(skill_range_tile_list, {x = x, y = atk_char["y"]})
            end
        end

        for x = atk_char["x"] + 1, skill_x_end, 1 do
            if (LOR(map[x][atk_char["y"]]["Tile"] == 0,
                function() return LAND(
                    skill["Blockable"] == true and map[x][atk_char["y"]]["Actor"] ~= "",
                    function() 
                        local is_enemy = MapUtils.CheckIfEnemy(atk_char, map[x][atk_char["y"]]["Actor"])
                        if (is_enemy == true) then
                            table.insert(skill_range_tile_list, {x = x, y = atk_char["y"]})
                        end
                        return is_enemy
                    end) 
                end)
            ) then
                break
            else
                table.insert(skill_range_tile_list, {x = x, y = atk_char["y"]})
            end
        end
    end

    if(skill["TargetType"] == "Vertical" or skill["TargetType"] == "Rook" or skill["TargetType"] == "Star"
    ) then

        for y = atk_char["y"] - 1, skill_y_start, -1 do
            if (LOR(map[atk_char["x"]][y]["Tile"] == 0,
                function() return LAND(
                    skill["Blockable"] == true and map[atk_char["x"]][y]["Actor"] ~= "",
                    function() 
                        local is_enemy = MapUtils.CheckIfEnemy(atk_char, map[atk_char["x"]][y]["Actor"])
                        if (is_enemy == true) then
                            table.insert(skill_range_tile_list, {x = atk_char["x"], y = y})
                        end
                        return is_enemy
                    end) 
                end)
            ) then
                break
            else
                table.insert(skill_range_tile_list, {x = atk_char["x"], y = y})
            end
        end

        for y = atk_char["y"] + 1, skill_y_end, 1 do
            if (LOR(map[atk_char["x"]][y]["Tile"] == 0,
                function() return LAND(
                    skill["Blockable"] == true and map[atk_char["x"]][y]["Actor"] ~= "",
                    function() 
                        local is_enemy = MapUtils.CheckIfEnemy(atk_char, map[atk_char["x"]][y]["Actor"])
                        if (is_enemy == true) then
                            table.insert(skill_range_tile_list, {x = atk_char["x"], y = y})
                        end
                        return is_enemy
                    end) 
                end)
            ) then
                break
            else
                table.insert(skill_range_tile_list, {x = atk_char["x"], y = y})
            end
        end
    end

    if(skill["TargetType"] == "Star" or skill["TargetType"] == "Diagonal") then

        local extremes = {}
        local x_dir, y_dir

        table.insert(extremes, 0, math.min(atk_char["x"] - skill_x_start, atk_char["y"] - skill_y_start))
        table.insert(extremes, 1, math.min(skill_x_end - atk_char["x"], atk_char["y"] - skill_y_start))
        table.insert(extremes, 2, math.min(atk_char["x"] - skill_x_start, skill_y_end - atk_char["y"]))
        table.insert(extremes, 3, math.min(skill_x_end - atk_char["x"], skill_y_end - atk_char["y"]))

        for dir = 0, #extremes, 1 do
            if (dir % 2 == 0) then
                x_dir = -1
            else
                x_dir = 1
            end

            if(dir >= 2) then
                y_dir = 1
            else
                y_dir = -1
            end

            for dist = 1, extremes[dir], 1 do
                x_diagonal, y_diagonal = atk_char["x"] + x_dir * dist, atk_char["y"] + y_dir * dist
                if (LOR(map[x_diagonal][y_diagonal]["Tile"] == 0,
                    function() return LAND(
                        skill["Blockable"] == true and map[x_diagonal][y_diagonal]["Actor"] ~= "",
                        function() 
                            local is_enemy = MapUtils.CheckIfEnemy(atk_char, map[x_diagonal][y_diagonal]["Actor"])
                            if (is_enemy == true) then
                                table.insert(skill_range_tile_list, {x = x_diagonal, y = y_diagonal})
                            end
                            return is_enemy
                        end) 
                    end)
                ) then
                    break
                else
                    table.insert(skill_range_tile_list, {x = x_diagonal, y = y_diagonal})
                end
            end
        end
    end

    return skill_range_tile_list
end

function PerformSkill(game_map, atk_char, def_char, skill)

    skill["Modifiers"] = {}

    Infusion.checkBeforeAttackEssenceTrigger(map, atk_char, skill)

    Infusion.checkOnAttackReceiveTrigger(map, def_char, skill)

    if(LAND(skill["Accuracy"] ~= "Always", function () return CalculateHitOrMiss(skill) == false end)) then --in case of a miss
        print("You missed!")
        return true
    end

    local base_attack_damage = DamageSkillCalculation(skill, atk_char, def_char)

    ApplyDamage(game_map, def_char, base_attack_damage)

    return true
end