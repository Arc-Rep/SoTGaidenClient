
local system     = require "system"
local audio      = require "audio"
local lfs        = require "lfs"

local general_gameplay_audio = {}
local audio_playing = {}

function LoadLevelAudio()

    local general_gameplay_audio_path = 
        system.pathForFile("GameResources\\Sound\\Play\\General", system.ResourceDirectory)

    print(general_gameplay_audio_path)
    for file in lfs.dir(general_gameplay_audio_path) do
        if (file ~= "." and file ~= "..") then
            general_gameplay_audio[file] = audio.loadSound("GameResources\\Sound\\Play\\General" .. "\\" .. file)
        end
    end

end

function FreeLevelAudio()

    local general_gameplay_audio_path = 
        system.pathForFile("GameResources\\Sound\\Play\\General", system.ResourceDirectory)

    for audio_sound, _ in pairs(general_gameplay_audio) do
        audio.dispose(general_gameplay_audio_path .. "\\" .. audio_sound)
    end
end

function PlayLevelAudio(audio_file)
    if (audio_playing["level"] == nil) then
        print("Playing")
        audio_playing["level"] = audio_file
        audio.play(general_gameplay_audio[audio_file], {onComplete = function() audio_playing["level"] = nil end} )
    end
end