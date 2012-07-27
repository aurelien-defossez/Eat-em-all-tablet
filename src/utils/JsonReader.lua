-----------------------------------------------------------------------------------------
--
-- JsonReader.lua
--
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local json = require("json")

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function readJson(filename, base)
	-- Open file
	base = base or system.ResourceDirectory
	local path = system.pathForFile(filename, base)
	local file = io.open(path, "r")

	if file then
		-- Read file content
		local content = file:read("*a")

		-- Close file
		io.close(file)

		-- Decode to Json
		return json.decode(content)
	else
		print("ERROR: Impossible to open file " .. filename)
	end
end

