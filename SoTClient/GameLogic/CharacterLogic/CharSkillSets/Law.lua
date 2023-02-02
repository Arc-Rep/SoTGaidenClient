local Law = {}

local DEFAULT_STREAK_NUM = 3

local function PrepareStreakElement(streak, options, targets_left)
    local streak_elem
    streak_elem["Focus"]             = "Enemy"
    streak_elem["Element"]           = "Light"
    streak_elem["Range"]             = 3
    streak_elem["TargetType"]        = "Omni"
    streak_elem["FocusType"]         = "Char"
    streak_elem["AuraRadius"]        = 0
    streak_elem["DmgBase"]           = 10 - (DEFAULT_STREAK_NUM - targets_left) * 2
    streak_elem["DmgIncrement"]      = {Mag = 0.5, Skl = 0.2}
    streak_elem["CritMod"]           = 0.2
    if(targets_left ~= 1) then 
        streak_elem["SequenceCriteria"]  = {SeekRange = 3}
    end 
    table.insert(streak, streak_elem, #streak + 1)

    if(targets_left ~= 1) then
        return PrepareStreakElement(streak, options, targets_left - 1)
    end
end

local function PrepareDivineStreak(skill, modifiers)
    local streak
    PrepareStreakElement(streak, modifiers)
    skill["Data"] = streak
    skill["Modifiers"] = modifiers
end

local function PrepareBlindingWisp(skill, modifiers)
    local blinding_wisp
    blinding_wisp["Focus"]          = "Enemy"
    blinding_wisp["Element"]        = "Light"
    blinding_wisp["Range"]          = 5
    blinding_wisp["TargetType"]     = "Omni"
    blinding_wisp["FocusType"]      = "Tile"
    blinding_wisp["DmgBase"]        = 15
    blinding_wisp["AuraRadius"]     = 1
    blinding_wisp["AuraType"]       = "Omni"
    blinding_wisp["AuraDmg"]        = blinding_wisp["DmgBase"]
    blinding_wisp["DmgIncrement"]   = {Mag = 0.8}
    blinding_wisp["CritMod"]        = 0.3
    skill["Data"] = blinding_wisp
    skill["Modifiers"] = modifiers
end

local function PrepareHolyExtermination(skill, modifiers)
    local holy_extermination
    holy_extermination["Focus"]         = "Enemy"
    holy_extermination["Element"]       = "Light"
    holy_extermination["TargetType"]    = "Self"
    holy_extermination["FocusType"]     = "NULL"
    holy_extermination["DmgBase"]       = 20
    holy_extermination["AuraRadius"]    = 2
    holy_extermination["AuraType"]      = "Omni"
    holy_extermination["AuraDmg"]       = 20
    holy_extermination["DmgIncrement"]  = {Mag = 1}
    holy_extermination["CritMod"]       = 0.4
end


function InitializeChar(char, options)

    local skill_1, skill_2, skill_3, ultimate = {}, {}, {}, {}

    skill_1["Name"]     = "Divine Streak"
    skill_2["Name"]     = "Blinding Wisp"
    skill_3["Name"]     = "Holy Extermination"
    ultimate["Name"]    = "Mirror Shift"

    PrepareDivineStreak(skill_1, options["Skill1"])

    char["Skill1"] = skill_1
    char["Skill2"] = skill_2
    char["Skill3"] = skill_3
    char["Skill4"] = ultimate
end


return Law