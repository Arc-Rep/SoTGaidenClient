

## Game Render Framework

Since SoT is a game and games need graphics, this section will better portray the methods by which the rendering process is done. All rendering frameworks are the same as used by Solar2D.

Depending on which components are being rendered, the file structure is as follows:

## File structure

### Screen Info

Detains misc properties and functions regarding the screen the user is experiencing the game with.

### RenderBroker

There are multiple components that need to be rendered and ordered correctly (UI elements are always put in front of the maps and character). The component responsible for this is the RenderBroker that is responsible for setting up, grouping and removing all texture modules. Each texture "major layer" is a separate group and must be accounted for in the RenderBroker. 
The normal rendering order is as follows (what is rendered first should be the "farthest" textures):

- Backgrounds
- Map textures
- Characters
- Special Effects
- UI and Dialog
- Menus

### RenderMap

This module detains all logic regarding the map render grid as well as events that might affect each of the individual tiles. All overall map rendering setup/clearing is done on this level. Individual tiles are rendered through the next module.

### RenderTile

This module fetches all textures pertaining to the map tiles and stores them within a "MapFiles" table which has multiple arrays for each "tile type".
The tile types are as follows:

- Floor 
- Walls             (Defines floor limits)
- Corners           (Used when walls connect)
- Ceiling           (Textures used beyond upper walls)
- Corner Ceiling    (Textures used beyond corners)

Some of these tiles might have conceptual "directions" i.e. a wall to the right or a floor tile that is used for horizontal hallways. To portray these directions, there are local tables to signify the number of textures of each type (i.e.CEILING_DIRECTIONS). 
Each element of these tables has two numbers. The first one signifies the direction of the tile if this direction was portrayed in a keyboard numpad. The second signifies the number of textures there are of this direction. For example, if the WALL_Directions table has the element {3, 2}, this means that there are two possible wall tiles for direction 3 (which in a keyboard numpad relates to the lower right direction). A 0 as a direction signifies it is directionless.

Given a map file path and these structures, a map is automatically generated and the textures for each tile are chosen in this level through an algorithm responsible for making sure the textures connect into a cohesive map. All textures are then stored with key "Texture" into the table of a logical map tile (i.e. map[x][y]["Texture"]).


### Dialog

Jonas por favoooooooooooorrrr

### Camera Map

The camera symbolizes the part of the map that is being shown to a player. Provided some coordinates or a focused entity, the game map shifts and centers what is desired. It is also possible to change attributes such as the zoom, drag amount and drag speed. There are multiple variables to keep track of all these properties.

#### Camera_x and Camera_y

These signify the coordinate of the center of the camera in the present.

#### Camera_focus_x and Camera_focus_y

These portray the focused entity at present. Do note that since, for example, there are animation transitions and drag operations the player can do, these aren't the same as camera_x and camera_y at all times. The camera does not teleport when the focus shifts but transitions smoothly between them. If a user drags the camera away, these variables keep track of who the focus is when the user lets go.

#### Camera_width/height_base

The pixel size of the camera's width and height.

#### Camera_tile_width/height

The tile size of the camera's width and height.

#### Focus_element_queue

The queue that stores all focused entities and is responsible for shifting the focus when it is updated.

#### Camera_drag_begin_x/y

Point in the screen where user started the dragging operation.

#### Camera_drag_x/y

Current point in the user's drag operation. Difference between this and the "begin" variable will change currect camera_x/y.