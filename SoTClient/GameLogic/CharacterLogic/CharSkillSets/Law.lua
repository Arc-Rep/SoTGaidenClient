local Law = {}

local DEFAULT_STREAK_NUM = 3

local function PrepareMirrorShift(mirror_shift, modifiers)

    mirror_shift["Focus"]           = "Enemy"
    mirror_shift["Element"]         = {}
    mirror_shift["Range"]           = 4
    mirror_shift["TargetType"]      = "Omni"
    mirror_shift["FocusType"]       = "Enemy"
    mirror_shift["DmgBase"]         = 12
    mirror_shift["DmgIncrement"]   = {"Mag", 1.5}
end

local function PrepareStreakElement(streak, options, targets_left)

    streak["Focus"]             = "Enemy"
    streak["Element"]           = {"Light"}
    streak["Range"]             = 3
    streak["TargetType"]        = "Omni"
    streak["FocusType"]         = "Char"
    streak["AuraRadius"]        = 0
    streak["DmgBase"]           = 10 - (DEFAULT_STREAK_NUM - targets_left) * 2
    streak["DmgIncrement"]      = {"Mag", 0.5, "Skl", 0.2}
    streak["CritMod"]           = {0.2}
    if(targets_left ~= 1) then 
        streak["SequenceCriteria"]  = {"SeekRange", 3}
    end

    if(targets_left ~= 1) then
        streak["Next"] = {}
        PrepareStreakElement(streak["Next"], options, targets_left - 1)
    end

    return streak
end

local function PrepareDivineStreak(streak, modifiers)

    PrepareStreakElement(streak, modifiers, DEFAULT_STREAK_NUM)

    streak["Modifiers"] = modifiers
end

local function PrepareBlindingWisp(blinding_wisp, modifiers)

    blinding_wisp["Focus"]          = "Enemy"
    blinding_wisp["Element"]        = {"Light"}
    blinding_wisp["Range"]          = 5
    blinding_wisp["TargetType"]     = "Omni"
    blinding_wisp["FocusType"]      = "Tile"
    blinding_wisp["DmgBase"]        = 15
    blinding_wisp["AuraRadius"]     = 1
    blinding_wisp["AuraType"]       = "Omni"
    blinding_wisp["AuraDmg"]        = blinding_wisp["DmgBase"]
    blinding_wisp["DmgIncrement"]   = {"Mag", 0.8}
    blinding_wisp["CritMod"]        = {0.3}

    blinding_wisp["Modifiers"] = modifiers

end

local function PrepareHolyExtermination(holy_extermination, modifiers)

    holy_extermination["Focus"]         = "Enemy"
    holy_extermination["Element"]       = {"Light"}
    holy_extermination["TargetType"]    = "Self"
    holy_extermination["Range"]         = 0
    holy_extermination["DmgBase"]       = 20
    holy_extermination["AuraRadius"]    = 2
    holy_extermination["AuraType"]      = "Omni"
    holy_extermination["AuraDmg"]       = 20
    holy_extermination["DmgIncrement"]  = {"Mag", 1}
    holy_extermination["CritMod"]       = {0.4}

end


function Law.InitializeChar(char, options)

    local skill_1, skill_2, skill_3, ultimate = {}, {}, {}, {}

    PrepareDivineStreak(skill_1, {})
    skill_1["Name"]     = "Divine Streak"

    PrepareBlindingWisp(skill_2, {})
    skill_2["Name"]     = "Blinding Wisp"
    
    PrepareHolyExtermination(skill_3, {})
    skill_3["Name"]     = "Holy Extermination"

    PrepareMirrorShift(ultimate, {})
    ultimate["Name"]    = "Mirror Shift"

    --PrepareDivineStreak(skill_1, options["Skill1"])

    char["Skill1"] = skill_1
    char["Skill2"] = skill_2
    char["Skill3"] = skill_3
    char["Skill4"] = ultimate
end


return Law