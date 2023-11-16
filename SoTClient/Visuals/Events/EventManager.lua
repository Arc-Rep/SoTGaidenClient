
local EventManager = {}

-- List of defines
EventManager.DRAG_MAP = 1
EventManager.UI = 2

local active_event_id = nil
local active_event = nil

function EventManager.SetActiveEvent(new_event_id, new_event_function)
    active_event_id = new_event_id
    active_event    = new_event_function
end

function EventManager.GetActiveEventID()
    return active_event_id
end

function EventManager.ReleaseActiveEvent()
    active_event_id = nil
    active_event    = nil
end

function EventManager.PerformEvent(event)
    active_event(event)

    if (event.phase == "ended") then
        EventManager.ReleaseActiveEvent()
    end

    return true
end

return EventManager