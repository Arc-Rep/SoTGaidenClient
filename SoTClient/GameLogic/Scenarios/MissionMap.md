
## MissionMap

The MissionMap module is responsible for setting up the logical part behind the game's level design and map elements. It also provides many different and varied utility functions that are related to concepts such as character placement and status, room properties and more.

### The Map Table

The map table is the single structure responsible for housing all of a level's data. It is treated as a singleton (there can't be two levels being played at the same time) and is accessible through the project's many layers that might require it for various tasks such as positioning, level events, cutscenes, etc.

#### The Tile Grid

A map is in essence a grid of multiple tiles that create the paths and obstacles of a said level. This is shown within the Map table by simply searching for through its coordinates and obtaining the subtables responsible for holding the data pertaining to a certain tile. For example, if I want the tile of coordinates (4, 5), then a simple search of the Map table variable "map" as map[4][5] is sufficient to obtain the tile table. Each tile table is comprised of the following keys:

- "Tile", which symbolizes the type of tile it is (walkable, trap, entrance, exit).
- "Actor", which returns the table of the character that is standing in said tile (should there be one).
- "Texture", which holds the texture associated with said tile.

Each map detains keys "x" and "y" which portray the maximum number of columns and rows that said map detains.

#### Entrance/Exit values

Each level detains an entrance (to be extended) and an exit or objective that signifies the end of the playthrough of the current challenge. To portray these concepts, the keys used are as follows:

- "entrance_x" and "entrance_y" for the entrance coordinates.
- "exit_x" and "exit_y" for the exit coordinates.

#### Rooms and Tunnels

Each level is composed of multiple rooms that are connected between themselves by tunnels. For both of these concepts there exist the keys "rooms" and "tunnels". 
By accessing map["rooms"], one obtains the list of rooms that make up the level, along with various properties pertaining to said room, such as its own "x" and "y" coordinates (which symbolize the coordinate of the left uppermost corner of the room), the number of "rows" and "columns" it has, as well as which is its "closestRoom". 
By accessing map["tunnels"], one obtains a list of the tunnels that connect the different rooms. These tunnel structures are simply lists of the tiles that make up the tunnel.