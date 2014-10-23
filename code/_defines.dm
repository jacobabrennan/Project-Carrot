#define TILE_SIZE 24
#define HOTSPOT_OFFSET (TILE_SIZE/2)
// Note that the above "TILE" refers to a specific type of object, /tile, and not to world.icon_size
#define HOTBAR_TILE_SIZE (TILE_SIZE+2)
#define BLOCK_UNDER_LAYER 3
#define BLOCK_OVER_LAYER 4
#define TILE_LAYER 5
#define ACTOR_LAYER 6
#define LIGHTING_LAYER 7
#define EFFECTS_LAYER 8
#define HOTBAR_LAYER 9
#define HUD_TILE_LAYER 10

#define PRIMARY 16
#define SECONDARY 32

#define TOWN_START "town_start"
#define TOTEM_RANGE 4
#define LIGHT_REACH 12
#define PINGOUT_TIME 60
#define TILE_TRANSLATE_TIME 5

#define TARGET_NONE 0
#define TARGET_TURF 1
#define TARGET_BLOCK 2
#define TARGET_RANGE 4
#define TARGET_ENEMY 8
#define TARGET_FRIEND 16
#define TARGET_ACTOR (TARGET_ENEMY|TARGET_FRIEND)

#define RANGE_TOUCH 0

#define FACTION_PLAYER 1
#define FACTION_ENEMY 2

#define TILE_NONE 0
#define TILE_WEAPON 1
#define TILE_OFFHAND 2
#define TILE_BODY 4
#define TILE_CHARM 8
#define TILE_0000000000010000 16
#define TILE_0000000000100000 32
#define TILE_0000000001000000 64
#define TILE_0000000010000000 128
#define TILE_0000000100000000 256
#define TILE_0000001000000000 512
#define TILE_0000010000000000 1024
#define TILE_0000100000000000 2048
#define TILE_0001000000000000 4096
#define TILE_0010000000000000 8192
#define TILE_0100000000000000 16384
#define TILE_1000000000000000 32768
//efine EQUIPMENT_0000000000000000 65536

/*
Crafting Rule of Thumb: 3 combinations of 5 different kinds of objects yeilds 32 different objects.
Crafting: How many items can be made from a combination of 4 items chosen from N items?
f(4,n) = (n**3 + n)/2

 1:  1
 2:  5
 3: 15
 4: 34
 5: 65
 6:111
 7:175
 8:260
 9:396
10:505
*/

#define DMM_IGNORE_AREAS 1
#define DMM_IGNORE_TURFS 2
#define DMM_IGNORE_OBJS 4
#define DMM_IGNORE_NPCS 8
#define DMM_IGNORE_PLAYERS 16
#define DMM_IGNORE_MOBS 24
#define DMM_IGNORE_TURF_VARS 32

// Chat
#define MAX_CHAT_LENGTH 250
#define CHAT_COOLDOWN 10
