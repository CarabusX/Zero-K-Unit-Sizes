Spring.Utilities = Spring.Utilities or {}

function Spring.Utilities.SetToSortedArray (set)
    local array = {}

    for key, value in pairs(set) do
        if (value) then
            array[ #array+1 ] = key
        end
    end

    table.sort(array)

    return array
end

local function TableOrArrayToString(key, data, indent)
    if key and (key ~= "") then
        if type(key) == "number" then
            key = "[" .. key .. "]"
        end
        key = key .. " = "
    else
        key = ""
    end

    indent = indent or ""

    local dataType = type(data)
    if dataType == "string" then
        return indent .. key .. "[[" .. data .. "]]"
    elseif dataType == "number" then
        return indent .. key .. data
    elseif dataType == "boolean" then
        return indent .. key .. (data and "true" or "false")
    elseif dataType == "table" then
        local innerIndent = indent .. "\t"
        local maxIndex = #data

        local str = indent .. key .. "{\n"
        for i = 1, maxIndex do
            str = str .. TableOrArrayToString(nil, data[i], innerIndent) .. ",\n"
        end
        if (0 < maxIndex) then
            str = str .. innerIndent .. "-- " .. maxIndex .. "\n"  -- print comment about array length
        end
        for k, v in pairs(data) do
            local isArrayIndex = (type(k) == "number" and 1 <= k and k <= maxIndex)
            if (not isArrayIndex) then
                str = str .. TableOrArrayToString(k, v, innerIndent) .. ",\n"
            end
        end
        return str .. indent .. "}"
    end
    return ""
end

Spring.Utilities.TableOrArrayToString = TableOrArrayToString
