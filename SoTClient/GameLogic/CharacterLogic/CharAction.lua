local CharAction = {}

local missionmaputils = require "SoTClient.GameLogic.Scenarios.MissionMapUtils"
local follow = require "SoTClient.GameLogic.CharacterLogic.CharBehavior.CharFollow"

local function BehaviourHandler_Ally(game_map, char_list, char)
    if(char["Status"] == "Follower") then
        --print("Data is " .. char["Focus"]["y"])
        local move_x, move_y, steps = follow.DoFollow(game_map, char["x"], char["y"], char["Focus"]["x"], char["Focus"]["y"])
        if(move_x ~= nil and move_y ~= nil) then
            CharAction.DoMovement(game_map, char, move_x, move_y)
        end
    end
end

local function BehaviourHandler_Enemy(game_map, char_list, char)
    local move_x, move_y, steps, temp_move_x, temp_move_y, temp_steps = nil, nil, nil, nil, nil, nil
    local cur_room = missionmaputils.GetCurrentRoom(game_map, char["x"], char["y"])
    if(char["Status"] == "Standby" or char["Status"] == "Follower") then
        print(cur_room["x"] .. " is the current x")
        for index, char_i in ipairs(char_list) do
            if(char_i["Team"] > 0 and cur_room == missionmaputils.GetCurrentRoom(game_map, char_i["x"], char_i["y"])) then
                temp_move_x, temp_move_y, temp_steps = follow.DoFollow(game_map, char["x"], char["y"], char_i["x"], char_i["y"])
                if((steps == nil and temp_steps ~= nil) or temp_steps < steps) then
                    char["Status"] = "Follower"
                    char["Focus"] = char_i
                    move_x = temp_move_x
                    move_y = temp_move_y
                    steps = temp_steps
                end
            end
        end
    end

    if(char["Status"] ~= "Standby" and move_x == nil and move_y == nil) then
        char["Status"] = "Standby"
        char["Focus"] = nil
    elseif(move_x ~= nil and move_y ~= nil) then
        CharAction.DoMovement(game_map, char, move_x, move_y)
    end
end

function CharAction.DoMovement(game_map, char, m_up_down, m_left_right)
    local cur_tile, desired_tile = game_map[char["x"]][char["y"]],
                                    game_map[char["x"] + m_up_down][char["y"] + m_left_right]

    local blocking_char = missionmaputils.getCharInSpace(desired_tile)

    if(blocking_char != "") then
        if((blocking_char["Team"] <= 0 and char["Team"] > 0) or (blocking_char["Team"] > 0 and char["Team"] <= 0)) then
            CharAction.doBasicAttack()
            return true
        end
        return false
    end

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
        BehaviourHandler_Ally(map, unit_list, char)
    end
end

return CharAction