local jsonfunc = {}

local json = require( "json" )
local defaultLocation = system.DocumentsDirectory

function jsonfunc.SaveTable(playerdata,filename,location)
    local loc = location
    if not location then
        loc = defaultLocation
    end

    local path = system.pathForFile( filename, loc )
    local file, errorString = io.open( path, "w" )
    if not file then
        print( "File error: " .. errorString )
        return false
    else
        file:write( json.encode( playerdata ) )
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

    return nil
end


return jsonfunc