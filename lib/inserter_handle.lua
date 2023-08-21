local Inserter_Handler = {}
require("lib/lib_centralized")
local function register_function_create(scriptVar, defineVar, functionVar, filterVar)
    scriptVar.on_event(defineVar.events.on_built_entity, functionVar, filterVar)
    scriptVar.on_event(defineVar.events.on_robot_built_entity, functionVar, filterVar)
    scriptVar.on_event(defineVar.events.script_raised_built, functionVar, filterVar)
    scriptVar.on_event(defineVar.events.script_raised_revive, functionVar, filterVar)
    scriptVar.on_event(defineVar.events.on_entity_cloned, functionVar, filterVar)
end
local function register_function_destroy(scriptVar, defineVar, functionVar, filterVar)
    scriptVar.on_event(defineVar.events.on_player_mined_entity, functionVar, filterVar)
    scriptVar.on_event(defineVar.events.on_robot_mined_entity, functionVar, filterVar)
    scriptVar.on_event(defineVar.events.on_entity_died, functionVar, filterVar)
    scriptVar.on_event(defineVar.events.script_raised_destroy, functionVar, filterVar)
end

--Script will be required from the control.lua stage, so we can register script events here.
Inserter_Handler.event_filters = {{filter="type", type="inserter"}}
function Inserter_Handler.is_scaled_inserter(inserter)
    return string.match(inserter.name, "-[%A]+x$")
end
function Inserter_Handler.get_all_scaled_inserters()
    local scaled_inserters = {}
    for ind, surface in pairs(game.surfaces) do
        local all_inserters = surface.find_entities_filtered{type="inserter"}
        for ind1, inserter in pairs(all_inserters) do
            if Inserter_Handler.is_scaled_inserter(inserter) then
                table.insert(scaled_inserters, inserter)
            end
        end
    end
    return scaled_inserters
end
function Inserter_Handler.on_init()
    global.scaled_inserters = {}
    global.scaled_inserter_data = {}
end
script.on_init(Inserter_Handler.on_init)
function Inserter_Handler.on_configuration_changed(event)
    if not global.scaled_inserters then
        global.scaled_inserters = {}
        global.scaled_inserter_data = {}
    end
end
script.on_configuration_changed(Inserter_Handler.on_configuration_changed)
function Inserter_Handler.register_inserter(inserter)
    --assume only pass this function an inserter if we know it's a scaled inserter
    table.insert(global.scaled_inserters, inserter)
    local suffix = string.match(inserter.name, "-(%A+)x$")
    --In the above line, we use parenthesis to capture the value of the non-letter character (or characters) between the hyphen and the x.
    local scale = tonumber(suffix)
    if not scale then
        local errorstring = "Inserter_Handler.register_inserter: inserter name[" .. inserter.name .. "] does not have a valid suffix"
        log(errorstring)
        errorstring = errorstring .. ": [" .. suffix .. "]"
        error(errorstring)
        -- [" .. suffix .. "]")
    end
    --The suffix should always be a number, so scale should always be a number.
    local helpers = {}
    --We're going to create some new entities on top of the inserter to increase its throughput.
    --The name of the helper entity will be the name of the inserter with the suffix "-helper" appended.
    --The helper entity will be a copy of the inserter, but with the following changes:
    --Unselectable, unminable, unrotatable, and unremovable.
    --We need to remember the helpers so we can remove them when the inserter is removed.
    --Or rotate them when the inserter is rotated.
    local helperNum = math.max(scale, 1, math.pow(scale, 2))
    for i=1, helperNum do
        local helper = inserter.surface.create_entity{name=inserter.name.."-helper", position=inserter.position, force=inserter.force, direction=inserter.direction}
        --This is a special entity that has its own prototype, and does not need to be registered or modified.
        table.insert(helpers, helper)
    end

    table.insert(global.scaled_inserter_data, {inserter=inserter, helpers = helpers, scale = scale})
    --TODO: More bookkeeping
end
function Inserter_Handler.cleanup_inserter(inserter)
    --assume only pass this function an inserter if we know it's a scaled inserter
    local ind = table.contains(global.scaled_inserters, inserter)
    if ind and type(ind)=="number" then
        table.remove(global.scaled_inserters, ind)
        local data = global.scaled_inserter_data[ind]
        for ind1, helper in pairs(data.helpers) do
            helper.destroy()
        end
        table.remove(global.scaled_inserter_data, ind)
    end
end
function Inserter_Handler.on_entity_created(event)
    local entity = event.created_entity or event.entity or event.destination
    if Inserter_Handler.is_scaled_inserter(entity) then
        Inserter_Handler.register_inserter(entity)
    end
end
register_function_create(script, defines, Inserter_Handler.on_entity_created, Inserter_Handler.event_filters)
function Inserter_Handler.on_entity_destroyed(event)
    local entity = event.entity or event.destination
    if Inserter_Handler.is_scaled_inserter(entity) then
        Inserter_Handler.cleanup_inserter(entity)
    end
end
register_function_destroy(script, defines, Inserter_Handler.on_entity_destroyed, Inserter_Handler.event_filters)
function Inserter_Handler.on_entity_rotated(event)
    local entity = event.entity
    if Inserter_Handler.is_scaled_inserter(entity) then
        local ind = table.contains(global.scaled_inserters, entity)
        if ind and type(ind)=="number" then
            local data = global.scaled_inserter_data[ind]
            for ind1, helper in pairs(data.helpers) do
                helper.direction = entity.direction
            end
        end
    end
end
function Inserter_Handler.set_helpers_active(helpers, active)
    for ind, helper in pairs(helpers) do
        helper.active = active
    end
end
function Inserter_Handler.need_handle_filters(inserter)
    if inserter.name:match("filter") then
        return true
    end
end
function Inserter_Handler.update_helper_filters(inserter, helpers)
    if Inserter_Handler.need_handle_filters(inserter) then
        local filterCount = inserter.filter_slot_count
        local filterMode = inserter.inserter_filter_mode
        for i=1, filterCount do
            local filter = inserter.get_filter(i)
            for ind, helper in pairs(helpers) do
                helper.set_filter(i, filter)
            end
        end
        for ind, helper in pairs(helpers) do
            helper.inserter_filter_mode = filterMode
            helper.inserter_stack_size_override = inserter.inserter_stack_size_override
        end
    end
end
script.on_event(defines.events.on_player_rotated_entity, Inserter_Handler.on_entity_rotated)
function Inserter_Handler.on_nth_tick(event)
    --for each registered big inserter, check status and activate or deactivate helpers as needed.
    for ind, inserter in pairs(global.scaled_inserter_data) do
        local status = inserter.inserter.status
        if status == defines.entity_status.no_power then
            Inserter_Handler.set_helpers_active(inserter.helpers, false)
        elseif status == defines.entity_status.no_fuel then
            Inserter_Handler.set_helpers_active(inserter.helpers, false)
        elseif status == defines.entity_status.disabled_by_control_behavior then
            Inserter_Handler.set_helpers_active(inserter.helpers, false)
        elseif status == defines.entity_status.marked_for_deconstruction then
            Inserter_Handler.set_helpers_active(inserter.helpers, false)
        elseif status == defines.entity_status.disabled_by_script then
            Inserter_Handler.set_helpers_active(inserter.helpers, false)
        else
            Inserter_Handler.set_helpers_active(inserter.helpers, true)
        end
        if Inserter_Handler.need_handle_filters(inserter.inserter) then
            Inserter_Handler.update_helper_filters(inserter.inserter, inserter.helpers)
        end
    end
end
script.on_nth_tick(20, Inserter_Handler.on_nth_tick)

return Inserter_Handler
