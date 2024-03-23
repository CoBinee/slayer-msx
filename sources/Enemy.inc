; Enemy.inc : エネミー
;


; マクロの定義
;

; エネミー
ENEMY_TYPE                      =   0x00
ENEMY_STATE                     =   0x01
ENEMY_FLAG                      =   0x02
ENEMY_POSITION_X                =   0x03
ENEMY_POSITION_Y                =   0x04
ENEMY_DIRECTION                 =   0x05
ENEMY_R                         =   0x06
ENEMY_SPRITE                    =   0x07
ENEMY_COLOR_NORMAL              =   0x08
ENEMY_COLOR_DAMAGE              =   0x09
ENEMY_ANIMATION                 =   0x0a
ENEMY_MOVE_SPEED                =   0x0b
ENEMY_MOVE_CYCLE                =   0x0c
ENEMY_MOVE_FRAME                =   0x0d
ENEMY_MOVE_PARAM_0              =   0x0e
ENEMY_MOVE_PARAM_1              =   0x0f
ENEMY_MOVE_PARAM_2              =   0x10
ENEMY_MOVE_PARAM_3              =   0x11
ENEMY_LIFE                      =   0x12
ENEMY_DAMAGE_POINT              =   0x13
ENEMY_DAMAGE_FRAME              =   0x14
ENEMY_POWER_POINT               =   0x15
ENEMY_POWER_CYCLE               =   0x16
ENEMY_POWER_FRAME               =   0x17
ENEMY_MAGIC_POINT               =   0x18
ENEMY_MAGIC_CYCLE               =   0x19
ENEMY_MAGIC_FRAME               =   0x1a
ENEMY_GUARD                     =   0x1b
ENEMY_CONDITION                 =   0x1c
ENEMY_ITEM_WEAK                 =   0x1d
ENEMY_ITEM_KILL                 =   0x1e
ENEMY_LENGTH                    =   0x1f
ENEMY_ENTRY                     =   (0x09 + 0x03)

; 種類
ENEMY_TYPE_NULL                 =   0x00
ENEMY_TYPE_BAT                  =   0x01
ENEMY_TYPE_GOBLIN               =   0x02
ENEMY_TYPE_ROGUE                =   0x03
ENEMY_TYPE_GARGOYLE             =   0x04
ENEMY_TYPE_REAPER               =   0x05
ENEMY_TYPE_LIZARD               =   0x06
ENEMY_TYPE_MAGE                 =   0x07
ENEMY_TYPE_SNAKE                =   0x08
ENEMY_TYPE_GHOUL                =   0x09
ENEMY_TYPE_DAEMON               =   0x0a
ENEMY_TYPE_SQUID                =   0x0b
ENEMY_TYPE_GAZER                =   0x0c
ENEMY_TYPE_SPIDER               =   0x0d
ENEMY_TYPE_RAT                  =   0x0e
ENEMY_TYPE_MIMIC                =   0x0f
ENEMY_TYPE_SLIME                =   0x10
ENEMY_TYPE_GOLEM                =   0x11
ENEMY_TYPE_GHOST                =   0x12
ENEMY_TYPE_LICH                 =   0x13
ENEMY_TYPE_PHANTOM              =   0x14
ENEMY_TYPE_CYCLOPS              =   0x15
ENEMY_TYPE_ZORN                 =   0x16
ENEMY_TYPE_SHADOW               =   0x17
ENEMY_TYPE_DRAGON               =   0x18
ENEMY_TYPE_CRYSTAL              =   0x19
ENEMY_TYPE_GATE                 =   0x1a
ENEMY_TYPE_MAGIC                =   0x1b

; 状態
ENEMY_STATE_NULL                =   0x00
ENEMY_STATE_STAY                =   0x10
ENEMY_STATE_FREE                =   0x20
ENEMY_STATE_APPROACH            =   0x30
ENEMY_STATE_WARP                =   0x40
ENEMY_STATE_MIMIC               =   0x50
ENEMY_STATE_GHOST               =   0x60
ENEMY_STATE_LICH                =   0x70
ENEMY_STATE_PHANTOM             =   0x80
ENEMY_STATE_CRYSTAL             =   0x90
ENEMY_STATE_GATE                =   0xa0
ENEMY_STATE_MAGIC               =   0xb0
ENEMY_STATE_DEAD                =   0xc0
ENEMY_STATE_KILL                =   0xd0

; フラグ
ENEMY_FLAG_NULL                 =   0x00
ENEMY_FLAG_NOHIT_BIT            =   0x00
ENEMY_FLAG_NOHIT                =   (1 << ENEMY_FLAG_NOHIT_BIT)
ENEMY_FLAG_NOHITENEMY_BIT       =   0x01
ENEMY_FLAG_NOHITENEMY           =   (1 << ENEMY_FLAG_NOHITENEMY_BIT)
ENEMY_FLAG_NOHITPLAYER_BIT      =   0x02
ENEMY_FLAG_NOHITPLAYER          =   (1 << ENEMY_FLAG_NOHITPLAYER_BIT)
ENEMY_FLAG_NOHITOWN_BIT         =   0x03
ENEMY_FLAG_NOHITOWN             =   (1 << ENEMY_FLAG_NOHITOWN_BIT)
ENEMY_FLAG_NORENDER_BIT         =   0x04
ENEMY_FLAG_NORENDER             =   (1 << ENEMY_FLAG_NORENDER_BIT)
ENEMY_FLAG_HIT_BIT              =   0x05
ENEMY_FLAG_HIT                  =   (1 << ENEMY_FLAG_HIT_BIT)
ENEMY_FLAG_HITPLAYER_BIT        =   0x06
ENEMY_FLAG_HITPLAYER            =   (1 << ENEMY_FLAG_HITPLAYER_BIT)
ENEMY_FLAG_2x2_BIT              =   0x07
ENEMY_FLAG_2x2                  =   (1 << ENEMY_FLAG_2x2_BIT)

; 位置
ENEMY_POSITION_NULL             =   0x00

; 向き
ENEMY_DIRECTION_UP              =   0x00
ENEMY_DIRECTION_DOWN            =   0x01
ENEMY_DIRECTION_LEFT            =   0x02
ENEMY_DIRECTION_RIGHT           =   0x03

; 大きさ
ENEMY_R_ZAKO                    =   0x08
ENEMY_R_BOSS                    =   0x10
ENEMY_R_GATE                    =   0x08
ENEMY_R_MAGIC                   =   0x08

; スプライト
ENEMY_SPRITE_OBJECT             =   0x28
ENEMY_SPRITE_DAMAGE             =   0x01
ENEMY_SPRITE_LENGTH             =   (ENEMY_ENTRY * 0x04)

; 色
ENEMY_COLOR_OBJECT              =   VDP_COLOR_WHITE
ENEMY_COLOR_DAMAGE_HIT          =   VDP_COLOR_MEDIUM_RED
ENEMY_COLOR_DAMAGE_MISS         =   VDP_COLOR_LIGHT_BLUE
ENEMY_COLOR_HEAL                =   VDP_COLOR_MEDIUM_GREEN

; アニメーション
ENEMY_ANIMATION_NULL            =   0x00
ENEMY_ANIMATION_DEAD            =   0x18

; 移動
ENEMY_MOVE_SPEED_SLOW           =   0x01
ENEMY_MOVE_SPEED_NORMAL         =   0x01
ENEMY_MOVE_SPEED_FAST           =   0x01
ENEMY_MOVE_SPEED_MAGIC          =   0x04
ENEMY_MOVE_CYCLE_SLOW           =   0x02
ENEMY_MOVE_CYCLE_NORMAL         =   0x01
ENEMY_MOVE_CYCLE_FAST           =   0x00
ENEMY_MOVE_CYCLE_MAGIC          =   0x00
ENEMY_MOVE_FRAME_NULL           =   0x00
ENEMY_MOVE_PARAM_0_NULL         =   0x00
ENEMY_MOVE_PARAM_1_NULL         =   0x3f
ENEMY_MOVE_PARAM_2_NULL         =   0x20
ENEMY_MOVE_PARAM_3_NULL         =   0x1f

; 体力
ENEMY_LIFE_NULL                 =   0x00

; ダメージ
ENEMY_DAMAGE_POINT_NULL         =   0x00
ENEMY_DAMAGE_FRAME_NULL         =   0x00
ENEMY_DAMAGE_FRAME_LENGTH       =   0x08

; 攻撃力
ENEMY_POWER_POINT_NULL          =   0x00
ENEMY_POWER_POINT_MAGIC_BIT     =   0x07
ENEMY_POWER_POINT_MAGIC         =   (1 << ENEMY_POWER_POINT_MAGIC_BIT)
ENEMY_POWER_CYCLE_VERYSLOW      =   0x1a
ENEMY_POWER_CYCLE_SLOW          =   0x13
ENEMY_POWER_CYCLE_NORMAL        =   0x0f
ENEMY_POWER_CYCLE_FAST          =   0x0a
ENEMY_POWER_CYCLE_VERYFAST      =   0x07
ENEMY_POWER_FRAME_NULL          =   0x00

; 魔力
ENEMY_MAGIC_POINT_NULL          =   0x00
ENEMY_MAGIC_CYCLE_VERYVERYSLOW  =   0xc0 ; ENEMY_POWER_CYCLE_VERYSLOW * 0x08
ENEMY_MAGIC_CYCLE_VERYSLOW      =   0x60 ; ENEMY_POWER_CYCLE_VERYSLOW * 0x04
ENEMY_MAGIC_CYCLE_SLOW          =   0x50 ; ENEMY_POWER_CYCLE_SLOW * 0x04
ENEMY_MAGIC_CYCLE_NORMAL        =   0x40 ; ENEMY_POWER_CYCLE_NORMAL * 0x04
ENEMY_MAGIC_CYCLE_FAST          =   0x38 ; ENEMY_POWER_CYCLE_FAST * 0x04
ENEMY_MAGIC_CYCLE_VERYFAST      =   0x28 ; ENEMY_POWER_CYCLE_VERYFAST * 0x04
ENEMY_MAGIC_FRAME_NULL          =   0x00

; 防御力
ENEMY_GUARD_NULL                =   0x00

; 状態異常

; アイテム

; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemyEntry
    .globl  _EnemyIsHit
    .globl  _EnemyIsDamage

; 外部変数宣言
;

    .globl  _enemy

