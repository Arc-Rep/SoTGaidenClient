
local math = require "math"

local MapUtils = require "SoTClient.GameLogic.Scenarios.MissionMapUtils"
local Infusion = require "SoTClient.GameLogic.MechanicsLogic.InfusionSystem.Infusion"
local Essence  = require "SoTClient.GameLogic.MechanicsLogic.InfusionSystem.Essence"
local StatCals = require "SoTClient.GameLogic.MechanicsLogic.BattleCalcs.StatCalcs"
local CombatUI = require "SoTClient.Visuals.UI.CombatUI"
local LazyEval = require "SoTClient.Utils.LazyEval"
local Audio    = require "SoTClient.Audio.AudioHandler"

function KillCharacter(game_map, char)
    game_map[char["x"]][char["y"]]["Actor"] = nil
    char["x"] = nil
    char["y"] = nil
end

function ApplyDamage(game_map, char, damage)
    print(char["Actor"] .. " suffered " .. damage .. " damage!")
    if(damage >= char["currentHP"]) then
        char["currentHP"] = 0
        KillCharacter(game_map, char)
        PlayLevelAudio("slash_kill.wav")
        print(char["Actor"] .. " killed!")
    else
        PlayLevelAudio("slash.wav")
        char["currentHP"] = char["currentHP"] - damage
    end

    if(char["HPBar"] ~= nil and char["HPText"] ~= nil) then
        CombatUI.setHP(char)
    end
end

function CheckValidTarget(map, atk_char, skill, target_x, target_y)

    
    if (map[target_x][target_y]["Actor"] ~= nil) then
        if (LAND(skill["Focus"] == "Enemy", function () return map[target_x][target_y]["Actor"]["Team"] ~= atk_char["Team"] end)) then
            return true
        elseif (LAND(skill["Focus"] == "Ally", function () return map[target_x][target_y]["Actor"]["Team"] ~= atk_char["Team"] end)) then
            return true
        elseif (LAND(skill["Focus"] == "Self", function () return target_x == atk_char["x"] and target_y == atk_char["y"] end)) then
            return true
        end
    end

    return false
end


function GetOmniSkillMapRange(map, atk_char, skill)

    local skill_x_start, skill_y_start, skill_x_end, skill_y_end = 
        CheckValidMapRange(
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
                CheckGeneralDirection(current_x, upper_y, atk_char["x"], atk_char["y"])

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

                x_char_dir, y_char_dir = CheckGeneralDirection(current_x, lower_y, atk_char["x"], atk_char["y"])

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


function GetSkillMapRange(map, atk_char, skill) -- change atk_char to atk_origin

    if(skill["TargetType"] == "Omni") then
        return GetOmniSkillMapRange(map, atk_char, skill)
    end

    local skill_range_tile_list = {{x = atk_char["x"], y = atk_char["y"]}}

    if (skill["TargetType"] == "Self") then
        return skill_range_tile_list
    end

    local skill_x_start, skill_y_start, skill_x_end, skill_y_end = 
        CheckValidMapRange(
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
                    skill["Blockable"] == true and map[x][atk_char["y"]]["Actor"] ~= nil,
                    function()
                        if (CheckValidTarget(map, atk_char, skill, x, atk_char["y"]) == true) then
                            table.insert(skill_range_tile_list, {x = x, y = atk_char["y"]})
                        end
                        return true
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
                    skill["Blockable"] == true and map[x][atk_char["y"]]["Actor"] ~= nil,
                    function() 
                        if (CheckValidTarget(map, atk_char, skill, x, atk_char["y"]) == true) then
                            table.insert(skill_range_tile_list, {x = x, y = atk_char["y"]})
                        end
                        return true
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
                    skill["Blockable"] == true and map[atk_char["x"]][y]["Actor"] ~= nil,
                    function() 
                        if (CheckValidTarget(map, atk_char, skill, atk_char["x"], y) == true) then
                            table.insert(skill_range_tile_list, {x = atk_char["x"], y = y})
                        end
                        return true
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
                    skill["Blockable"] == true and map[atk_char["x"]][y]["Actor"] ~= nil,
                    function() 
                        local is_valid_target = CheckValidTarget(map, atk_char, skill, atk_char["x"], y)
                        if (is_valid_target == true) then
                            table.insert(skill_range_tile_list, {x = atk_char["x"], y = y})
                        end
                        return true
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
                        skill["Blockable"] == true and map[x_diagonal][y_diagonal]["Actor"] ~= nil,
                        function() 
                            if (CheckValidTarget(map, atk_char, skill, x_diagonal, y_diagonal) == true) then
                                table.insert(skill_range_tile_list, {x = x_diagonal, y = y_diagonal})
                            end
                            return true
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