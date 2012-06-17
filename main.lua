-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar)
system.activate("multitouch")

-- include the Corona "storyboard" module
local storyboard = require("storyboard")

for i = 1, 30 do
	print("")
end

storyboard.gotoScene("multiplayer")
