; Title.inc : タイトル
;


; マクロの定義
;

; タイトル
TITLE_STATE                     =   0x00
TITLE_FRAME                     =   0x01
TITLE_PAGE                      =   0x02
TITLE_START                     =   0x03
TITLE_LENGTH                    =   0x04

; 状態
TITLE_STATE_NULL                =   0x00

; フレーム
TITLE_FRAME_NULL                =   0x00

; ページ
TITLE_PAGE_LOGO                 =   0x00
TITLE_PAGE_MONSTER_0            =   0x01
TITLE_PAGE_MONSTER_1            =   0x02
TITLE_PAGE_MONSTER_2            =   0x03
TITLE_PAGE_ITEM_0               =   0x04
TITLE_PAGE_ITEM_1               =   0x05
TITLE_PAGE_CONDITION            =   0x06
TITLE_PAGE_LENGTH               =   0x07

; スタート
TITLE_START_NULL                =   0x00

; 外部関数宣言
;

    .globl  _TitleInitialize
    .globl  _TitleUpdate

; 外部変数宣言
;

    .globl  _title
