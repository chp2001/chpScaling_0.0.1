
local function output_2x_defs_to_file()
    --local file = io.open("2x_defs.lua", "w")
    local text = ""
    for mainkey, subcat in pairs(data.raw) do
        for subkey, item in pairs(subcat) do
            if string.match(subkey, "2x") then
                text = text .. serpent.block(item) .. "\n"
            end
        end
    end
    game.write_file("2x_defs.lua", text)
end
if not table.contains then
	---@param table table
	---@param element any
	---@return integer|boolean
	--Usable in if statements, returns the index of the element if it exists, or false if it doesn't.
	function table.contains(table, element)
		for index, value in pairs(table) do
			if value == element then
				return index
			end
		end
		return false
	end
end
local function recurs_block(key, subdict)
    local text = ""
    text = text .. key .. " = {\n"
    for subkey, item in pairs(subdict) do
        if type(item) == "table" then
            text = text .. recurs_block(subkey, item)
        else
            text = text .. subkey .. " = " .. serpent.line(item) .. ",\n"
        end
    end
    text = text .. "},\n"
    return text
end
--[[
script.on_configuration_changed(function()
    --output_2x_defs_to_file() --only works with access to data.raw
    local text = ""
    for key, item in pairs(game.recipe_prototypes) do
        --if string.match(key, "2x") then
            text = text .. recurs_block(key, item)
        --end
    end
    game.write_file("2x_defs.lua", text)
end)--]]

require("lib/inserter_handle")
