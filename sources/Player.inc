; Player.inc : プレイヤ
;


; マクロの定義
;

; プレイヤ
PLAYER_STATE                    =   0x00
PLAYER_FLAG                     =   0x01
PLAYER_POSITION_X               =   0x02
PLAYER_POSITION_Y               =   0x03
PLAYER_DIRECTION                =   0x04
PLAYER_COLOR                    =   0x05
PLAYER_ANIMATION                =   0x06
PLAYER_MOVE                     =   0x07
PLAYER_LIFE                     =   0x08
PLAYER_DAMAGE_POWER             =   0x09
PLAYER_DAMAGE_MAGIC             =   0x0a
PLAYER_DAMAGE_FRAME             =   0x0b
PLAYER_POWER                    =   0x0c
PLAYER_GUARD                    =   0x0d
PLAYER_CONDITION_POISON_L       =   0x0e
PLAYER_CONDITION_POISON_H       =   0x0f
PLAYER_CONDITION_SLOW_L         =   0x10
PLAYER_CONDITION_SLOW_H         =   0x11
PLAYER_CONDITION_UNPOWER_L      =   0x12
PLAYER_CONDITION_UNPOWER_H      =   0x13
PLAYER_CONDITION_UNGUARD_L      =   0x14
PLAYER_CONDITION_UNGUARD_H      =   0x15
PLAYER_CONDITION_SLEEP_L        =   0x16
PLAYER_CONDITION_SLEEP_H        =   0x17
PLAYER_CONDITION_BLIND_L        =   0x18
PLAYER_CONDITION_BLIND_H        =   0x19
PLAYER_CONDITION_CONFUSE_L      =   0x1a
PLAYER_CONDITION_CONFUSE_H      =   0x1b
PLAYER_CONDITION_CONFUSE_SHIFT  =   0x1c
PLAYER_ITEM_SWORD               =   0x1d
PLAYER_ITEM_SHIELD              =   0x1e
PLAYER_ITEM_POTION              =   0x1f
PLAYER_ITEM_BOOTS               =   0x20
PLAYER_ITEM_COMPASS             =   0x21
PLAYER_ITEM_KEY                 =   0x22
PLAYER_ITEM_TORCH               =   0x23
PLAYER_ITEM_HAMMER              =   0x24
PLAYER_ITEM_CANDLE              =   0x25
PLAYER_ITEM_MIRROR              =   0x26
PLAYER_ITEM_RING                =   0x27
PLAYER_ITEM_AMULET              =   0x28
PLAYER_ITEM_ARROW               =   0x29
PLAYER_ITEM_DROP                =   0x2a
PLAYER_ITEM_GRASS               =   0x2b
PLAYER_ITEM_DRAGON_SLAYER       =   0x2c
PLAYER_ITEM_CRYSTAL             =   0x2d
PLAYER_LENGTH                   =   0x2e

; 状態
PLAYER_STATE_NULL               =   0x00
PLAYER_STATE_PLAY               =   0x10
PLAYER_STATE_GATE               =   0x20
PLAYER_STATE_DEAD               =   0x30

; フラグ
PLAYER_FLAG_NULL                =   0x00
PLAYER_FLAG_NOCOLLISION_BIT     =   0x00
PLAYER_FLAG_NOCOLLISION         =   (1 << PLAYER_FLAG_NOCOLLISION_BIT)
PLAYER_FLAG_NORENDER_BIT        =   0x01
PLAYER_FLAG_NORENDER            =   (1 << PLAYER_FLAG_NORENDER_BIT)

; 向き
PLAYER_DIRECTION_UP             =   0x00
PLAYER_DIRECTION_DOWN           =   0x01
PLAYER_DIRECTION_LEFT           =   0x02
PLAYER_DIRECTION_RIGHT          =   0x03

; 大きさ
PLAYER_R                        =   0x08

; スプライト
PLAYER_SPRITE_OBJECT            =   0x08
PLAYER_SPRITE_DAMAGE            =   0x01

; 色
PLAYER_COLOR_OBJECT             =   VDP_COLOR_WHITE
PLAYER_COLOR_DAMAGE             =   VDP_COLOR_MEDIUM_RED

; アニメーション
PLAYER_ANIMATION_NULL           =   0x00
PLAYER_ANIMATION_DEAD           =   0x48

; 入力
PLAYER_INPUT_NULL               =   0x00
PLAYER_INPUT_UP_BIT             =   0x00
PLAYER_INPUT_UP                 =   (1 << PLAYER_INPUT_UP_BIT)
PLAYER_INPUT_DOWN_BIT           =   0x01
PLAYER_INPUT_DOWN               =   (1 << PLAYER_INPUT_DOWN_BIT)
PLAYER_INPUT_LEFT_BIT           =   0x02
PLAYER_INPUT_LEFT               =   (1 << PLAYER_INPUT_LEFT_BIT)
PLAYER_INPUT_RIGHT_BIT          =   0x03
PLAYER_INPUT_RIGHT              =   (1 << PLAYER_INPUT_RIGHT_BIT)

; 移動
PLAYER_MOVE_NULL                =   0x00
PLAYER_MOVE_SPEED_SLOW          =   0x01
PLAYER_MOVE_SPEED_NORMAL        =   0x01
PLAYER_MOVE_SPEED_FAST          =   0x02
PLAYER_MOVE_CYCLE_SLOW          =   0x01
PLAYER_MOVE_CYCLE_NORMAL        =   0x00
PLAYER_MOVE_CYCLE_FAST          =   0x00

; 体力
PLAYER_LIFE_MAX                 =   0x38

; ダメージ
PLAYER_DAMAGE_POWER_NULL        =   0x00
PLAYER_DAMAGE_MAGIC_NULL        =   0x00
PLAYER_DAMAGE_FRAME_NULL        =   0x00
PLAYER_DAMAGE_FRAME_POWER       =   0x08
PLAYER_DAMAGE_FRAME_MAGIC       =   0x08
PLAYER_DAMAGE_FRAME_POISON      =   0x04

; 攻撃力
PLAYER_POWER_NULL               =   0x00
PLAYER_POWER_POINT_NORMAL       =   0x01
PLAYER_POWER_POINT_SKIP_BIT     =   0x07
PLAYER_POWER_POINT_SKIP         =   (1 << PLAYER_POWER_POINT_SKIP_BIT)
PLAYER_POWER_CYCLE_NORMAL       =   0x0c

; 防御力
PLAYER_GUARD_NULL               =   0x00
PLAYER_GUARD_POINT_NORMAL       =   0x01

; 状態異常
PLAYER_CONDITION_NULL           =   0x00
PLAYER_CONDITION_POISON         =   0x01
PLAYER_CONDITION_POISON_FRAME   =   (0x001e * 0x0020 + 0x0002)
PLAYER_CONDITION_POISON_CYCLE   =   0x3f
PLAYER_CONDITION_POISON_DAMAGE  =   0x02
PLAYER_CONDITION_SLOW           =   0x02
PLAYER_CONDITION_SLOW_FRAME     =   (0x000a * 0x0020)
PLAYER_CONDITION_UNPOWER        =   0x03
PLAYER_CONDITION_UNPOWER_FRAME  =   (0x000a * 0x0020)
PLAYER_CONDITION_UNGUARD        =   0x04
PLAYER_CONDITION_UNGUARD_FRAME  =   (0x000a * 0x0020)
PLAYER_CONDITION_SLEEP          =   0x05
PLAYER_CONDITION_SLEEP_FRAME    =   (0x000a * 0x0020)
PLAYER_CONDITION_BLIND          =   0x06
PLAYER_CONDITION_BLIND_FRAME    =   (0x000a * 0x0020)
PLAYER_CONDITION_BLIND_CYCLE    =   0x3f
PLAYER_CONDITION_BLIND_DELAY    =   0x04
PLAYER_CONDITION_CONFUSE        =   0x07
PLAYER_CONDITION_CONFUSE_FRAME  =   (0x000a * 0x0020)
PLAYER_CONDITION_CONFUSE_NULL   =   0x00
PLAYER_CONDITION_LENGTH         =   0x08

; アイテム
PLAYER_ITEM_NULL                =   0x00

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerUpdate
    .globl  _PlayerRender
    .globl  _PlayerIsHit
    .globl  _PlayerHeal
    .globl  _PlayerBadCondition
    .globl  _PlayerIsItem
    .globl  _PlayerIsDamage

; 外部変数宣言
;

    .globl  _player

