--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

--local display_ratio = display.pixelHeight/display.pixelWidth

-- Height and Width are inversed in landscape mode (aka display ratio is to the power of -1)
local screen_height = 320
local screen_width = 480


application =
{
	content =
	{
		width = screen_width,
		height = screen_height, 
		scale = "adaptive",
		fps = 60,
		--yAlign = "center", xAlign = "center",
		--[[
		imageSuffix =
		{
			    ["@2x"] = 2,
			    ["@4x"] = 4,
		},
		--]]
	},
}
