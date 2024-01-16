local lfs    = require "lfs"
local system = require "system"

function GetAllFilesOnPath(path, resource_dir_type)
    local path = system.pathForFile(path, resource_dir_type)

    local files = lfs.dir(path)
    files["."]  = nil
    files[".."] = nil

    return files
end