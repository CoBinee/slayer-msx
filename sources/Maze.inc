; Maze.inc : 迷路
;


; マクロの定義
;

; 大きさ
MAZE_SIZE_X                     =   0x08
MAZE_SIZE_X_MASK                =   0x07
MAZE_SIZE_X_SHIFT               =   0x00
MAZE_SIZE_Y                     =   0x08
MAZE_SIZE_Y_MASK                =   0x38
MAZE_SIZE_Y_SHIFT               =   0x03

; フラグ
MAZE_FLAG_NULL                  =   0x00
MAZE_FLAG_WALL_UP_BIT           =   0x00
MAZE_FLAG_WALL_UP               =   (1 << MAZE_FLAG_WALL_UP_BIT)
MAZE_FLAG_WALL_DOWN_BIT         =   0x01
MAZE_FLAG_WALL_DOWN             =   (1 << MAZE_FLAG_WALL_DOWN_BIT)
MAZE_FLAG_WALL_LEFT_BIT         =   0x02
MAZE_FLAG_WALL_LEFT             =   (1 << MAZE_FLAG_WALL_LEFT_BIT)
MAZE_FLAG_WALL_RIGHT_BIT        =   0x03
MAZE_FLAG_WALL_RIGHT            =   (1 << MAZE_FLAG_WALL_RIGHT_BIT)
MAZE_FLAG_ITEM_PUT_BIT          =   0x04
MAZE_FLAG_ITEM_PUT              =   (1 << MAZE_FLAG_ITEM_PUT_BIT)

; 部屋
MAZE_ROOM_SIZE_X                =   0xb0
MAZE_ROOM_SIZE_Y                =   0xb0
MAZE_ROOM_OFFSET_X              =   0x08
MAZE_ROOM_OFFSET_Y              =   0x08
MAZE_ROOM_UP                    =   0x10
MAZE_ROOM_DOWN                  =   0x9f
MAZE_ROOM_LEFT                  =   0x10
MAZE_ROOM_RIGHT                 =   0x9f

; 出口
MAZE_EXIT_MINUS                 =   0x50
MAZE_EXIT_PLUS                  =   0x5f
MAZE_EXIT_UP_X                  =   0x58
MAZE_EXIT_UP_Y                  =   0x08
MAZE_EXIT_DOWN_X                =   0x58
MAZE_EXIT_DOWN_Y                =   0xa8
MAZE_EXIT_LEFT_X                =   0x08
MAZE_EXIT_LEFT_Y                =   0x58
MAZE_EXIT_RIGHT_X               =   0xa8
MAZE_EXIT_RIGHT_Y               =   0x58

; ゲート
MAZE_GATE_X                     =   0x58
MAZE_GATE_Y                     =   0x58

; エントリ
MAZE_ENTRY_ENEMY_TYPE           =   0x00
MAZE_ENTRY_ENEMY_REST           =   0x01
MAZE_ENTRY_ITEM                 =   0x02
MAZE_ENTRY_SOUND                =   0x03
MAZE_ENTRY_LENGTH               =   0x04

; 外部関数宣言
;

    .globl  _MazeInitialize
    .globl  _MazeGetOrderRoom
    .globl  _MazeGetEnemy
    .globl  _MazeKillEnemy
    .globl  _MazeGetEnemyRest
    .globl  _MazeGetItem
    .globl  _MazeKillItem
    .globl  _MazeIsPutItem
    .globl  _MazeGetSound
    .globl  _MazeIsRoom
    .globl  _MazeIsExit
    .globl  _MazePrintRoom

; 外部変数宣言
;

