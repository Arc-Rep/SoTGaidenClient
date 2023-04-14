
local RenderBroker = {}

local MapRender = require "SotClient.Visuals.RenderMap"
local GameOverseer = require "SotClient.GameLogic.LevelMechanics.GameOverseer"
local CombatUI = require "SotClient.Visuals.UI.CombatUI"
local MapData = require "SoTClient.GameLogic.Scenarios.MissionMap"
local tilemap_group = nil
local character_group = nil
local effect_group = nil
local ui_group = nil

function RenderBroker.SetupBattleRenderGroups()

    -- Render order for all gameplay components
    tilemap_group =   display.newGroup()
    character_group = display.newGroup()
    effect_group =    display.newGroup()
    ui_group =        display.newGroup()

end

function RenderBroker.FreeBattleRenderGroups()

    tilemap_group:removeSelf()
    character_group:removeSelf()
    effect_group:removeSelf()
    ui_group:removeSelf()

    tilemap_group = nil
    character_group = nil
    effect_group = nil
    ui_group = nil

end

function RenderBroker.ExtractTilemapGroup()
    return tilemap_group
end

function RenderBroker.ExtractCharacterGroup()
    return character_group
end

function RenderBroker.ExtractEffectGroup()
    return effect_group
end

function RenderBroker.ExtractUIGroup()
    return ui_group
end

function RenderBroker.SetTileMap(map, map_type)
    MapRender.SetRenderMap(map, map_type, GameOverseer.GetUnitList(), GameOverseer.getPlayerCharStats(), tilemap_group, character_group)
end

function RenderBroker.SetUI()
	CombatUI.setHP()
	CombatUI.setEssence()
	CombatUI.createPlayerUI(ui_group)
end

function RenderBroker.SetRenderBattle(map, map_type, sceneGroup)
    RenderBroker.SetupBattleRenderGroups()
    RenderBroker.SetTileMap(map, map_type)
    RenderBroker.SetUI()

    sceneGroup:insert(tilemap_group)
    sceneGroup:insert(character_group)
    sceneGroup:insert(effect_group)
    sceneGroup:insert(ui_group)
end

function RenderBroker.UpdateRender()
	MapRender.UpdateTilemap(MapData.GetMap())
end

return RenderBroker