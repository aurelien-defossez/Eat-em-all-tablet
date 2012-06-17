-----------------------------------------------------------------------------------------
--
-- utils.lua
--
-----------------------------------------------------------------------------------------

function checkMandatoryParameters(object, parameters)
	for key, value in ipairs(parameters) do
		assertAttribute(object, value)
	end
end

function assertAttribute(object, attribute)
	assert(object[attribute] ~= nil, attribute .. " is not defined")
end

function applyDefaults(object, defaults)
	for key, value in pairs(defaults) do
		object[key] = object[key] or defaults[key]
	end
end
