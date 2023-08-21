local tab = require("lib/tablefunc") or {}
--local table = tab.copy(table) or {}
do
    require("prototypes.heavy_inserters")
    require("lib/lib_centralized")
    proto = proto or {}
    --local manip = require("lib/manipulate_globals")
    
    --manip.save()
end
--table = tab.merge(table, tab)
local bManip = {}

function bManip.spamProtoCacheToLog()
    local targetTable = proto.cache_resizedata
    local str = ""
    local indentStr = "  "
    local function indent(level)
        if level < 1 then return "" end
        local tstr = ""
        for i = 1, level do
            tstr = tstr .. indentStr
        end
        return tstr
    end
    --Want to print a json-compatible table
    local recurs_json = function(t, d) return end --temp declaration
    local function recurs_json_table(t, d)
        local rstr = "{\n"
        local first = true
        for i, val in pairs(t) do
            if first then
                first = false
            else
                rstr = rstr .. ",\n"
            end
            rstr = rstr .. indent(d) .. "\"" .. i .. "\": "
            rstr = rstr .. recurs_json(val, d + 1)
        end
        rstr = rstr .. "\n" .. indent(d - 1) .. "}"
        return rstr
    end
    local function recurs_json_value(v, d)
        local rstr = ""
        if type(v) == "string" then
            rstr = rstr .. "\"" .. v .. "\""
        elseif type(v) == "number" then
            rstr = rstr .. v
        elseif type(v) == "boolean" then
            rstr = rstr .. tostring(v)
        else
            rstr = rstr .. "\""..serpent.line(v).."\""
        end
        return rstr
    end
    local function recurs_json_set(t, d)
        --Used for tables that have string keys, and true values
        local rstr = "{\n"
        local first = true
        for i, val in pairs(t) do
            if first then
                first = false
            else
                rstr = rstr .. ",\n"
            end
            rstr = rstr .. indent(d) .. "\"" .. i .. "\""
        end
        rstr = rstr .. "\n" .. indent(d - 1) .. "}"
        return rstr
    end
    recurs_json = function (t, d)
        --driver function, calls the appropriate function based on type
        if type(t) == "table" then
            local isSet = true
            for i, val in pairs(t) do
                if type(val) ~= "boolean" or val ~= true then
                    isSet = false
                    break
                end
            end
            if isSet then
                return recurs_json_set(t, d)
            else
                return recurs_json_table(t, d)
            end
        else
            return recurs_json_value(t, d)
        end
    end
    str = str .. recurs_json(targetTable, 1)
    log("\nCHP table:\n"..str.."\n\n")
end
bManip.active = false
bManip.delayed = false
function bManip.setActive(active)
    log("bManip.setActive("..tostring(active)..")")
    if active then
        bManip.active = true
    else
        bManip.active = false
    end
end
function bManip.setDelayed(delayed)
    log("bManip.setDelayed("..tostring(delayed)..")")
    if delayed then
        bManip.delayed = true
    else
        bManip.delayed = false
    end
end
bManip.datatable = {}
bManip.pushed = 0
function bManip.pushData(datum)
    local keylists = {}
    for i, val in pairs(datum) do
        --table.insert(keylists, tab.getKeys(val))
        table.insert(keylists, {val.name, val.type})
    end
    --log("Pushing datum: "..serpent.line(tab.getKeys(datum))..",\n".."Datum contains: "..serpent.line(keylists))
    if not bManip.active or bManip.delayed then
        table.insert(bManip.datatable, datum)
    else
        data:extend(datum)
        bManip.pushed = bManip.pushed + 1
        if bManip.pushed % 100 == 0 then
            log("Pushed "..bManip.pushed.." items")
        end
    end
end
function bManip.finalize()
    log("Finalizing")
    for i, datum in pairs(bManip.datatable) do
        data:extend(datum)
        bManip.pushed = bManip.pushed + 1
        if bManip.pushed % 100 == 0 then
            log("Pushed "..bManip.pushed.." items")
        end
    end
    bManip.datatable = {}
    local subgroups = {}
    for name, val in pairs(data.raw["item-subgroup"]) do
        if not subgroups[name] then
            subgroups[name] = val.group
        end
    end
    local missing_subgroups = {}
    for name, item in pairs(data.raw.item) do
        if item.subgroup and not subgroups[item.subgroup] then
            if not missing_subgroups[item.subgroup] then
                missing_subgroups[item.subgroup] = true
            end
        end
    end
    for name, val in pairs(missing_subgroups) do
        --check if it's a multiplier subgroup.
        --i.e. if it's something like inserter-2x, inserter-3x, etc.
        --if it is, we create a new subgroup with the same group, and the missing name
        --if it isn't, do nothing
        local multiplier = name:match("(.+)-%d+x")
        if multiplier then
            local group = subgroups[multiplier]
            if group then
                local order_old = data.raw["item-subgroup"][multiplier].order
                local order_new = order_old .. "-" .. name
                data:extend{
                    {
                        type = "item-subgroup",
                        name = name,
                        group = group,
                        order = order_new,
                    }
                }
            end
        end
    end
end
bManip.cache = {}
bManip.bData = {}
--bManip.bMethods = {}
if not data then
    return bManip
end

function bManip.enforce_localization(proto, originalName, scale)
    --Take prototype, ensure that it has a localised name and description
    --If it doesn't, create a localised name and description from the prototype's name
    if table_size(tab.getAlphaKeys(proto)) == 0 then
        for i, val in pairs(proto) do
            bManip.enforce_localization(val, originalName, scale)
        end
        return
    end
    local prepend = {"","("}
    local postpend = {")", "-"..scale.."x"}
    local base_name = {"entity-name."..originalName}
    local proper_name = tab.extend(prepend, base_name)
    proper_name = tab.extend(proper_name, postpend) 
    if not proto.localised_name then
        proto.localised_name = proper_name
    elseif type(proto.localised_name) == "string" then
        local current_name = {{proto.localised_name}}
        proto.localised_name = tab.extend(prepend, current_name)
        proto.localised_name = tab.extend(proto.localised_name, postpend)
    elseif type(proto.localised_name) == "table" then
        proto.localised_name = {proto.localised_name}
        proto.localised_name = tab.extend(prepend, proto.localised_name)
        proto.localised_name = tab.extend(proto.localised_name, postpend)
    end
    if not proto.localised_description then
        proto.localised_description = proper_name
    elseif type(proto.localised_description) == "string" then
        local current_name = {{proto.localised_description}}
        proto.localised_description = tab.extend(prepend, current_name)
        proto.localised_description = tab.extend(proto.localised_description, postpend)
    elseif type(proto.localised_description) == "table" then
        proto.localised_description = {proto.localised_description}
        proto.localised_description = tab.extend(prepend, proto.localised_description)
        proto.localised_description = tab.extend(proto.localised_description, postpend)
    end
end

---@class bManip.bData.buildingData
---@field name string
---@field category string
---@field scale number
---@field item table
---@field entity table
---@field recipe table
---@field recipes table
---@field tech table
---@field base_game boolean
---@field base_game_name string
---@field original bManip.bData.buildingData --Only used for base_game = false
---@field pushed boolean --Only used for base_game = false
---@field checklist table --Only used for base_game = false
--
---@field hasEntity fun(buildingData:bManip.bData.buildingData):boolean
---@field hasItem fun(buildingData:bManip.bData.buildingData):boolean
---@field hasRecipe fun(buildingData:bManip.bData.buildingData):boolean
---@field hasTech fun(buildingData:bManip.bData.buildingData):boolean
--
---@field linkEntity fun(buildingData:bManip.bData.buildingData, entity:table)
---@field linkItem fun(buildingData:bManip.bData.buildingData, item:table)
---@field linkRecipe fun(buildingData:bManip.bData.buildingData, recipe:table)
---@field linkTech fun(buildingData:bManip.bData.buildingData, tech:table)
---@field linkOriginal fun(buildingData:bManip.bData.buildingData, original:bManip.bData.buildingData)
--
---@field scaleCopy fun(buildingData:bManip.bData.buildingData, scale:number):bManip.bData.buildingData
function bManip.bData.newBuildingData(base_game, base_game_name)
    local newBuildingData = {
        name = base_game_name,
        category = "",
        scale = 1,
        item = {},
        entity = {},
        recipe = {},
        recipes = {},
        tech = {},
        base_game = base_game,
        base_game_name = base_game_name,
        original = nil,
        pushed = base_game,
        checklist = {},
    }
    for i, val in pairs(bManip.bData) do
        if type(val)=="function" then
            newBuildingData[i] = val
        end
    end
    return newBuildingData
end
bManip.newBuildingData = bManip.bData.newBuildingData

--bManip.bData.linkEntity: Links the entity to the buildingData
---@param buildingData bManip.bData.buildingData
---@param entity table
function bManip.bData.linkEntity(buildingData, entity)
    buildingData.entity = entity
    if not buildingData.name then
        if entity.name then
            buildingData.name = entity.name
        else
            buildingData.name = entity[1].name
        end
    end
end

--bManip.bData.linkItem: Links the item to the buildingData
---@param buildingData bManip.bData.buildingData
---@param item table
function bManip.bData.linkItem(buildingData, item)
    buildingData.item = item
    if not buildingData.name then
        buildingData.name = item.name
    end
end

--bManip.bData.linkRecipe: Links the recipe to the buildingData
---@param buildingData bManip.bData.buildingData
---@param recipe table
function bManip.bData.linkRecipe(buildingData, recipe)
    --Check if single recipe of format {name = "recipe-name", recipe = recipe}
    --Or list of recipes of format {{name = "recipe-name", recipe = recipe}, ...}
    if recipe.recipe then
        buildingData.recipe = recipe
        buildingData.recipes = {recipe}
    else
        buildingData.recipe = recipe[1]
        buildingData.recipes = recipe
    end
    if not buildingData.name then
        buildingData.name = recipe.name
    end
end

--bManip.bData.linkTech: Links the tech to the buildingData
---@param buildingData bManip.bData.buildingData
---@param tech table
function bManip.bData.linkTech(buildingData, tech)
    buildingData.tech = tech
    if not buildingData.name then
        buildingData.name = tech.name
    end
end

--bManip.bData.linkOriginal: Links the original buildingData to the buildingData
---@param buildingData bManip.bData.buildingData
---@param original bManip.bData.buildingData
function bManip.bData.linkOriginal(buildingData, original)
    buildingData.original = original
end


--bManip.bData.hasEntity: Returns true if the buildingData has an entity
---@param buildingData bManip.bData.buildingData
---@return boolean
function bManip.bData.hasEntity(buildingData)
    return buildingData.entity and table_size(buildingData.entity) > 0
end
--bManip.bMethods.hasEntity = bManip.bData.hasEntity

--bManip.bData.hasItem: Returns true if the buildingData has an item
---@param buildingData bManip.bData.buildingData
---@return boolean
function bManip.bData.hasItem(buildingData)
    return buildingData.item and table_size(buildingData.item) > 0
end
--bManip.bMethods.hasItem = bManip.bData.hasItem

--bManip.bData.hasRecipe: Returns true if the buildingData has a recipe
---@param buildingData bManip.bData.buildingData
---@return boolean
function bManip.bData.hasRecipe(buildingData)
    return buildingData.recipe and table_size(buildingData.recipe) > 0
end
--bManip.bMethods.hasRecipe = bManip.bData.hasRecipe

--bManip.bData.hasTech: Returns true if the buildingData has a tech
---@param buildingData bManip.bData.buildingData
---@return boolean
function bManip.bData.hasTech(buildingData)
    return buildingData.tech and table_size(buildingData.tech) > 0
end
--bManip.bMethods.hasTech = bManip.bData.hasTech


---bManip.generatePlaceResultList: Checks all items for place_result, and returns a list of placeable items
---@return table
function bManip.generatePlaceResultList()
    if bManip.cache.placeResultList then return bManip.cache.placeResultList end
    local buildingList = {}
    --couple potential gotchas:
    -- 1. some entities have multiple items that can place them
    for _, item in pairs(data.raw.item) do
        if item.flags and tab.contains(item.flags, "hidden") then goto skipitem end
        if item.place_result then
            buildingList[item.name] = item.place_result
        end
        ::skipitem::
    end
    bManip.cache.placeResultList = buildingList
    return buildingList
end

---bManip.parseRecipeResultTable: Takes a recipe result table, and ensures proper formatting
---@param results table
---@return table
function bManip.parseRecipeResultTable(results)
    local parsedResults = {}
    --Common formats:
    -- 1. {name = "item-name", amount = 1}
    for i, result in pairs(results) do
        local res = {}
        for ind, val in pairs(result) do
            if ind==1 then
                res.name = val
            elseif ind==2 then
                res.amount = val
            else
                res[ind] = val
            end
        end
        parsedResults[i] = res
    end
    return parsedResults
end

---bManip.getRecipeResults: Returns a list of items that the recipe produces
---@param recipeKey string
---@param recipe table
---@return table
function bManip.getRecipeResults(recipeKey, recipe)
    if bManip.cache.recipeResults and bManip.cache.recipeResults[recipeKey] then
        return bManip.cache.recipeResults[recipeKey]
    end
    local results = {}
    --sometimes, relevant data is hidden in the "normal" or "expensive" tables
    
    if recipe.result then
        results = {{name=recipe.result, amount=recipe.result_count or 1}}
        goto done
    end
    if recipe.results then
        results = bManip.parseRecipeResultTable(recipe.results)
        goto done
    end
    if recipe.normal then
        if recipe.normal.result then
            results = {{name=recipe.normal.result, amount=recipe.normal.result_count or 1}}
            goto done
        end
        if recipe.normal.results then
            results = bManip.parseRecipeResultTable(recipe.normal.results)
            goto done
        end
    end
    if recipe.expensive then
        if recipe.expensive.result then
            results = {{name=recipe.expensive.result, amount=recipe.expensive.result_count or 1}}
            goto done
        end
        if recipe.expensive.results then
            results = bManip.parseRecipeResultTable(recipe.expensive.results)
            goto done
        end
    end
    ::done::
    if bManip.cache.recipeResults then
        bManip.cache.recipeResults[recipeKey] = results
    else
        bManip.cache.recipeResults = {[recipeKey] = results}
    end
    return results
end


---bManip.parseRecipeIngredientTable: Takes a recipe ingredient table, and ensures proper formatting
---@param ingredients table
---@return table
function bManip.parseRecipeIngredientTable(ingredients)
    local parsedIngredients = {}
    --Common formats:
    -- 1. {name = "item-name", amount = 1}
    for i, ingredient in pairs(ingredients) do
        local ing = {}
        for ind, val in pairs(ingredient) do
            if ind==1 then
                ing.name = val
            elseif ind==2 then
                ing.amount = val
            else
                ing[ind] = val
            end
        end
        parsedIngredients[i] = ing
    end
    return parsedIngredients
end


---bManip.getRecipeIngredients: Returns a list of items that the recipe requires
---@param recipeKey string
---@param recipe table
---@return table
function bManip.getRecipeIngredients(recipeKey, recipe)
    if bManip.cache.recipeIngredients and bManip.cache.recipeIngredients[recipeKey] then
        return bManip.cache.recipeIngredients[recipeKey]
    end
    local ingredients = {}
    --sometimes, relevant data is hidden in the "normal" or "expensive" tables
    if recipe.ingredients then
        ingredients = bManip.parseRecipeIngredientTable(recipe.ingredients)
        goto done
    end
    if recipe.normal then
        if recipe.normal.ingredients then
            ingredients = bManip.parseRecipeIngredientTable(recipe.normal.ingredients)
            goto done
        end
    end
    if recipe.expensive then
        if recipe.expensive.ingredients then
            ingredients = bManip.parseRecipeIngredientTable(recipe.expensive.ingredients)
            goto done
        end
    end
    ::done::
    if bManip.cache.recipeIngredients then
        bManip.cache.recipeIngredients[recipeKey] = ingredients
    else
        bManip.cache.recipeIngredients = {[recipeKey] = ingredients}
    end
    return ingredients
end


---bManip.generateRecipeTable: Checks all recipes for their products, and returns a list of recipes that produce the item
---@return table, table, table
function bManip.generateRecipeTableList()
    if bManip.cache.recipeList then return bManip.cache.recipeList, bManip.cache.recipeLookup, bManip.cache.itemFromRecipe end
    local recipeList = {}
    local recipeLookup = {}
    local itemFromRecipe = {}
    local itemList = bManip.generatePlaceResultList()
    for key, recipe in pairs(data.raw.recipe) do
        local results = bManip.getRecipeResults(key, recipe)
        for _, result in pairs(results) do
            if itemList[result.name] then
                if not recipeList[result.name] then
                    recipeList[result.name] = {}
                    recipeLookup[result.name] = {}
                end
                if not itemFromRecipe[key] then
                    itemFromRecipe[key] = {}
                end
                table.insert(itemFromRecipe[key], result.name)
                table.insert(recipeList[result.name], {name=key, recipe=recipe})
                recipeLookup[result.name][key] = true
            end
        end
    end
    --try to clean up the recipeList
    --If any entry has a list of 1 recipe, we can just use the recipe directly instead of a table
    --If any entry has a list where a recipe has the same name as the item, we can just use the recipe directly instead of a table
    for item, recipes in pairs(recipeList) do
        if #recipes == 1 then
            recipeList[item] = recipes[1]
        else
            for i, recipe in pairs(recipes) do
                if recipe[1] == item then
                    recipeList[item] = recipe
                    break
                end
            end
        end
    end
    bManip.cache.recipeList = recipeList
    bManip.cache.recipeLookup = recipeLookup
    bManip.cache.itemFromRecipe = itemFromRecipe
    return recipeList, recipeLookup, itemFromRecipe
end

---bManip.generateTechTableList: Checks all technologies for their effects, and returns a list of technologies that unlock the item
---@return table
function bManip.generateTechTableList()
    if bManip.cache.techList then return bManip.cache.techList end
    local techList = {}
    local itemList = bManip.generatePlaceResultList()
    local recipeList, recipeLookup, itemFromRecipe = bManip.generateRecipeTableList()
    for key, tech in pairs(data.raw.technology) do
        if not tech.effects then goto skiptech end
        for _, effect in pairs(tech.effects) do
            if effect.type == "unlock-recipe" then
                local recipeKey = effect.recipe
                if itemFromRecipe[recipeKey] then
                    for _, item in pairs(itemFromRecipe[recipeKey]) do
                        if not techList[item] then
                            techList[item] = {}
                        end
                        table.insert(techList[item], {name=key, tech=tech})
                    end
                end
            end
        end
        ::skiptech::
    end
    --technologies --cannot-- can unlock the same item twice
    -- for item, techs in pairs(techList) do
        
    --         techList[item] = techs[1]
    -- end
    bManip.cache.techList = techList
    return techList
end

---bManip.generateEntityTableList: Check through all categories for entities that match the placeResultList
---@return table
function bManip.generateEntityTableList()
    if bManip.cache.entityList then return bManip.cache.entityList end
    local entityList = {}
    local itemList = bManip.generatePlaceResultList()
    local endstr = ""
    for catname, category in pairs(data.raw) do
        for entityname, entity in pairs(category) do
            if entityname:match("-spaced") then goto skipentity end
            if not tab.containsKey(entity, "minable") then goto skipentity end
            if not tab.containsKey(entity.minable, "result") then goto skipentity end
            local itemname = entity.minable.result
            if itemList[itemname] then
                if not entityList[itemname] then
                    entityList[itemname] = {}
                end
                table.insert(entityList[itemname], {name=entityname, entity=entity, category=catname})
                endstr = endstr .. entityname .. ", "
            end
            ::skipentity::
        end
    end
    log("Found entities: "..endstr)
    bManip.cache.entityList = entityList
    return entityList
end

---bManip.generateItemList: Takes the placeResultList, and gets the item data for each item
---@return table
function bManip.generateItemList()
    if bManip.cache.itemList then return bManip.cache.itemList end
    local itemList = {}
    local placeResultList = bManip.generatePlaceResultList()
    for itemname, placeResult in pairs(placeResultList) do
        local item = data.raw.item[itemname]
        if item then
            itemList[itemname] = item
        end
    end
    bManip.cache.itemList = itemList
    return itemList
end

---bManip.generateBuildingDataList: Generates a list of buildingData for all items that can be placed
---@return table
function bManip.generateBuildingDataList()
    if bManip.cache.buildingDataList then return bManip.cache.buildingDataList end
    local buildingDataList = {}
    local itemList = bManip.generateItemList()
    local recipeList, recipeLookup, itemFromRecipe = bManip.generateRecipeTableList()
    local techList = bManip.generateTechTableList()
    local entityList = bManip.generateEntityTableList()
    local accepted = 0
    local discarded = 0
    local discarded_missing_item = 0
    local discarded_missing_entity = 0
    local discarded_missing_recipe = 0
    local discarded_missing_tech = 0
    local first = false
    for itemname, item in pairs(itemList) do
        local buildingData = bManip.newBuildingData(true, itemname)
        if recipeList[itemname] then
            buildingData:linkRecipe(recipeList[itemname])
        end
        if techList[itemname] then
            -- local entry = techList[itemname]
            -- local tech = entry.tech
            buildingData:linkTech(techList[itemname])
        end
        if entityList[itemname] then
            local entry = entityList[itemname]
            local entity = entry
            if entity.entity then
                entity = entity.entity
            else
                entity = {}
                for i, val in pairs(entry) do
                    table.insert(entity, val.entity)
                end
            end
            local category = entry.category
            if not entry.category then
                category = entry[1].category
            end
            buildingData:linkEntity(entity)
            buildingData.category = category
        end
        if item then
            buildingData:linkItem(item)
        end
        if buildingData:hasEntity() and buildingData:hasItem() and buildingData:hasRecipe() then
            buildingDataList[itemname] = buildingData
            accepted = accepted + 1
        else
            local reasons = {}
            discarded = discarded + 1
            if not buildingData:hasItem() then
                discarded_missing_item = discarded_missing_item + 1
                table.insert(reasons, "missing item")
            end
            if not buildingData:hasEntity() then
                discarded_missing_entity = discarded_missing_entity + 1
                table.insert(reasons, "missing entity")
            end
            if not buildingData:hasRecipe() then
                discarded_missing_recipe = discarded_missing_recipe + 1
                table.insert(reasons, "missing recipe")
            end
            if not buildingData:hasTech() then
                discarded_missing_tech = discarded_missing_tech + 1
                table.insert(reasons, "missing tech")
            end
            if buildingData.name:match("logistic-chest") or first then
                error("Discarded "..buildingData.name.." for "..table.concat(reasons, ", ").."\n"..serpent.block(buildingData.entity))
                first = false
            end
        end
    end
    log("Accepted: "..accepted..", Discarded: "..discarded..", Missing Item: "..discarded_missing_item..", Missing Entity: "..discarded_missing_entity..", Missing Recipe: "..discarded_missing_recipe..", Missing Tech: "..discarded_missing_tech)
    bManip.cache.buildingDataList = buildingDataList
    return buildingDataList
end

---bManip.bData.scaleCopy: Creates a copy of the buildingData, with the scale changed
---@param buildingData bManip.bData.buildingData
---@param scale number
---@return bManip.bData.buildingData
function bManip.bData.scaleCopy(buildingData, scale)
    local newBuildingData = bManip.newBuildingData(false, buildingData.base_game_name)
    newBuildingData.name = buildingData.name.."-"..scale.."x"
    newBuildingData.category = buildingData.category
    newBuildingData.scale = scale
    newBuildingData.item = tab.copy(buildingData.item)
    newBuildingData.entity = tab.copy(buildingData.entity)
    newBuildingData.recipe = tab.copy(buildingData.recipe)
    newBuildingData.recipes = tab.copy(buildingData.recipes)
    newBuildingData.tech = buildingData.tech
    newBuildingData.original = buildingData
    newBuildingData.pushed = false
    newBuildingData.checklist = {item = false, entity = false, recipe = false, tech = false}
    return newBuildingData
end

---bManip.splitNumString: Splits a string into a number and a unit
---@param value string
---@return number, string
function bManip.splitNumString(value)
    --value is a string
    local unit = string.match(value, "%a+")
    local number = string.sub(value, 1, string.len(value) - string.len(unit))
    return (tonumber(number) or 0), unit
end

---bManip.scaleNumString: Scales a number or number string by the scale
---@param value number|string|table
---@param scale number
---@return number|string|table
function bManip.scaleNumString(value, scale)
    if value == nil then
        return 0
    end
    if type(value) == "number" then
        return value * scale
    elseif type(value) == "string" then
        local targetString = value
        local number, unit = bManip.splitNumString(targetString)
        return number * scale .. unit
    elseif type(value) == "table" then
        local targetTable = value
        for i, val in pairs(targetTable) do
            targetTable[i] = bManip.scaleNumString(val, scale)
        end
        return targetTable
    end
    return value * scale
end


---bManip.bData.handleHeavyInserter: For larger inserters, creates helper objects and pushes them to the data.raw table
---@param buildingData bManip.bData.buildingData
function bManip.bData.handleHeavyInserter(buildingData)
    local key = buildingData.name
    local newName = key.."-helper"
    local newBuildings = tab.copy(buildingData.entity)
    for i, newBuilding in pairs(newBuildings) do
        newBuilding.name = newName
        newBuilding.minable = nil
        newBuilding.selectable_in_game = false
        newBuilding.flags = {"not-deconstructable", "not-on-map", "not-repairable", "not-blueprintable", "not-flammable", "not-rotatable", "not-selectable-in-game"}
        newBuilding.mined_sound = nil
        newBuilding.dying_explosion = nil
        newBuilding.corpse = nil
        if key:match("burner") then
            newBuilding.energy_per_movement = nil
            newBuilding.energy_per_rotation = nil
        end
    end
    -- local keys = {}
    -- for k, v in pairs(newBuildings) do
    --     table.insert(keys, k)
    -- end
    -- error("Keys were "..serpent.block(keys))
    --error("Pushing "..newName.." size: "..table_size(buildingData).." entity "..serpent.block(newBuilding))
    bManip.pushData(newBuildings)

end


---bManip.bData.scaleItem: If not pushed, checks checklist, and changes the scale of the item
---@param buildingData bManip.bData.buildingData
function bManip.bData.scaleItem(buildingData)
    if buildingData.pushed then return end
    if buildingData.checklist.item then return end
    if buildingData.scale==1 then return end
    buildingData.checklist.item = true
    buildingData.item.name = buildingData.item.name .. "-"..buildingData.scale.."x"
    buildingData.item.place_result = buildingData.name
    if buildingData.item.subgroup and buildingData.item.subgroup == "inserter" then
        if buildingData.scale == 2 then
            buildingData.item.subgroup = "heavy-inserter"
        else
            buildingData.item.subgroup = "inserter-"..buildingData.scale.."x"
        end
        --buildingData:handleHeavyInserter()
    end
    bManip.pushData({buildingData.item})
end

---bManip.bData.scaleEntity: If not pushed, checks checklist, and changes the scale of the entity
---@param buildingData bManip.bData.buildingData
function bManip.bData.scaleEntity(buildingData)
    if buildingData.pushed then return end
    if buildingData.checklist.entity then return end
    if buildingData.scale==1 then return end
    buildingData.checklist.entity = true
    if buildingData.entity.name then
        buildingData.entity.name = buildingData.name
        buildingData.entity.minable.result = buildingData.name
        bManip.scaleEntityStats(buildingData.entity, buildingData.scale)
        if buildingData.entity.type and buildingData.entity.type == "inserter" then
            if buildingData.scale == 2 then
                buildingData.item.subgroup = "heavy-inserter"
            else
                buildingData.item.subgroup = "inserter-"..buildingData.scale.."x"
            end
            buildingData:handleHeavyInserter()
        end
        bManip.pushData({buildingData.entity})
    else
        --Multiple entities
        for i, entity in pairs(buildingData.entity) do
            entity.name = buildingData.name
            entity.minable.result = buildingData.name
            bManip.scaleEntityStats(entity, buildingData.scale)
            if entity.type and entity.type == "inserter" then
                if buildingData.scale == 2 then
                    buildingData.item.subgroup = "heavy-inserter"
                else
                    buildingData.item.subgroup = "inserter-"..buildingData.scale.."x"
                end
                buildingData:handleHeavyInserter()
            end
        end
        bManip.pushData(buildingData.entity)
    end
end

---bManip.scaleEntityStats: Scales the stats of the entity
---@param entity table
---@param scale number
---@return nil --Modifies the entity directly
function bManip.scaleEntityStats(entity, scale)
    local configSettings = settings.startup
    local newSizeFunction = function (size, scl) return size * scl end
    local newAreaFunction = function (area, scl) return area * scl * scl end
    --local newMaterialCostFunction = load(configSettings["chpScaling-newMaterialCost-function"].value) or function (area, newArea, cost) return cost * (newArea / area) end
    local newStatDownsideFunction = function (area, newArea, scl, downside) return downside*math.ceil(math.pow(scl,2.5)) end
    local newStatUpsideFunction = function (area, newArea, scl, upside) return upside*math.ceil(math.pow(scl,2.5)) end
    local newStorageSizeFunction = function (size, scl) return size * math.ceil(math.pow(scl,2.5)) end
    local newModuleSlotsFunction = function (slots, scl) return slots * scl end
    
    local bbox=proto.GetSizableBBox(entity)
    local bbsize=vector.roundEx(proto.BBoxSize(bbox),2,true)
    local size = math.max(bbsize.x, bbsize.y)
    local area = bbsize.x * bbsize.y
    local scaleMult = scale or 1
    local newsize = newSizeFunction(size, scale)
    scaleMult = newsize / size
    proto.AutoResize_by_scale(entity, scale)
    local newarea = newAreaFunction(area, scale)
    local areaMult = newarea / area
    local newStatUpsideMult = newStatUpsideFunction(1, 1, scale, 1)
    local newStatDownsideMult = newStatDownsideFunction(1, 1, scale, 1)
    local newStorageSizeMult = newStorageSizeFunction(1, scale)
    local sizeRelatedKeys = {--Stat keys we want to scale based on scaleMult
        "pickup_position",
        "extension_speed",
        "max_distance_of_sector_revealed",
        "max_distance_of_nearby_sector_revealed",
        "construction_radius",
        "logistics_radius",
        "logistics_connection_distance",
        "robot_slots_count",
    }
    --Only one "material cost mult" related key, minable/mining_time, so we'll just do it manually
    entity.minable.mining_time = entity.minable.mining_time * areaMult
    local upsideRelatedKeys = {--Stat keys we want to scale based on newStatUpsideMult
        "resource_searching_radius",
        "max_health",
        "max_power_output",
        "production",
        "pumping_speed",
        "fluid_usage_per_tick",
        "crafting_speed",
        "researching_speed",
        "mining_speed",
        "distribution_effectivity",
        "charging_energy",
        "charging_station_count",
        "recharge_minimum"
    }

    local downsideRelatedKeys = {--Stat keys we want to scale based on newStatDownsideMult
        "energy_usage",
        "energy_consumption",
        "energy_per_movement",
        "energy_per_rotation",
    }

    local storageSizeRelatedKeys = {--Stat keys we want to scale based on newStorageSizeMult
        "inventory_size",
    }

    --Quickly apply mults to energy_source
    if entity["energy_source"] then
        local energy_source_keys = {"buffer_capacity", "input_flow_limit", "output_flow_limit"}
        for _, key in pairs(energy_source_keys) do
            if entity["energy_source"][key] then
                entity["energy_source"][key] = bManip.scaleNumString(entity["energy_source"][key], newStatUpsideMult)
            end
        end
        if entity["energy_source"]["fuel_inventory_size"] then
            entity["energy_source"]["fuel_inventory_size"] = entity["energy_source"]["fuel_inventory_size"] * newStorageSizeMult
        end
    end
    --multiply insert_position safely
    if entity["insert_position"] then
        local insert_pos = vector(entity["insert_position"])
        local rounded = vector.round(insert_pos)
        local offset = insert_pos - rounded
        entity["insert_position"] = vector.raw(rounded*scaleMult + offset)
    end
    --multiply fluid_box safely
    if entity["fluid_box"] then
        for key, val in pairs(entity["fluid_box"]) do
            if type(val)=="table" and val["base_area"] then
                val["base_area"] = val["base_area"] * areaMult
            end
        end
        if entity["fluid_box"]["base_area"] then
            entity["fluid_box"]["base_area"] = entity["fluid_box"]["base_area"] * areaMult
        end
    end
    --module slots
    if entity["module_specification"] then
        if entity["module_specification"]["module_slots"] then
            entity["module_specification"]["module_slots"] = newModuleSlotsFunction(entity["module_specification"]["module_slots"], scaleMult)
        end
    end
    if entity["supply_area_distance"] then
        entity["supply_area_distance"] = math.min(entity["supply_area_distance"] * scaleMult, 64)
    end
    --attack parameters
    if entity["attack_parameters"] then
        local params = entity["attack_parameters"]
        if params["range"] then
            params["range"] = params["range"] * scaleMult
        end
        local overallDPSChange = 1
        if params["cooldown"] then
            params["cooldown"] = params["cooldown"] * scaleMult
            overallDPSChange = overallDPSChange / scaleMult
        end
        if params["damage_modifier"] then
            params["damage_modifier"] = params["damage_modifier"] * scaleMult
            overallDPSChange = overallDPSChange * scaleMult
        end
        if overallDPSChange < newStatUpsideMult then
            if params["damage_modifier"] then
                params["damage_modifier"] = params["damage_modifier"] * (newStatUpsideMult / overallDPSChange)
            elseif params["cooldown"] then
                params["cooldown"] = params["cooldown"] * (overallDPSChange / newStatUpsideMult)
            end
            overallDPSChange = newStatUpsideMult
        end
    end
    --charging offsets
    if entity["charging_offsets"] then
        local newSlots = {}
        local chargerMult = newStatUpsideMult
        if #entity["charging_offsets"] * chargerMult > 255 then
            for i = chargerMult, 1, -1 do
                if #entity["charging_offsets"] * i <= 255 then
                    chargerMult = i
                    break
                end
            end
        end
        for i, offset in pairs(entity["charging_offsets"]) do
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
            table.insert(entity["charging_offsets"], offset)
        end
    end
    --remove next-upgrade-target
    if entity["next_upgrade"] then
        entity["next_upgrade"] = nil
    end
    --scale size-related keys
    for _, key in pairs(sizeRelatedKeys) do
        if entity[key] then
            entity[key] = bManip.scaleNumString(entity[key], scaleMult)
        end
    end
    --scale upside-related keys
    for _, key in pairs(upsideRelatedKeys) do
        if entity[key] then
            entity[key] = bManip.scaleNumString(entity[key], newStatUpsideMult)
        end
    end
    --scale downside-related keys
    for _, key in pairs(downsideRelatedKeys) do
        if entity[key] then
            entity[key] = bManip.scaleNumString(entity[key], newStatDownsideMult)
        end
    end
    -- local beforeStore=0
    -- if entity["inventory_size"] then
    --     beforeStore = entity["inventory_size"]
    -- end
    --scale storage size-related keys
    for _, key in pairs(storageSizeRelatedKeys) do
        if entity[key] then
            entity[key] = bManip.scaleNumString(entity[key], newStorageSizeMult)
        end
    end
    -- if entity["inventory_size"] then
    --     if entity["inventory_size"] > 3500 then
    --         local errorStr = "Entity "..entity.name.." has an inventory size of "..beforeStore
    --         errorStr = errorStr .. " before scaling, and "..entity["inventory_size"].." after scaling.\n"
    --         errorStr = errorStr .. "The storage multiplier was "..newStorageSizeMult..".\n"
    --         error(errorStr)
    --     end
    -- end
    if entity["fast_replaceable_group"] then
        entity["fast_replaceable_group"] = entity["fast_replaceable_group"] .. "-" .. scale .. "x"
    end

    
end


---bManip.generateNewRecipe: Generates a new recipe based on the old recipe
---@param oldRecipe table
---@param name string
---@param ingredients table
---@param products table
---@param mainProduct string
---@param kwarg table|nil
---@return table
function bManip.generateNewRecipe(oldRecipe, name, ingredients, products, mainProduct, kwarg)
    local ret_recipe = tab.copy(oldRecipe) or {}
    ret_recipe.normal=nil
    ret_recipe.expensive=nil
    ret_recipe.result = nil
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
        ret_recipe.enabled = oldRecipe.enabled
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

---bManip.bData.scaleRecipe: If not pushed, checks checklist, and changes the scale of the recipe
---@param buildingData bManip.bData.buildingData
function bManip.bData.scaleRecipe(buildingData)
    if buildingData.pushed then return end
    if buildingData.checklist.recipe then return end
    if buildingData.scale==1 then return end
    buildingData.checklist.recipe = true
    local recipe = buildingData.recipe.recipe
    local newRecipe = {}
    local configSettings = settings.startup
    --local newMaterialCostFunction = load(configSettings["chpScaling-newMaterialCost-function"].value) or function (area, newArea, cost) return cost * (newArea / area) end
    local newAreaFunction = function (area, scale) return area * scale * scale end
    local areaMult = newAreaFunction(1, buildingData.scale)
    local newMaterialCostMult = areaMult--newMaterialCostFunction(1, areaMult, 1)

    local oldIngredients = bManip.getRecipeIngredients(buildingData.name, recipe)
    local newIngredients = {}
    for _, ingredient in pairs(oldIngredients) do
        local newIngredient = tab.copy(ingredient)
        newIngredient.amount = bManip.scaleNumString(newIngredient.amount, newMaterialCostMult)
        table.insert(newIngredients, newIngredient)
    end
    local oldResults = bManip.getRecipeResults(buildingData.name, recipe)
    local newResults = {}
    for _, result in pairs(oldResults) do
        local newResult = tab.copy(result)
        if result.name == buildingData.base_game_name then
            newResult.name = buildingData.name
        else
            newResult.amount = bManip.scaleNumString(newResult.amount, newMaterialCostMult)
        end
        table.insert(newResults, newResult)
    end
    local mainProduct = buildingData.name
    --Primary recipe
    newRecipe = bManip.generateNewRecipe(recipe, recipe.name.."-"..buildingData.scale.."x", newIngredients, newResults, mainProduct)
    bManip.pushData({newRecipe})
    if buildingData:hasTech() then
        newRecipe.enabled = false
        for k, v in pairs(buildingData.tech) do
            local techEntry = v.tech
            table.insert(techEntry.effects, {type = "unlock-recipe", recipe = newRecipe.name})
        end
    end
    local smallToLargeRecipe = {}
    local largeToSmallRecipe = {}
    local smallIngredients = {{name=buildingData.original.name, amount=newMaterialCostMult}}
    local largeIngredients = {{name=buildingData.name, amount=1}}
    local kwarg = {energy_required = 1}
    --Make scaled version out of un-scaled version
    if buildingData.scale <= 1 then goto done end
    
    smallToLargeRecipe = bManip.generateNewRecipe(recipe, newRecipe.name.."-from-"..buildingData.original.name, smallIngredients, largeIngredients, mainProduct, kwarg)
    largeToSmallRecipe = bManip.generateNewRecipe(recipe, newRecipe.name.."-decompose", largeIngredients, smallIngredients, buildingData.original.name, kwarg)

    bManip.pushData({smallToLargeRecipe, largeToSmallRecipe})
    if buildingData:hasTech() then
        smallToLargeRecipe.enabled = false
        largeToSmallRecipe.enabled = false
        for k, v in pairs(buildingData.tech) do
            local techEntry = v.tech
            table.insert(techEntry.effects, {type = "unlock-recipe", recipe = smallToLargeRecipe.name})
            table.insert(techEntry.effects, {type = "unlock-recipe", recipe = largeToSmallRecipe.name})
        end
    end
    buildingData.recipes = {newRecipe, smallToLargeRecipe, largeToSmallRecipe}
    
    ::done::
    buildingData.checklist.recipe = true
    buildingData.checklist.tech = true
    buildingData.recipe = newRecipe
    -- if buildingData.name:match("wooden") then
    --     log(serpent.block(newRecipe))
    -- end
end

---bManip.bData.createScaledCopy: Creates a scaled copy of the buildingData
---@param buildingData bManip.bData.buildingData
---@param scale number
---@return bManip.bData.buildingData
function bManip.bData.createScaledCopy(buildingData, scale)
    local newBuildingData = bManip.bData.scaleCopy(buildingData, scale)
    bManip.bData.scaleRecipe(newBuildingData)
    bManip.bData.scaleEntity(newBuildingData)
    bManip.bData.scaleItem(newBuildingData)
    bManip.enforce_localization(newBuildingData.item, buildingData.name, scale)
    bManip.enforce_localization(newBuildingData.entity, buildingData.name, scale)
    bManip.enforce_localization(newBuildingData.recipe, buildingData.name, scale)
    return newBuildingData
end

---bManip.scaleAll: Generates buildingDataList, and scales all items
---@param scale number
---@param filter function|nil --If filter returns true, the item will be skipped
function bManip.scaleAll(scale, filter)
    local buildingDataList = bManip.generateBuildingDataList()
    local skipped = 0
    local notSkipped = 0
    for _, buildingData in pairs(buildingDataList) do
        if filter and filter(buildingData.name, buildingData) then 
            skipped = skipped + 1
            goto skipitem 
        end
        bManip.bData.createScaledCopy(buildingData, scale)
        notSkipped = notSkipped + 1
        ::skipitem::
    end
    log("Skipped "..skipped.." items, scaled "..notSkipped.." items")
    for i, val in pairs(bManip.cache) do
        log("Cache "..i.." has "..table_size(val).." entries")
    end
    if notSkipped == 0 then
        error("No items were scaled")
    end
end

return bManip