
local Player = {}

local Json = require("SoTClient.Utils.JsonFuncs")
local rootloc = system.DocumentsDirectory
local math = require("math")
local player,currenthp,maxhp,currentessence,maxessence,atk,ability1,ability2,ability3,ability4


function Player.readPlayer()
    player = Json.LoadTable("playerdata.json",rootloc)
    Player.currenthp = player.hp
    Player.currentessence = player.essence
    atk = (player.str)+(player.dex)+(player.itl)
    Player.maxhp = math.round(5*((player.str*0.5)+(player.dex*0.39)+(player.itl*0.23)))+10
    Player.maxessence = math.round(5*((player.str*0.1)+(player.dex*0.12)+(player.itl*0.87)))
    ability1 = player.ability1
    ability2 = player.ability2
    ability3 = player.ability3
    ability4 = player.ability4
end

return Player