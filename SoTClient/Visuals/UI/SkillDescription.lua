local SkillDescription = {}

local skill_overlay = nil
local skill_name = nil
local skill_description = nil
local skill_power = nil

local overlay_x = 0
local overlay_y = display.contentHeight - display.contentWidth * 0.1
local overlay_width = display.contentWidth * 0.30
local overlay_base_height = display.contentWidth * 0.05
local overlay_margin_size = display.contentHeight * 0.01

local name_font_size = 15


function SkillDescription.createDescription(skill_data, skillIndex, UI)
        skill_overlay_description = display.newText(skill_data["Description"], overlay_margin_size, overlay_y - overlay_margin_size, overlay_width - (overlay_margin_size*2), 0, native.systemFont, 10)
        skill_overlay_description.anchorX = 0
        skill_overlay_description.anchorY = 1

        skill_overlay_name = display.newText(skill_data["Name"], overlay_margin_size, overlay_y - overlay_base_height + overlay_margin_size, overlay_width * 0.70, 0, native.systemFont, 12)
        skill_overlay_name.anchorX = 0
        skill_overlay_name.anchorY = 0

        local skill_overlay_height = overlay_base_height

        if (skill_overlay_description.height > overlay_base_height) then
            skill_overlay_height = skill_overlay_description.height + skill_overlay_name.height
            skill_overlay_name.y = overlay_y - skill_overlay_height + overlay_margin_size
        end

        skill_overlay = display.newRect(overlay_x, overlay_y , overlay_width, skill_overlay_height)
        skill_overlay.anchorX = 0
        skill_overlay.anchorY = 1
        skill_overlay.alpha = 0.8
        skill_overlay:setFillColor(0, 0, 0)
        UI:insert(skill_overlay)

        skill_overlay_power = display.newText("Power: " .. skill_data["DmgBase"], overlay_width - overlay_margin_size, overlay_y - skill_overlay_height + overlay_margin_size, 0, 0, native.systemFont, 10)
        skill_overlay_power.anchorX = 1
        skill_overlay_power.anchorY = 0
        UI:insert(skill_overlay_power)
        UI:insert(skill_overlay_name)
        UI:insert(skill_overlay_description)

end

function SkillDescription.removeDescription()
    skill_overlay:removeSelf()
    skill_overlay = nil
    skill_overlay_name:removeSelf()
    skill_overlay_name = nil
    skill_overlay_description:removeSelf()
    skill_overlay_description = nil
    skill_overlay_power:removeSelf()
    skill_overlay_power = nil
end

function SkillDescription.isDescriptionActive()
    return skill_overlay ~= nil
end

return SkillDescription