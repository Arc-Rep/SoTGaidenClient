
local AnimationQueue = {}

local animations = {}
local animations_ongoing = false
local animations_finished = 0
local current_cycle = 1

local animation_cycle_end_callback = nil

local function animationListener( event )
    if event.phase == "ended" or event.phase == "cancelled" and event.target.onComplete then
        event.target.onComplete()
        AnimationFinished()
    end
end

local function AnimationFinished()
    animations_finished = animations_finished + 1
    if (animations_finished == #animations[current_cycle]) then
        animations_finished = 0
        current_cycle = current_cycle + 1
        if (current_cycle > #animations) then
            -- End animation cycle and reset 
            animations_ongoing = false
            animations = {}
            return animation_cycle_end_callback()
        end
        PerformAnimationCycle()
    end
end

local function PerformAnimationCycle()

    for animation_index = 1, #(animations[current_cycle]), 1 do
        local current_animation = animations[current_cycle][animation_index]

        if (current_animation["MoveParameters"] ~= nil) then

            if (current_animation["MoveParameters"]["end_function"] == nil) then
                current_animation["MoveParameters"].onComplete = AnimationFinished
                current_animation["MoveParameters"].onCancel   = AnimationFinished
            else
                local end_function = current_animation["MoveParameters"].onComplete
                current_animation["MoveParameters"].onComplete = 
                    function()
                        current_animation["MoveParameters"].end_function()
                        AnimationFinished()
                    end
                current_animation["MoveParameters"].onCancel = current_animation["MoveParameters"].onComplete
            end

            transition.moveBy(current_animation["Texture"], current_animation["MoveParameters"])
        end

        if (current_animation["Animation"] ~= nil) then
            if (current_animation["Animation"]["onComplete"] ~= nil) then
                current_animation["Animation"]:addEventListener("sprite", animationListener)
            end
            current_animation["Texture"]:setSequence(current_animation["Animation"])
            current_animation["Texture"]:play()
        end

        if (current_animation["SFX"] ~= nil) then
            current_animation.onComplete = AnimationFinished()
            current_animation["SFX"]:play()
        end
    end
end

function AnimationQueue.StartAnimations(animation_callback)
    current_cycle = 1

    if (#animations == 0) then
        -- No animations to account for (no need to reset)
        return animation_callback()
    else
        while (#animations[current_cycle] == 0) do
            current_cycle = current_cycle + 1
            if (current_cycle > #animations) then
                return animation_callback()
            end
        end
    end

    animation_cycle_end_callback = animation_callback
    animations_ongoing = true

    PerformAnimationCycle()
end

function AnimationQueue.SetNewCycle(move_last_element)

    if (move_last_element == true) then
        local last_animation = animations[#animations][#animations[#animations]]
        animations[#animations][#animations[#animations]] = nil
        animations[#animations + 1] = { last_animation }
    else
        animations[#animations + 1] = {}
    end
end

function AnimationQueue.ResetQueue()
    animations = {}
end

-- For now, only one of these types of animations is permitted
function AnimationQueue.AddAnimation(texture, move_params, animation, sfx)
    local new_animation = {Texture = texture, MoveParameters = move_params, Animation = animation, SFX = sfx}
    animations[#animations][#animations[#animations] + 1] = new_animation
end

function AnimationQueue.ReturnCurrentAnimation()
    return animations[#animations]
end

return AnimationQueue