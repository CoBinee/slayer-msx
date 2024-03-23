; Maze.s : 迷路
;


; モジュール宣言
;
    .module Maze

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Maze.inc"
    .include	"Enemy.inc"
    .include	"Item.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 迷路を初期化する
;
_MazeInitialize::
    
    ; レジスタの保存

    ; フラグの初期化
100$:
    ld      hl, #(mazeFlag + 0x0000)
    ld      de, #(mazeFlag + 0x0001)
    ld      bc, #(MAZE_SIZE_X * MAZE_SIZE_Y - 0x0001)
    xor     a
    ld      (hl), a
    ldir

    ; 迷路の作成
    call    MazeBuild
    
    ; エネミーの初期化
110$:
    ld      hl, #mazeEnemyRest
    ld      de, #MAZE_ENTRY_ENEMY_REST
    ld      bc, #(((MAZE_SIZE_X * MAZE_SIZE_Y) << 8) | 0x0000)
111$:
    push    hl
    ld      a, c
    call    MazeGetRoomEntry
    add     hl, de
    ld      a, (hl)
    pop     hl
    ld      (hl), a
    inc     hl
    inc     c
    djnz    111$

    ; アイテムの初期化
120$:
    ld      hl, #mazeItem
    ld      de, #MAZE_ENTRY_ITEM
    ld      bc, #(((MAZE_SIZE_X * MAZE_SIZE_Y) << 8) | 0x0000)
121$:
    push    hl
    ld      a, c
    call    MazeGetRoomEntry
    add     hl, de
    ld      a, (hl)
    pop     hl
    ld      (hl), a
    inc     hl
    inc     c
    djnz    121$

    ; レジスタの復帰
    
    ; 終了
    ret

; 迷路を作成する
;
MazeBuild:

    ; レジスタの保存

    ; フラグの初期設定
    ld      hl, #(mazeFlag + 0x0000)
    ld      de, #(mazeFlag + 0x0001)
    ld      bc, #(MAZE_SIZE_X * MAZE_SIZE_Y - 0x0001)
    ld      a, #(MAZE_FLAG_WALL_UP | MAZE_FLAG_WALL_DOWN | MAZE_FLAG_WALL_LEFT | MAZE_FLAG_WALL_RIGHT)
    ld      (hl), a
    ldir

    ; クラスタリングのためのワークの初期化
    ld      hl, #mazeWork
    ld      b, #(MAZE_SIZE_X * MAZE_SIZE_Y)
    xor     a
00$:
    ld      (hl), a
    inc     hl
    inc     a
    djnz    00$

    ; クラスタリングによる迷路の生成
100$:
    call    _SystemGetRandom
    and     #(MAZE_SIZE_X_MASK | MAZE_SIZE_Y_MASK)
    ld      e, a
    ld      d, #0x00
101$:
    call    30$
    jr      nz, 102$
    ld      a, e
    inc     a
    and     #(MAZE_SIZE_X_MASK | MAZE_SIZE_Y_MASK)
    ld      e, a
    jr      101$
102$:
    call    40$
    ld      hl, #mazeWork
    ld      a, (hl)
    inc     hl
    ld      b, #(MAZE_SIZE_X * MAZE_SIZE_Y - 0x0001)
103$:
    cp      (hl)
    jr      nz, 100$
    inc     hl
    djnz    103$

    ; 距離取得のためのワークの初期化
    ld      hl, #(mazeWork + 0x0000)
    ld      de, #(mazeWork + 0x0001)
    ld      bc, #(MAZE_SIZE_X * MAZE_SIZE_Y - 0x0001)
    ld      a, #0xff
    ld      (hl), a
    ldir

    ; 迷路の距離の取得
    call    _SystemGetRandom
    and     #(MAZE_SIZE_X_MASK | MAZE_SIZE_Y_MASK)
    ld      e, a
    ld      d, #0x00
    xor     a
    ld      hl, #mazeWork
    add     hl, de
    ld      (hl), a
    call    50$

    ; 迷路の順番の取得
    xor     a
    ld      c, a
110$:
    ld      de, #0x0000
    ld      b, #(MAZE_SIZE_X * MAZE_SIZE_Y)
111$:
    ld      hl, #mazeWork
    add     hl, de
    cp      (hl)
    jr      nz, 112$
    ld      hl, #mazeOrder
    add     hl, de
    ld      (hl), c
    inc     c
112$:
    inc     e
    djnz    111$
    inc     a
    ld      d, a
    ld      a, c
    cp      #(MAZE_SIZE_X * MAZE_SIZE_Y)
    ld      a, d
    jr      c, 110$

    ; 外周に穴をあける
    ld      hl, #(mazeFlag + 0x0000)
    ld      de, #(mazeFlag + MAZE_SIZE_X * (MAZE_SIZE_Y - 1))
    ld      b, #MAZE_SIZE_X
120$:
    call    _SystemGetRandom
    rlca
    cp      #0x60
    jr      nc, 121$
    res     #MAZE_FLAG_WALL_UP_BIT, (hl)
    ex      de, hl
    res     #MAZE_FLAG_WALL_DOWN_BIT, (hl)
    ex      de, hl
121$:
    inc     hl
    inc     de
    djnz    120$
    ld      hl, #(mazeFlag + 0x0000)
    ld      de, #(mazeFlag + MAZE_SIZE_X - 1)
    ld      b, #MAZE_SIZE_X
122$:
    call    _SystemGetRandom
    rlca
    cp      #0x60
    jr      nc, 123$
    res     #MAZE_FLAG_WALL_LEFT_BIT, (hl)
    ex      de, hl
    res     #MAZE_FLAG_WALL_RIGHT_BIT, (hl)
    ex      de, hl
123$:
    push    bc
    ld      bc, #MAZE_SIZE_X
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    122$

    ; 迷路の作成の完了
    jp      90$

    ; 上の参照の取得 de > bc
20$:
    push    af
    ld      a, e
    and     #MAZE_SIZE_Y_MASK
    jr      z, 29$
    sub     #MAZE_SIZE_X
    ld      c, a
    ld      a, e
    and     #MAZE_SIZE_X_MASK
    add     a, c
    jr      28$

    ; 下の参照の取得 de > bc
21$:
    push    af
    ld      a, e
    add     a, #MAZE_SIZE_X
    and     #MAZE_SIZE_Y_MASK
    jr      z, 29$
    ld      c, a
    ld      a, e
    and     #MAZE_SIZE_X_MASK
    add     a, c
    jr      28$

    ; 左の参照の取得 de > bc
22$:
    push    af
    ld      a, e
    and     #MAZE_SIZE_X_MASK
    jr      z, 29$
    dec     a
    ld      c, a
    ld      a, e
    and     #MAZE_SIZE_Y_MASK
    add     a, c
    jr      28$

    ; 右の参照の取得 de > bc
23$:
    push    af
    ld      a, e
    inc     a
    and     #MAZE_SIZE_X_MASK
    jr      z, 29$
    ld      c, a
    ld      a, e
    and     #MAZE_SIZE_Y_MASK
    add     a, c
;   jr      28$

    ; 参照可
28$:
    ld      c, a
    ld      b, d
    pop     af
    or      a
    ret

    ; 参照不可
29$:
    pop     af
    scf
    ret

    ; 上下左右のクラスタの検査
30$:
    push    hl
    push    bc
    ld      hl, #mazeWork
    add     hl, de
    ld      a, (hl)
    call    20$
    jr      c, 31$
    ld      hl, #mazeWork
    add     hl, bc
    cp      (hl)
    jr      nz, 39$
31$:
    call    21$
    jr      c, 32$
    ld      hl, #mazeWork
    add     hl, bc
    cp      (hl)
    jr      nz, 39$
32$:
    call    22$
    jr      c, 33$
    ld      hl, #mazeWork
    add     hl, bc
    cp      (hl)
    jr      nz, 39$
33$:
    call    23$
    jr      c, 34$
    ld      hl, #mazeWork
    add     hl, bc
    cp      (hl)
    jr      39$
34$:
    sub     a
39$:
    pop     bc
    pop     hl
    ret

    ; クラスタの結合
40$:
    push    hl
    push    bc
    call    _SystemGetRandom
    rlca
    rlca
    and     #0x03
    jr      z, 41$
    dec     a
    jr      z, 44$
    dec     a
    jr      z, 43$
    jr      42$
41$:
    ld      hl, #mazeWork
    add     hl, de
    ld      a, (hl)
    call    20$
    jr      c, 42$
    ld      hl, #mazeWork
    add     hl, bc
    cp      (hl)
    jr      z, 42$
    ld      hl, #mazeFlag
    add     hl, de
    res     #MAZE_FLAG_WALL_UP_BIT, (hl)
    ld      hl, #mazeFlag
    add     hl, bc
    res     #MAZE_FLAG_WALL_DOWN_BIT, (hl)
    jr      45$
42$:
    ld      hl, #mazeWork
    add     hl, de
    ld      a, (hl)
    call    21$
    jr      c, 43$
    ld      hl, #mazeWork
    add     hl, bc
    cp      (hl)
    jr      z, 43$
    ld      hl, #mazeFlag
    add     hl, de
    res     #MAZE_FLAG_WALL_DOWN_BIT, (hl)
    ld      hl, #mazeFlag
    add     hl, bc
    res     #MAZE_FLAG_WALL_UP_BIT, (hl)
    jr      45$
43$:
    ld      hl, #mazeWork
    add     hl, de
    ld      a, (hl)
    call    22$
    jr      c, 44$
    ld      hl, #mazeWork
    add     hl, bc
    cp      (hl)
    jr      z, 44$
    ld      hl, #mazeFlag
    add     hl, de
    res     #MAZE_FLAG_WALL_LEFT_BIT, (hl)
    ld      hl, #mazeFlag
    add     hl, bc
    res     #MAZE_FLAG_WALL_RIGHT_BIT, (hl)
    jr      45$
44$:
    ld      hl, #mazeWork
    add     hl, de
    ld      a, (hl)
    call    23$
    jr      c, 41$
    ld      hl, #mazeWork
    add     hl, bc
    cp      (hl)
    jr      z, 41$
    ld      hl, #mazeFlag
    add     hl, de
    res     #MAZE_FLAG_WALL_RIGHT_BIT, (hl)
    ld      hl, #mazeFlag
    add     hl, bc
    res     #MAZE_FLAG_WALL_LEFT_BIT, (hl)
;   jr      45$
45$:
    push    de
    ld      hl, #mazeWork
    add     hl, de
    ld      d, (hl)
    ld      hl, #mazeWork
    add     hl, bc
    ld      e, (hl)
    ld      a, e
    cp      d
    jr      c, 46$
    ld      e, d
    ld      d, a
46$:
    ld      hl, #mazeWork
    ld      a, e
    ld      b, #(MAZE_SIZE_X * MAZE_SIZE_Y)
47$:
    cp      (hl)
    jr      nz, 48$
    ld      (hl), d
48$:
    inc     hl
    djnz    47$
    pop     de
    pop     bc
    pop     hl
    ret

    ; 迷路の距離の取得
50$:
    ld      hl, #mazeFlag
    add     hl, de
    bit     #MAZE_FLAG_WALL_UP_BIT, (hl)
    jr      nz, 52$
    push    de
    ld      hl, #mazeWork
    add     hl, de
    ld      a, e
    sub     #MAZE_SIZE_X
    ld      e, a
    ld      a, (hl)
    inc     a
    ld      hl, #mazeWork
    add     hl, de
    cp      (hl)
    jr      nc, 51$
    ld      (hl), a
    call    50$
51$:
    pop     de
52$:
    ld      hl, #mazeFlag
    add     hl, de
    bit     #MAZE_FLAG_WALL_DOWN_BIT, (hl)
    jr      nz, 54$
    push    de
    ld      hl, #mazeWork
    add     hl, de
    ld      a, e
    add     a, #MAZE_SIZE_X
    ld      e, a
    ld      a, (hl)
    inc     a
    ld      hl, #mazeWork
    add     hl, de
    cp      (hl)
    jr      nc, 53$
    ld      (hl), a
    call    50$
53$:
    pop     de
54$:
    ld      hl, #mazeFlag
    add     hl, de
    bit     #MAZE_FLAG_WALL_LEFT_BIT, (hl)
    jr      nz, 56$
    push    de
    ld      hl, #mazeWork
    add     hl, de
    dec     e
    ld      a, (hl)
    inc     a
    dec     hl
    cp      (hl)
    jr      nc, 55$
    ld      (hl), a
    call    50$
55$:
    pop     de
56$:
    ld      hl, #mazeFlag
    add     hl, de
    bit     #MAZE_FLAG_WALL_RIGHT_BIT, (hl)
    jr      nz, 58$
    push    de
    ld      hl, #mazeWork
    add     hl, de
    inc     e
    ld      a, (hl)
    inc     a
    inc     hl
    cp      (hl)
    jr      nc, 57$
    ld      (hl), a
    call    50$
57$:
    pop     de
58$:
    ret

    ; 処理の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 現在の部屋の順番を取得する
;
MazeGetOrder:

    ; レジスタの保存
    push    hl
    push    de

    ; a < 部屋の順番

    ; 順番の取得
    ld      a, (_game + GAME_ROOM)
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeOrder
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 指定された部屋の配置を取得する
;
MazeGetRoomEntry:

    ; レジスタの保存
    push    de

    ;  a < 部屋の番号
    ; hl > mazeEntry[a]

    ; 配置の取得
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeOrder
    add     hl, de
    ld      a, (hl)
;   ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      hl, #mazeEntry
    add     hl, de

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 指定された順番の部屋を取得する
;
_MazeGetOrderRoom::

    ; レジスタの保存
    push    hl
    push    bc

    ; a < 部屋の順番
    ; a > 部屋の番号

    ; 部屋の取得
    ld      hl, #mazeOrder
    ld      bc, #((MAZE_SIZE_X * MAZE_SIZE_Y) << 8)
10$:
    cp      (hl)
    jr      z, 11$
    inc     hl
    inc     c
    djnz    10$
11$:
    ld      a, c

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; 現在の部屋のエネミーを取得する
;
_MazeGetEnemy::

    ; レジスタの保存
    push    hl
    push    de

    ; a > エネミーの種類（ENEMY_TYPE_?）
    ; b > エネミーの数

    ; エネミーの取得
    call    _MazeGetEnemyRest
    ld      b, a
    ld      a, (_game + GAME_ROOM)
    call    MazeGetRoomEntry
    ld      de, #MAZE_ENTRY_ENEMY_TYPE
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 現在の部屋のエネミーが一匹倒される
;
_MazeKillEnemy::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; エネミーの減少
    ld      a, (_game + GAME_ROOM)
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeEnemyRest
    add     hl, de
    dec     (hl)
    jr      nz, 90$

    ; アイテムの配置条件の判定
    ld      hl, #mazeItem
    add     hl, de
    ld      a, (hl)
    ld      c, a
    or      a
    jr      z, 90$
    cp      #ITEM_BOOTS
    jr      c, 19$
    ld      hl, #mazeItem
    ld      de, #mazeEnemyRest
    ld      b, #(MAZE_SIZE_X * MAZE_SIZE_Y)
10$:
    ld      a, c
    cp      (hl)
    jr      nz, 11$
    ld      a, (de)
    or      a
    jr      nz, 90$
11$:
    inc     hl
    inc     de
    djnz    10$
19$:

    ; アイテムの配置
    ld      a, (_game + GAME_ROOM)
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeFlag
    add     hl, de
    set     #MAZE_FLAG_ITEM_PUT_BIT, (hl)
    call    _ItemEntry
    ld      a, c
    cp      #ITEM_BOOTS
    jr      c, 90$

    ; 同じアイテムを他の部屋から削除
    ld      hl, #mazeFlag
    ld      de, #mazeItem
    ld      b, #(MAZE_SIZE_X * MAZE_SIZE_Y)
20$:
    ld      a, (de)
    cp      c
    jr      nz, 21$
    bit     #MAZE_FLAG_ITEM_PUT_BIT, (hl)
    jr      nz, 21$
    xor     a
    ld      (de), a
21$:
    inc     hl
    inc     de
    djnz    20$

    ; エネミー減少の完了
90$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 現在の部屋のエネミーの数を取得する
;
_MazeGetEnemyRest::

    ; レジスタの保存
    push    hl
    push    de

    ; a > エネミーの数

    ; エネミーの数の取得
    ld      a, (_game + GAME_ROOM)
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeEnemyRest
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 現在の部屋のアイテムを取得する
;
_MazeGetItem::

    ; レジスタの保存
    push    hl
    push    de

    ; a > アイテム（ITEM_?）

    ; アイテムの取得
    ld      a, (_game + GAME_ROOM)
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeItem
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 現在の部屋のアイテムを削除する
;
_MazeKillItem::

    ; レジスタの保存
    push    hl
    push    de

    ; アイテムの取得
    ld      a, (_game + GAME_ROOM)
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeItem
    add     hl, de
    xor     a
    ld      (hl), a

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 現在の部屋にアイテムが置かれているかどうかを取得する
;
_MazeIsPutItem::

    ; レジスタの保存
    push    hl
    push    de

    ; cf > アイテムが置かれている

    ; アイテムの判定
    ld      a, (_game + GAME_ROOM)
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeItem
    add     hl, de
    ld      a, (hl)
    or      a
    jr      z, 11$
    ld      hl, #mazeFlag
    add     hl, de
    bit     #MAZE_FLAG_ITEM_PUT_BIT, (hl)
    jr      z, 10$
    scf
    jr      11$
10$:
    or      a
11$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 現在の部屋のサウンドを取得する
;
_MazeGetSound::

    ; レジスタの保存
    push    hl
    push    de

    ; a > サウンド（GAME_SOUND_?）

    ; サウンドの取得
    ld      a, (_game + GAME_ROOM)
    call    MazeGetRoomEntry
    ld      de, #MAZE_ENTRY_SOUND
    add     hl, de
    ld      e, (hl)

    ; ボス曲の判定
    ld      a, e
    cp      #GAME_SOUND_BGM_BOSS
    jr      nz, 19$
    call    _MazeGetEnemyRest
    or      a
    jr      nz, 19$
    ld      e, #GAME_SOUND_BGM_ZAKO
19$:
    ld      a, e

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 部屋の中かどうかを判定する
;
_MazeIsRoom::

    ; レジスタの保存

    ; de < 位置
    ; cf > 部屋の中である

    ; 位置の判定
    ld      a, d
    cp      #MAZE_ROOM_UP
    jr      c, 18$
    cp      #(MAZE_ROOM_DOWN + 0x01)
    jr      nc, 18$
    ld      a, e
    cp      #MAZE_ROOM_LEFT
    jr      c, 18$
    cp      #(MAZE_ROOM_RIGHT + 0x01)
    jr      nc, 18$
    or      a
    jr      19$
18$:
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 出口を含んだ部屋かどうかを判定する
;
_MazeIsExit::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < 位置
    ; cf > 部屋の中である

    ; フラグの取得
    ld      a, (_game + GAME_ROOM)
    ld      c, a
    ld      b, #0x00
    ld      hl, #mazeFlag
    add     hl, bc

    ; 出口の判定
    ld      a, e
    cp      #MAZE_ROOM_SIZE_X
    jr      nc, 18$
    ld      a, d
    cp      #MAZE_ROOM_SIZE_Y
    jr      nc, 18$
;   ld      a, d
    cp      #MAZE_ROOM_UP
    jr      nc, 10$
    bit     #MAZE_FLAG_WALL_UP_BIT, (hl)
    jr      nz, 18$
    ld      a, e
    cp      #MAZE_EXIT_MINUS
    jr      c, 18$
    cp      #(MAZE_EXIT_PLUS + 0x01)
    jr      nc, 18$
    jr      17$
10$:
    cp      #(MAZE_ROOM_DOWN + 0x01)
    jr      c, 11$
    bit     #MAZE_FLAG_WALL_DOWN_BIT, (hl)
    jr      nz, 18$
    ld      a, e
    cp      #MAZE_EXIT_MINUS
    jr      c, 18$
    cp      #(MAZE_EXIT_PLUS + 0x01)
    jr      nc, 18$
    jr      17$
11$:
    ld      a, e
    cp      #MAZE_ROOM_LEFT
    jr      nc, 12$
    bit     #MAZE_FLAG_WALL_LEFT_BIT, (hl)
    jr      nz, 18$
    ld      a, d
    cp      #MAZE_EXIT_MINUS
    jr      c, 18$
    cp      #(MAZE_EXIT_PLUS + 0x01)
    jr      nc, 18$
    jr      17$
12$:
    cp      #(MAZE_ROOM_RIGHT + 0x01)
    jr      c, 17$
    bit     #MAZE_FLAG_WALL_RIGHT_BIT, (hl)
    jr      nz, 18$
    ld      a, d
    cp      #MAZE_EXIT_MINUS
    jr      c, 18$
    cp      #(MAZE_EXIT_PLUS + 0x01)
    jr      nc, 18$
17$:
    or      a
    jr      19$
18$:
    scf
19$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; 迷路の部屋を描画する
;
_MazePrintRoom::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; 部屋の描画
    ld      hl, #mazePatternNameWall
    ld      de, #(_patternName + 0x0001)
    ld      b, #0x17
10$:
    push    bc
    ld      b, #0x16
11$:
    ld      a, (hl)
    inc     hl
    cp      (hl)
    jr      z, 12$
    ld      (de), a
    inc     de
    dec     b
    jr      nz, 11$
    jr      14$
12$:
    inc     hl
    ld      c, (hl)
    inc     hl
13$:
    ld      (de), a
    inc     de
    dec     b
    jr      z, 14$
    dec     c
    jr      nz, 13$
    jr      11$
14$:
    ex      de, hl
    ld      bc, #0x000a
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    10$

    ; 部屋の取得
    ld      a, (_game + GAME_ROOM)
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeFlag
    add     hl, de
    ld      c, (hl)

    ; 上の入り口の描画
    ld      hl, #mazePatternNameExitUp
    ld      de, #(_patternName + 0x000a)
    ld      b, #0x03
    bit     #MAZE_FLAG_WALL_UP_BIT, c
    call    z, 20$

    ; 下の入り口の描画
    ld      hl, #mazePatternNameExitDown
    ld      de, #(_patternName + 0x02aa)
    ld      b, #0x02
    bit     #MAZE_FLAG_WALL_DOWN_BIT, c
    call    z, 20$

    ; 左の入り口の描画
    ld      hl, #mazePatternNameExitLeft
    ld      de, #(_patternName + 0x0121)
    ld      b, #0x05
    bit     #MAZE_FLAG_WALL_LEFT_BIT, c
    call    z, 20$

    ; 右の入り口の描画
    ld      hl, #mazePatternNameExitRight
    ld      de, #(_patternName + 0x0133)
    ld      b, #0x05
    bit     #MAZE_FLAG_WALL_RIGHT_BIT, c
    call    z, 20$
    jr      29$

    ; 入口の描画
20$:
    push    bc
    ld      bc, #0x0004
    ldir
    ex      de, hl
    ld      bc, #0x001c
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    20$
    ret
29$:

    ; 扉の描画
    ld      a, (_game + GAME_ROOM)
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeOrder
    add     hl, de
    ld      a, (hl)
    or      a
    jr      nz, 49$
    ld      hl, #(_patternName + 0x016b)
    ld      de, #(0x001f)
    ld      a, #0xbc
    ld      (hl), a
    inc     hl
    inc     a
    ld      (hl), a
    add     hl, de
    inc     a
    ld      (hl), a
    inc     hl
    inc     a
    ld      (hl), a
49$:

    ; デバッグ
    ; call    MazePrintFlag

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret
    
; 迷路のフラグを描画する
;
MazePrintFlag:

    ; レジスタの保存

    ; フラグの描画
;   ld      hl, #(_patternName + 0x0218)
;   ld      de, #mazeFlag
;   ld      c, #MAZE_SIZE_Y
10$:
;   ld      b, #MAZE_SIZE_X
11$:
;   ld      a, (de)
;   add     a, #0xb0
;   ld      (hl), a
;   inc     hl
;   inc     de
;   djnz    11$
;   push    de
;   ld      de, #(0x20 - MAZE_SIZE_X)
;   add     hl, de
;   pop     de
;   dec     c
;   jr      nz, 10$

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 配置
;
mazeEntry:

    .db     ENEMY_TYPE_GATE,     0x01, ITEM_NULL,          GAME_SOUND_BGM_ZAKO ; 00
    .db     ENEMY_TYPE_CRYSTAL,  0x01, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_BAT,      0x04, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_RAT,      0x02, ITEM_KEY,           GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_BAT,      0x05, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_GOBLIN,   0x02, ITEM_SWORD,         GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_BAT,      0x08, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_RAT,      0x04, ITEM_KEY,           GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_MIMIC,    0x01, ITEM_ARROW,         GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_CYCLOPS,  0x01, ITEM_POTION,        GAME_SOUND_BGM_BOSS
    .db     ENEMY_TYPE_RAT,      0x05, ITEM_KEY,           GAME_SOUND_BGM_ZAKO ; 10
    .db     ENEMY_TYPE_SNAKE,    0x04, ITEM_TORCH,         GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_SPIDER,   0x04, ITEM_BOOTS,         GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_GOBLIN,   0x04, ITEM_SWORD,         GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_SLIME,    0x04, ITEM_RING,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_REAPER,   0x01, ITEM_SHIELD,        GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_SPIDER,   0x05, ITEM_BOOTS,         GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_GOBLIN,   0x05, ITEM_SWORD,         GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_GHOST,    0x04, ITEM_COMPASS,       GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_REAPER,   0x04, ITEM_SHIELD,        GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_MIMIC,    0x04, ITEM_DROP,          GAME_SOUND_BGM_ZAKO ; 20
    .db     ENEMY_TYPE_ZORN,     0x01, ITEM_POTION,        GAME_SOUND_BGM_BOSS
    .db     ENEMY_TYPE_SNAKE,    0x05, ITEM_TORCH,         GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_SPIDER,   0x08, ITEM_BOOTS,         GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_SLIME,    0x05, ITEM_RING,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_GHOUL,    0x04, ITEM_CANDLE,        GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_GHOST,    0x05, ITEM_COMPASS,       GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_REAPER,   0x05, ITEM_SHIELD,        GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_SNAKE,    0x08, ITEM_TORCH,         GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_SLIME,    0x08, ITEM_RING,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_GAZER,    0x04, ITEM_HAMMER,        GAME_SOUND_BGM_ZAKO ; 30
    .db     ENEMY_TYPE_GHOST,    0x08, ITEM_COMPASS,       GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_MAGE,     0x04, ITEM_SHIELD,        GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_SQUID,    0x04, ITEM_MIRROR,        GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_ROGUE,    0x05, ITEM_SWORD,         GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_LICH,     0x04, ITEM_AMULET,        GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_MIMIC,    0x08, ITEM_GRASS,         GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_SHADOW,   0x01, ITEM_POTION,        GAME_SOUND_BGM_BOSS
    .db     ENEMY_TYPE_GHOUL,    0x05, ITEM_CANDLE,        GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_GAZER,    0x05, ITEM_HAMMER,        GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_GOLEM,    0x05, ITEM_NULL,          GAME_SOUND_BGM_ZAKO ; 40
    .db     ENEMY_TYPE_ROGUE,    0x08, ITEM_SWORD,         GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_SQUID,    0x05, ITEM_MIRROR,        GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_LICH,     0x05, ITEM_AMULET,        GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_MAGE,     0x05, ITEM_SHIELD,        GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_GARGOYLE, 0x05, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_GHOUL,    0x08, ITEM_CANDLE,        GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_GAZER,    0x08, ITEM_HAMMER,        GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_GOLEM,    0x08, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_ROGUE,    0x09, ITEM_SWORD,         GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_SQUID,    0x08, ITEM_MIRROR,        GAME_SOUND_BGM_ZAKO ; 50
    .db     ENEMY_TYPE_LICH,     0x08, ITEM_AMULET,        GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_MAGE,     0x08, ITEM_SHIELD,        GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_GARGOYLE, 0x08, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_LIZARD,   0x08, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_DAEMON,   0x08, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_PHANTOM,  0x05, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_DRAGON,   0x01, ITEM_CRYSTAL,       GAME_SOUND_BGM_BOSS
    .db     ENEMY_TYPE_GOLEM,    0x09, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_LIZARD,   0x09, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_GARGOYLE, 0x09, ITEM_NULL,          GAME_SOUND_BGM_ZAKO ; 60
    .db     ENEMY_TYPE_DAEMON,   0x09, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_PHANTOM,  0x08, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
    .db     ENEMY_TYPE_MIMIC,    0x09, ITEM_DRAGON_SLAYER, GAME_SOUND_BGM_ZAKO

;   .db     ENEMY_TYPE_GATE,     0x01, ITEM_NULL,          GAME_SOUND_BGM_ZAKO ; 00
;   .db     ENEMY_TYPE_CRYSTAL,  0x01, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_BAT,      0x04, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_BAT,      0x05, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_BAT,      0x08, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_RAT,      0x02, ITEM_KEY,           GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_RAT,      0x04, ITEM_KEY,           GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_GOBLIN,   0x02, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_MIMIC,    0x01, ITEM_ARROW,         GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_CYCLOPS,  0x01, ITEM_POTION,        GAME_SOUND_BGM_BOSS
;   .db     ENEMY_TYPE_RAT,      0x05, ITEM_KEY,           GAME_SOUND_BGM_ZAKO ; 10
;   .db     ENEMY_TYPE_GOBLIN,   0x04, ITEM_SWORD,         GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_GOBLIN,   0x05, ITEM_SWORD,         GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_REAPER,   0x01, ITEM_SHIELD,        GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_REAPER,   0x04, ITEM_SHIELD,        GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_SNAKE,    0x04, ITEM_TORCH,         GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_SPIDER,   0x04, ITEM_BOOTS,         GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_SPIDER,   0x05, ITEM_BOOTS,         GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_SLIME,    0x04, ITEM_RING,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_GHOST,    0x04, ITEM_COMPASS,       GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_MIMIC,    0x04, ITEM_DROP,          GAME_SOUND_BGM_ZAKO ; 20
;   .db     ENEMY_TYPE_ZORN,     0x01, ITEM_POTION,        GAME_SOUND_BGM_BOSS
;   .db     ENEMY_TYPE_SNAKE,    0x05, ITEM_TORCH,         GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_SNAKE,    0x08, ITEM_TORCH,         GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_SPIDER,   0x08, ITEM_BOOTS,         GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_SLIME,    0x05, ITEM_RING,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_SLIME,    0x08, ITEM_RING,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_GHOST,    0x05, ITEM_COMPASS,       GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_GHOST,    0x08, ITEM_COMPASS,       GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_ROGUE,    0x05, ITEM_SWORD,         GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_REAPER,   0x05, ITEM_SHIELD,        GAME_SOUND_BGM_ZAKO ; 30
;   .db     ENEMY_TYPE_MAGE,     0x04, ITEM_SHIELD,        GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_GHOUL,    0x04, ITEM_CANDLE,        GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_GAZER,    0x04, ITEM_HAMMER,        GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_SQUID,    0x04, ITEM_MIRROR,        GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_LICH,     0x04, ITEM_AMULET,        GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_MIMIC,    0x08, ITEM_GRASS,         GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_SHADOW,   0x01, ITEM_POTION,        GAME_SOUND_BGM_BOSS
;   .db     ENEMY_TYPE_GHOUL,    0x05, ITEM_CANDLE,        GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_GHOUL,    0x08, ITEM_CANDLE,        GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_GAZER,    0x05, ITEM_HAMMER,        GAME_SOUND_BGM_ZAKO ; 40
;   .db     ENEMY_TYPE_GAZER,    0x08, ITEM_HAMMER,        GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_SQUID,    0x05, ITEM_MIRROR,        GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_SQUID,    0x08, ITEM_MIRROR,        GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_LICH,     0x05, ITEM_AMULET,        GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_LICH,     0x08, ITEM_AMULET,        GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_ROGUE,    0x08, ITEM_SWORD,         GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_ROGUE,    0x09, ITEM_SWORD,         GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_MAGE,     0x05, ITEM_SHIELD,        GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_MAGE,     0x08, ITEM_SHIELD,        GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_GARGOYLE, 0x05, ITEM_NULL,          GAME_SOUND_BGM_ZAKO ; 50
;   .db     ENEMY_TYPE_GARGOYLE, 0x08, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_LIZARD,   0x08, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_DAEMON,   0x08, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_GOLEM,    0x05, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_GOLEM,    0x08, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_PHANTOM,  0x05, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_DRAGON,   0x01, ITEM_CRYSTAL,       GAME_SOUND_BGM_BOSS
;   .db     ENEMY_TYPE_PHANTOM,  0x08, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_DAEMON,   0x09, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_GARGOYLE, 0x09, ITEM_NULL,          GAME_SOUND_BGM_ZAKO ; 60
;   .db     ENEMY_TYPE_LIZARD,   0x09, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_GOLEM,    0x09, ITEM_NULL,          GAME_SOUND_BGM_ZAKO
;   .db     ENEMY_TYPE_MIMIC,    0x09, ITEM_DRAGON_SLAYER, GAME_SOUND_BGM_ZAKO

; パターンネーム
;
mazePatternNameWall:

    .db     0x00, 0x00, 0x16
    .db     0x00, 0xf0, 0xf1, 0xf1, 0x12, 0xf2, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xf4, 0xf4, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf3, 0xbb, 0xbb, 0x12, 0xf5, 0x00, 0x00, 0x01
    .db     0x00, 0xf6, 0xf7, 0xf7, 0x12, 0xf8, 0x00, 0x00, 0x01
    .db     0x00, 0x00, 0x16

mazePatternNameExitUp:

    .db     0xf3, 0xbb, 0xbb, 0xf5
    .db     0xfe, 0xbb, 0xbb, 0xfc
    .db     0xf4, 0xbb, 0xbb, 0xf4

mazePatternNameExitDown:

    .db     0xfb, 0xbb, 0xbb, 0xf9
    .db     0xf3, 0xbb, 0xbb, 0xf5

mazePatternNameExitLeft:

    .db     0xfd, 0xfe, 0xbb, 0xbb
    .db     0xf4, 0xf4, 0xbb, 0xbb
    .db     0xbb, 0xbb, 0xbb, 0xbb
    .db     0xbb, 0xbb, 0xbb, 0xbb
    .db     0xfa, 0xfb, 0xbb, 0xbb

mazePatternNameExitRight:

    .db     0xbb, 0xbb, 0xfc, 0xfd
    .db     0xbb, 0xbb, 0xf4, 0xf4
    .db     0xbb, 0xbb, 0xbb, 0xbb
    .db     0xbb, 0xbb, 0xbb, 0xbb
    .db     0xbb, 0xbb, 0xf9, 0xfa


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; フラグ
;
mazeFlag:

    .ds     MAZE_SIZE_X * MAZE_SIZE_Y

; 順番
;
mazeOrder:

    .ds     MAZE_SIZE_X * MAZE_SIZE_Y

; ワーク
;
mazeWork:

    .ds     MAZE_SIZE_X * MAZE_SIZE_Y

; エネミー
;
mazeEnemyRest:

    .ds     MAZE_SIZE_X * MAZE_SIZE_Y

; アイテム
;
mazeItem:

    .ds     MAZE_SIZE_X * MAZE_SIZE_Y
