local UnitTable = {}

local Squads = {}
Squads["Player1"] = {}
Squads["Hostiles"] = {}

function UnitTable.AddEnemyUnit(Unit)
    table.insert(Squads["Hostiles"], Unit)
    table.insert(UnitTable, Unit)
end

function UnitTable.AddPlayerUnit(Unit)
    table.insert(Squad["Player1"],  Unit)
    table.insert(UnitTable,         Unit)
end

return UnitTable