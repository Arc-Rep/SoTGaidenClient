
local Player = {}

local Json = require("SoTClient.Utils.JsonFuncs")
local rootloc = system.DocumentsDirectory
local math = require("SoTClient.Utils.MathUtils")


function Player.readPlayer()
    local player = Json.LoadTable("playerdata.json",rootloc)
    if player == nil then
        Player.currenthp = 10
        Player.currentessence = 10
        Player.atk = 10
        Player.maxhp = 10
        Player.maxessence = 10
        Player.ability1 = nil
        Player.ability2 = nil
        Player.ability3 = nil
        Player.ability4 = nil
        return false
    end
    Player.currenthp = player.hp
    Player.currentessence = player.essence
    Player.atk = (player.str)+(player.dex)+(player.itl)
    Player.maxhp = math.Round(5*((player.str*0.5)+(player.dex*0.39)+(player.itl*0.23))) + 10
    Player.maxessence = math.Round(5*((player.str*0.1)+(player.dex*0.12)+(player.itl*0.87)))
    Player.ability1 = player.ability1
    Player.ability2 = player.ability2
    Player.ability3 = player.ability3
    Player.ability4 = player.ability4
    return true
end

return Player