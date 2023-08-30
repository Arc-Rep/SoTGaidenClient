
function MoveCharacterTo(map, char, x, y)
    map[char["x"]][char["y"]]["Actor"] = ""
    char["x"] = x
    char["y"] = y
    map[char["x"]][char["y"]]["Actor"] = char
end