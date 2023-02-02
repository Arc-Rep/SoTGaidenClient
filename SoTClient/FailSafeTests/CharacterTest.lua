
local utils = require("SoTClient.Utils.GeneralUtils")

SKILL_FOCUS = {"Self", "Ally", "Enemy", "Tile", "Wall"}
SKILL_ELEMENTS = {"Light", "Dark", "Water", "Poison", "Blood"}
SKILL_TARGET_TYPE = {"Omni", "Self", "Line", "Horizontal", "Vertical", "Diagonal"}
SKILL_FOCUS_TYPE = {"Char", "Tile", "Wall", "NULL"}
SKILL_AURA_TYPE = {"Omni", "Line", "Horizontal", "Vertical", "Diagonal"}
SKILL_STAT_TYPES = {"Str", "Mag", "Skl", "Dex", "Luck"}


local function TestSkill(skill)

    if(skill["Data"] == nil) then
        return false
    end

    skill_data = skill["Data"]

    if(skill_data["Focus"] ~= nil) then
        if(util.contains(SKILL_FOCUS, skill_data["Focus"]) == false) then
            return false
        end
    else
        return false
    end

    if(skill_data["Element"] ~= nil) then
        if(util.contains(SKILL_ELEMENTS, skill_data["Element"]) == false) then
            return false
        end
    else
        return false
    end

    if(skill_data["TargetType"] ~= nil) then
        if(util.contains(SKILL_TARGET_TYPE, skill_data["TargetType"]) == false) then
            return false
        end
    else
        return false
    end

    if(skill_data["FocusType"] ~= nil) then
        if(util.contains(SKILL_FOCUS_TYPE, skill_data["FocusType"]) == false) then
            return false
        end
    else
        return false
    end

    if(skill_data["Range"] ~= nil) then
        if(skill_data["Range"] < 0) then
            return false
        end
        return false
    end

    if(skill_data["AuraRadius"] ~= nil) then
        if(skill_data["AuraRadius"] < 0) 
            return false
        elseif(skill_data["AuraRadius"] ~= 0 and skill_data["AuraType"] == nil) then
            return false
        elseif(util.contains(SKILL_AURA_TYPE, skill_data["AuraType"]) == false) then
            return false
        end
    else
        return false
    end

    if(#skill_data["DmgIncrement"] % 2 ~= 0) then
        return false
    for i = 1, #skill_data["DmgIncrement"], 2 do
        if(util.contains(SKILL_STAT_TYPE, skill_data["DmgIncrement"][i]) == false or type(skill_data["DmgIncrement"][i+1]) ~= "number") then
            return false
        end
    end

    if(#skill_data["CritMod"] % 2 ~= 1 or skill_data["CritMod"][1] ~= "number") then
        return false
    for i = 2, #skill_data["CritMod"], 2 do
        if(util.contains(SKILL_STAT_TYPE, skill_data["CritMod"][i]) == false or type(skill_data["CritMod"][i+1]) ~= "number") then
            return false
        end
    end

    return true
end