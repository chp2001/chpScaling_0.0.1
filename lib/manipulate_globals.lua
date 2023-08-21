local manip = {}
local function tablecopy(t)
    if type(t) ~= "table" then return t end
    local copyTable = {}
    for i, val in pairs(t) do
        copyTable[i] = tablecopy(val)
    end
    return copyTable
end
function manip.save()
    manip.saved = {}
    local save = manip.saved
    save.table = tablecopy(table)
end
function manip.load()
    local save = manip.saved
    if save then
        for i, val in pairs(save.table) do
            table[i] = val
        end
    end
end