---@diagnostic disable: undefined-global, duplicate-set-field
--Check if table.contains exists, and if not, define it.
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
do
	require("prototypes/heavy_inserters")
	require("lib/lib_centralized")
	proto = proto or {}
end
---@function skipBuildingScaling
---@param key string
---@param indexTable table
---@return boolean
---@usage if skipBuildingScaling(key, indexTable) then goto continue end
local function skipBuildingScaling(key, indexTable)
	local banned_subgroups = {"circuit-network","belt","defensive-structure","gun"}
	local subgroup = indexTable["item"]["subgroup"]
	local isBanned = table.contains(banned_subgroups, subgroup)
	for i, val in pairs(proto.no_resize_types) do
		if key:find(val,1,true) then
			isBanned = true
		elseif val == "offshore-pump" and key == "offshore-pump" then
			error("offshore-pump did not match with "..val)
		end
	end
	if key == "offshore-pump" and not isBanned then
		error("offshore-pump: "..serpent.block(indexTable))
	end
	if not indexTable["category"] then
		goto continue
	end
	if indexTable["item"].name:match("loader") then --or indexTable["item"].name:match("condenser") then
		goto continue
	end
	if indexTable["entity"]["speed"] then
		goto continue
	end
	if not (indexTable["category"]=="assembling-machine") then
		--goto continue
	end
	for i, entity in pairs(indexTable["entity"]) do
		if not proto.ShouldResize(entity) then
			goto continue
		end
	end
	if key == "kr-air-purifier" then
		goto continue
	end
	
	if isBanned then
		goto continue
	end
	if key == "pumpjack" or key == "boiler" then
		--goto continue
	end
	if key=="concrete" then
		log("concrete: "..serpent.block(indexTable))
		error("concrete: "..serpent.block(indexTable))
	end
	do
		return false
	end
	::continue::
	return true
end
local function recurs_size(tbl)
	local size = 0
	for key, val in pairs(tbl) do
		if type(val) == "table" then
			size = size + recurs_size(val)
		else
			size = size + 1
		end
	end
	return size
end
local bManip = require("lib.data_buildingfunctions")
local before = recurs_size(bManip)
bManip.active = true
bManip.setActive(true)
bManip.setDelayed(true)
log("chpScaling:bManip is active: "..tostring(bManip.active))
--bManip.scaleAll(2, skipBuildingScaling)
--bManip.scaleAll(4, skipBuildingScaling)
--bManip.scaleAll(6, skipBuildingScaling)
local scaleTable = {}
local scaleSetting = settings.startup["chpScaling-scales-list"].value
---@cast scaleSetting string
for scale in string.gmatch(scaleSetting, "([^,]+)") do
	table.insert(scaleTable, tonumber(scale))
end

for i, scale in pairs(scaleTable) do
	bManip.scaleAll(scale, skipBuildingScaling)
end
bManip.finalize()
--bManip.spamProtoCacheToLog()
local after = recurs_size(bManip)
log("chpScaling:bManip size before: "..before)
log("chpScaling:bManip size after: "..after)
if not bManip.active then


---@return table
local generateBuildingList = function()
	local checkTarget = data.raw["item"]
	local buildingList = {}
	--We can check for buildings by seeing if there is a corresponding item to place them.
	--Should check for a "place_result" field in the item, or "place_as_tile" field.
	for key, item in pairs(checkTarget) do
		if item.place_result then
			buildingList[key] = item.place_result
		elseif item.place_as_tile then
			buildingList[key] = item.place_as_tile.result
		else
			goto continue
		end
		if item.flags and table.contains(item.flags,"hidden") then
			buildingList[key] = nil
		end
	    ::continue::
	end
	return buildingList
end

---@function generateDetailedBuildingList
---@return table
---@description Generates a list of buildings, with their category and result.
local generateDetailedBuildingList = function()
	local buildingList = generateBuildingList()
	local buildingListDetailed = {}
	local itemTable = {}
	local recipeTable = {}
	local technologyTable = {}
	local technologyStack = {}
	local mismatch_table = {}
	local mismatch_table_reverse = {}
	for itemName, buildingName in pairs(buildingList) do
		if not itemName==buildingName then
			mismatch_table[itemName] = buildingName
			mismatch_table_reverse[buildingName] = itemName
		end
	end
	--We want to go through all the subdictionaries of data.raw, and see if they have a key that matches one of the buildings.
	--We can then mark that building with the category.
	for key, category in pairs(data.raw) do
		if key=="item-subgroup" then goto continue end
		for subkey, item in pairs(category) do
			if item["type"] and item["type"] == "tips-and-tricks-item" then goto hardskip end
			if key == "technology" then
				if item.effects then
					for i, effect in pairs(item.effects) do
						if effect.type == "unlock-recipe" then
							recipeName = effect.recipe
							if mismatch_table_reverse[recipeName] or buildingList[recipeName] then
								if technologyTable[recipeName] then
									if technologyStack[recipeName] then
										table.insert(technologyStack[recipeName], item)
									else
										technologyStack[recipeName] = {technologyTable[recipeName], item}
									end
								else
									technologyTable[recipeName] = item
								end
							end
						end
					end
				end
				goto continue
			end
			if buildingList[subkey] then
				if key == "item" then 
					itemTable[subkey] = item
					goto continue
				elseif key == "recipe" then 
					recipeTable[subkey] = item
					goto continue
				elseif not item["max_health"] then
					goto continue
				end
				buildingListDetailed[subkey] = {category=key, result=buildingList[subkey], entry=item}
			end
			::continue::
		end
		::hardskip::
		::continue::
	end
	for key, item in pairs(buildingListDetailed) do
		if itemTable[key] then
			buildingListDetailed[key].item = itemTable[key]
		elseif mismatch_table[key] and itemTable[mismatch_table[key]] then
			buildingListDetailed[key].item = itemTable[mismatch_table[key]]
		end
		if recipeTable[key] then
			buildingListDetailed[key].recipe = recipeTable[key]
		elseif mismatch_table[key] and recipeTable[mismatch_table[key]] then
			buildingListDetailed[key].recipe = recipeTable[mismatch_table[key]]
		end
		if technologyTable[key] then
			buildingListDetailed[key].technology = technologyTable[key]
			if technologyStack[key] then
				buildingListDetailed[key].technologyStack = technologyStack[key]
			end
		elseif mismatch_table[key] and technologyTable[mismatch_table[key]] then
			buildingListDetailed[key].technology = technologyTable[mismatch_table[key]]
			if technologyStack[mismatch_table[key]] then
				buildingListDetailed[key].technologyStack = technologyStack[mismatch_table[key]]
			end
		end
	end
	
	return buildingListDetailed
end
local logspamcount = 0
local function limited_log(...)
	logspamcount = logspamcount + 1
	if logspamcount > 20 then
		return
	end
	log(...)
end


local function scaleBuildingSize(building, sizeMult)

end
local function createScaledBuilding(key, indexTable, sizeMult, statMult, materialCostMult)

end
local heavyInserters = {}
local buildingsToAdd = {}
local testTable = generateDetailedBuildingList()
local sizemult = 2
local statmult = math.ceil(math.pow(sizemult, 2.5))
local materialcostmult = math.ceil(math.pow(sizemult, 2))
for key, indexTable in pairs(testTable) do
	if skipBuildingScaling(key, indexTable) then
		goto continue
	end
	--If we're here, we should be scaling the building
	local item = indexTable["item"]
	local recipe = indexTable["recipe"]
	local technology = indexTable["technology"]
	local building = indexTable["entry"]
	local buildingName = building.name
	local hasTech = (technology ~= nil)
	local hasRecipe = (recipe ~= nil)
	local hasItem = (item ~= nil)
	
	local newItem = table.deepcopy(item)
	local newRecipe = table.deepcopy(recipe)
	local newBuilding = table.deepcopy(building)
	if recipe == nil or newRecipe == nil then
		goto continue
	end
	if item == nil or newItem == nil then
		goto continue
	end
	if building == nil or newBuilding == nil then
		goto continue
	end
	local newName = buildingName .. "-"..sizemult.."x"
	newItem.name = newName
	newItem.place_result = newName

	newRecipe.name = newName
	--newRecipe.result = newName
	if newRecipe["expensive"] then
		newRecipe["expensive"].result = newName
		for ind, ingredient in pairs(newRecipe["expensive"].ingredients) do
			--if ingredient[1] == item.name then
			if ingredient.name then
				ingredient.amount = ingredient.amount * materialcostmult
			else
				newRecipe["expensive"].ingredients[ind][2] = ingredient[2] * materialcostmult
			end
			--end
		end
		if newRecipe["expensive"]["energy_required"] then
			newRecipe["expensive"]["energy_required"] = newRecipe["expensive"]["energy_required"] * materialcostmult
		end
	end
	if newRecipe["normal"] then
		newRecipe["normal"].result = newName
		for ind, ingredient in pairs(newRecipe["normal"].ingredients) do
			--if ingredient[1] == item.name then
			if ingredient.name then
				ingredient.amount = ingredient.amount * materialcostmult
			else
				newRecipe["normal"].ingredients[ind][2] = ingredient[2] * materialcostmult
			end
			--end
		end
		if newRecipe["normal"]["energy_required"] then
			newRecipe["normal"]["energy_required"] = newRecipe["normal"]["energy_required"] * materialcostmult
		end
	end
	if newRecipe["ingredients"] then
		for ind, ingredient in pairs(newRecipe["ingredients"]) do
			--if ingredient[1] == item.name then
			if ingredient.name then
				ingredient.amount = ingredient.amount * materialcostmult
			else
				newRecipe["ingredients"][ind][2] = ingredient[2] * materialcostmult
			end
				
			--end
		end
	end
	if newRecipe["energy_required"] then
		newRecipe["energy_required"] = newRecipe["energy_required"] * materialcostmult
	end
	if newRecipe["result"] then
		newRecipe["result"] = newName
	end
	local function recursReplaceResult(tbl,oldname,newname)
		for ind, product in pairs(tbl) do
			if product.name then
				if product.name == oldname then
					product.name = newname
				end
			else
				if product[1] == oldname then
					product[1] = newname
				end
			end
		end
	end
	if newRecipe["results"] then
		recursReplaceResult(newRecipe["results"], item.name, newName)
	end
	if newRecipe["expensive"] and newRecipe["expensive"]["results"] then
		recursReplaceResult(newRecipe["expensive"]["results"], item.name, newName)
	end
	if newRecipe["normal"] and newRecipe["normal"]["results"] then
		recursReplaceResult(newRecipe["normal"]["results"], item.name, newName)
	end
	if newRecipe["main_product"] then
		if newRecipe["main_product"] == item.name then
			newRecipe["main_product"] = newName
		end
	end
	local function generateNewRecipe(oldRecipe, name, ingredients, products, mainProduct, kwarg)
		local ret_recipe = table.deepcopy(oldRecipe) or {}
		if kwarg == nil then
			kwarg = {}
		end
		local ret_recipe_defaults = {
			type = "recipe",
			name = name,
			ingredients = ingredients,
			results = products,
			main_product = mainProduct,
			energy_required = "",
			expensive = "",
			normal = "",
			result = "",
		}
		for recikey, val in pairs(ret_recipe_defaults) do
			ret_recipe[recikey] = val
			if val == "" then
				ret_recipe[recikey] = nil
			end
		end
		if not (ret_recipe.enabled ~= nil) then
			ret_recipe.enabled = (not hasTech)
		end
		
		for ind, ingredient in pairs(ret_recipe["ingredients"]) do
			if not ingredient.name then
				ret_recipe["ingredients"][ind] = {name=ingredient[1], amount=ingredient[2]}
			end
			ingredient["type"] = ingredient["type"] or "item"
		end
		for ind, product in pairs(ret_recipe["results"]) do
			if not product.name then
				ret_recipe["results"][ind] = {name=product[1], amount=product[2]}
			end
			product["type"] = product["type"] or "item"
		end
		for recikey, val in pairs(kwarg) do
			ret_recipe[recikey] = val
		end
		return ret_recipe
	end
	local function pushRecipeToTechnology(push_recipe)
		if technology == nil then
			return
		end
		if indexTable.technologyStack then
			for ind_, tech_ in pairs(indexTable.technologyStack) do
				local target = data.raw["technology"][tech_.name]
				table.insert(target.effects, {type = "unlock-recipe", recipe = push_recipe.name})
			end
		else
			table.insert(data.raw["technology"][technology.name].effects, {type = "unlock-recipe", recipe = push_recipe.name})
		end
	end

	--Want to copy the original entirely, but use statmult of the original building as the ingredient.
	local newRecipe_2 = generateNewRecipe(newRecipe, newName.."-from-"..item.name, {{name=item.name, amount=materialcostmult}}, {{name=newName, amount=1}}, newName, nil)
	local newRecipe_3 = generateNewRecipe(newRecipe, newName.."-decompose", {{name=newName, amount=1}}, {{name=item.name, amount=materialcostmult}}, item.name, {allow_as_intermediate = false,result_count = materialcostmult,result=item.name})


	newBuilding.name = newName
	if newBuilding["minable"] then
		newBuilding["minable"].result = newName
		newBuilding["minable"].mining_time = newBuilding["minable"].mining_time * materialcostmult
	end
	local function scaleVector(vector, scale)
		if vector == nil then
			return
		end
		for ind, val in pairs(vector) do
			if type(val) == "number" then
				vector[ind] = val * scale
			elseif type(val) == "table" then
				scaleVector(val, scale)
			end
		end
	end
	--[[
	local function scalePipeConnections(vector, scale)
		if vector == nil then
			return
		end
		for ind, val in pairs(vector) do
			if type(val) == "number" then
				if val > 0.1 then
					vector[ind] = (val - 0.5) * scale + 0.5
				elseif val < -0.1 then
					vector[ind] = (val + 0.5) * scale - 0.5
				end
			elseif type(val) == "table" then
				scalePipeConnections(val, scale)
			end
		end
	end
	scaleVector(newBuilding["vector_to_place_result"], 2)
	scaleVector(newBuilding["selection_box"], 2)
	if newBuilding["circuit_wire_connection_points"] then
		for ind, point in pairs(newBuilding["circuit_wire_connection_points"]) do
			local subTable = newBuilding["circuit_wire_connection_points"][ind]
			if subTable["wire"] then
				scaleVector(subTable["wire"]["green"], 2)
				scaleVector(subTable["wire"]["red"], 2)
			end
			if subTable["shadow"] then
				scaleVector(subTable["shadow"]["green"], 2)
				scaleVector(subTable["shadow"]["red"], 2)
			end
		end
	end
	if newBuilding["output_fluid_box"] then
		if newBuilding["output_fluid_box"]["pipe_connections"] then
			scalePipeConnections(newBuilding["output_fluid_box"]["pipe_connections"], 2)
		end
	end
	if newBuilding["input_fluid_box"] then
		if newBuilding["input_fluid_box"]["pipe_connections"] then
			scalePipeConnections(newBuilding["input_fluid_box"]["pipe_connections"], 2)
		end
	end
	if newBuilding["drawing_box"] then
		scaleVector(newBuilding["drawing_box"], 2)
	end
	if newBuilding["collision_box"] then
		scaleVector(newBuilding["collision_box"], 2)
	end--]]
	local function splitEnergyString(value)
		--value is a string
		local unit = string.match(value, "%a+")
		local number = string.sub(value, 1, string.len(value) - string.len(unit))
		return tonumber(number), unit
	end
	local function scaleWhatMightBeANumberOrAString(value, scale)
		if value == nil then
			return
		end
		if type(value) == "number" then
			return value * scale
		elseif type(value) == "string" then
			local targetString = value
			local number, unit = splitEnergyString(targetString)
			if number == nil then
				error("Error while scaling energy_usage of " .. newBuilding.name .. ": " .. "Could not parse string: " .. targetString)
			end
			return number * scale .. unit
		end
		return value * scale
	end
	proto.AutoResize_by_scale(newBuilding, 2)
	if newBuilding["resource_searching_radius"] then
		newBuilding["resource_searching_radius"] = newBuilding["resource_searching_radius"] * statmult
	end
	if newBuilding["max_health"] then
		newBuilding["max_health"] = newBuilding["max_health"] * statmult
	end
	if newBuilding["energy_usage"] then
		if type(newBuilding["energy_usage"]) == "string" then
			local targetString = newBuilding["energy_usage"]
			local res, error_msg = pcall(scaleWhatMightBeANumberOrAString, targetString, statmult)
			if not res then
				error("Error while scaling energy_usage of " .. newBuilding.name .. ": " .. error_msg .. "\ntargetString: " .. targetString)
			end
			newBuilding["energy_usage"] = scaleWhatMightBeANumberOrAString(targetString, statmult)
		elseif type(newBuilding["energy_usage"]) == "number" then
			newBuilding["energy_usage"] = newBuilding["energy_usage"] * statmult
		end
	end
	if newBuilding["energy_consumption"] then
		if type(newBuilding["energy_consumption"]) == "string" then
			local targetString = newBuilding["energy_consumption"]
			--format of string often looks like "100kW"
			local number = tonumber(string.sub(targetString, 1, string.len(targetString)-2))
			local unit = string.sub(targetString, string.len(targetString)-1, string.len(targetString))
			newBuilding["energy_consumption"] = (number * statmult) .. unit
		elseif type(newBuilding["energy_consumption"]) == "number" then
			newBuilding["energy_consumption"] = newBuilding["energy_consumption"] * statmult
		end
	end
	if newBuilding["max_power_output"] then
		newBuilding["max_power_output"] = scaleWhatMightBeANumberOrAString(newBuilding["max_power_output"], statmult)
	end
	if newBuilding["production"] then
		newBuilding["production"] = scaleWhatMightBeANumberOrAString(newBuilding["production"], statmult)
	end
	if newBuilding["energy_source"] then
		if newBuilding["energy_source"]["fuel_inventory_size"] then
			newBuilding["energy_source"]["fuel_inventory_size"] = newBuilding["energy_source"]["fuel_inventory_size"] * sizemult
		end
		if newBuilding["energy_source"]["output_flow_limit"] then
			newBuilding["energy_source"]["output_flow_limit"] = scaleWhatMightBeANumberOrAString(newBuilding["energy_source"]["output_flow_limit"], statmult)
		end
		if newBuilding["energy_source"]["input_flow_limit"] then
			newBuilding["energy_source"]["input_flow_limit"] = scaleWhatMightBeANumberOrAString(newBuilding["energy_source"]["input_flow_limit"], statmult)
		end
		if newBuilding["energy_source"]["buffer_capacity"] then
			newBuilding["energy_source"]["buffer_capacity"] = scaleWhatMightBeANumberOrAString(newBuilding["energy_source"]["buffer_capacity"], statmult)
		end
	end
	if newBuilding["next_upgrade"] then
		--newBuilding["next_upgrade"] = newBuilding["next_upgrade"] .. "-2x"
		newBuilding["next_upgrade"] = nil
	end
	if newBuilding["insert_position"] then
		newBuilding["insert_position"][2] = (newBuilding["insert_position"][2] - 0.2)
		newBuilding["insert_position"][2] = newBuilding["insert_position"][2] * sizemult
		newBuilding["insert_position"][2] = (newBuilding["insert_position"][2] + 0.2)
	end
	if newBuilding["pickup_position"] then
		scaleVector(newBuilding["pickup_position"], sizemult)
	end
	if newBuilding["extension_speed"] then
		newBuilding["extension_speed"] = newBuilding["extension_speed"] * sizemult
	end
	if newBuilding["rotation_speed"] then
		--newBuilding["rotation_speed"] = newBuilding["rotation_speed"] * statmult
	end
	if newBuilding["fast_replaceable_group"] then
		newBuilding["fast_replaceable_group"] = newBuilding["fast_replaceable_group"] .. "-"..sizemult.."x"
	end
	if newBuilding["fluid_usage_per_tick"] then
		newBuilding["fluid_usage_per_tick"] = newBuilding["fluid_usage_per_tick"] * statmult
	end
	if newBuilding["pumping_speed"] then
		newBuilding["pumping_speed"] = newBuilding["pumping_speed"] * statmult
	end
	if newBuilding["fluid_box"] then
		if newBuilding["fluid_box"]["base_area"] then
			newBuilding["fluid_box"]["base_area"] = newBuilding["fluid_box"]["base_area"] * statmult
		end
		--if newBuilding["fluid_box"]["height"] then
		--	newBuilding["fluid_box"]["height"] = newBuilding["fluid_box"]["height"] * statmult
		--end
	end

	--[[if newBuilding["source_inventory_size"] then
		newBuilding["source_inventory_size"] = newBuilding["source_inventory_size"] * 2
	end
	if newBuilding["result_inventory_size"] then
		newBuilding["result_inventory_size"] = newBuilding["result_inventory_size"] * 2
	end--]]
	if newBuilding["module_specification"] then
		if newBuilding["module_specification"]["module_slots"] then
			newBuilding["module_specification"]["module_slots"] = newBuilding["module_specification"]["module_slots"] * sizemult
		end
	end
	if newBuilding["supply_area_distance"] then
		newBuilding["supply_area_distance"] = newBuilding["supply_area_distance"] * sizemult
		if newBuilding["supply_area_distance"] > 64 then
			newBuilding["supply_area_distance"] = 64
		end
	end
	if newBuilding["allowed_effects"] then
		newBuilding["allowed_effects"] = {"consumption", "speed", "productivity", "pollution"}
	end
	if newBuilding["crafting_speed"] then
		newBuilding["crafting_speed"] = newBuilding["crafting_speed"] * statmult
	end
	if newBuilding["researching_speed"] then
		newBuilding["researching_speed"] = newBuilding["researching_speed"] * statmult
	end
	if newBuilding["mining_speed"] then
		newBuilding["mining_speed"] = newBuilding["mining_speed"] * statmult
	end
	if newBuilding["distribution_effectivity"] then
		newBuilding["distribution_effectivity"] = newBuilding["distribution_effectivity"] * statmult
	end
	if newBuilding["inventory_size"] then
		newBuilding["inventory_size"] = newBuilding["inventory_size"] * statmult
	end
	if newBuilding["max_distance_of_sector_revealed"] then
		newBuilding["max_distance_of_sector_revealed"] = newBuilding["max_distance_of_sector_revealed"] * sizemult
	end
	if newBuilding["max_distance_of_nearby_sector_revealed"] then
		newBuilding["max_distance_of_nearby_sector_revealed"] = newBuilding["max_distance_of_nearby_sector_revealed"] * sizemult
	end
	if newBuilding["attack_parameters"] then
		local attackParams = newBuilding["attack_parameters"]
		if attackParams["range"] then
			attackParams["range"] = attackParams["range"] * sizemult
		end
		local overallDPSChange = 1
		if attackParams["cooldown"] then
			attackParams["cooldown"] = attackParams["cooldown"] * sizemult
			overallDPSChange = overallDPSChange / sizemult
		end
		if attackParams["min_range"] then
			attackParams["min_range"] = attackParams["min_range"] * sizemult
		end
		if attackParams["damage_modifier"] then
			attackParams["damage_modifier"] = attackParams["damage_modifier"] * statmult
			overallDPSChange = overallDPSChange * statmult
		end
		if overallDPSChange < statmult then
			if attackParams["damage_modifier"] then
				attackParams["damage_modifier"] = attackParams["damage_modifier"] * statmult / overallDPSChange
			elseif attackParams["cooldown"] then
				attackParams["cooldown"] = attackParams["cooldown"] * overallDPSChange / statmult
			end
			overallDPSChange = statmult
		end
	end
	if newBuilding["construction_radius"] then
		newBuilding["construction_radius"] = newBuilding["construction_radius"] * sizemult
	end
	if newBuilding["logistics_radius"] then
		newBuilding["logistics_radius"] = newBuilding["logistics_radius"] * sizemult
	end
	if newBuilding["logistics_connection_distance"] then
		newBuilding["logistics_connection_distance"] = newBuilding["logistics_connection_distance"] * sizemult
	end
	if newBuilding["charging_energy"] then
		newBuilding["charging_energy"] = scaleWhatMightBeANumberOrAString(newBuilding["charging_energy"], statmult)
	end
	if newBuilding["robot_slots_count"] then
		newBuilding["robot_slots_count"] = newBuilding["robot_slots_count"] * sizemult
	end
	if newBuilding["charging_station_count"] and newBuilding["charging_station_count"] > 0 then
		newBuilding["charging_station_count"] = newBuilding["charging_station_count"] * sizemult
	elseif newBuilding["charging_offsets"] then
		local newSlots = {}
		local chargerMult = statmult
		if #newBuilding["charging_offsets"] then
			if #newBuilding["charging_offsets"] * statmult > 255 then
				for i = statmult, 1, -1 do
					if #newBuilding["charging_offsets"] * i <= 255 then
						chargerMult = i
						break
					end
				end
			end
		end
		for i, offset in pairs(newBuilding["charging_offsets"]) do
			if offset.x then
				for j = 2, chargerMult do
					table.insert(newSlots, {x = offset.x * j, y = offset.y * j})
				end
			else
				for j = 2, chargerMult do
					table.insert(newSlots, {offset[1] * j, offset[2] * j})
				end
			end
		end
		for i, offset in pairs(newSlots) do
			table.insert(newBuilding["charging_offsets"], offset)
		end
	end
	if newBuilding["recharge_minimum"] then
		newBuilding["recharge_minimum"] = scaleWhatMightBeANumberOrAString(newBuilding["recharge_minimum"], statmult)
	end

	if hasTech then
		--[[table.insert(data.raw["technology"][technology.name].effects, {type = "unlock-recipe", recipe = newRecipe.name})
		table.insert(data.raw["technology"][technology.name].effects, {type = "unlock-recipe", recipe = newRecipe_2.name})
		table.insert(data.raw["technology"][technology.name].effects, {type = "unlock-recipe", recipe = newRecipe_3.name})--]]
		pushRecipeToTechnology(newRecipe)
		pushRecipeToTechnology(newRecipe_2)
		pushRecipeToTechnology(newRecipe_3)
		if key:match("boiler") then
			--log(key..": "..serpent.block(indexTable.technologyStack))
		end
	else
		--log("[chp2001]: "..newRecipe.name.." has no tech")
	end
	local spamLog = false
	if hasRecipe then
		data:extend({newRecipe, newRecipe_2, newRecipe_3})
		if spamLog then log("[chp2001]: Added recipe "..newRecipe.name.." and "..newRecipe_2.name.." and "..newRecipe_3.name) end
		--[[log(serpent.block(data.raw.recipe[newRecipe.name]))
		log(serpent.block(data.raw.recipe[newRecipe_2.name]))
		log(serpent.block(data.raw.recipe[newRecipe_3.name]))
		log(serpent.block(data.raw.recipe[recipe.name]))--]]
	end
	if hasItem then
		if newItem["subgroup"] == "inserter" then
			newItem["subgroup"] = "heavy-inserter"
		end
		data:extend({newItem})
		if spamLog then log("[chp2001]: Added item "..newItem.name) end
	else
		error("Entity "..key.." has no item")
	end
	if newBuilding["type"] == "inserter" then
		heavyInserters[newBuilding.name] = newBuilding
	end
	data:extend({newBuilding})
	if key == "se-meteor-point-defence" then
		local stringy = serpent.block(newBuilding)
		stringy = stringy .. "\n"
		stringy = stringy .. serpent.block(newRecipe)
		stringy = stringy .. "\n"
		stringy = stringy .. serpent.block(newItem)
		error(stringy)
	end
	if spamLog then log("[chp2001]: Added building "..newBuilding.name) end
	buildingsToAdd[newBuilding.name] = newBuilding
	--if key == "electric-mining-drill" then
		--log(serpent.block(newBuilding))
	--end
	if key == "pumpjack" then
		--log(serpent.block(newBuilding))
	end
	

	::continue::
end

--Make duplicate, unselectable, unmineable, and undamageable versions of all the inserters
for key, inserter in pairs(heavyInserters) do
	local newName = key .. "-helper"
	local newBuilding = util.table.deepcopy(inserter)
	newBuilding.name = newName
	newBuilding.minable = nil
	newBuilding.selectable_in_game = false
	newBuilding.flags = {"not-deconstructable", "not-on-map", "not-repairable", "not-blueprintable", "not-flammable", "not-rotatable", "not-selectable-in-game"}
	--newBuilding.selection_box = {{0,0},{0,0}}
	--newBuilding.collision_box = {{0,0},{0,0}}
	--newBuilding.collision_mask = {}
	newBuilding.mined_sound = nil
	newBuilding.dying_explosion = nil
	newBuilding.corpse = nil
	if key == "burner-inserter-2x" then
		newBuilding.energy_per_movement = nil
		newBuilding.energy_per_rotation = nil
	end

	--No recipe or item needed
	--No technology needed
	--Only add the building
	data:extend({newBuilding})
end

end