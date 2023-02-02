local lfs = require( "lfs" )

local gu = {}

function gu.PrintTable( t )
    local printTable_cache = {}
    local function sub_printTable( t, indent )
        if ( printTable_cache[tostring(t)] ) then
            print( indent .. "*" .. tostring(t) )
        else
            printTable_cache[tostring(t)] = true
            if ( type( t ) == "table" ) then
                for pos,val in pairs( t ) do
                    if ( type(val) == "table" ) then
                        print( indent .. "[" .. pos .. "] => " .. tostring( t ).. " {" )
                        sub_printTable( val, indent .. string.rep( " ", string.len(pos)+8 ) )
                        print( indent .. string.rep( " ", string.len(pos)+6 ) .. "}" )
                    elseif ( type(val) == "string" ) then
                        print( indent .. "[" .. pos .. '] => "' .. val .. '"' )
                    else
                        print( indent .. "[" .. pos .. "] => " .. tostring(val) )
                    end
                end
            else
                print( indent..tostring(t) )
            end
        end
    end
    if ( type(t) == "table" ) then
        print( tostring(t) .. " {" )
        sub_printTable( t, "  " )
        print( "}" )
    else
        sub_printTable( t, "  " )
    end
end


-- Get raw path to the app documents directory
function gu.GetDocumentsPath()
    local doc_path = system.pathForFile( "", system.DocumentsDirectory )

    for file in lfs.dir( doc_path ) do
        -- "file" is the current file or directory name
        print( "Found file: " .. file )
    end
end

-- Find idx of element in table that contains value
function table_contains(table, element)
    for key, value in pairs(table) do
        if value == element then
        return key
        end
    end
    return false
end

return gu