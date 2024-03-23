; Game.inc : ゲーム
;


; マクロの定義
;

; ゲーム
GAME_STATE                      =   0x00
GAME_FLAG                       =   0x01
GAME_REQUEST                    =   0x02
GAME_ROOM                       =   0x03
GAME_SOUND                      =   0x04
GAME_FRAME                      =   0x05
GAME_LENGTH                     =   0x06

; 状態
GAME_STATE_NULL                 =   0x00
GAME_STATE_START                =   0x10
GAME_STATE_PLAY                 =   0x20
GAME_STATE_OVER                 =   0x30
GAME_STATE_CLEAR                =   0x40
GAME_STATE_END                  =   0x50

; フラグ
GAME_FLAG_NULL                  =   0x00
GAME_FLAG_WAIT_BIT              =   0x00
GAME_FLAG_WAIT                  =   (1 << GAME_FLAG_WAIT)

; リクエスト
GAME_REQUEST_NULL               =   0x00
GAME_REQUEST_ROOM_UP_BIT        =   0x00
GAME_REQUEST_ROOM_UP            =   (1 << GAME_REQUEST_ROOM_UP_BIT)
GAME_REQUEST_ROOM_DOWN_BIT      =   0x01
GAME_REQUEST_ROOM_DOWN          =   (1 << GAME_REQUEST_ROOM_DOWN_BIT)
GAME_REQUEST_ROOM_LEFT_BIT      =   0x02
GAME_REQUEST_ROOM_LEFT          =   (1 << GAME_REQUEST_ROOM_LEFT_BIT)
GAME_REQUEST_ROOM_RIGHT_BIT     =   0x03
GAME_REQUEST_ROOM_RIGHT         =   (1 << GAME_REQUEST_ROOM_RIGHT_BIT)
GAME_REQUEST_PRINT_COMPASS_BIT  =   0x04
GAME_REQUEST_PRINT_COMPASS      =   (1 << GAME_REQUEST_PRINT_COMPASS_BIT)
GAME_REQUEST_OVER_BIT           =   0x05
GAME_REQUEST_OVER               =   (1 << GAME_REQUEST_OVER_BIT)
GAME_REQUEST_GATE_OPEN_BIT      =   0x06
GAME_REQUEST_GATE_OPEN          =   (1 << GAME_REQUEST_GATE_OPEN_BIT)
GAME_REQUEST_GATE_ENTER_BIT     =   0x07
GAME_REQUEST_GATE_ENTER         =   (1 << GAME_REQUEST_GATE_ENTER_BIT)

; 部屋
GAME_ROOM_NULL                  =   0x00

; フレーム
GAME_FRAME_NULL                 =   0x00

; スプライト
GAME_SPRITE_PLAYER              =   0x00
GAME_SPRITE_ENEMY               =   0x10
GAME_SPRITE_ITEM                =   0x60
GAME_SPRITE_COMPASS             =   0x64

; サウンド
GAME_SOUND_NULL                 =   0x00
GAME_SOUND_BGM_ZAKO             =   0x01
GAME_SOUND_BGM_BOSS             =   0x02
GAME_SOUND_BGM_OVER             =   0x03
GAME_SOUND_BGM_CLEAR            =   0x04
GAME_SOUND_SE_HIT               =   0x01
GAME_SOUND_SE_MISS              =   0x02
GAME_SOUND_SE_DAMAGE_NORMAL     =   0x03
GAME_SOUND_SE_DAMAGE_POISON     =   0x04
GAME_SOUND_SE_CAST              =   0x05
GAME_SOUND_SE_ITEM              =   0x06

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate
    .globl  _GamePlayBgm
    .globl  _GamePlaySe

; 外部変数宣言
;

    .globl  _game
