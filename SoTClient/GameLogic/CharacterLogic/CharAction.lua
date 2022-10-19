local CharAction = {}

local missionmaputils = require "SoTClient.GameLogic.Scenarios.MissionMapUtils"
local follow = require "SoTClient.GameLogic.CharacterLogic.CharBehavior.CharFollow"
local missionmaputils = require "SoTClient.GameLogic.Scenarios.MissionMapUtils"

local function BehaviourHandler_Enemy(game_map, char_list, char)
    if(char["Status"] == "Standby") then
        local cur_room = missionmaputils.GetCurrentRoom(game_map, char["x"], char["y"])
        print(cur_room["x"] .. " is the current x")
        for index, char_i in ipairs(char_list) do
            if(char_i["Team"] > 0 and cur_room == missionmaputils.GetCurrentRoom(game_map, char_i["x"], char_i["y"])) then
                char["Status"] = "Follower"
                char["Focus"] = char_i
            end
        end
    end
end

local function BehaviourHandler_Ally()

end

function CharAction.DoMovement(game_map, char, m_up_down, m_left_right)
    local cur_tile, desired_tile = game_map[char["x"]][char["y"]],
                                    game_map[char["x"] + m_up_down][char["y"] + m_left_right]

    if(missionmaputils.CheckLegalMovement(game_map, char["x"], char["y"], m_up_down, m_left_right) == false) then
        return false
    end

    cur_tile["Actor"] = ""
    char["x"] = char["x"] + m_up_down
    char["y"] = char["y"] + m_left_right
    desired_tile["Actor"] = char

    return true
end

function CharAction.DoCharAction(map, unit_list,char)
    if(char["Team"] < 0) then
        BehaviourHandler_Enemy(map, unit_list, char)
    else
        BehaviourHandler_Ally()
    end

    if(char["Status"] == "Follower") then
        print("Data is " .. char["Focus"]["y"]) 
        CharAction.DoMovement(map, char, follow.DoFollow(map, char["x"], char["y"], char["Focus"]["x"], char["Focus"]["y"]))
    end
end

return CharAction