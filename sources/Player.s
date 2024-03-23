; Player.s : プレイヤ
;


; モジュール宣言
;
    .module Player

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include	"Maze.inc"
    .include    "Player.inc"
    .include	"Enemy.inc"
    .include	"Item.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存

    ; 初期値の設定
    ld      hl, #playerDefault
    ld      de, #_player
    ld      bc, #PLAYER_LENGTH
    ldir
    
    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存
    
    ; 状態異常の更新
    
    ; デバッグ
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 9999$
    ; ld      a, #PLAYER_CONDITION_CONFUSE
    ; call    _PlayerBadCondition
9999$:

    ; ダメージの更新
    ld      hl, #(_player + PLAYER_LIFE)
    ld      a, (hl)
    or      a
    jp      z, 190$

    ; 防御力の取得
    ld      c, #0x00
    ld      de, (_player + PLAYER_CONDITION_UNGUARD_L)
    ld      a, d
    or      e
    jr      nz, 100$
    ld      a, (_player + PLAYER_ITEM_SHIELD)
    add     a, #PLAYER_GUARD_POINT_NORMAL
    ld      c, a
100$:

    ; 物理ダメージの更新
    ld      a, (_player + PLAYER_DAMAGE_POWER)
    or      a
    jr      z, 119$
    sub     c
    jr      c, 110$
    jr      nz, 111$
110$:
    ld      a, #0x01
111$:
    ld      b, a
    ld      a, (hl)
    sub     b
    jr      nc, 112$
    xor     a
112$:
    ld      (hl), a
    xor     a
    ld      (_player + PLAYER_DAMAGE_POWER), a
    ld      a, #PLAYER_DAMAGE_FRAME_POWER
    ld      (_player + PLAYER_DAMAGE_FRAME), a
    ld      a, #GAME_SOUND_SE_DAMAGE_NORMAL
    call    _GamePlaySe
    call    _SystemGetRandom
    and     #0x10
    jr      nz, 119$
    ld      de, (_player + PLAYER_CONDITION_SLEEP_L)
    ld      a, d
    or      e
    jr      z, 119$
    ld      de, #0x0001
    ld      (_player + PLAYER_CONDITION_SLEEP_L), de
119$:

    ; 魔法ダメージの更新
    ld      a, (_player + PLAYER_DAMAGE_MAGIC)
    or      a
    jr      z, 129$
    ld      d, a
    ld      a, (_player + PLAYER_ITEM_AMULET)
    or      a
    ld      a, d
    jr      z, 121$
    sub     c
    jr      c, 120$
    jr      nz, 121$
120$:
    ld      a, #0x01
121$:
    ld      b, a
    ld      a, (hl)
    sub     b
    jr      nc, 122$
    xor     a
122$:
    ld      (hl), a
    xor     a
    ld      (_player + PLAYER_DAMAGE_MAGIC), a
    ld      a, #PLAYER_DAMAGE_FRAME_MAGIC
    ld      (_player + PLAYER_DAMAGE_FRAME), a
    ld      a, #GAME_SOUND_SE_DAMAGE_NORMAL
    call    _GamePlaySe
    call    _SystemGetRandom
    and     #0x10
    jr      nz, 129$
    ld      de, (_player + PLAYER_CONDITION_SLEEP_L)
    ld      a, d
    or      e
    jr      z, 119$
    ld      de, #0x0001
    ld      (_player + PLAYER_CONDITION_SLEEP_L), de
129$:

    ; 死亡判定
130$:
    ld      a, (hl)
    or      a
    jr      nz, 131$
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_NOCOLLISION_BIT, (hl)
    ld      a, #PLAYER_STATE_DEAD
    ld      (_player + PLAYER_STATE), a
131$:

    ; ダメージ更新の完了
190$:
    ld      hl, #(_player + PLAYER_DAMAGE_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 191$
    dec     (hl)
191$:

    ; 待機の監視
    ld      a, (_game + GAME_FLAG)
    bit     #GAME_FLAG_WAIT_BIT, a
    jp      nz, 40$

    ; 状態異常の更新
    ld      a, (_player + PLAYER_LIFE)
    or      a
    jr      z, 290$
    ld      a, #PLAYER_COLOR_OBJECT
    ld      (_player + PLAYER_COLOR), a
    ld      hl, #(_player + PLAYER_CONDITION_POISON_L)
    ld      de, #playerConditionColor
    ld      b, #(PLAYER_CONDITION_LENGTH - 0x01)
200$:
    ld      a, (hl)
    ld      c, a
    inc     hl
    or      (hl)
    jr      z, 202$
    ld      a, (de)
    push    de
    ld      e, c
    ld      d, (hl)
    dec     de
    dec     hl
    ld      (hl), e
    inc     hl
    ld      (hl), d
    ld      c, a
    ld      a, d
    or      e
    jr      z, 201$
    ld      a, (_player + PLAYER_COLOR)
    cp      #PLAYER_COLOR_OBJECT
    jr      nz, 201$
    ld      a, c
    ld      (_player + PLAYER_COLOR), a
201$:
    pop     de
202$:
    inc     hl
    inc     de
    djnz    200$

    ; 毒の更新
210$:
    ld      a, (_player + PLAYER_CONDITION_POISON_L)
    and     #PLAYER_CONDITION_POISON_CYCLE
    dec     a
    jr      nz, 219$
    ld      a, (_player + PLAYER_LIFE)
    sub     #PLAYER_CONDITION_POISON_DAMAGE
    jr      c, 211$
    jr      nz, 212$
211$:
    ld      hl, #0x0000
    ld      (_player + PLAYER_CONDITION_POISON_L), hl
    ld      a, #0x01
212$:
    ld      (_player + PLAYER_LIFE), a
    ld      a, #PLAYER_DAMAGE_FRAME_POISON
    ld      (_player + PLAYER_DAMAGE_FRAME), a
    ld      a, #GAME_SOUND_SE_DAMAGE_POISON
    call    _GamePlaySe
219$:

    ; 状態異常の更新の完了
290$:

    ; 状態別の処理
    ld      hl, #40$
    push    hl
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
40$:

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを描画する
;
_PlayerRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      a, (_player + PLAYER_DAMAGE_FRAME)
    or      a
    jr      nz, 10$
    ld      a, (_player + PLAYER_CONDITION_BLIND_L)
    and     #PLAYER_CONDITION_BLIND_CYCLE
    cp      #PLAYER_CONDITION_BLIND_DELAY
    jr      nc, 19$
    ld      a, (_player + PLAYER_FLAG)
    and     #PLAYER_FLAG_NORENDER
    jr      nz, 19$
    ld      a, (_player + PLAYER_DIRECTION)
    add     a, a
    ld      b, a
    ld      a, (_player + PLAYER_ANIMATION)
    rrca
    rrca
    rrca
    and     #0x01
    add     a, b
    add     a, #PLAYER_SPRITE_OBJECT
    ld      b, a
    ld      a, (_player + PLAYER_COLOR)
    ld      c, a
    jr      11$
10$:
    ld      bc, #((PLAYER_SPRITE_DAMAGE << 8) | PLAYER_COLOR_DAMAGE)
;   jr      11$
11$:
    ld      hl, #(_sprite + GAME_SPRITE_PLAYER)
    ld      a, (_player + PLAYER_POSITION_Y)
    add     a, #(MAZE_ROOM_OFFSET_Y - PLAYER_R - 0x01)
    ld      (hl), a
    inc     hl
    ld      a, (_player + PLAYER_POSITION_X)
    add     a, #(MAZE_ROOM_OFFSET_X - PLAYER_R)
    ld      (hl), a
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), c
;   inc     hl
19$:

    ; レジスタの復帰

    ; 終了
    ret
    
; 何もしない
;
PlayerNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを操作する
;
PlayerPlay:

    ; レジスタの保存

    ; 睡眠の判定
    ld      hl, (_player + PLAYER_CONDITION_SLEEP_L)
    ld      a, h
    or      l
    jp      nz, 190$

    ; 移動の取得 > h
010$:
    ld      a, (_player + PLAYER_ITEM_BOOTS)
    add     a, #PLAYER_MOVE_SPEED_NORMAL
    ld      b, a
    ld      c, #PLAYER_MOVE_CYCLE_NORMAL
    ld      hl, (_player + PLAYER_CONDITION_SLOW_L)
    ld      a, h
    or      l
    jr      z, 011$
    ld      bc, #((PLAYER_MOVE_SPEED_SLOW << 8) | PLAYER_MOVE_CYCLE_SLOW)
011$:
    ld      a, (_player + PLAYER_MOVE)
    and     c
    jp      nz, 190$
    ld      h, b

    ; 攻撃力の取得 > c
020$:
    ld      de, (_player + PLAYER_CONDITION_UNPOWER_L)
    ld      a, d
    or      e
    jr      nz, 021$
    ld      a, (_player + PLAYER_POWER)
    or      a
    jr      nz, 021$
    ld      a, (_player + PLAYER_ITEM_SWORD)
    add     a, #PLAYER_POWER_POINT_NORMAL
    ld      c, a
    jr      029$
021$:
    ld      c, #0x00
;   jr      029$
029$:

    ; 大きさの取得 > b
    ld      b, #PLAYER_R

    ; 入力の取得 > l
    ld      l, #PLAYER_INPUT_NULL
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      z, 030$
    set     #PLAYER_INPUT_UP_BIT, l
030$:
    ld      a, (_input + INPUT_KEY_DOWN)
    or      a
    jr      z, 031$
    set     #PLAYER_INPUT_DOWN_BIT, l
031$:
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 032$
    set     #PLAYER_INPUT_LEFT_BIT, l
032$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 033$
    set     #PLAYER_INPUT_RIGHT_BIT, l
033$:
    ld      de, (_player + PLAYER_CONDITION_CONFUSE_L)
    ld      a, d
    or      e
    jr      z, 039$
    ld      a, l
    rlca
    rlca
    rlca
    rlca
    or      l
    ld      l, a
    ld      a, (_player + PLAYER_CONDITION_CONFUSE_SHIFT)
034$:
    rlc     l
    dec     a
    jr      nz, 034$
039$:

    ; キー入力による移動
100$:
    bit     #PLAYER_INPUT_UP_BIT, l
    jr      z, 110$
101$:
    push    hl
    call    200$
    pop     hl
    dec     h
    jr      nz, 101$
    jr      180$
110$:
    bit     #PLAYER_INPUT_DOWN_BIT, l
    jr      z, 120$
111$:
    push    hl
    call    210$
    pop     hl
    dec     h
    jr      nz, 111$
    jr      180$
120$:
    bit     #PLAYER_INPUT_LEFT_BIT, l
    jr      z, 130$
121$:
    push    hl
    call    220$
    pop     hl
    dec     h
    jr      nz, 121$
    jr      180$
130$:
    bit     #PLAYER_INPUT_RIGHT_BIT, l
    jr      z, 190$
131$:
    push    hl
    call    230$
    pop     hl
    dec     h
    jr      nz, 131$
;   jr      180$
180$:
    ld      hl, #(_player + PLAYER_ANIMATION)
    ld      a, (_player + PLAYER_ITEM_BOOTS)
    add     a, #PLAYER_MOVE_SPEED_NORMAL
    add     a, (hl)
    ld      (hl), a
190$:
    ld      hl, #(_player + PLAYER_MOVE)
    inc     (hl)
    jp      90$

    ; 上へ移動
200$:
    ld      a, #PLAYER_DIRECTION_UP
    ld      (_player + PLAYER_DIRECTION), a
    ld      a, (_player + PLAYER_POSITION_Y)
    cp      #(MAZE_EXIT_UP_Y + 0x01)
    jr      nc, 201$
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_ROOM_UP_BIT, (hl)
    jr      209$
201$:
    call    300$
    or      a
    jr      nz, 202$
    ld      hl, #(_player + PLAYER_POSITION_Y)
    dec     (hl)
    jr      208$
202$:
    ld      c, #PLAYER_POWER_POINT_SKIP
    rrca
    jr      c, 203$
    call    330$
    or      a
    jr      nz, 209$
    ld      hl, #(_player + PLAYER_POSITION_X)
    inc     (hl)
    jr      208$
203$:
    rrca
    jr      c, 209$
    call    320$
    or      a
    jr      nz, 209$
    ld      hl, #(_player + PLAYER_POSITION_X)
    dec     (hl)
;   jr      208$
208$:
    call    40$
209$:
    ret

    ; 下へ移動
210$:
    ld      a, #PLAYER_DIRECTION_DOWN
    ld      (_player + PLAYER_DIRECTION), a
    ld      a, (_player + PLAYER_POSITION_Y)
    cp      #MAZE_EXIT_DOWN_Y
    jr      c, 211$
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_ROOM_DOWN_BIT, (hl)
    jr      219$
211$:
    call    310$
    or      a
    jr      nz, 212$
    ld      hl, #(_player + PLAYER_POSITION_Y)
    inc     (hl)
    jr      218$
212$:
    ld      c, #PLAYER_POWER_POINT_SKIP
    rrca
    jr      c, 213$
    call    330$
    or      a
    jr      nz, 219$
    ld      hl, #(_player + PLAYER_POSITION_X)
    inc     (hl)
    jr      218$
213$:
    rrca
    jr      c, 219$
    call    320$
    or      a
    jr      nz, 219$
    ld      hl, #(_player + PLAYER_POSITION_X)
    dec     (hl)
;   jr      218$
218$:
    call    40$
219$:
    ret

    ; 左へ移動
220$:
    ld      a, #PLAYER_DIRECTION_LEFT
    ld      (_player + PLAYER_DIRECTION), a
    ld      a, (_player + PLAYER_POSITION_X)
    cp      #(MAZE_EXIT_LEFT_X + 0x01)
    jr      nc, 221$
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_ROOM_LEFT_BIT, (hl)
    jr      229$
221$:
    call    320$
    or      a
    jr      nz, 222$
    ld      hl, #(_player + PLAYER_POSITION_X)
    dec     (hl)
    jr      228$
222$:
    ld      c, #PLAYER_POWER_POINT_SKIP
    rrca
    jr      c, 223$
    call    310$
    or      a
    jr      nz, 229$
    ld      hl, #(_player + PLAYER_POSITION_Y)
    inc     (hl)
    jr      228$
223$:
    rrca
    jr      c, 229$
    call    300$
    or      a
    jr      nz, 229$
    ld      hl, #(_player + PLAYER_POSITION_Y)
    dec     (hl)
;   jr      228$
228$:
    call    40$
229$:
    ret

    ; 右へ移動
230$:
    ld      a, #PLAYER_DIRECTION_RIGHT
    ld      (_player + PLAYER_DIRECTION), a
    ld      a, (_player + PLAYER_POSITION_X)
    cp      #MAZE_EXIT_RIGHT_X
    jr      c, 231$
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_ROOM_RIGHT_BIT, (hl)
    jr      239$
231$:
    call    330$
    or      a
    jr      nz, 232$
    ld      hl, #(_player + PLAYER_POSITION_X)
    inc     (hl)
    jr      238$
232$:
    ld      c, #PLAYER_POWER_POINT_SKIP
    rrca
    jr      c, 233$
    call    310$
    or      a
    jr      nz, 239$
    ld      hl, #(_player + PLAYER_POSITION_Y)
    inc     (hl)
    jr      238$
233$:
    rrca
    jr      c, 239$
    call    300$
    or      a
    jr      nz, 239$
    ld      hl, #(_player + PLAYER_POSITION_Y)
    dec     (hl)
;   jr      238$
238$:
    call    40$
239$:
    ret

    ; 上へ移動できるかどうかの判定
300$:
    ld      h, #0x00
    ld      a, (_player + PLAYER_POSITION_Y)
    dec     a
    ld      d, a
    ld      a, (_player + PLAYER_POSITION_X)
    ld      e, a
    call    _EnemyIsHit
    jr      c, 301$
    ld      a, d
    sub     b
    ld      d, a
    ld      a, e
    sub     b
    ld      e, a
    call    _MazeIsExit
    rl      h
    ld      a, e
    add     a, b
    add     a, b
    dec     a
    ld      e, a
    call    _MazeIsExit
    rl      h
    jr      309$
301$:
    call    340$
;   jr      309$
309$:
    ld      a, h
    ret

    ; 下へ移動できるかどうかの判定
310$:
    ld      h, #0x00
    ld      a, (_player + PLAYER_POSITION_Y)
    inc     a
    ld      d, a
    ld      a, (_player + PLAYER_POSITION_X)
    ld      e, a
    call    _EnemyIsHit
    jr      c, 311$
    ld      a, d
    add     a, b
    dec     a
    ld      d, a
    ld      a, e
    sub     b
    ld      e, a
    call    _MazeIsExit
    rl      h
    ld      a, e
    add     a, b
    add     a, b
    dec     a
    ld      e, a
    call    _MazeIsExit
    rl      h
    jr      319$
311$:
    call    340$
;   jr      319$
319$:
    ld      a, h
    ret

    ; 左へ移動できるかどうかの判定
320$:
    ld      h, #0x00
    ld      a, (_player + PLAYER_POSITION_Y)
    ld      d, a
    ld      a, (_player + PLAYER_POSITION_X)
    dec     a
    ld      e, a
    call    _EnemyIsHit
    jr      c, 321$
    ld      a, e
    sub     b
    ld      e, a
    ld      a, d
    sub     b
    ld      d, a
    call    _MazeIsExit
    rl      h
    ld      a, d
    add     a, b
    add     a, b
    dec     a
    ld      d, a
    call    _MazeIsExit
    rl      h
    jr      329$
321$:
    call    340$
;   jr      329$
329$:
    ld      a, h
    ret

    ; 右へ移動できるかどうかの判定
330$:
    ld      h, #0x00
    ld      a, (_player + PLAYER_POSITION_Y)
    ld      d, a
    ld      a, (_player + PLAYER_POSITION_X)
    inc     a
    ld      e, a
    call    _EnemyIsHit
    jr      c, 331$
    ld      a, e
    add     a, b
    dec     a
    ld      e, a
    ld      a, d
    sub     b
    ld      d, a
    call    _MazeIsExit
    rl      h
    ld      a, d
    add     a, b
    add     a, b
    dec     a
    ld      d, a
    call    _MazeIsExit
    rl      h
    jr      339$
331$:
    call    340$
;   jr      339$
339$:
    ld      a, h
    ret

    ; 攻撃の更新
340$:
    push    hl
    ld      hl, #(_player + PLAYER_POWER)
    ld      a, c
    and     #~PLAYER_POWER_POINT_SKIP
    jr      z, 341$
    ld      a, (_player + PLAYER_ITEM_RING)
    sub     #PLAYER_POWER_CYCLE_NORMAL
    neg
    jr      342$
341$:
    ld      a, (hl)
    bit     #PLAYER_POWER_POINT_SKIP_BIT, c
    jr      nz, 342$
    or      a
    jr      z, 342$
    dec     a
342$:
    ld      (hl), a
    ld      hl, #(_player + PLAYER_ANIMATION)
    ld      a, #PLAYER_MOVE_SPEED_NORMAL
    add     a, (hl)
    ld      (hl), a
    pop     hl
    ld      c, #PLAYER_POWER_POINT_SKIP
    ld      h, #0x03
    ret

    ; アイテム取得の判定
40$:
    push    hl
    push    bc
    ld      de, (_player + PLAYER_POSITION_X)
    call    _ItemIsHit
    or      a
    jr      z, 49$
    cp      #ITEM_POTION
    jr      z, 42$
    cp      #ITEM_COMPASS
    jr      nz, 41$
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_PRINT_COMPASS_BIT, (hl)
41$:
    dec     a
    ld      e, a
    ld      d, #0x00
    ld      hl, #(_player + PLAYER_ITEM_SWORD)
    add     hl, de
    ld      a, (hl)
    add     a, c
    ld      (hl), a
    jr      48$
42$:
    ld      a, c
    call    _PlayerHeal
;   jr      48$
48$:
    call    _MazeKillItem
    ld      a, #GAME_SOUND_SE_ITEM
    call    _GamePlaySe
49$:
    pop     bc
    pop     hl
    ret

    ; 操作の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがゲートに入る
;
PlayerGate:

    ; レジスタの保存

    ; 位置合わせ
    ld      hl, #(_player + PLAYER_POSITION_Y)
    ld      a, (hl)
    cp      #MAZE_GATE_Y
    jr      z, 11$
    jr      nc, 10$
    inc     (hl)
    ld      a, #PLAYER_DIRECTION_DOWN
    jr      19$
10$:
    dec     (hl)
    ld      a, #PLAYER_DIRECTION_UP
    jr      19$
11$:
    ld      hl, #(_player + PLAYER_POSITION_X)
    ld      a, (hl)
    cp      #MAZE_GATE_X
    jr      z, 13$
    jr      nc, 12$
    inc     (hl)
    ld      a, #PLAYER_DIRECTION_RIGHT
    jr      19$
12$:
    dec     (hl)
    ld      a, #PLAYER_DIRECTION_LEFT
    jr      19$
13$:
    ld      a, #PLAYER_DIRECTION_DOWN
19$:
    ld      (_player + PLAYER_DIRECTION), a

    ; アニメーションの更新
    ld      hl, #(_player + PLAYER_ANIMATION)
    ld      a, #PLAYER_MOVE_SPEED_NORMAL
    add     a, (hl)
    ld      (hl), a

    ; レジスタの復帰

    ; 終了
    ret    

; プレイヤが死亡する
;
PlayerDead:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; アニメーションの設定
    ld      a, #PLAYER_ANIMATION_DEAD
    ld      (_player + PLAYER_ANIMATION), a

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; ダメージの監視
    ld      a, (_player + PLAYER_DAMAGE_FRAME)
    or      a
    jr      nz, 19$

    ; 点滅
    ld      hl, #(_player + PLAYER_ANIMATION)
    dec     (hl)
    jr      z, 11$
    ld      a, (hl)
    ld      hl, #(_player + PLAYER_FLAG)
    and     #0x02
    jr      z, 10$
    res     #PLAYER_FLAG_NORENDER_BIT, (hl)
    jr      19$
10$:
    set     #PLAYER_FLAG_NORENDER_BIT, (hl)
    jr      19$
11$:
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_NORENDER_BIT, (hl)
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_OVER_BIT, (hl)
    xor     a
    ld      (_player + PLAYER_STATE), a
;   jr      19$
19$:
    ; レジスタの復帰

    ; 終了
    ret    

; プレイヤとのヒットコリジョンを判定する
;
_PlayerIsHit::

    ; レジスタの保存
    push    hl

    ; de < 位置
    ; b  < 大きさ
    ; c  < ダメージ量
    ; cf > コリジョンにヒットした

    ; コリジョン判定
    ld      a, (_player + PLAYER_FLAG)
    and     #PLAYER_FLAG_NOCOLLISION
    jr      nz, 12$
    ld      a, (_player + PLAYER_LIFE)
    or      a
    jr      z, 12$
    ld      a, (_player + PLAYER_POSITION_Y)
    add     a, #PLAYER_R
    ld      l, a
    ld      a, d
    sub     b
    cp      l
    jr      nc, 12$
    ld      a, d
    add     a, b
    ld      l, a
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     #PLAYER_R
    cp      l
    jr      nc, 12$
    ld      a, (_player + PLAYER_POSITION_X)
    add     a, #PLAYER_R
    ld      l, a
    ld      a, e
    sub     b
    cp      l
    jr      nc, 12$
    ld      a, e
    add     a, b
    ld      l, a
    ld      a, (_player + PLAYER_POSITION_X)
    sub     #PLAYER_R
    cp      l
    jr      nc, 12$
    bit     #ENEMY_POWER_POINT_MAGIC_BIT, c
    jr      nz, 10$
    ld      a, (_player + PLAYER_DAMAGE_POWER)
    add     a, c
    ld      (_player + PLAYER_DAMAGE_POWER), a
    jr      11$
10$:
    res     #ENEMY_POWER_POINT_MAGIC_BIT, c
    ld      a, (_player + PLAYER_DAMAGE_MAGIC)
    add     a, c
    ld      (_player + PLAYER_DAMAGE_MAGIC), a
11$:
    scf
    jr      19$
12$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; プレイヤを回復させる
;
_PlayerHeal::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; a < 回復するライフの量

    ; 体力の回復
    ld      hl, #(_player + PLAYER_LIFE)
    add     a, (hl)
    cp      #PLAYER_LIFE_MAX
    jr      c, 10$
    ld      a, #PLAYER_LIFE_MAX
10$:
    ld      (hl), a

    ; 状態異常の回復
    ld      hl, #(_player + PLAYER_CONDITION_POISON_L + 0x0000)
    ld      de, #(_player + PLAYER_CONDITION_POISON_L + 0x0001)
    ld      bc, #((PLAYER_CONDITION_LENGTH - PLAYER_CONDITION_POISON) * 0x0002 - 0x0001)
    xor     a
    ld      (hl), a
    ldir

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; プレイヤが状態異常になる
;
_PlayerBadCondition::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; a < 状態異常（PLAYER_CONDITION_?）

    ; 状態異常の設定
    or      a
    jr      z, 19$
    ld      d, a
    dec     a
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #(_player + PLAYER_CONDITION_POISON_L)
    add     hl, bc
    ld      a, (hl)
    inc     hl
    or      (hl)
    jr      nz, 19$
    call    _SystemGetRandom
    and     #0x24
    jr      nz, 19$
    push    de
    ex      de, hl
    ld      hl, #(playerCondition + 0x0001)
    add     hl, bc
    ld      bc, #0x0002
    lddr
    pop     de
    ld      a, d
    cp      #PLAYER_CONDITION_CONFUSE
    jr      nz, 19$
    call    _SystemGetRandom
    rrca
    and     #0x03
    jr      nz, 10$
    inc     a
10$:
    ld      (_player + PLAYER_CONDITION_CONFUSE_SHIFT), a
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; プレイヤがアイテムを持っているかを判定する
;
_PlayerIsItem::

    ; レジスタの保存
    push    hl
    push    de

    ;  a < アイテム（ITEM_?）
    ; cf > アイテムを持っている

    ; アイテムの判定
    or      a
    jr      z, 10$
    dec     a
    ld      e, a
    ld      d, #0x00
    ld      hl, #(_player + PLAYER_ITEM_SWORD)
    add     hl, de
    ld      a, (hl)
    or      a
    jr      z, 10$
    scf
10$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; プレイヤがダメージを受けているかどうかを判定する
;
_PlayerIsDamage::

    ; レジスタの保存

    ; cf > ダメージを受けている

    ; ダメージの判定
    ld      a, (_player + PLAYER_DAMAGE_FRAME)
    or      a
    jr      z, 10$
    scf
10$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
playerProc:
    
    .dw     PlayerNull
    .dw     PlayerPlay
    .dw     PlayerGate
    .dw     PlayerDead

; プレイヤの初期値
;
playerDefault:

    .db     PLAYER_STATE_PLAY
    .db     PLAYER_FLAG_NULL
    .db     MAZE_GATE_X
    .db     MAZE_GATE_Y
    .db     PLAYER_DIRECTION_DOWN
    .db     PLAYER_COLOR_OBJECT
    .db     PLAYER_ANIMATION_NULL
    .db     PLAYER_MOVE_NULL
    .db     PLAYER_LIFE_MAX
    .db     PLAYER_DAMAGE_POWER_NULL
    .db     PLAYER_DAMAGE_MAGIC_NULL
    .db     PLAYER_DAMAGE_FRAME_NULL
    .db     PLAYER_POWER_NULL
    .db     PLAYER_GUARD_NULL
    .dw     PLAYER_CONDITION_NULL ; PLAYER_CONDITION_POISON
    .dw     PLAYER_CONDITION_NULL ; PLAYER_CONDITION_SLOW
    .dw     PLAYER_CONDITION_NULL ; PLAYER_CONDITION_UNPOWER
    .dw     PLAYER_CONDITION_NULL ; PLAYER_CONDITION_UNGUARD
    .dw     PLAYER_CONDITION_NULL ; PLAYER_CONDITION_SLEEP
    .dw     PLAYER_CONDITION_NULL ; PLAYER_CONDITION_BLIND
    .dw     PLAYER_CONDITION_NULL ; PLAYER_CONDITION_CONFUSE
    .db     PLAYER_CONDITION_CONFUSE_NULL
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_SWORD
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_SHIELD
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_POTION
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_BOOTS
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_COMPASS
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_KEY
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_TORCH
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_HAMMER
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_CANDLE
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_MIRROR
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_RING
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_AMULET
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_ARROW
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_DROP
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_GRASS
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_DRAGON_SLAYER
    .db     PLAYER_ITEM_NULL ; PLAYER_ITEM_CRYSTAL

; 状態異常
;
playerCondition:

    .dw     PLAYER_CONDITION_POISON_FRAME
    .dw     PLAYER_CONDITION_SLOW_FRAME
    .dw     PLAYER_CONDITION_UNPOWER_FRAME
    .dw     PLAYER_CONDITION_UNGUARD_FRAME
    .dw     PLAYER_CONDITION_SLEEP_FRAME
    .dw     PLAYER_CONDITION_BLIND_FRAME
    .dw     PLAYER_CONDITION_CONFUSE_FRAME

playerConditionColor:

    .db     VDP_COLOR_MAGENTA
    .db     VDP_COLOR_MEDIUM_GREEN
    .db     VDP_COLOR_MEDIUM_GREEN
    .db     VDP_COLOR_MEDIUM_GREEN
    .db     VDP_COLOR_LIGHT_BLUE
    .db     VDP_COLOR_WHITE
    .db     VDP_COLOR_WHITE


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤ
;
_player::
    
    .ds     PLAYER_LENGTH
