

local Essence = {}

local math = require "math"
 
function Essence.setupEssences()

    Essence["Blind"]["Name"] = "Blind"
    Essence["Blind"]["Trigger"] = "BeforeAttack"
    Essence["Blind"]["Effect"] = 
        function (map, character, attack)
            if(attack["Modifiers"]["Accuracy"] == nil) then
                attack["Modifiers"]["Accuracy"] = 0.5
            else
                attack["Modifiers"]["Accuracy"] = attack["Modifiers"]["Accuracy"] * 0.5
            end
        end

    Essence["Vanish"]["Name"] = "Vanish"
    Essence["Vanish"]["Trigger"] = "OnAttackReceive"
    Essence["Vanish"]["Effect"] = 
        function (map, character, attack)
            if(attack["Modifiers"]["Accuracy"] == nil) then
                attack["Modifiers"]["Accuracy"] = 0.7
            else
                attack["Modifiers"]["Accuracy"] = attack["Modifiers"]["Accuracy"] * 0.7
            end
        end

    Essence["Poison"]["Name"]    = "Poison"
    Essence["Poison"]["Trigger"] = "TurnEnd"
    Essence["Poison"]["Effect"]  = 
        function (map, character)
            if(math.floor(character["Steps"] / 10) == 0) then
                ApplyDamage(map, character, math.floor(character["maxHP"]/20))
            end
        end

    Essence["Regen"]["Name"]    = "Regen"
    Essence["Regen"]["Trigger"] = "TurnEnd"
    Essence["Regen"]["Effect"]  = 
        function (map, character)
            if(math.floor(character["Steps"] / 10) == 0) then
                ApplyDamage(map, character, -math.floor(character["maxHP"]/20))
            end
        end

    Essence["Weaken"]["Name"]   = "Weaken"
    Essence["Weaken"]["Trigger"] = "BeforeAttack"
    Essence["Weaken"]["Effect"] = 
        function (map, character, attack)
            if(attack["Modifiers"]["Damage"] == nil) then
                attack["Modifiers"]["Damage"] = 0.70
            else
                attack["Modifiers"]["Damage"] = attack["Modifiers"]["Damage"] * 0.70
            end
        end
    
    Essence["Bravery"]["Name"]   = "Bravery"
    Essence["Bravery"]["Trigger"] = "BeforeAttack"
    Essence["Bravery"]["Effect"] = 
        function (map, character, attack)   
            if(attack["Modifiers"]["Damage"] == nil) then
                attack["Modifiers"]["Damage"] = 1.30
            else
                attack["Modifiers"]["Damage"] = attack["Modifiers"]["Damage"] * 1.30
            end
        end

    Essence["Protection"]["Name"] = "Protection"
    Essence["Protection"]["Trigger"] = "OnAttackReceive"
    Essence["Protection"]["Effect"] =
        function (map, character, attack)
            if(attack["Modifiers"]["Damage"] == nil) then
                attack["Modifiers"]["Damage"] = 0.70
            else
                attack["Modifiers"]["Damage"] = attack["Modifiers"]["Damage"] * 0.60
            end
        end

    Essence["Feeble"]["Name"] = "Feeble"
    Essence["Feeble"]["Trigger"] = "OnAttackReceive"
    Essence["Feeble"]["Effect"] =
        function (map, character, attack)
            if(attack["Modifiers"]["Damage"] == nil) then
                attack["Modifiers"]["Damage"] = 1.40
            else
                attack["Modifiers"]["Damage"] = attack["Modifiers"]["Damage"] * 1.40
            end
        end
end

return Essence
