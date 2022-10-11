--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

local display_ratio = display.pixelHeight/display.pixelWidth
local screen_width = 480
local screen_height = display_ratio * screen_width

application =
{
	content =
	{
		width = screen_width,
		height = screen_height, 
		scale = "letterbox",
		fps = 60,
		
		--[[
		imageSuffix =
		{
			    ["@2x"] = 2,
			    ["@4x"] = 4,
		},
		--]]
	},
}
