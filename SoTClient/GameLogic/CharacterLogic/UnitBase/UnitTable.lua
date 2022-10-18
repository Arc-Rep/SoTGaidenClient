local UnitTable = {}

function UnitTable:AddUnit(unit_list, Squads, Unit)
    table.insert(unit_list, Unit)
    table.insert(Squads[Unit["Team"]],  Unit)
end

return UnitTable