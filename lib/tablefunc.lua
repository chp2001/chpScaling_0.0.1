local tab = {}
--tab.copy: creates a new table with the values of t
--  copies recursively to prevent reference errors
function tab.copy(t)
    if type(t) ~= "table" then return t end
    local copyTable = {}
    for i, val in pairs(t) do
        copyTable[i] = tab.copy(val)
    end
    return copyTable
end
--tab.merge: creates a new table with the values of t1 and t2 merged together
--  If a value exists in both tables, the value from t2 will be used
function tab.merge(t1, t2)
    if type(t1) ~= "table" or type(t2) ~= "table" then return t1 end
    local copyTable = tab.copy(t1)
    for i, val in pairs(t2) do
        copyTable[i] = tab.merge(copyTable[i], val)
    end
    return copyTable
end
--tab.contains: returns the index of the value if it exists, false otherwise
function tab.contains(t, val)
    for i, v in pairs(t) do
        if v == val then return i end
    end
    return false
end
--tab.containsKey: returns true if the table contains the key, false otherwise
function tab.containsKey(t, key)
    local err, res = pcall(function() return t[key] end)
    return err and res ~= nil
end
--tab.increment: increments the value at the key by the amount
--  if the value does not exist, it will be set to the amount
function tab.increment(t, key, amount)
    if not tab.containsKey(t, key) then
        t[key] = amount
    else
        t[key] = t[key] + amount
    end
end
--tab.extend: extends the table with the values of t2
--   assumes table is an array
function tab.extend(t1, t2)
    local t = tab.copy(t1)
    for i, val in pairs(t2) do
        table.insert(t, val)
    end
    return t
end

function tab.getAlphaKeys(t)
    local keys = {}
    for k, v in pairs(t) do
        if type(k) == "string" then
            table.insert(keys, k)
        end
    end
    return keys
end

function tab.getNumericKeys(t)
    local keys = {}
    for k, v in pairs(t) do
        if type(k) == "number" then
            table.insert(keys, k)
        end
    end
    return keys
end

function tab.getKeys(t)
    local keys = {}
    for k, v in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end


return tab