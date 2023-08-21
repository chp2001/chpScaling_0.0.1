data:extend({
    {
        type = "string-setting",
        name = "chpScaling-scales-list",
        localized_name = "chpScaling: Scales list",
        localized_description = "chpScaling: A comma-separated list of scales to use. Does not matter the order or uniqueness, but they must be valid numbers",
        setting_type = "startup",
        --This is a comma-separated list of scales. Does not matter the order or uniqueness, but they must be valid numbers
        default_value = "2",
        order = "cs-0-s",
    },
    -- {
    --     type = "string-setting",
    --     name = "chpScaling-newSize-function",
    --     localized_name = "chpScaling: New size function",
    --     localized_description = "chpScaling: A function that takes the old size and the scale, and returns the new size",
    --     setting_type = "startup",
    --     default_value = "function (size, scale) return size * scale end",
    --     order = "cs-a-ns",
    -- },
    -- {
    --     type = "string-setting",
    --     name = "chpScaling-newArea-function",
    --     localized_name = "chpScaling: New area function",
    --     localized_description = "chpScaling: A function that takes the old area and the scale, and returns the new area",
    --     setting_type = "startup",
    --     default_value = "function (area, scale) return area * scale * scale end",
    --     order = "cs-b-na",
    -- },
    -- {
    --     type = "string-setting",
    --     name = "chpScaling-newMaterialCost-function",
    --     localized_name = "chpScaling: New material cost function",
    --     localized_description = "chpScaling: A function that takes the old material cost, the new area, and the new material cost, and returns the new material cost",
    --     setting_type = "startup",
    --     --Material cost is typically based on the previous area compared to the new area, multiplied by the original cost
    --     default_value = "function (area, newArea, cost) return cost * (newArea / area) end",
    --     order = "cs-c-nmc",
    -- },
    -- {
    --     type = "string-setting",
    --     name = "chpScaling-newStatDownside-function",
    --     localized_name = "chpScaling: New stat downside function",
    --     localized_description = "chpScaling: A function that takes the old area, the new area, the scale, and the original downside, and returns the new downside",
    --     setting_type = "startup",
    --     --Stat downsides are typically based on the previous area compared to the new area, multiplied by the original downside
    --     --For additional impact, we also multiply by the scale
    --     default_value = "function (area, newArea, scale, downside) return scale * downside * (newArea / area) end",
    --     order = "cs-d-nsd",
    -- },
    -- {
    --     type = "string-setting",
    --     name = "chpScaling-newStatUpside-function",
    --     localized_name = "chpScaling: New stat upside function",
    --     localized_description = "chpScaling: A function that takes the old area, the new area, the scale, and the original upside, and returns the new upside",
    --     setting_type = "startup",
    --     --Stat upsides are typically based on the previous area compared to the new area, multiplied by the original upside
    --     --For additional impact, we also multiply by the scale
    --     default_value = "function (area, newArea, upside) return scale * upside * (newArea / area) end",
    --     order = "cs-e-nsu",
    -- },
    -- {
    --     type = "string-setting",
    --     name = "chpScaling-newStorageSize-function",
    --     localized_name = "chpScaling: New storage size function",
    --     localized_description = "chpScaling: A function that takes the old area, the new area, the scale, and the original size, and returns the new size",
    --     setting_type = "startup",
    --     --Storage size is typically based on the previous area compared to the new area, multiplied by the original size
    --     --For additional impact, we also multiply by the scale
    --     default_value = "function (area, newArea, scale, size) return scale * size * (newArea / area) end",
    --     order = "cs-f-nss",
    -- },
    -- {
    --     type = "string-setting",
    --     name = "chpScaling-newModuleSlots-function",
    --     localized_name = "chpScaling: New module slots function",
    --     localized_description = "chpScaling: A function that takes the scale and the number of slots, and returns the new number of slots",
    --     setting_type = "startup",
    --     --Module slots typically scale only off of the change in scale
    --     default_value = "function (scale, slots) return scale * slots end",
    --     order = "cs-g-nms",
    -- }

        
})
