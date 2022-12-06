local jsonfunc = {}

local json = require( "json" )
local defaultLocation = system.DocumentsDirectory

function jsonfunc.SaveTable(playerdata,filename,location)
    local loc = location
    if not location then
        loc = defaultLocation
    end

    -- Path for the file to write
    local path = system.pathForFile( filename, loc )

    -- Open the file handle
    local file, errorString = io.open( path, "w" )

    if not file then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
        return false
    else
        -- Write encoded JSON data to file
        file:write( json.encode( playerdata ) )
        -- Close the file handle
        io.close( file )
        return true
    end
end

function jsonfunc.LoadTable(filename,location)
    local loc = location
    if not location then
        loc = defaultLocation
    end

    local path = system.pathForFile( filename, loc )
    local file, errorString = io.open( path, "r" )
 
    if not file then
        print( "File error: " .. errorString )
    else
        local contents = file:read( "*a" )
        local t = json.decode( contents )
        io.close( file )
        return t
    end
end


return jsonfunc