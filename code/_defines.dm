#define TILE_SIZE 24
#define HOTSPOT_OFFSET (TILE_SIZE/2)
// Note that the above "TILE" refers to a specific type of object, /tile, and not to world.icon_size
#define HOTBAR_TILE_SIZE (TILE_SIZE+2)
#define HOTBAR_LAYER 6
#define HUD_TILE_LAYER 7

#define TARGET_NONE 0
#define TARGET_TURF 1
#define TARGET_RANGE 2
#define TARGET_ENEMY 4
#define TARGET_FRIEND 8
#define TARGET_ACTOR (4|8)

#define RANGE_CENTER -1
#define RANGE_TOUCH 0

#define FACTION_PLAYER 1
#define FACTION_ENEMY 2