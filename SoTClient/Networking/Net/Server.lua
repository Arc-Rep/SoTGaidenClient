
local network = require("network")

local function setupTransferListener( event )
 
    if ( event.isError ) then
        print( "Network error: ", event.response )

    elseif ( event.phase == "began" ) then
        if ( event.bytesEstimated <= 0 ) then
            print( "Download starting, size unknown" )
        else
            print( "Download starting, estimated size: " .. event.bytesEstimated )
        end
 
    elseif ( event.phase == "progress" ) then
        if ( event.bytesEstimated <= 0 ) then
            print( "Download progress: " .. event.bytesTransferred )
        else
            print( "Download progress: " .. event.bytesTransferred .. " of estimated: " .. event.bytesEstimated )
        end
         
    elseif ( event.phase == "ended" ) then
        print( "Download complete, total bytes transferred: " .. event.bytesTransferred )
    end
end

local function setupDownloadListener( event )

    if ( event.isError ) then
        print( "Network error - download failed: ", event.response )
    elseif ( event.phase == "began" ) then
        print( "Progress Phase: began" )
    elseif ( event.phase == "ended" ) then
        print( "Download Ended" )
    end
end

local function makeRequest(listener_type, address, request_type, networkListener, params, file_name, file_folder)
    if (listener_type == "SIMPLE") then
        network.request(address, request_type, networkListener, params)
    elseif (listener_type == "DOWNLOAD") then
        network.download(address, request_type, networkListener, params, file_name, file_folder)
    end
end