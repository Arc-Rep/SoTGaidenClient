
function LOR (exp1, exp2)
    if(type(exp1) == "boolean") then
        if(exp1 == true) then
            return true
        end
    elseif(type(exp1) == "function") then
        if(exp1() == true) then
            return true
        end
    end            
    if(type(exp2) == "boolean") then
        if(exp2 == true) then
            return true
        end
    elseif(type(exp2) == "function") then
        if(exp2() == true) then
            return true
        end
    end    
    return false
end

function LAND (exp1, exp2)
    if(type(exp1) == "boolean") then
        if(exp1 == false) then
            return false
        end
    elseif(type(exp1) == "function") then
        if(exp1() == false) then
            return false
        end
    end            
    if(type(exp2) == "boolean") then
        if(exp2 == false) then
            return false
        end
    elseif(type(exp2) == "function") then
        if(exp2() == false) then
            return false
        end
    end 
    return true
end