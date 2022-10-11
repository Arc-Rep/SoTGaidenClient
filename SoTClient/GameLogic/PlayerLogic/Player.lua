
local Player = {}

local json = require( "json" )
local rootloc = system.DocumentsDirectory

function Player.ReadPlayer()
    local path = "D:/GameDev/SoT Gaiden/UserData/playerdata.json"

    -- Open the file handle
    local file, errorString = io.open( path, "r" )
    
    if not file then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
        return nil
    else
        -- Write encoded JSON data to file
        local contents = file:read("*a")
        print(contents)
        local playerdata = json.decode(contents)
        -- file:read( json.decode(playerdata) )
        -- Close the file handle
        io.close( file )
        return playerdata
    end
end

return Player