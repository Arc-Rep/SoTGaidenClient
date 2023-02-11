
local Infusion = {}

local INFUSION_MAX_ELEMENTS = 3

function Infusion.setup()
    Infusion.ElementQueue = {}
    for i = 1, INFUSION_MAX_ELEMENTS, 1 do
        Infusion.ElementQueue[i] = nil
    end
end

function Infusion.addInfusion(new_infusion)
    if #Infusion.ElementQueue == INFUSION_MAX_ELEMENTS then
        for i = INFUSION_MAX_ELEMENTS, 2, -1 do
            Infusion.ElementQueue[i] = Infusion.ElementQueue[i - 1]
        end
        Infusion.ElementQueue[1] = new_infusion

    elseif #Infusion.ElementQueue < INFUSION_MAX_ELEMENTS then
        Infusion.ElementQueue[#Infusion.ElementQueue + 1] = new_infusion
    else
        print("Error: Infuse surpassed maximum index")
    end
end

function Infusion.retrieveInfusion()
    if #Infusion.ElementQueue == 0 then
        return nil
    end

    local retrieved_infusion = Infusion.ElementQueue[1]
    local infusion_elements = #Infusion.ElementQueue

    for i = 2, infusion_elements, 1 do
        Infusion.ElementQueue[i-1] = Infusion.ElementQueue[i]
    end

    return retrieved_infusion
end

function Infusion.retrieveStatus()
    local retrieved_statuses = {}

    for i = 1, #Infusion.ElementQueue, 1 do
        if Infusion.ElementQueue[i].Type == "Status" then
            retrieved_statuses[#retrieved_statuses+1] = Infusion.ElementQueue[i]
        end
    end

    return retrieved_statuses
end

return Infusion