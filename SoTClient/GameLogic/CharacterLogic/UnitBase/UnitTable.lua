local UnitTable = {}

function UnitTable:AddPlayerUnit(unit_list, Squads, Unit)
    table.insert(unit_list, Unit)
    table.insert(Squads[Unit["Team"]],  Unit)
end

function UnitTable:AddEnemyUnit(unit_list, Squads, Unit)
    table.insert(unit_list, Unit)
    table.insert(Squads["Hostiles"], Unit)
end


return UnitTable