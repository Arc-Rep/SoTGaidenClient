local Law = {}

local DEFAULT_STREAK_NUM = 3

local function PrepareStreakElement(streak, options, targets_left)
    local streak_elem

    streak_elem["Element"]           = "light"
    streak_elem["Range"]             = 3
    streak_elem["TargetType"]        = "Omni"
    streak_elem["DmgBase"]           = 10
    streak_elem["DmgIncrement"]      = ["Mag", 0.5, "Skill", 0.2]
    streak_elem["CritMod"]           = [nil, 0.2]
    if(targets_left ~= 1) then 
        streak_elem["SequenceCriteria"]  = ["SeekRange", 3]

    table.insert(streak, streak_elem,#streak + 1)

    targets_left = targets_left - 1

    if(targets_left ~= 0) then
        return PrepareStreakElement(streak, options, targets_left)
    return
end

local function PrepareDivineStreak(skill, options)
    local streak = []

    if(options["TargetsHit"] == nil) then
        options["TargetsHit"] = DEFAULT_STREAK_NUM
    end

    PrepareStreakElement(streak, options, options["TargetsHit"])

    skill["Data"] = streak
    skill["Options"] = options
end

local function InitializeChar(char, options)

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