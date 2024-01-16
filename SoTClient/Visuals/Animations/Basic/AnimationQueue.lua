
local AnimationQueue = {}

local animations = {}
local animations_ongoing = false
local animations_finished = 0
local current_cycle = 1

local animation_cycle_end_callback = nil

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
    local animation_number = #(animations[current_cycle])

    for animation_index = 1, animation_number, 1 do
        local current_animation = animations[current_cycle][animation_index]
        if (current_animation["Parameters"]["end_function"] == nil) then
            current_animation["Parameters"].onComplete = AnimationFinished
            current_animation["Parameters"].onCancel   = AnimationFinished
        else
            local end_function = current_animation["Parameters"].onComplete
            current_animation["Parameters"].onComplete = 
                function()
                    current_animation["Parameters"].end_function(AnimationFinished)
                end
            current_animation["Parameters"].onCancel = current_animation["Parameters"].onComplete
        end
        transition.moveBy(current_animation["Texture"], current_animation["Parameters"])
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

function AnimationQueue.SetNewCycle()
    animations[#animations + 1] = {}
end

function AnimationQueue.ResetQueue()
    animations = {}
end

function AnimationQueue.AddAnimation(texture, params)
    local new_animation = {Texture = texture, Parameters = params}
    animations[#animations][#animations[#animations] + 1] = new_animation
end

function AnimationQueue.ReturnCurrentAnimation()
    return #animations
end

return AnimationQueue