local JsonFuncs = require("SoTClient.Utils.JsonFuncs")
local CharAnimationList = require("SoTClient.Visuals.Animations.Character.CharAnimationList")
local CharacterAnimation = {}


function CharacterAnimation.GetAnimation(char_id, character_anim_data, action)

    return {
        name = CharAnimationList.convertAnimationIndexToAnimationID(action),
        start = character_anim_data["action_sequences"][action].start,
        count = character_anim_data["action_sequences"][action].count,
        time = character_anim_data["action_sequences"][action].time,
        loopCount = character_anim_data["action_sequences"][action].loopCount
    }
end

function CharacterAnimation.ImportAnimationSet(char_id)
    local character_anim_data = JsonFuncs.LoadTable("GameResources\\Character\\" .. char_id .. ".json", system.ResourceDirectory)
    local character_animation_set = {}

    character_animation_set["sheet"] = graphics.newImageSheet(
                "GameResources\\Sprites\\Character\\" .. char_id .. "\\" .. char_id ..".png", 
                {
                    width = character_anim_data["sheet_data"].width,
                    height = character_anim_data["sheet_data"].height,
                    numFrames = character_anim_data["sheet_data"].numFrames
                }
    )

    -- For now, only movement and idle animations are considered.
    -- Later on we will need to add "intelligent" animations that target other characters
    character_animation_set["sequences"] = {}
    for action = CharAnimationList["idle"], CharAnimationList["move_end"], 1 do
        character_animation_set["sequences"][action] = CharacterAnimation.GetAnimation(char_id, character_anim_data, tostring(action))
    end

    return character_animation_set
end

return CharacterAnimation