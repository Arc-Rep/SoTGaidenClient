
local json = require( "json" )
local defaultLocation = system.DocumentsDirectory

function SaveTable( playerdata, filename, location )
 
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

