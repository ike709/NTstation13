#define MIDNIGHT_ROLLOVER		864000	//number of deciseconds in a day

//Security levels
#define SEC_LEVEL_GREEN	0
#define SEC_LEVEL_BLUE	1
#define SEC_LEVEL_RED	2
#define SEC_LEVEL_DELTA	3

//some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26	//Used to trigger removal from a processing list

#define TOUCH 1
#define INGEST 2

#define AREA_ERRNONE 0
#define AREA_STATION 1
#define AREA_SPACE 2
#define AREA_SPECIAL 3

#define BORDER_ERROR 0
#define BORDER_NONE 1
#define BORDER_BETWEEN 2
#define BORDER_2NDTILE 3
#define BORDER_SPACE 4

#define ROOM_ERR_LOLWAT 0
#define ROOM_ERR_SPACE -1
#define ROOM_ERR_TOOLARGE -2

#define MANIFEST_ERROR_NAME		1
#define MANIFEST_ERROR_COUNT	2
#define MANIFEST_ERROR_ITEM		4

#define TRANSITIONEDGE			7 //Distance from edge to move to another z-level

#define STATE_DEFAULT 1
#define STATE_CALLSHUTTLE 2
#define STATE_CANCELSHUTTLE 3
#define STATE_MESSAGELIST 4
#define STATE_VIEWMESSAGE 5
#define STATE_DELMESSAGE 6
#define STATE_STATUSDISPLAY 7
#define STATE_ALERT_LEVEL 8
#define STATE_CONFIRM_LEVEL 9
#define STATE_TOGGLE_EMERGENCY 10
#define STATE_CREWTRANSFER 11

//HUD styles. Please ensure HUD_VERSIONS is the same as the maximum index. Index order defines how they are cycled in F12.
#define HUD_STYLE_STANDARD 1
#define HUD_STYLE_REDUCED 2
#define HUD_STYLE_NOHUD 3


#define HUD_VERSIONS 3	//used in show_hud()
//1 = standard hud
//2 = reduced hud (just hands and intent switcher)
//3 = no hud (for screenshots)

#define MINERAL_MATERIAL_AMOUNT 2000
//The amount of materials you get from a sheet of mineral like iron/diamond/glass etc
