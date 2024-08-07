local Law = {}

local missionmaputils = require 'SoTClient.GameLogic.Scenarios.MissionMapUtils'
local movement = require 'SoTClient.GameLogic.MechanicsLogic.MapLogic.Movement'
local BattleLogic = require 'SoTClient.GameLogic.MechanicsLogic.BattleCalcs.BattleLogic'
local LevelGen = require "SoTClient.GameLogic.Scenarios.LevelGen"

local DEFAULT_STREAK_NUM = 3

local function PreparePiercingJudgement(piercing_judgement, modifiers)

    piercing_judgement["Focus"]           = "Enemy"
    piercing_judgement["Element"]         = {}
    piercing_judgement["Status"]          = "Feeble"
    piercing_judgement["Range"]           = 3
    piercing_judgement["TargetType"]      = "Star"
    piercing_judgement["FocusType"]       = "Enemy"
    piercing_judgement["DmgBase"]         = 12
    piercing_judgement["DmgIncrement"]    = {"Str", 0.5, "Mag", 1.5}
    piercing_judgement["Accuracy"]        = 1
    piercing_judgement["Blockable"]       = false
    piercing_judgement["Effect"]          = 
        function (map, char, focus_x, focus_y)
            local dist_x, dist_y = CheckGeneralDirection(char["x"], char["y"], focus_x, focus_y)
            for i = 1, piercing_judgement["Range"], 1 do

                local current_tile = map[char["x"] + dist_x * i][char["y"] + dist_y * i]

                if (current_tile ~= nil) then
                    if (current_tile["Actor"] ~= nil) then
                        if (CheckIfEnemy(char, current_tile["Actor"])) then
                            PerformSkill(map, char, current_tile["Actor"], piercing_judgement)
                        end
                    end
                end
            end
        end
end

local function PrepareStreakElement(streak)
    local streak_element = {}

    streak_element["Focus"]        = streak["Focus"]
    streak_element["Element"]      = streak["Element"]
    streak_element["Accuracy"]     = streak["Accuracy"]
    streak_element["Range"]        = streak["Range"]   
    streak_element["TargetType"]   = streak["TargetType"]  
    streak_element["FocusType"]    = streak["FocusType"]  
    streak_element["AuraRadius"]   = streak["AuraRadius"]    
    streak_element["DmgBase"]      = streak["DmgBase"]
    streak_element["Blockable"]    = streak["Blockable"] 
    streak_element["DmgIncrement"] = streak["DmgIncrement"]
    streak_element["CritMod"]      = streak["CritMod"]
    streak_element["Modifiers"]    = streak["Modifiers"]

    return streak_element
end

local function PrepareDivineStreak(streak, modifiers)
    streak["Modifiers"]         = modifiers
    streak["Focus"]             = "Enemy"
    streak["Element"]           = {"Light"}
    streak["Accuracy"]          = "Always"
    streak["Range"]             = 3
    streak["TargetType"]        = "Omni"
    streak["FocusType"]         = "Char"
    streak["AuraRadius"]        = 0
    streak["DmgBase"]           = 10
    streak["DmgIncrement"]      = {"Mag", 0.5, "Skl", 0.2}
    streak["Blockable"]         = "false"
    streak["CritMod"]           = {0.2}
    streak["EffectModifier"]    = 3
    streak["Effect"]            =
        function(map, char, focus_x, focus_y)

            PerformSkill(map, char, map[focus_x][focus_y]["Actor"], streak)

            local char_hit = {}

            char_hit["x"] = focus_x
            char_hit["y"] = focus_y

            local streak_hit = PrepareStreakElement(streak)

            for streak_index = 1, streak["EffectModifier"], 1 do
                streak_hit["DmgBase"] = streak_hit["DmgBase"] / ((streak_index - 1) * 2)
                
                if (streak["DmgBase"] < 1) then
                    break
                end

                local aura_tile_list = GetSkillMapRange(map, char_hit, streak)

                local enemy_list = {}
                
                for i = 1, #aura_tile_list, 1 do
                    
                    tile_x, tile_y = aura_tile_list[i]["x"], aura_tile_list[i]["y"]
                    tile = map[tile_x][tile_y]

                    if (LAND(
                            tile["Actor"] ~= nil and tile_x ~= char_hit["x"] and tile_y ~= char_hit["y"],
                            function() return CheckIfEnemy(char, tile["Actor"]) end
                        )
                    ) then
                        table.insert(enemy_list, tile["Actor"])
                    end
                end

                if (#enemy_list == 0) then
                    break
                end

                local char_chosen
                
                if (#enemy_list == 1) then
                    char_chosen = enemy_list[1]
                else
                    char_chosen = enemy_list[LevelGen.generateRandomBetween(1, #enemy_list)]
                end

                char_hit["x"] = char_chosen["x"]
                char_hit["y"] = char_chosen["y"]
            end
        end

    return streak
end

local function PrepareWeightOfTheUndaunted(weight_of_the_undaunted, modifiers)
    -- Add effect range and stun
    weight_of_the_undaunted["Focus"]          = "Enemy"
    weight_of_the_undaunted["Element"]        = {"Light"}
    weight_of_the_undaunted["Range"]          = 3
    weight_of_the_undaunted["EffectRange"]    = 2
    weight_of_the_undaunted["TileClear"]      = "EnemyPrevious"
    weight_of_the_undaunted["TargetType"]     = "Star"
    weight_of_the_undaunted["FocusType"]      = "Enemy"
    weight_of_the_undaunted["DmgBase"]        = 10
    weight_of_the_undaunted["DmgIncrement"]   = {"Str", 2.0}
    weight_of_the_undaunted["Blockable"]      = true
    weight_of_the_undaunted["Accuracy"]       = 1
    weight_of_the_undaunted["Effect"]         = 
        function (map, char, focus_x, focus_y)
            local dist_x, dist_y = CheckGeneralDirection(char["x"], char["y"], focus_x, focus_y)
            local current_tile_x, current_tile_y = focus_x, focus_y
            local current_tile = nil
            local char_hit = map[focus_x][focus_y]["Actor"]

            MoveCharacterTo(map, char, focus_x - dist_x, focus_y - dist_y)
            PerformSkill(map, char, char_hit, weight_of_the_undaunted)

            if (char_hit["currentHP"] == 0) then
                return
            end

            local weight_impact = {}

            weight_impact["DmgBase"]      = weight_of_the_undaunted["DmgBase"] / 2
            weight_impact["DmgIncrement"] = {"Str", 2.0}
            weight_impact["Accuracy"]     = "Always"
            weight_impact["Element"]      = {}

            for i = 1, weight_of_the_undaunted["Range"], 1 do
                
                current_tile_x, current_tile_y = current_tile_x + dist_x, current_tile_y + dist_y
                current_tile = map[current_tile_x][current_tile_y]

                if LOR(current_tile == nil, function() return current_tile["Tile"] == 0 end) then
                    MoveCharacterTo(map, char_hit, current_tile_x - dist_x, current_tile_y - dist_y)
                    break
                end

                if (current_tile["Actor"] ~= nil) then
                    MoveCharacterTo(map, char_hit, current_tile_x - dist_x, current_tile_y - dist_y)
                    PerformSkill(map, char, current_tile["Actor"], weight_impact)

                    if (current_tile["Actor"]["currentHP"] == 0) then
                        return
                    end

                    weight_impact["DmgBase"] = weight_impact["DmgBase"] / 2
                    char_hit = current_tile["Actor"]
                    i = i + 1
                end

                if i == weight_of_the_undaunted["Range"] then
                    MoveCharacterTo(map, char_hit, current_tile_x, current_tile_y)
                end
            end
        end

    weight_of_the_undaunted["Modifiers"] = modifiers

end

local function PrepareHolyExtermination(holy_extermination, modifiers)

    local holy_extermination_aura = {}
    holy_extermination_aura["TargetType"]    = "Omni"
    holy_extermination_aura["Accuracy"]      = "Always"
    holy_extermination_aura["Range"]         = 2
    holy_extermination_aura["DmgBase"]       = 20
    holy_extermination_aura["DmgIncrement"]  = {"Mag", 1}
    holy_extermination_aura["CritMod"]       = {0.4}
    holy_extermination_aura["Element"]       = {"Light"}

    holy_extermination["Focus"]         = "Enemy"
    holy_extermination["TargetType"]    = "Self"
    holy_extermination["Aura"]          = holy_extermination_aura
    holy_extermination["Effect"]        =
        function (map, char, focus_x, focus_y)
            local aura_tile_list = GetSkillMapRange(map, char, holy_extermination_aura)
            while (#aura_tile_list ~= 0) do
                --By removing from the end, we are sure that enemies are pushed from the outside first
                local aura_tile = table.remove(aura_tile_list, #aura_tile_list)
                local tile = map[aura_tile["x"]][aura_tile["y"]]
                if (tile["Actor"] ~= nil) then
                    if (CheckIfEnemy(char, tile["Actor"]) == true) then
                        local enemy = tile["Actor"]
                        --Character is pushed backwards from the player's perspective
                        local dir_x, dir_y = CheckGeneralDirection(char["x"], char["y"], enemy["x"], enemy["y"])
                        PerformSkill(map, char, enemy, holy_extermination_aura)
                        if (
                            LAND(
                                not(CheckIfDead(enemy)),
                                function() 
                                    return CheckEmptySpace(map, enemy["x"] + dir_x, enemy["y"] + dir_y) == true
                                end
                            ) 
                        ) then
                            MoveCharacterTo(map, enemy, enemy["x"] + dir_x, enemy["y"] + dir_y)
                        end
                    end
                end
            end
        end
end


function Law.InitializeChar(char, options)

    local skill_1, skill_2, skill_3, ultimate = {}, {}, {}, {}

    PreparePiercingJudgement(skill_1, {})
    skill_1["Name"]     = "Piercing Judgement"

    PrepareDivineStreak(skill_2, {})
    skill_2["Name"]     = "Divine Streak"
    
    PrepareWeightOfTheUndaunted(skill_3, {})
    skill_3["Name"]     = "Weight of the Undaunted"

    PrepareHolyExtermination(ultimate, {})
    ultimate["Name"]    = "Holy Extermination"

    --PrepareDivineStreak(skill_1, options["Skill1"])

    char["Skill1"] = skill_1
    char["Skill2"] = skill_2
    char["Skill3"] = skill_3
    char["Skill4"] = ultimate
end


return Law