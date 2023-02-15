

local Essence = {}
 
function Essence.setupEssences()
    Essence["Fire"]["Name"] = "Fire"
    Essence["Fire"]["Type"] = "Elemental"
    Essence["Water"]["Name"] = "Water"
    Essence["Water"]["Type"] = "Elemental"
    Essence["Nature"]["Name"] = "Nature"
    Essence["Nature"]["Type"] = "Elemental"
    Essence["Light"]["Name"] = "Light"
    Essence["Light"]["Type"] = "Elemental"
    Essence["Dark"]["Name"] = "Dark"
    Essence["Dark"]["Type"] = "Elemental"

    Essence["Blind"]["Name"] = "Blind"
    Essence["Blind"]["Type"] = "Status"
    Essence["Poison"]["Name"] = "Poison"
    Essence["Poison"]["Type"] = "Status"
end

return Essence
