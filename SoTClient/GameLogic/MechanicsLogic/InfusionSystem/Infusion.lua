
local Infusion = {}

local INFUSION_MAX_ELEMENTS = 3

function Infusion.setup()
    local char_infusion = {}
    char_infusion.ElementQueue = {}
    for i = 1, INFUSION_MAX_ELEMENTS, 1 do
        char_infusion.ElementQueue[i] = nil
    end
    return char_infusion
end

function Infusion.addInfusion(char_infusion, new_infusion)

    if #char_infusion.ElementQueue == INFUSION_MAX_ELEMENTS then
        for i = INFUSION_MAX_ELEMENTS, 2, -1 do
            char_infusion.ElementQueue[i] = char_infusion.ElementQueue[i - 1]
        end
        char_infusion.ElementQueue[1] = new_infusion

    elseif #char_infusion.ElementQueue < INFUSION_MAX_ELEMENTS then
        char_infusion.ElementQueue[#char_infusion.ElementQueue + 1] = new_infusion
    else
        print("Error: Infuse surpassed maximum index")
    end
end

function Infusion.removeInfusion(char_infusion)

    if #char_infusion.ElementQueue == 0 then
        return 
    end

    local infusion_elements = #char_infusion.ElementQueue

    for i = 2, infusion_elements, 1 do
        char_infusion.ElementQueue[i-1] = char_infusion.ElementQueue[i]
    end
end

function Infusion.checkTopInfusion(char_infusion)
    if #char_infusion.ElementQueue == 0 then
        return nil
    end

    local retrieved_infusion = char_infusion.ElementQueue[1]

    return retrieved_infusion
end

function Infusion.retrieveInfusion(char_infusion)

    local retrieved_infusion = Infusion.checkTopInfusion(char_infusion)
    
    Infusion.removeInfusion(char_infusion)

    return retrieved_infusion
end

function Infusion.checkTurnEndEssenceTrigger(map, char)
    local char_infusion = char["Infusion"]

    for i = 1, #char_infusion.ElementQueue, 1 do
        if char_infusion.ElementQueue[i].Trigger == "TurnEnd" then
            char_infusion.ElementQueue[i].Effect(map, char)
        end
    end

    return retrieved_statuses
end

function Infusion.checkBeforeAttackEssenceTrigger(map, atk_char, attack)
    local char_infusion = atk_char["Infusion"]

    for i = 1, #char_infusion.ElementQueue, 1 do
        if char_infusion.ElementQueue[i].Trigger == "BeforeAttack" then
            char_infusion.ElementQueue[i].Effect(map, atk_char, attack)
        end
    end

    return retrieved_statuses
end

function Infusion.checkOnAttackReceiveTrigger(map, def_char, attack)
    local char_infusion = def_char["Infusion"]

    for i = 1, #char_infusion.ElementQueue, 1 do
        if char_infusion.ElementQueue[i].Trigger == "OnAttackReceive" then
            char_infusion.ElementQueue[i].Effect(map, def_char, attack)
        end
    end

    return retrieved_statuses
end

function Infusion.checkTurnEndTrigger(map, character)
    local char_infusion = character["Infusion"]

    for i = 1, #char_infusion.ElementQueue, 1 do
        if char_infusion.ElementQueue[i].Trigger == "TurnEnd" then
            char_infusion.ElementQueue[i].Effect(map, character)
        end
    end

    return retrieved_statuses
end

return Infusion