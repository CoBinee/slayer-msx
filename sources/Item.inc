; Item.inc : アイテム
;


; マクロの定義
;

; アイテム
ITEM_NULL                       =   0x00
ITEM_SWORD                      =   0x01
ITEM_SHIELD                     =   0x02
ITEM_POTION                     =   0x03
ITEM_BOOTS                      =   0x04
ITEM_COMPASS                    =   0x05
ITEM_KEY                        =   0x06
ITEM_TORCH                      =   0x07
ITEM_HAMMER                     =   0x08
ITEM_CANDLE                     =   0x09
ITEM_MIRROR                     =   0x0a
ITEM_RING                       =   0x0b
ITEM_AMULET                     =   0x0c
ITEM_ARROW                      =   0x0d
ITEM_DROP                       =   0x0e
ITEM_GRASS                      =   0x0f
ITEM_DRAGON_SLAYER              =   0x10
ITEM_CRYSTAL                    =   0x11
ITEM_LENGTH                     =   0x12

; 位置
ITEM_POSITION_X                 =   0x00
ITEM_POSITION_Y                 =   0x01
ITEM_POSITION_LENGTH            =   0x02

; 大きさ
ITEM_R                          =   0x08

; 剣
ITEM_SWORD_PARAM                =   0x01

; 盾
ITEM_SHIELD_PARAM               =   0x01

; 薬
ITEM_POTION_PARAM               =   0x40

; 靴
ITEM_BOOTS_PARAM                =   0x01

; 磁石
ITEM_COMPASS_PARAM              =   0x01

; 鍵
ITEM_KEY_PARAM                  =   0x01

; 松明
ITEM_TORCH_PARAM                =   0x01

; 金槌
ITEM_HAMMER_PARAM               =   0x01

; 蝋燭
ITEM_CANDLE_PARAM               =   0x01

; 鏡
ITEM_MIRROR_PARAM               =   0x01

; 指輪
ITEM_RING_PARAM                 =   0x04

; お守り
ITEM_AMULET_PARAM               =   0x01

; 矢
ITEM_ARROW_PARAM                =   0x01

; 雫
ITEM_DROP_PARAM                 =   0x01

; 眼鏡
ITEM_GRASS_PARAM                =   0x01

; ドラゴンスレイヤー
ITEM_DRAGON_SLAYER_PARAM        =   0x01

; クリスタル
ITEM_CRYSTAL_PARAM              =   0x01


; 外部関数宣言
;

    .globl  _ItemInitialize
    .globl  _ItemUpdate
    .globl  _ItemRender
    .globl  _ItemEntry
    .globl  _ItemIsHit

; 外部変数宣言
;
