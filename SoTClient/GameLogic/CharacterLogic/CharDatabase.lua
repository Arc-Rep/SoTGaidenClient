function LoadCharacter(characterName, unit)
    local moduleName = "SoTClient.GameLogic.CharacterLogic.CharData." .. characterName
    local charModule = require(moduleName)
    unit["Actor"] = charModule["Actor"]
    unit["Class"] = charModule["Class"]
    unit["ability1"] = charModule["ability1"]
    unit["ability2"] = charModule["ability2"]
    unit["ability3"] = charModule["ability3"]
    unit["ability4"] = charModule["ability4"]
    unit["Str"] = charModule["Str"]
    unit["Def"] = charModule["Def"]
    unit["Res"] = charModule["Res"]
    unit["maxStr"] = charModule["maxStr"]
    unit["maxDef"] = charModule["maxDef"]
    unit["maxRes"] = charModule["maxRes"]
    unit["maxHP"] = charModule["maxHP"]
    unit["maxEssence"] = charModule["maxEssence"]
    unit["currentEssence"] = charModule["maxEssence"]
    unit["elem_res"] = charModule["elem_res"]
    unit["currentHP"] = charModule["maxHP"]
    return charModule
end
