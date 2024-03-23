; Enemy.s : エネミー
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include	"Maze.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"
    .include    "EnemyDefault.inc"
    .include    "Item.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; エネミーを初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存

    ; エネミーのクリア
    call    EnemyClear

    ; スプライトの初期化
    xor     a
    ld      (enemySprite), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存
    
    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
100$:
    push    bc

    ; エネミーの判定
    ld      a, ENEMY_TYPE(ix)
    or      a
    jp      z, 190$

    ; ダメージの更新
    ld      a, ENEMY_DAMAGE_POINT(ix)
    or      a
    jr      z, 115$
    ld      a, ENEMY_ITEM_WEAK(ix)
    or      a
    jr      z, 110$
    call    _PlayerIsItem
    jr      c, 110$
    ld      a, #ENEMY_COLOR_DAMAGE_MISS
    ld      ENEMY_COLOR_DAMAGE(ix), a
    ld      a, #GAME_SOUND_SE_MISS
    call    _GamePlaySe
    jr      114$
110$:
    ld      a, ENEMY_DAMAGE_POINT(ix)
    sub     ENEMY_GUARD(ix)
    jr      c, 111$
    jr      z, 111$
    ld      c, a
    jr      112$
111$:
    ld      c, #0x01
;   jr      112$
112$:
    ld      a, ENEMY_LIFE(ix)
    sub     c
    jr      nc, 113$
    xor      a
113$:
    ld      ENEMY_LIFE(ix), a
    ld      a, #ENEMY_COLOR_DAMAGE_HIT
    ld      ENEMY_COLOR_DAMAGE(ix), a
    ld      a, #GAME_SOUND_SE_HIT
    call    _GamePlaySe
114$:
    xor     a
    ld      ENEMY_DAMAGE_POINT(ix), a
    ld      a, #ENEMY_DAMAGE_FRAME_LENGTH
    ld      ENEMY_DAMAGE_FRAME(ix), a
    ld      a, ENEMY_LIFE(ix)
    or      a
    jr      nz, 115$
    set     #ENEMY_FLAG_NOHIT_BIT, ENEMY_FLAG(ix)
    ld      a, #ENEMY_STATE_DEAD
    ld      ENEMY_STATE(ix), a
115$:
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jr      z, 116$
    dec     ENEMY_DAMAGE_FRAME(ix)
116$:

    ; 待機の監視
    ld      a, (_game + GAME_FLAG)
    bit     #GAME_FLAG_WAIT_BIT, a
    jr      nz, 190$

    ; 状態別の処理
    ld      hl, #190$
    push    hl
    ld      a, ENEMY_STATE(ix)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
190$:

    ; 次のエネミーへ
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    dec     b
    jp      nz, 100$

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを描画する
;
_EnemyRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      ix, #_enemy
    ld      a, (enemySprite)
    ld      e, a
    ld      d, #0x00
    ld      b, #ENEMY_ENTRY
10$:
    push    bc
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 12$
    ld      hl, #(_sprite + GAME_SPRITE_ENEMY)
    add     hl, de
    bit     #ENEMY_FLAG_2x2_BIT, ENEMY_FLAG(ix)
    jr      nz, 11$
    call    20$
    ld      a, e
    add     a, #0x04
    ld      e, a
    jr      12$
11$:
    push    de
    call    30$
    pop     de
    ld      a, e
    add     a, #0x10
    ld      e, a
;   jr      12$
12$:
    ld      a, e
    cp      #ENEMY_SPRITE_LENGTH
    jr      c, 13$
    ld      e, #0x00
13$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$
    jp      90$

    ; 1x1 スプライトの描画
20$:
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jr      nz, 21$
    ld      a, ENEMY_FLAG(ix)
    bit     #ENEMY_FLAG_NORENDER_BIT, a
    jr      nz, 29$
    ld      a, ENEMY_ANIMATION(ix)
    rrca
    rrca
    rrca
    and     #0x01
    add     a, ENEMY_SPRITE(ix)
    ld      b, a
    ld      c, ENEMY_COLOR_NORMAL(ix)
    jr      22$
21$:
    ld      b, #ENEMY_SPRITE_DAMAGE
    ld      c, ENEMY_COLOR_DAMAGE(ix)
;   jr      22$
22$:
    ld      a, ENEMY_POSITION_Y(ix)
    sub     ENEMY_R(ix)
    add     a, #(MAZE_ROOM_OFFSET_Y - 0x01)
    ld      (hl), a
    inc     hl
    ld      a, ENEMY_POSITION_X(ix)
    sub     ENEMY_R(ix)
    add     a, #MAZE_ROOM_OFFSET_X
    ld      (hl), a
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), c
    inc     hl
29$:
    ret

    ; 2x2 スプライトの描画
30$:
    ld      d, ENEMY_POSITION_Y(ix)
    ld      e, ENEMY_POSITION_X(ix)
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jr      nz, 31$
    ld      a, ENEMY_FLAG(ix)
    bit     #ENEMY_FLAG_NORENDER_BIT, a
    jp      nz, 39$
    ld      a, ENEMY_ANIMATION(ix)
    rrca
    rrca
    rrca
    and     #0x02
    add     a, ENEMY_SPRITE(ix)
    ld      b, a
    ld      c, ENEMY_COLOR_NORMAL(ix)
    ld      a, d
    sub     ENEMY_R(ix)
    add     a, #(MAZE_ROOM_OFFSET_Y - 0x01)
    ld      (hl), a
    inc     hl
    ld      a, e
    sub     ENEMY_R(ix)
    add     a, #MAZE_ROOM_OFFSET_X
    ld      (hl), a
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), c
    inc     hl
    inc     b
    ld      a, d
    sub     ENEMY_R(ix)
    add     a, #(MAZE_ROOM_OFFSET_Y - 0x01)
    ld      (hl), a
    inc     hl
    ld      a, e
    add     a, #MAZE_ROOM_OFFSET_X
    ld      (hl), a
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), c
    inc     hl
    ld      a, b
    add     a, #0x0f
    ld      b, a
    ld      a, d
    add     a, #(MAZE_ROOM_OFFSET_Y - 0x01)
    ld      (hl), a
    inc     hl
    ld      a, e
    sub     ENEMY_R(ix)
    add     a, #MAZE_ROOM_OFFSET_X
    ld      (hl), a
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), c
    inc     hl
    inc     b
    ld      a, d
    add     a, #(MAZE_ROOM_OFFSET_Y - 0x01)
    ld      (hl), a
    inc     hl
    ld      a, e
    add     a, #MAZE_ROOM_OFFSET_X
    ld      (hl), a
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), c
    inc     hl
    jr      39$
31$:
    ld      b, #ENEMY_SPRITE_DAMAGE
    ld      c, ENEMY_COLOR_DAMAGE(ix)
    ld      a, d
    sub     ENEMY_R(ix)
    add     a, #(MAZE_ROOM_OFFSET_Y - 0x01)
    ld      (hl), a
    inc     hl
    ld      a, e
    sub     ENEMY_R(ix)
    add     a, #MAZE_ROOM_OFFSET_X
    ld      (hl), a
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), c
    inc     hl
    ld      a, d
    sub     ENEMY_R(ix)
    add     a, #(MAZE_ROOM_OFFSET_Y - 0x01)
    ld      (hl), a
    inc     hl
    ld      a, e
    add     a, #MAZE_ROOM_OFFSET_X
    ld      (hl), a
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), c
    inc     hl
    ld      a, d
    add     a, #(MAZE_ROOM_OFFSET_Y - 0x01)
    ld      (hl), a
    inc     hl
    ld      a, e
    sub     ENEMY_R(ix)
    add     a, #MAZE_ROOM_OFFSET_X
    ld      (hl), a
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), c
    inc     hl
    ld      a, d
    add     a, #(MAZE_ROOM_OFFSET_Y - 0x01)
    ld      (hl), a
    inc     hl
    ld      a, e
    add     a, #MAZE_ROOM_OFFSET_X
    ld      (hl), a
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), c
    inc     hl
;   jr      39$
39$:
    ret

    ; 描画の完了
90$:

    ; スプライトの更新
    ld      hl, #enemySprite
    ld      a, (hl)
    add     a, #0x04
    cp      #ENEMY_SPRITE_LENGTH
    jr      c, 91$
    xor     a
91$:
    ld      (hl), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーをクリアする
;
EnemyClear:

    ; レジスタの保存

    ; 初期値の設定
    ld      hl, #(_enemy + 0x0000)
    ld      de, #(_enemy + 0x0001)
    ld      bc, #(ENEMY_LENGTH * ENEMY_ENTRY - 0x0001)
    xor     a
    ld      (hl), a
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを配置する
;
_EnemyEntry::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy

    ; エネミーのクリア
    call    EnemyClear

    ; エネミーの取得
    call    _MazeGetEnemy
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyDefault
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl

    ; エネミーの存在
    ld      a, b
    or      a
    jr      z, 90$

    ; 位置の取得
    ld      a, b
    ld      iy, #enemyPosition9
    cp      #0x06
    jr      nc, 10$
    ld      iy, #enemyPosition5
    cp      #0x02
    jr      nc, 10$
    ld      iy, #enemyPosition1
10$:

    ; 配置
    ld      de, #_enemy
20$:
    push    hl
    push    bc
    push    de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     ix
    ld      a, 0x00(iy)
    ld      ENEMY_POSITION_X(ix), a
    inc     iy
    ld      a, 0x00(iy)
    ld      ENEMY_POSITION_Y(ix), a
    inc     iy
    call    _SystemGetRandom
    ld      ENEMY_ANIMATION(ix), a
    call    _SystemGetRandom
    rlca
    and     #0x3f
    ld      ENEMY_MAGIC_FRAME(ix), a
    pop     bc
    pop     hl
    djnz    20$

    ; 配置の完了
90$:

    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 何もしない
;
EnemyNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; 待機する
;
EnemyStay:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; プレイヤへ向く
    call    EnemyGetDirectionToPlayer
    ld      ENEMY_DIRECTION(ix), a

    ; 移動するふりをして攻撃する
    ld      a, ENEMY_POWER_POINT(ix)
    or      a
    jr      z, 19$
    ld      l, ENEMY_POSITION_X(ix)
    ld      h, ENEMY_POSITION_Y(ix)
    push    hl
    push    de
    call    EnemyMove
    pop     de
    pop     hl
    ld      ENEMY_POSITION_X(ix), l
    ld      ENEMY_POSITION_Y(ix), h
19$:

    ; 魔法を放つ
    call    EnemyCastCycle

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

; 自由に移動する
;
EnemyFree:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 向きの変更
    call    _SystemGetRandom
    ld      c, a
    and     #0x18
    jr      z, 00$
    ld      a, c
    rrca
    rrca
    and     #0x03
    jr      01$
00$:
    call    EnemyGetDirectionToPlayer
;   jr      01$
01$:
    ld      ENEMY_DIRECTION(ix), a

    ; 移動量の設定
    call    _SystemGetRandom
    and     ENEMY_MOVE_PARAM_1(ix)
    add     a, ENEMY_MOVE_PARAM_2(ix)
    ld      ENEMY_MOVE_PARAM_0(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    call    EnemyMove
    jr      nc, 19$
    bit     #ENEMY_FLAG_HITPLAYER_BIT, ENEMY_FLAG(ix)
    jr      nz, 19$
    bit     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)
    jr      nz, 10$
    ld      a, ENEMY_MOVE_PARAM_0(ix)
    or      a
    jr      z, 10$
    dec     ENEMY_MOVE_PARAM_0(ix)
    jr      19$
10$:
    ld      a, ENEMY_STATE(ix)
    and     #0xf0
    ld      ENEMY_STATE(ix), a
19$:

    ; 魔法を放つ
    call    EnemyCastCycle

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤに向かってに移動する
;
EnemyApproach:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; プレイヤの位置の取得
    ld      a, (_player + PLAYER_POSITION_X)
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_Y)
    ld      d, a

    ; 向きの変更
    call    _SystemGetRandom
    and     #0x42
    jr      z, 04$
    call    EnemyGetDirectionToPlayer
    ld      c, a
    or      a
    jr      z, 00$
    dec     a
    jr      z, 01$
    dec     a
    jr      z, 02$
    jr      03$
00$:
    ld      a, ENEMY_POSITION_Y(ix)
    sub     d
    jr      z, 04$
    jr      05$
01$:
    ld      a, d
    sub     ENEMY_POSITION_Y(ix)
    jr      z, 04$
    jr      05$
02$:
    ld      a, ENEMY_POSITION_X(ix)
    sub     e
    jr      z, 04$
    jr      05$
03$:
    ld      a, e
    sub     ENEMY_POSITION_X(ix)
    jr      z, 04$
    jr      05$
04$:
    call    _SystemGetRandom
    rrca
    and     #0x03
    ld      c, a
    call    _SystemGetRandom
    and     ENEMY_MOVE_PARAM_1(ix)
    add     a, ENEMY_MOVE_PARAM_2(ix)
    ld      ENEMY_MOVE_PARAM_0(ix), a
;   jr      05$
05$:
    ld      ENEMY_DIRECTION(ix), c
    ld      ENEMY_MOVE_PARAM_0(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    call    EnemyMove
    jr      nc, 19$
    bit     #ENEMY_FLAG_HITPLAYER_BIT, ENEMY_FLAG(ix)
    jr      nz, 19$
    bit     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)
    jr      nz, 10$
    ld      a, ENEMY_MOVE_PARAM_0(ix)
    or      a
    jr      z, 10$
    dec     ENEMY_MOVE_PARAM_0(ix)
    jr      19$
10$:
    ld      a, ENEMY_STATE(ix)
    and     #0xf0
    ld      ENEMY_STATE(ix), a
19$:

    ; 魔法を放つ
    ld      a, ENEMY_MAGIC_POINT(ix)
    or      a
    jr      z, 29$
    inc     ENEMY_MAGIC_FRAME(ix)
    ld      a, ENEMY_MAGIC_FRAME(ix)
    cp      ENEMY_MAGIC_CYCLE(ix)
    jr      c, 29$
    bit     #ENEMY_FLAG_2x2_BIT, ENEMY_FLAG(ix)
    jr      nz, 20$
    call    EnemyGetDirectionToPlayer
    ld      ENEMY_DIRECTION(ix), a
    call    EnemyCastToDirection
    jr      21$
20$:
    call    EnemyCastToAll
;   jr      21$
21$:
    call    _SystemGetRandom
    and     #0x0f
    ld      ENEMY_MAGIC_FRAME(ix), a
29$:

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

; ワープする
;
EnemyWarp:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 移動の設定
    call    _SystemGetRandom
    and     ENEMY_MOVE_PARAM_3(ix)
    add     a, #0x1e
    ld      ENEMY_MOVE_PARAM_0(ix), a

    ; コリジョンなし
    set     #ENEMY_FLAG_NOHIT_BIT, ENEMY_FLAG(ix)

    ; 描画しない
    set     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 0x*1: 移動
10$:
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    cp      #0x01
    jr      nz, 20$

    ; 移動中
    dec     ENEMY_MOVE_PARAM_0(ix)
    jp      nz, 90$

    ; 位置の設定
    ld      a, ENEMY_R(ix)
    call    EnemyGetRandomPosition
    ld      ENEMY_POSITION_X(ix), e
    ld      ENEMY_POSITION_Y(ix), d

    ; コリジョンあり
    res     #ENEMY_FLAG_NOHIT_BIT, ENEMY_FLAG(ix)

    ; 点滅の設定
    ld      a, #0x0f
    ld      ENEMY_MOVE_PARAM_0(ix), a

    ; 移動の完了
    inc     ENEMY_STATE(ix)
;   jr      90$

    ; 0x*2: 出現
20$:
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    cp      #0x02
    jr      nz, 30$

    ; 点滅
    ld      a, ENEMY_MOVE_PARAM_0(ix)
    and     #0x02
    jr      z, 21$
    res     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)
    jr      22$
21$:
    set     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)
22$:

    ; 点滅中
    dec     ENEMY_MOVE_PARAM_0(ix)
    jp      nz, 90$

    ; 待機の設定
    call    _SystemGetRandom
    and     ENEMY_MOVE_PARAM_1(ix)
    add     a, ENEMY_MOVE_PARAM_2(ix)
    ld      ENEMY_MOVE_PARAM_0(ix), a

    ; 描画する
    res     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)

    ; 出現の完了
    inc     ENEMY_STATE(ix)
;   jr      90$

    ; 0x*3: 待機
30$:
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    cp      #0x03
    jr      nz, 40$

    ; プレイヤへ向く
    call    EnemyGetDirectionToPlayer
    ld      ENEMY_DIRECTION(ix), a

    ; 移動するふりをして攻撃する
    ld      a, ENEMY_POWER_POINT(ix)
    or      a
    jr      z, 31$
    ld      l, ENEMY_POSITION_X(ix)
    ld      h, ENEMY_POSITION_Y(ix)
    push    hl
    push    de
    call    EnemyMove
    pop     de
    pop     hl
    ld      ENEMY_POSITION_X(ix), l
    ld      ENEMY_POSITION_Y(ix), h
31$:

    ; 魔法を放つ
    call    EnemyCastCycle

    ; 待機中
    dec     ENEMY_MOVE_PARAM_0(ix)
    jr      nz, 90$

    ; 点滅の設定
    ld      a, #0x0f
    ld      ENEMY_MOVE_PARAM_0(ix), a

    ; 待機の完了
    inc     ENEMY_STATE(ix)
;   jr      90$

    ; 0x*4: 消滅
40$:
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    cp      #0x04
    jr      nz, 90$

    ; 点滅
    ld      a, ENEMY_MOVE_PARAM_0(ix)
    and     #0x02
    jr      nz, 41$
    res     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)
    jr      42$
41$:
    set     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)
42$:

    ; 点滅中
    dec     ENEMY_MOVE_PARAM_0(ix)
    jr      nz, 90$

    ; 出現の完了
    ld      a, ENEMY_STATE(ix)
    and     #0xf0
    ld      ENEMY_STATE(ix), a
;   jr      90$

    ; ワープの完了
90$:

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

; ミミックが行動する
;
EnemyMimic:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; アニメーションの設定
    ld      a, #ITEM_KEY
    call    _PlayerIsItem
    jr      c, 00$
    xor     a
    ld      ENEMY_ANIMATION(ix), a
00$:

    ; 初期化は継続
;   inc     ENEMY_STATE(ix)
09$:

    ; 鍵の所持
    ld      a, #ITEM_KEY
    call    _PlayerIsItem
    call    c, EnemyStay

    ; レジスタの復帰

    ; 終了
    ret

; ゴーストが行動する
;
EnemyGhost:

    ; レジスタの保存

    ; 初期化
;   ld      a, ENEMY_STATE(ix)
;   and     #0x0f
;   jr      nz, 09$

    ; 初期化は継続
;   inc     ENEMY_STATE(ix)
09$:

    ; 蝋燭の所持
    ld      a, #ITEM_CANDLE
    call    _PlayerIsItem
    jr      c, 11$
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x7f
    cp      #0x10
    jr      nc, 10$
    and     #0x02
    jr      nz, 11$
10$:
    set     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)
    jr      12$
11$:
    res     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)
;   jr      12$
12$:

    ; ENEMY_STATE_FREE で行動
    call    EnemyFree
    bit     #ENEMY_FLAG_HITPLAYER_BIT, ENEMY_FLAG(ix)
    jr      z, 20$
    res     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)
20$:

    ; レジスタの復帰

    ; 終了
    ret

; リッチが行動する
;
EnemyLich:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; コリジョンの設定
    ld      a, #ITEM_MIRROR
    call    _PlayerIsItem
    jr      c, 00$
    set     #ENEMY_FLAG_NOHIT_BIT, ENEMY_FLAG(ix)
    jr      01$
00$:
    res     #ENEMY_FLAG_NOHIT_BIT, ENEMY_FLAG(ix)
01$:

    ; 初期化は継続
;   inc     ENEMY_STATE(ix)
09$:

    ; 鏡の所持
    ld      a, #ITEM_MIRROR
    call    _PlayerIsItem
    jr      c, 10$
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x02
    jr      nz, 10$
    set     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)
    jr      11$
10$:
    res     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)
;   jr      11$
11$:

    ; ENEMY_STATE_FREE で行動
    call    EnemyFree
    bit     #ENEMY_FLAG_HITPLAYER_BIT, ENEMY_FLAG(ix)
    jr      z, 20$
    res     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)
20$:

    ; レジスタの復帰

    ; 終了
    ret

; ファントムが行動する
;
EnemyPhantom:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; コリジョンの設定
    ld      a, #ITEM_MIRROR
    call    _PlayerIsItem
    jr      c, 00$
    set     #ENEMY_FLAG_NOHIT_BIT, ENEMY_FLAG(ix)
    jr      01$
00$:
    res     #ENEMY_FLAG_NOHIT_BIT, ENEMY_FLAG(ix)
01$:

    ; 初期化は継続
;   inc     ENEMY_STATE(ix)
09$:

    ; 蝋燭と鏡の所持
    ld      a, #ITEM_MIRROR
    call    _PlayerIsItem
    jr      c, 10$
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x02
    jr      z, 11$
10$:
    ld      a, #ITEM_CANDLE
    call    _PlayerIsItem
    jr      c, 12$
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x7f
    cp      #0x10
    jr      c, 12$
11$:
    set     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)
    jr      13$
12$:
    res     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)
;   jr      13$
13$:

    ; ENEMY_STATE_APPROACH で行動
    call    EnemyApproach
    bit     #ENEMY_FLAG_HITPLAYER_BIT, ENEMY_FLAG(ix)
    jr      z, 20$
    res     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)
20$:

    ; レジスタの復帰

    ; 終了
    ret

; クリスタルが行動する
;
EnemyCrystal:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; アニメーションの設定
    ld      a, #ITEM_CRYSTAL
    call    _PlayerIsItem
    jr      c, 00$
    xor     a
    ld      ENEMY_ANIMATION(ix), a
    ld      a, #ENEMY_COLOR_HEAL
    ld      ENEMY_COLOR_DAMAGE(ix), a
00$:

    ; 初期化は継続
;   inc     ENEMY_STATE(ix)
09$:

    ; クリスタルの所持
    ld      a, #ITEM_CRYSTAL
    call    _PlayerIsItem
    jr      c, 10$
    ld      a, (_enemyDefaultCrystal + ENEMY_LIFE)
    cp      ENEMY_LIFE(ix)
    jr      z, 11$
    ld      ENEMY_LIFE(ix), a
    ld      a, #PLAYER_LIFE_MAX
    call    _PlayerHeal
    jr      11$
10$:
    call    EnemyStay
;   jr      11$
11$:

    ; レジスタの復帰

    ; 終了
    ret

; 門が行動する
;
EnemyGate:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; アニメーションの設定
    xor     a
    ld      ENEMY_ANIMATION(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 門が開く
    ld      hl, #(_game + GAME_REQUEST)
    bit     #GAME_REQUEST_GATE_OPEN_BIT, (hl)
    jr      z, 19$
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    ld      b, #0x00 ; ENEMY_R(ix)
    ld      c, ENEMY_POWER_POINT(ix)
    call    _PlayerIsHit
    jr      nc, 10$
    set     #GAME_REQUEST_GATE_ENTER_BIT, (hl)
10$:

    ; アニメーションの設定
    ld      a, (_enemyDefaultGate + ENEMY_SPRITE)
    ld      c, a
    ld      a, ENEMY_ANIMATION(ix)
    rrca
    and     #0x06
    add     a, c
    ld      ENEMY_SPRITE(ix), a
    inc     ENEMY_ANIMATION(ix)
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 魔法が飛ぶ
;
EnemyMagic:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; SE の再生
;   ld      a, #GAME_SOUND_SE_CAST
;   call    _GamePlaySe

    ; 初期化は継続
;   inc     ENEMY_STATE(ix)
09$:

    ; 攻撃の設定
    ld      a, ENEMY_POWER_CYCLE(ix)
    ld      ENEMY_POWER_FRAME(ix), a

    ; 移動
    res     #ENEMY_FLAG_NOHITPLAYER_BIT, ENEMY_FLAG(ix)
    call    EnemyMove
    bit     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)
    jr      z, 10$
    ld      a, #ENEMY_STATE_KILL
    ld      ENEMY_STATE(ix), a
10$:
    set     #ENEMY_FLAG_NOHITPLAYER_BIT, ENEMY_FLAG(ix)

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが死亡する
;
EnemyDead:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; アニメーションの設定
    ld      a, #ENEMY_ANIMATION_DEAD
    ld      ENEMY_ANIMATION(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージの監視
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jr      nz, 19$

    ; 点滅
    dec     ENEMY_ANIMATION(ix)
    jr      z, 11$
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x01
    jr      z, 10$
    res     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)
    jr      19$
10$:
    set     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)
    jr      19$
11$:
    ld      a, ENEMY_ITEM_KILL(ix)
    or      a
    jr      z, 12$
    call    _PlayerIsItem
    jr      nc, 13$
12$:

    ; エネミーの削除
    call    _MazeKillEnemy

    ; クリスタルの監視
    ld      a, ENEMY_TYPE(ix)
    cp      #ENEMY_TYPE_CRYSTAL
    jr      nz, 13$
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_GATE_OPEN_BIT, (hl)
13$:

    ; BGM の再生
    bit     #ENEMY_FLAG_2x2_BIT, ENEMY_FLAG(ix)
    jr      z, 14$
    ld      a, #GAME_SOUND_BGM_ZAKO
    call    _GamePlayBgm
14$:

    ; エネミーの削除
    xor     a
    ld      ENEMY_TYPE(ix), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを消す
;
EnemyKill:

    ; レジスタの保存

    ; エネミーの削除
    ld      a, ENEMY_TYPE(ix)
    cp      #ENEMY_TYPE_MAGIC
    call    nz, _MazeKillEnemy
    xor     a
    ld      ENEMY_TYPE(ix), a

    ; レジスタの復帰

    ; 終了
    ret

; 向いている方向に移動する
;
EnemyMove:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; cf > 移動した

    ; 自分自身とのコリジョン判定をしない
    set     #ENEMY_FLAG_NOHITOWN_BIT, ENEMY_FLAG(ix)

    ; ヒットフラグのクリア
    res     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)
    res     #ENEMY_FLAG_HITPLAYER_BIT, ENEMY_FLAG(ix)

    ; 位置の保存
    ld      l, ENEMY_POSITION_X(ix)
    ld      h, ENEMY_POSITION_Y(ix)
    push    hl

    ; 移動の取得 > h
    ld      h, ENEMY_MOVE_SPEED(ix)

    ; 攻撃力の取得 > c
    ld      c, #0x00
    ld      a, ENEMY_POWER_FRAME(ix)
    cp      ENEMY_POWER_CYCLE(ix)
    jr      c, 010$
    ld      c, ENEMY_POWER_POINT(ix)
010$:

    ; 大きさの取得 > b
    ld      b, ENEMY_R(ix)

    ; 向きの取得
    ld      a, ENEMY_DIRECTION(ix)
    or      a
    jr      z, 100$
    dec     a
    jr      z, 110$
    dec     a
    jr      z, 120$
    jr      130$
100$:
    push    hl
    call    200$
    pop     hl
    bit     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)
    jr      nz, 190$
    dec     h
    jr      nz, 100$
    jr      190$
110$:
    push    hl
    call    210$
    pop     hl
    bit     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)
    jr      nz, 190$
    dec     h
    jr      nz, 110$
    jr      190$
120$:
    push    hl
    call    220$
    pop     hl
    bit     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)
    jr      nz, 190$
    dec     h
    jr      nz, 120$
    jr      190$
130$:
    push    hl
    call    230$
    pop     hl
    bit     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)
    jr      nz, 190$
    dec     h
    jr      nz, 130$
;   jr      190$
190$:
    jp      90$

    ; 上へ移動
200$:
    ld      d, ENEMY_POSITION_Y(ix)
    dec     d
    ld      e, ENEMY_POSITION_X(ix)
    bit     #ENEMY_FLAG_NOHITPLAYER_BIT, ENEMY_FLAG(ix)
    jr      nz, 201$
    call    _PlayerIsHit
    jr      c, 203$
201$:
    bit     #ENEMY_FLAG_NOHITENEMY_BIT, ENEMY_FLAG(ix)
    jr      nz, 202$
    call    EnemyIsCollision
    jr      c, 208$
202$:
    ld      a, d
    sub     b
    ld      d, a
    ld      a, e
    sub     b
    ld      e, a
    call    _MazeIsRoom
    jr      c, 208$
    ld      a, e
    add     a, b
    add     a, b
    dec     a
    ld      e, a
    call    _MazeIsRoom
    jr      c, 208$
    dec     ENEMY_POSITION_Y(ix)
    jr      209$
203$:
    call    240$
208$:
    set     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)
209$:
    ret

    ; 下へ移動
210$:
    ld      d, ENEMY_POSITION_Y(ix)
    inc     d
    ld      e, ENEMY_POSITION_X(ix)
    bit     #ENEMY_FLAG_NOHITPLAYER_BIT, ENEMY_FLAG(ix)
    jr      nz, 211$
    call    _PlayerIsHit
    jr      c, 213$
211$:
    bit     #ENEMY_FLAG_NOHITENEMY_BIT, ENEMY_FLAG(ix)
    jr      nz, 212$
    call    EnemyIsCollision
    jr      c, 218$
212$:
    ld      a, d
    add     a, b
    dec     a
    ld      d, a
    ld      a, e
    sub     b
    ld      e, a
    call    _MazeIsRoom
    jr      c, 218$
    ld      a, e
    add     a, b
    add     a, b
    dec     a
    ld      e, a
    call    _MazeIsRoom
    jr      c, 218$
    inc     ENEMY_POSITION_Y(ix)
    jr      219$
213$:
    call    240$
218$:
    set     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)
219$:
    ret

    ; 左へ移動
220$:
    ld      e, ENEMY_POSITION_X(ix)
    dec     e
    ld      d, ENEMY_POSITION_Y(ix)
    bit     #ENEMY_FLAG_NOHITPLAYER_BIT, ENEMY_FLAG(ix)
    jr      nz, 221$
    call    _PlayerIsHit
    jr      c, 223$
221$:
    bit     #ENEMY_FLAG_NOHITENEMY_BIT, ENEMY_FLAG(ix)
    jr      nz, 222$
    call    EnemyIsCollision
    jr      c, 228$
222$:
    ld      a, e
    sub     b
    ld      e, a
    ld      a, d
    sub     b
    ld      d, a
    call    _MazeIsRoom
    jr      c, 228$
    ld      a, d
    add     a, b
    add     a, b
    dec     a
    ld      d, a
    call    _MazeIsRoom
    jr      c, 228$
    dec     ENEMY_POSITION_X(ix)
    jr      229$
223$:
    call    240$
228$:
    set     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)
229$:
    ret

    ; 右へ移動
230$:
    ld      e, ENEMY_POSITION_X(ix)
    inc     e
    ld      d, ENEMY_POSITION_Y(ix)
    bit     #ENEMY_FLAG_NOHITPLAYER_BIT, ENEMY_FLAG(ix)
    jr      nz, 231$
    call    _PlayerIsHit
    jr      c, 233$
231$:
    bit     #ENEMY_FLAG_NOHITENEMY_BIT, ENEMY_FLAG(ix)
    jr      nz, 232$
    call    EnemyIsCollision
    jr      c, 238$
232$:
    ld      a, e
    add     a, b
    dec     a
    ld      e, a
    ld      a, d
    sub     b
    ld      d, a
    call    _MazeIsRoom
    jr      c, 238$
    ld      a, d
    add     a, b
    add     a, b
    dec     a
    ld      d, a
    call    _MazeIsRoom
    jr      c, 238$
    inc     ENEMY_POSITION_X(ix)
    jr      239$
233$:
    call    240$
238$:
    set     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)
239$:
    ret

    ; 攻撃の更新
240$:
    ld      a, c
    or      a
    jr      z, 241$
    ld      a, ENEMY_CONDITION(ix)
    call    _PlayerBadCondition
    xor     a
    ld      ENEMY_POWER_FRAME(ix), a
    ld      c, #0x00
    jr      249$
241$:
    inc     ENEMY_POWER_FRAME(ix)
249$:
    set     #ENEMY_FLAG_HITPLAYER_BIT, ENEMY_FLAG(ix)
    ret

    ; 移動の完了
90$:

    ; 位置の取得
    pop     hl

    ; コリジョン判定の解除
    res     #ENEMY_FLAG_NOHITOWN_BIT, ENEMY_FLAG(ix)

    ; 移動の判定
    inc     ENEMY_MOVE_FRAME(ix)
    ld      a, ENEMY_MOVE_FRAME(ix)
    and     ENEMY_MOVE_CYCLE(ix)
    jp      z, 91$
    ld      ENEMY_POSITION_X(ix), l
    ld      ENEMY_POSITION_Y(ix), h
    or      a
    jr      92$
91$:
    scf
;   jr      92$
92$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; エネミーとのコリジョンを判定する
;
EnemyIsCollision:

    ; レジスタの保存
    push    hl
    push    bc
    push    ix

    ; de < 位置
    ;  b < 大きさ
    ; cf > コリジョンにヒットした

    ; コリジョン判定
    ld      ix, #_enemy
    ld      h, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 11$
    ld      a, ENEMY_LIFE(ix)
    or      a
    jr      z, 11$
    ld      a, ENEMY_FLAG(ix)
    and     #(ENEMY_FLAG_NOHIT | ENEMY_FLAG_NOHITENEMY | ENEMY_FLAG_NOHITOWN)
    jr      nz, 11$
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, ENEMY_R(ix)
    ld      l, a
    ld      a, d
    sub     b
    cp      l
    jr      nc, 11$
    ld      a, d
    add     a, b
    ld      l, a
    ld      a, ENEMY_POSITION_Y(ix)
    sub     ENEMY_R(ix)
    cp      l
    jr      nc, 11$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, ENEMY_R(ix)
    ld      l, a
    ld      a, e
    sub     b
    cp      l
    jr      nc, 11$
    ld      a, e
    add     a, b
    ld      l, a
    ld      a, ENEMY_POSITION_X(ix)
    sub     ENEMY_R(ix)
    cp      l
    jr      nc, 11$
    scf
    jr      19$
11$:
    push    bc
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    dec     h
    jr      nz, 10$
    or      a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     bc
    pop     hl

    ; 終了
    ret

; エネミーとのヒットコリジョンを判定する
;
_EnemyIsHit::

    ; レジスタの保存
    push    hl
    push    bc
    push    ix

    ; de < 位置
    ;  b < 大きさ
    ;  c < ダメージ量（7bits）
    ; cf > コリジョンにヒットした

    ; コリジョン判定
    ld      ix, #_enemy
    ld      l, #0x00
    ld      h, #ENEMY_ENTRY
10$:
    push    hl
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 11$
    ld      a, ENEMY_LIFE(ix)
    or      a
    jr      z, 11$
    ld      a, ENEMY_FLAG(ix)
    and     #(ENEMY_FLAG_NOHIT | ENEMY_FLAG_NOHITPLAYER | ENEMY_FLAG_NOHITOWN)
    jr      nz, 11$
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, ENEMY_R(ix)
    ld      l, a
    ld      a, d
    sub     b
    cp      l
    jr      nc, 11$
    ld      a, d
    add     a, b
    ld      l, a
    ld      a, ENEMY_POSITION_Y(ix)
    sub     ENEMY_R(ix)
    cp      l
    jr      nc, 11$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, ENEMY_R(ix)
    ld      l, a
    ld      a, e
    sub     b
    cp      l
    jr      nc, 11$
    ld      a, e
    add     a, b
    ld      l, a
    ld      a, ENEMY_POSITION_X(ix)
    sub     ENEMY_R(ix)
    cp      l
    jr      nc, 11$
    ld      a, c
    and     #~PLAYER_POWER_POINT_SKIP
    add     a, ENEMY_DAMAGE_POINT(ix)
    ld      ENEMY_DAMAGE_POINT(ix), a
    pop     hl
    inc     l
    jr      12$
11$:
    pop     hl
;   jr      12$
12$:
    push    bc
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    dec     h
    jr      nz, 10$
    ld      a, l
    or      a
    jr      z, 19$
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     bc
    pop     hl

    ; 終了
    ret

; 魔法を放つ
;
EnemyCast:

    ; レジスタの保存
    push    hl
    push    de
    push    iy

    ; de < 位置
    ;  b < 向き
    ;  c < ダメージ量
    ;  h < 状態異常

    ; エントリの取得
    push    bc
    push    de
    ld      iy, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_TYPE(iy)
    or      a
    jr      z, 11$
    add     iy, de
    djnz    10$
11$:
    ld      a, b
    pop     de
    pop     bc
    or      a
    jr      z, 90$

    ; 魔法の初期化
    push    hl
    push    bc
    push    de
    ld      hl, #_enemyDefaultMagic
    push    iy
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     bc
    pop     hl

    ; 魔法の設定
    ld      ENEMY_POSITION_X(iy), e
    ld      ENEMY_POSITION_Y(iy), d
    ld      ENEMY_DIRECTION(iy), b
    ld      a, c
    or      #ENEMY_POWER_POINT_MAGIC
    ld      ENEMY_POWER_POINT(iy), a
    ld      ENEMY_CONDITION(iy), h
    ld      a, b
    add     a, a
    add     a, ENEMY_SPRITE(iy)
    ld      ENEMY_SPRITE(iy), a
    ld      e, h
    ld      d, #0x00
    ld      hl, #enemyColorMagic
    add     hl, de
    ld      a, (hl)
    ld      ENEMY_COLOR_NORMAL(iy), a

    ; エントリの完了
90$:

    ; レジスタの復帰
    pop     iy
    pop     de
    pop     hl

    ; 終了
    ret

; 向いている方向に魔法を放つ
;
EnemyCastToDirection:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; ix < エネミー

    ; 向きの取得
    ld      b, ENEMY_DIRECTION(ix)

    ; 位置の取得
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)

    ; ダメージ量の取得
    ld      c, ENEMY_MAGIC_POINT(ix)

    ; 状態異常の取得
    ld      h, ENEMY_CONDITION(ix)

    ; 魔法を放つ
    bit     #ENEMY_FLAG_2x2_BIT, ENEMY_FLAG(ix)
    jr      nz, 10$
    call    EnemyCast
    jr      19$
10$:
    ld      l, ENEMY_R(ix)
    srl     l
    ld      a, b
    cp      #ENEMY_DIRECTION_LEFT
    jr      nc, 11$
    cp      #ENEMY_DIRECTION_RIGHT
    jr      nc, 11$
    ld      a, e
    sub     l
    ld      e, a
    call    EnemyCast
    ld      a, e
    add     a, l
    add     a, l
    ld      e, a
    call    EnemyCast
    jr      19$
11$:
    ld      a, d
    sub     l
    ld      d, a
    call    EnemyCast
    ld      a, d
    add     a, l
    add     a, l
    ld      d, a
    call    EnemyCast
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 全方位に魔法を放つ
;
EnemyCastToAll:

    ; レジスタの保存
    push    bc

    ; ix < エネミー

    ; 向きの保存
    ld      a, ENEMY_DIRECTION(ix)
    push    af

    ; 魔法を放つ
    xor     a
    ld      ENEMY_DIRECTION(ix), a
    ld      b, #0x04
10$:
    call    EnemyCastToDirection
    inc     ENEMY_DIRECTION(ix)
    djnz    10$

    ; 向きの復帰
    pop     af
    ld      ENEMY_DIRECTION(ix), a

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; エネミーのサイクルにあわせて魔法を放つ
;
EnemyCastCycle:

    ; レジスタの保存

    ; ix < エネミー

    ; サイクルが来たら魔法を放つ
    ld      a, ENEMY_MAGIC_POINT(ix)
    or      a
    jr      z, 19$
    inc     ENEMY_MAGIC_FRAME(ix)
    ld      a, ENEMY_MAGIC_FRAME(ix)
    cp      ENEMY_MAGIC_CYCLE(ix)
    jr      c, 19$
    bit     #ENEMY_FLAG_2x2_BIT, ENEMY_FLAG(ix)
    jr      nz, 10$
    call    EnemyCastToDirection
    jr      11$
10$:
    call    EnemyCastToAll
;   jr      11$
11$:
    call    _SystemGetRandom
    and     #0x0f
    ld      ENEMY_MAGIC_FRAME(ix), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤのいる方向を取得する
;
EnemyGetDirectionToPlayer:

    ; レジスタの保存
    push    bc
    push    de

    ; ix < エネミー
    ;  a > 向き（ENEMY_DIRECTION_?）

    ; 位置の取得
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)

    ; 向きの取得
    ld      a, (_player + PLAYER_LIFE)
    or      a
    jr      z, 15$
    ld      a, (_player + PLAYER_POSITION_X)
    sub     ENEMY_POSITION_X(ix)
    jr      nc, 10$
    neg
10$:
    ld      b, a
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     ENEMY_POSITION_Y(ix)
    jr      nc, 11$
    neg
11$:
    cp      b
    jr      c, 13$
    ld      a, (_player + PLAYER_POSITION_Y)
    cp      d
    jr      nc, 12$
    ld      a, d
    sub     ENEMY_R(ix)
    sub     #ENEMY_R_MAGIC
    ld      d, a
    ld      a, #ENEMY_DIRECTION_UP
    jr      19$
12$:
    ld      a, d
    add     a, ENEMY_R(ix)
    add     a, #ENEMY_R_MAGIC
    ld      d, a
    ld      a, #ENEMY_DIRECTION_DOWN
    jr      19$
13$:
    ld      a, (_player + PLAYER_POSITION_X)
    cp      e
    jr      nc, 14$
    ld      a, e
    sub     ENEMY_R(ix)
    sub     #ENEMY_R_MAGIC
    ld      e, a
    ld      a, #ENEMY_DIRECTION_LEFT
    jr      19$
14$:
    ld      a, e
    add     a, ENEMY_R(ix)
    add     a, #ENEMY_R_MAGIC
    ld      e, a
    ld      a, #ENEMY_DIRECTION_RIGHT
    jr      19$
15$:
    call    _SystemGetRandom
    and     #0x03
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; ランダムな位置を取得する
;
EnemyGetRandomPosition:

    ; レジスタの保存
    push    bc

    ;  a < 大きさ
    ; de > 位置

    ; 大きさの取得
    ld      b, a

    ; 位置の取得
    call    _SystemGetRandom
    and     #0xee
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, #(MAZE_ROOM_LEFT + 0x10)
    ld      e, a
    ld      a, d
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #(MAZE_ROOM_UP + 0x10)
    ld      d, a

    ; ダメージの取得
    ld      c, #0x00

    ; 重ならないように調整
10$:
    call    _PlayerIsHit
    jr      c, 11$
    call    EnemyIsCollision
    jr      nc, 19$
11$:
    ld      a, e
    add     a, #0x10
    ld      e, a
    cp      #MAZE_ROOM_RIGHT
    jr      c, 10$
    ld      e, #(MAZE_ROOM_LEFT + 0x10)
    ld      a, d
    add     a, #0x10
    ld      d, a
    cp      #MAZE_ROOM_DOWN
    jr      c, 10$
    ld      d, #(MAZE_ROOM_UP + 0x10)
    jr      10$
19$:

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; エネミーがダメージを受けているかどうかを判定する
;
_EnemyIsDamage::

    ; レジスタの保存
    push    bc
    push    de
    push    ix

    ; cf > ダメージを受けている

    ; ダメージの判定
    ld      ix, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 11$
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jr      nz, 18$
11$:
    add     ix, de
    djnz    10$
    or      a
    jr      19$
18$:
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
enemyProc:
    
    .dw     EnemyNull
    .dw     EnemyStay
    .dw     EnemyFree
    .dw     EnemyApproach
    .dw     EnemyWarp
    .dw     EnemyMimic
    .dw     EnemyGhost
    .dw     EnemyLich
    .dw     EnemyPhantom
    .dw     EnemyCrystal
    .dw     EnemyGate
    .dw     EnemyMagic
    .dw     EnemyDead
    .dw     EnemyKill

; エネミーの初期値
;
enemyDefault:

    .dw     _enemyDefaultNull
    .dw     _enemyDefaultBat
    .dw     _enemyDefaultGoblin
    .dw     _enemyDefaultRogue
    .dw     _enemyDefaultGargoyle
    .dw     _enemyDefaultReaper
    .dw     _enemyDefaultLizard
    .dw     _enemyDefaultMage
    .dw     _enemyDefaultSnake
    .dw     _enemyDefaultGhoul
    .dw     _enemyDefaultDaemon
    .dw     _enemyDefaultSquid
    .dw     _enemyDefaultGazer
    .dw     _enemyDefaultSpider
    .dw     _enemyDefaultRat
    .dw     _enemyDefaultMimic
    .dw     _enemyDefaultSlime
    .dw     _enemyDefaultGolem
    .dw     _enemyDefaultGhost
    .dw     _enemyDefaultLich
    .dw     _enemyDefaultPhantom
    .dw     _enemyDefaultCyclops
    .dw     _enemyDefaultZorn
    .dw     _enemyDefaultShadow
    .dw     _enemyDefaultDragon
    .dw     _enemyDefaultCrystal
    .dw     _enemyDefaultGate
    .dw     _enemyDefaultMagic

; エネミーの位置
;
enemyPosition1:
    
    .db     MAZE_ROOM_SIZE_X / 2 + 0x00, MAZE_ROOM_SIZE_Y / 2 + 0x00

enemyPosition5:

    .db     MAZE_ROOM_SIZE_X / 2 - 0x10, MAZE_ROOM_SIZE_Y / 2 - 0x10
    .db     MAZE_ROOM_SIZE_X / 2 + 0x10, MAZE_ROOM_SIZE_Y / 2 + 0x10
    .db     MAZE_ROOM_SIZE_X / 2 + 0x10, MAZE_ROOM_SIZE_Y / 2 - 0x10
    .db     MAZE_ROOM_SIZE_X / 2 - 0x10, MAZE_ROOM_SIZE_Y / 2 + 0x10
    .db     MAZE_ROOM_SIZE_X / 2 + 0x00, MAZE_ROOM_SIZE_Y / 2 + 0x00

enemyPosition9:

    .db     MAZE_ROOM_SIZE_X / 2 - 0x10, MAZE_ROOM_SIZE_Y / 2 - 0x10
    .db     MAZE_ROOM_SIZE_X / 2 + 0x10, MAZE_ROOM_SIZE_Y / 2 + 0x10
    .db     MAZE_ROOM_SIZE_X / 2 + 0x10, MAZE_ROOM_SIZE_Y / 2 - 0x10
    .db     MAZE_ROOM_SIZE_X / 2 - 0x10, MAZE_ROOM_SIZE_Y / 2 + 0x10
    .db     MAZE_ROOM_SIZE_X / 2 + 0x00, MAZE_ROOM_SIZE_Y / 2 - 0x10
    .db     MAZE_ROOM_SIZE_X / 2 + 0x00, MAZE_ROOM_SIZE_Y / 2 + 0x10
    .db     MAZE_ROOM_SIZE_X / 2 - 0x10, MAZE_ROOM_SIZE_Y / 2 + 0x00
    .db     MAZE_ROOM_SIZE_X / 2 + 0x10, MAZE_ROOM_SIZE_Y / 2 + 0x00
    .db     MAZE_ROOM_SIZE_X / 2 + 0x00, MAZE_ROOM_SIZE_Y / 2 + 0x00

; 色
;
enemyColorMagic:

    .db     VDP_COLOR_MEDIUM_RED
    .db     VDP_COLOR_MAGENTA
    .db     VDP_COLOR_MEDIUM_GREEN
    .db     VDP_COLOR_MEDIUM_GREEN
    .db     VDP_COLOR_MEDIUM_GREEN
    .db     VDP_COLOR_LIGHT_BLUE
    .db     VDP_COLOR_MEDIUM_RED
    .db     VDP_COLOR_MEDIUM_RED
    

; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; エネミー
;
_enemy::
    
    .ds     ENEMY_LENGTH * ENEMY_ENTRY

; スプライト
;
enemySprite:

    .ds     0x01