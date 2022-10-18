local UnitTable = {}

local Squads = {}
Squads["Player1"] = {}

function UnitTable.AddUnit(Unit)
    table.insert(Squad["Player1"],  Unit)
    table.insert(UnitTable,         Unit)
end

return UnitTable