newStructure = {
    -- Armor Type Name
    'Structure',

    -- Armor Definition
    'Normal 1.0',
    'Overcharge 0.066666',
    'Deathnuke 0.032',
    'Fire 2.5',
}

do


---@param newTable table
function hookInsert(newTable)
    for key, armorTable in armordefinition do
        for _, str in armorTable do
            if newTable[1] == str then
                armordefinition[key] = newTable
                break
            end
        end
    end
end

hookInsert(newStructure)

end
