local CharAction = {}

local missionmaputils = require "SoTClient.GameLogic.Scenarios.MissionMapUtils"
local follow = require "SoTClient.GameLogic.CharacterLogic.CharBehavior.CharFollow"

local function BehaviourHandler_Enemy(game_map, unit_list, unit){
    if(char["Status"] == "Standby") then
        local cur_room = missionmaputils.GetCurrentRoom(game_map, unit["x"], unit["y"])
        for index, unit_i in ipairs(unit_list) do
            if(unit_i["Team"] > 0 and cur_room == missionmaputils.GetCurrentRoom(game_map, unit_i["x"], unit_i["y"])) then
                unit["Status"] = "Follower"
                unit["Focus"] = unit_i
            end
        end
    end
}

local function BehaviourHandler_Ally(){

}

local function DoMovement(game_map, char, m_up_down, m_left_right)
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

function CharAction.DoPlayerAction(map, char){
    if(char["Team"] < 0) then 
        BehaviourHandler_Enemy()
    else 
        BehaviourHandler_Ally() 
    end

    if(char["Status"] == "Follower") then
       DoMovement(map, char, follow.doFollow(map, char["x"], char["y"], char["Focus"]["x"], char["Focus"]["y"]))
    end
}

return CharAction