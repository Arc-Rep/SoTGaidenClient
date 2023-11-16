local BasicAttack = require "SoTClient.GameLogic.MechanicsLogic.BattleCalcs.BasicAttack"
local missionmaputils = require "SoTClient.GameLogic.Scenarios.MissionMapUtils"
local follow = require "SoTClient.GameLogic.CharacterLogic.CharBehavior.CharFollow"
local LazyEval = require "SoTClient.Utils.LazyEval"
local BasicAnimation = require "SoTClient.Visuals.Animations.Basic.BasicAnimations"
local MapRender = require "SotClient.Visuals.RenderMap"
local Camera = require "SoTClient.Visuals.CameraMap"
local math = require "math"

local function BehaviourHandler_Ally(game_map, char_list, char, TurnEnd)
    local hittables = CheckHittableEnemies(game_map, char, char_list)
    if(#hittables ~= 0) then
        BasicAttack.doAttack(game_map, char, hittables[1])
        MapRender.UpdateTilemap(game_map)
        return true
    end
    if(char["Status"] == "Follower") then
        --print("Data is " .. char["Focus"]["y"])
        local move_x, move_y, steps = DoFollow(game_map, char["x"], char["y"], char["Focus"]["x"], char["Focus"]["y"])
        if(move_x == 0 and move_y == 0) then
            return true
        elseif(move_x ~= nil and move_y ~= nil) then
            return DoMovement(game_map, char, move_x, move_y, TurnEnd)
        end
    end

    return true
end

local function BehaviourHandler_Enemy(game_map, char_list, char, TurnEnd)
    local move_x, move_y, steps, temp_move_x, temp_move_y, temp_steps = nil, nil, nil, nil, nil, nil
    local cur_room = GetCurrentRoom(game_map, char["x"], char["y"])
    local hittables = CheckHittableEnemies(game_map, char, char_list)
    if(#hittables ~= 0) then
        char["Status"] = "Follower"
        char["Focus"] = hittables[1]
        BasicAttack.doAttack(game_map, char, char["Focus"])
        MapRender.UpdateTilemap(game_map)
        return true
    end
    if(char["Status"] == "Standby" or char["Status"] == "Follower") then
        for index, char_i in ipairs(char_list) do
            if (char_i["currentHP"] ~= 0) then
                if(char_i["Team"] > 0 and cur_room == GetCurrentRoom(game_map, char_i["x"], char_i["y"])) then
                    temp_move_x, temp_move_y, temp_steps = DoFollow(game_map, char["x"], char["y"], char_i["x"], char_i["y"])
                    if(temp_steps == nil) then

                    elseif(LOR(steps == nil, function() return temp_steps < steps end)) then
                        char["Status"] = "Follower"
                        char["Focus"] = char_i
                        move_x = temp_move_x
                        move_y = temp_move_y
                        steps = temp_steps
                    end
                end
            end
        end
    end

    if(char["Status"] ~= "Standby" and move_x == nil and move_y == nil) then
        char["Status"] = "Standby"
        char["Focus"] = nil
    elseif(move_x ~= nil and move_y ~= nil) then
        if (move_x ~= 0 or move_y ~= 0) then
            return DoMovement(game_map, char, move_x, move_y, TurnEnd) == true
        end
    end
    return true
end

function DoMovement(game_map, char, move_x, move_y, TurnEnd)

    if(CheckLegalMovement(game_map, char["x"], char["y"], move_x, move_y) == false) then
        return false
    end

    if (char["Texture"] ~= nil) then
        ElementMove{
            map = game_map,
            object = char,
            params = {
                x = move_x,
                y = move_y,
                time = (math.abs(move_x) + math.abs(move_y)) * 250,
                end_function = TurnEnd
            }
        }
        return false
    else
        cur_tile["Actor"] = nil
        desired_tile["Actor"] = char
        char["x"] = char["x"] + move_x
        char["y"] = char["y"] + move_y
    end
    return true
end

function PlayerMoveEvent(game_map, char, move_x, move_y, TurnEnd)
    
    if (char["x"] == nil or char["y"] == nil or char["currentHP"] == 0) then
        return false
    end

    local desired_tile = game_map[char["x"] + move_x][char["y"] + move_y]

    if(desired_tile["Actor"] ~= nil) then
        local neighbour = desired_tile["Actor"]

        if CheckIfEnemy(char, neighbour) == true then
            BasicAttack.doAttack(game_map, char, neighbour)
            MapRender.UpdateTilemap(game_map)
            return true
        end
    end

    return DoMovement(game_map, char, move_x, move_y, TurnEnd)
end

function doCharActionSkill(game_map, char, skill, focus_x, focus_y)
    skill["Effect"](game_map, char, focus_x, focus_y)
    MapRender.UpdateTilemap(game_map)
end

function CheckFocusExists(unit)
    if(CheckIfDead(unit["Focus"]) == true) then
        unit["Focus"] = nil
        unit["Status"] = "Standby"
    end
end

function DoCharAction(map, unit_list, char, TurnEnd)

    if(char["Focus"] ~= nil) then
        CheckFocusExists(char)
    end

    if(char["Team"] == 0) then
        return BehaviourHandler_Enemy(map, unit_list, char, TurnEnd)
    else
        return BehaviourHandler_Ally(map, unit_list, char, TurnEnd)
    end
end