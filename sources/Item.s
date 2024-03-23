; Item.s : アイテム
;


; モジュール宣言
;
    .module Item

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Maze.inc"
    .include    "Player.inc"
    .include	"Item.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; アイテムを初期化する
;
_ItemInitialize::
    
    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; アイテムを更新する
;
_ItemUpdate::
    
    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; アイテムを描画する
;
_ItemRender::

    ; レジスタの保存

    ; スプライトの描画
    call    _MazeIsPutItem
    jr      nc, 19$
    ld      hl, #(_sprite + GAME_SPRITE_ITEM)
    ld      a, (itemPosition + ITEM_POSITION_Y)
    add     a, #(MAZE_ROOM_OFFSET_Y - ITEM_R - 0x01)
    ld      (hl), a
    inc     hl
    ld      a, (itemPosition + ITEM_POSITION_X)
    add     a, #(MAZE_ROOM_OFFSET_X - ITEM_R)
    ld      (hl), a
    inc     hl
    call    _MazeGetItem
    add     a, #(0x10 - 0x01)
    ld      (hl), a
    inc     hl
    ld      (hl), #VDP_COLOR_WHITE
;   inc     hl
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 現在の部屋にアイテムを配置する
;
_ItemEntry:

    ; レジスタの保存
    push    bc
    push    de

    ; アイテムの配置
    call    _MazeIsPutItem
    jr      nc, 19$
    ld      bc, #(((MAZE_ROOM_SIZE_Y / 2) << 8) | (MAZE_ROOM_SIZE_X / 2))
    ld      de, (_player + PLAYER_POSITION_X)
    ld      a, d
    cp      #MAZE_ROOM_UP
    jr      c, 13$
    cp      #(MAZE_ROOM_DOWN + 0x01)
    jr      nc, 13$
    ld      a, e
    cp      #MAZE_ROOM_LEFT
    jr      c, 13$
    cp      #(MAZE_ROOM_RIGHT + 0x01)
    jr      nc, 13$
    ld      a, d
    cp      #(MAZE_ROOM_SIZE_Y / 2)
    jr      c, 10$
    ld      b, #(MAZE_ROOM_SIZE_Y / 4)
    jr      11$
10$:
    ld      b, #(MAZE_ROOM_SIZE_Y * 3 / 4)
;   jr      11$
11$:
    ld      a, e
    cp      #(MAZE_ROOM_SIZE_X / 2)
    jr      c, 12$
    ld      c, #(MAZE_ROOM_SIZE_X / 4)
    jr      13$
12$:
    ld      c, #(MAZE_ROOM_SIZE_X * 3 / 4)
;   jr      13$
13$:
    ld      (itemPosition), bc
19$:

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret
    
; アイテムとのヒットコリジョンを判定する
;
_ItemIsHit::

    ; レジスタの保存
    push    hl
    push    de

    ; de < 位置
    ;  b < 大きさ
    ;  a > ヒットしたアイテム（ITEM_?）
    ;  c > アイテムのパラメータ

    ; コリジョン判定
    call    _MazeIsPutItem
    jr      nc, 10$
    ld      a, (itemPosition + ITEM_POSITION_Y)
;   add     a, #ITEM_R
    ld      l, a
    ld      a, d
    sub     b
    cp      l
    jr      nc, 10$
    ld      a, d
    add     a, b
    ld      l, a
    ld      a, (itemPosition + ITEM_POSITION_Y)
;   sub     #ITEM_R
    cp      l
    jr      nc, 10$
    ld      a, (itemPosition + ITEM_POSITION_X)
;   add     a, #ITEM_R
    ld      l, a
    ld      a, e
    sub     b
    cp      l
    jr      nc, 10$
    ld      a, e
    add     a, b
    ld      l, a
    ld      a, (itemPosition + ITEM_POSITION_X)
;   sub     #ITEM_R
    cp      l
    jr      nc, 10$
    call    _MazeGetItem
    ld      e, a
    dec     e
    ld      d, #0x00
    ld      hl, #itemParam
    add     hl, de
    ld      c, (hl)
    jr      19$
10$:
    xor     a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; パラメータ
itemParam:

;   .db     0x00
    .db     ITEM_SWORD_PARAM
    .db     ITEM_SHIELD_PARAM
    .db     ITEM_POTION_PARAM
    .db     ITEM_BOOTS_PARAM
    .db     ITEM_COMPASS_PARAM
    .db     ITEM_KEY_PARAM
    .db     ITEM_TORCH_PARAM
    .db     ITEM_HAMMER_PARAM
    .db     ITEM_CANDLE_PARAM
    .db     ITEM_MIRROR_PARAM
    .db     ITEM_RING_PARAM
    .db     ITEM_AMULET_PARAM
    .db     ITEM_ARROW_PARAM
    .db     ITEM_DROP_PARAM
    .db     ITEM_GRASS_PARAM
    .db     ITEM_DRAGON_SLAYER_PARAM
    .db     ITEM_CRYSTAL_PARAM


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 位置
;
itemPosition:

    .ds     ITEM_POSITION_LENGTH
