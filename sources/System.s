; System.s : システムライブラリ
;


; モジュール宣言
;
    .module System

; 参照ファイル
;
    .include    "main.inc"
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"


; CODE 領域
;
    .area   _CODE

; システムを起動する
;
_SystemBoot::

    ; レジスタの保存

    ; スロットの起動
    call    SystemBootSlot

    ; レジスタの復帰

    ; 終了
    ret

; スロットを起動する
;
SystemBootSlot:

    ; レジスタの保存

    ; スロットの初期化
    ld      hl, #(_slot + 0x0000)
    ld      de, #(_slot + 0x0001)
    ld      bc, #(SLOT_SIZE - 0x0001)
    ld      (hl), #0xff
    ldir

    ; ページ 1 のスロットの保存
    call    RSLREG
    rrca
    rrca
    and     #0b00000011
    ld      c, a
    ld      b, #0x00
    ld      hl, #EXPTBL
    add     hl, bc
    ld      a, (hl)
    and     #0b10000000
    or      c
    ld      c, a
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    ld      a, (hl)
    and     #0b00001100
    or      c
    ld      (_slot + SLOT_PAGE1), a

    ; ページ 2 のスロットの設定
    .ifne   BUILD_ROM
    ld      h, #0x80
    call    ENASLT
    .endif

    ; レジスタの復帰

    ; 終了
    ret


; SYSTEM 領域（PAGE 2 に配置する）
;
    .ifne   BUILD_ROM
    .area   _SYSTEM (ABS)
    .org    0xb000
    .else
    .area   _CODE
    .endif

; システムを初期化する
;
_SystemInitialize::
    
    ; レジスタの保存
    
    ; フラグの初期化
    xor     a
    ld      (_flag), a
    
    ; スロットの初期化
    call    SystemInitializeSlot

    ; キー入力の初期化
    call    SystemInitializeInput
    
    ; ビデオの初期化
    call    SystemInitializeVideo

    ; スプライトの初期化
    call    SystemInitializeSprite

    ; パターンネームの初期化
    call    SystemInitializePatternName

    ; サウンドの初期化
    call    SystemInitializeSound

    ; レジスタの復帰
    
    ; 終了
    ret

; スロットを初期化する
;
SystemInitializeSlot:

    ; レジスタの保存

    ; スロットの走査
    ld      e, #0x00
10$:
    ld      d, #0x00
11$:
    push    de

    ; スロットの切り替え
    ld      c, e
    ld      b, #0x00
    ld      hl, #EXPTBL
    add     hl, bc
    ld      a, (hl)
    and     #0b10000000
    or      e
    or      d
    ld      c, a
    ld      hl, #0x4000
    push    bc
    call    ENASLT
    pop     bc

    ; ページ 1 の設定
    ld      hl, (0x5ffe)
    push    hl

    ; ROM/RAM の判定
    ld      hl, #0xffff
    ld      (0x5ffe), hl
    ld      hl, #0x4010
    ld      a, (hl)
    cpl
    ld      (hl), a
    cp      (hl)
    cpl
    ld      (hl), a
    jr      z, 14$

    ; OPLL の判定
    ld      a, (_slot + SLOT_OPLL)
    cp      #0xff
    jr      nz, 12$
    ld      hl, #0x401c
    ld      a, (hl)
    cp      #'O
    jr      nz, 12$
    inc     hl
    ld      a, (hl)
    cp      #'P
    jr      nz, 12$
    inc     hl
    ld      a, (hl)
    cp      #'L
    jr      nz, 12$
    inc     hl
    ld      a, (hl)
    cp      #'L
    jr      nz, 12$
    ld      hl, #(_slot + SLOT_OPLL)
    ld      (hl), c
12$:

    ; PAC の判定
    ld      a, (_slot + SLOT_PAC)
    cp      #0xff
    jr      nz, 13$
    ld      hl, #0x694d
    ld      (0x5ffe), hl
    ld      hl, #0x4010
    ld      a, (hl)
    cpl
    ld      (hl), a
    cp      (hl)
    cpl
    ld      (hl), a
    jr      nz, 13$
    ld      hl, #(_slot + SLOT_PAC)
    ld      (hl), c
13$:

    ; ページ 1 の復帰
14$:
    pop     hl
    ld      (0x5ffe), hl

    ; 次のスロットへ
19$:
    pop     de
    ld      a, d
    add     a, #0x04
    and     #0x0c
    ld      d, a
    jr      nz, 11$
    inc     e
    ld      a, e
    and     #0x03
    jp      nz, 10$

    ; ページ 1 のスロットの復帰
90$:
    ld      hl, #0x4000
    ld      a, (_slot + SLOT_PAGE1)
    call    ENASLT

    ; レジスタの復帰

    ; 終了
    ret

; キー入力を初期化する  
;
SystemInitializeInput:
    
    ; レジスタの保存
    
    ; キー入力の初期化
    ld      hl, #(_input + 0x0000)
    ld      de, #(_input + 0x0001)
    ld      bc, #INPUT_SIZE
    ld      (hl), #0x00
    ldir

    ; キークリック音の無効化
    xor     a
    ld      (CLIKSW), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; キーの入力を更新する
;
_SystemUpdateInput::
    
    ; レジスタの保存
    
    ; キーの取得
    xor     a
    call    GTSTCK
    or      a
    jr      nz, 10$
    inc     a
    call    GTSTCK
10$:
    ld      c, a
    ld      b, #0x00
    ld      hl, #inputKeyTable
    add     hl, bc
    ld      h, (hl)

    ; ボタンの取得
    xor     a
    call    GTTRIG
    or      a
    jr      nz, 20$
    inc     a
    call    GTTRIG
    or      a
    jr      z, 21$
20$:
    set     #INPUT_BUTTON_SPACE, h
21$:
    ld      a, #0x03
    call    GTTRIG
    or      a
    jr      nz, 22$
    ld      a, #0x06
    call    SNSMAT
    and     #0x01
    jr      nz, 23$
22$:
    set     #INPUT_BUTTON_SHIFT, h
23$:
    ld      a, #0x07
    call    SNSMAT
    and     #0x04
    jr      nz, 24$
    set     #INPUT_BUTTON_ESC, h
24$:

    ; キー入力の取得
    ld      c, h
    ld      hl, #(_input + INPUT_KEY_UP)
    ld      b, #INPUT_SIZE
30$:
    ld      a, (hl)
    srl     c
    jr      c, 31$
    xor     a
    jr      32$
31$:
    inc     a
    jr      nz, 32$
    inc     a
32$:
    ld      (hl), a
    inc     hl
    djnz    30$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ビデオを初期化する
;
SystemInitializeVideo:
    
    ; レジスタの保存
    
    ; ポートの取得
    ld      a, (0x0006)
    ld      (_videoPort + 0), a
    ld      a, (0x0007)
    ld      (_videoPort + 1), a
    
    ; レジスタの取得
    ld      hl, #RG0SAV
    ld      de, #_videoRegister
    ld      bc, #0x08
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; ビデオを更新する
;
_SystemUpdateVideo::
    
    ; レジスタの保存
    
    ; ポートの取得
    ld      a, (_videoPort + 1)
    ld      d, a
    inc     a
    ld      e, a
    
    ; レジスタの取得
    ld      hl, #_videoRegister

    ; レジスタの転送
    ld      c, e
    outi
    ld      a, #0x80
    out     (c), a
    outi
    inc     a
    out     (c), a
    outi
    inc     a
    out     (c), a
    outi
    inc     a
    out     (c), a
    outi
    inc     a
    out     (c), a
    outi
    inc     a
    out     (c), a
    outi
    inc     a
    out     (c), a
    outi
    inc     a
    out     (c), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; スプライトを初期化する
;
SystemInitializeSprite:

    ; レジスタの保存

    ; スプライトのクリア
    call    _SystemClearSprite

    ; レジスタの復帰
    
    ; 終了
    ret

; スプライトを更新する
;
_SystemUpdateSprite::
    
    ; レジスタの保存
    
    ; スプライトアトリビュートテーブルの取得
    ld      a, (_videoRegister + VDP_R5)
    ld      l, #0x00
    rra
    rr      l
;   ld      h, a
    
    ; VRAM アドレスの設定
    ld      c, e
    out     (c), l
;   ld      a, h
    or      #0b01000000
    out     (c), a
    
    ; スプライトアトリビュートテーブルの転送
    ld      c, d
    ld      hl, #_sprite
    ld      b, #0x80
;   otir
10$:
    outi
    jp      nz, 10$

    ; レジスタの復帰
    
    ; 終了
    ret

; スプライトをクリアする
;
_SystemClearSprite::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    
    ; スプライトのクリア
    ld      hl, #(_sprite + 0x0000)
    ld      de, #(_sprite + 0x0001)
    ld      bc, #0x007f
    ld      (hl), #0xc0
    ldir
    
    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; パターンネームを初期化する
;
SystemInitializePatternName:

    ; レジスタの保存

    ; パターンネームのクリア
    call    _SystemClearPatternName

    ; レジスタの復帰
    
    ; 終了
    ret

; パターンネームを更新する
;
_SystemUpdatePatternName::
    
    ; レジスタの保存
    
    ; パターンネームテーブルの取得    
    ld      a, (_videoRegister + VDP_R2)
    add     a, a
    add     a, a
;   ld      h, a
    ld      l, #0x00

    ; VRAM アドレスの設定
    ld      c, e
    out     (c), l
;   ld      a, h
    or      #0b01000000
    out     (c), a

    ; パターンネームテーブルの転送
    ld      c, d
    ld      hl, #_patternName
    ld      b, #0x00
;   otir
;   nop
10$:
    outi
    jp      nz, 10$
;   otir
;   nop
11$:
    outi
    jp      nz, 11$
;   otir
;   nop
12$:
    outi
    jp      nz, 12$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; パターンネームをクリアする
;
_SystemClearPatternName::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; a < pattern name data

    ; パターンネームのクリア
    ld      hl, #(_patternName + 0x0000)
    ld      de, #(_patternName + 0x0001)
    ld      bc, #0x02ff
    ld      (hl), a
    ldir

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; サウンドを初期化する
;
SystemInitializeSound:
    
    ; レジスタの保存
    
    ; PSG の初期化
    call    GICINI
    ld      e, #0b10111111
    ld      a, #0x07
    call    WRTPSG
    
;   ; サウンドレジスタの初期化
;   ld      0x00(ix), #0b01010101
;   ld      0x01(ix), #0b00000000
;   ld      0x02(ix), #0b00000000
;   ld      0x03(ix), #0b00000000
;   ld      0x04(ix), #0b00000000
;   ld      0x05(ix), #0b00000000
;   ld      0x06(ix), #0b00000000
;   ld      0x07(ix), #0b10111111
;   ld      0x08(ix), #0b00000000
;   ld      0x09(ix), #0b00000000
;   ld      0x0a(ix), #0b00000000
;   ld      0x0b(ix), #0b00001011
;   ld      0x0c(ix), #0b00000000
;   ld      0x0d(ix), #0b00000000
;   ld      0x0e(ix), #0b00000000
;   ld      0x0f(ix), #0b00000000

    ; OPLL の初期化
    ld      a, (_slot + SLOT_OPLL)
    cp      #0xff
    jr      z, 20$
    ld      iy, (_slot + SLOT_OPLL_IY)
    ld      ix, #INIOPL
    ld      hl, #soundOpllWork
    call    CALSLT
    ld      hl, #0x4000
    ld      a, (_slot + SLOT_PAGE1)
    call    ENASLT
20$:
    
    ; サウンドの初期化
    ld      hl, #(_sound + 0x0000)
    ld      de, #(_sound + 0x0000)
    ld      bc, #(SOUND_SIZE - 0x0001)
    ld      (hl), #0x00
    ldir
    ld      a, #0b10111111
    ld      (_sound + SOUND_PSG_MIXER), a

    ; チャンネルの初期化
    ld      ix, #_soundChannel
    ld      de, #SOUND_CHANNEL_SIZE
    ld      b, #SOUND_CHANNEL_ENTRY
40$:
    xor     a
    ld      SOUND_CHANNEL_REQUEST_L(ix), a
    ld      SOUND_CHANNEL_REQUEST_H(ix), a
    ld      SOUND_CHANNEL_HEAD_L(ix), a
    ld      SOUND_CHANNEL_HEAD_H(ix), a
    ld      SOUND_CHANNEL_PLAY_L(ix), a
    ld      SOUND_CHANNEL_PLAY_H(ix), a
    ld      a, (_slot + SLOT_OPLL)
    sub     #0xff
    jr      nz, 41$
    ld      SOUND_CHANNEL_VOICE_MASK(ix), a
    res     #SOUND_FLAG_OPLL_BIT, SOUND_CHANNEL_FLAG(ix)
    jr      42$
41$:
    ld      SOUND_CHANNEL_VOICE_MASK(ix), #0x0f
    set     #SOUND_FLAG_OPLL_BIT, SOUND_CHANNEL_FLAG(ix)
;   jr      42$
42$:
    call    SystemClearSoundChannel
    add     ix, de
    djnz    40$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; サウンドを更新する
;
_SystemUpdateSound::
    
    ; レジスタの保存
    
    ; スリープ
    ld      hl, #_flag
    bit     #FLAG_SOUND_SLEEP_BIT, (hl)
    jr      z, 10$
    ld      e, #0b10111111
    ld      a, #0x07
    call    WRTPSG
    jp      90$
10$:
    
    ; チャンネルの走査
    ld      ix, #_soundChannel
    ld      bc, #0x0000
200$:
    push    bc
    
    ; リクエスト
    ld      a, SOUND_CHANNEL_REQUEST_L(ix)
    or      SOUND_CHANNEL_REQUEST_H(ix)
    jr      z, 201$
    ld      l, SOUND_CHANNEL_REQUEST_L(ix)
    ld      h, SOUND_CHANNEL_REQUEST_H(ix)
    xor     a
    ld      SOUND_CHANNEL_REQUEST_L(ix), a
    ld      SOUND_CHANNEL_REQUEST_H(ix), a
    ld      SOUND_CHANNEL_HEAD_L(ix), l
    ld      SOUND_CHANNEL_HEAD_H(ix), h
    ld      SOUND_CHANNEL_PLAY_L(ix), l
    ld      SOUND_CHANNEL_PLAY_H(ix), h
    call    SystemClearSoundChannel
201$:
    
    ; サウンドデータの存在
    ld      a, SOUND_CHANNEL_PLAY_L(ix)
    or      SOUND_CHANNEL_PLAY_H(ix)
    jp      z, 290$
    
    ; 待機
    dec     SOUND_CHANNEL_REST(ix)
    jr      z, 202$
    
    ; 音量の減衰
    ld      a, SOUND_CHANNEL_VOICE(ix)
    or      a
    jp      nz, 290$
    ld      a, SOUND_CHANNEL_VOLUME_PLAY(ix)
    or      a
    jp      z, 290$
    ld      a, SOUND_CHANNEL_VOLUME_MINUS(ix)
    or      a
    jp      z, 290$
    dec     SOUND_CHANNEL_VOLUME_FRAME(ix)
    jp      nz, 290$
    dec     SOUND_CHANNEL_VOLUME_PLAY(ix)
    ld      e, SOUND_CHANNEL_VOLUME_PLAY(ix)
    ld      a, c
    add     a, #0x08
    call    WRTPSG
    ld      a, SOUND_CHANNEL_VOLUME_MINUS(ix)
    ld      SOUND_CHANNEL_VOLUME_FRAME(ix), a
    jp      290$
202$:
    
    ; 再生ポインタの取得
    ld      l, SOUND_CHANNEL_PLAY_L(ix)
    ld      h, SOUND_CHANNEL_PLAY_H(ix)
    
    ; MML の解析
210$:
    ld      a, (hl)
    inc     hl
    
    ; 0x00 : 終端コード
    or      a
    jr      nz, 211$
;   xor     a
    ld      SOUND_CHANNEL_HEAD_L(ix), a
    ld      SOUND_CHANNEL_HEAD_H(ix), a
    ld      SOUND_CHANNEL_PLAY_L(ix), a
    ld      SOUND_CHANNEL_PLAY_H(ix), a
    ld      SOUND_CHANNEL_TONE_FREQUENCY_L(ix), a
    ld      SOUND_CHANNEL_TONE_FREQUENCY_H(ix), a
    res     #SOUND_FLAG_NOISE_BIT, SOUND_CHANNEL_FLAG(ix)
    set     #SOUND_FLAG_UPDATE_BIT, SOUND_CHANNEL_FLAG(ix)
    jr      290$
211$:
    
    ; 0xff : 繰り返し
    cp      #0xff
    jr      nz, 212$
    ld      l, SOUND_CHANNEL_HEAD_L(ix)
    ld      SOUND_CHANNEL_PLAY_L(ix), l
    ld      h, SOUND_CHANNEL_HEAD_H(ix)
    ld      SOUND_CHANNEL_PLAY_H(ix), h
    jr      210$
212$:
    
    ; '@''A'～'Z' の処理
    ld      de, #213$
    push    de
    sub     #'@
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      iy, #soundMmlProc
    add     iy, de
    ld      e, 0x00(iy)
    ld      d, 0x01(iy)
    push    de
    pop     iy
    jp      (iy)
;   pop     de
213$:
    jr      c, 210$
    
    ; 音の長さの設定
    ld      a, (hl)
    cp      #('9 + 0x01)
    jr      nc, 220$
    sub     #'0
    jr      c, 220$
    inc     hl
    jr      221$
220$:
    ld      a, SOUND_CHANNEL_LENGTH(ix)
221$:
    push    hl
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundLengthTable
    add     hl, de
    ld      a, SOUND_CHANNEL_TEMPO(ix)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
;   ld      d, #0x00
    add     hl, de
    ld      a, (hl)
    ld      SOUND_CHANNEL_REST(ix), a
    set     #SOUND_FLAG_UPDATE_BIT, SOUND_CHANNEL_FLAG(ix)
    pop     hl
    
    ; 再生ポインタの保存
    ld      SOUND_CHANNEL_PLAY_L(ix), l
    ld      SOUND_CHANNEL_PLAY_H(ix), h
    
    ; 次のチャンネルへ
290$:
    pop     bc
    ld      a, b
    or      SOUND_CHANNEL_FLAG(ix)
    ld      b, a
    ld      de, #SOUND_CHANNEL_SIZE
    add     ix, de
    inc     c
    ld      a, c
    cp      #SOUND_CHANNEL_ENTRY
    jp      c, 200$
    
    ; 更新の確認
    bit     #SOUND_FLAG_UPDATE_BIT, b
    jp      z, 90$
    
    ; エンベロープ周波数の設定
    ld      de, (_sound + SOUND_PSG_ENVELOPE_FREQUENCY)
    ld      a, #0x0b
    call    WRTPSG
    ld      e, d
    inc     a
    call    WRTPSG
    
    ; ノイズ周波数の設定
    ld      a, (_sound + SOUND_PSG_NOISE_FREQUENCY)
    ld      e, a
    ld      a, #0x06
    call    WRTPSG
    
    ; OPLL の設定
    ld      hl, #0x4000
    ld      a, (_slot + SLOT_OPLL)
    cp      #0xff
    call    nz, ENASLT
    
    ; PSG の設定
    ld      a, (_sound + SOUND_PSG_MIXER)
    ld      c, a
    ld      b, #0x00

    ; チャンネルＡの設定
    ld      hl, #(_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_FLAG)
    bit     #SOUND_FLAG_UPDATE_BIT, (hl)
    jp      z, 309$
    ld      a, #0b00001001
    or      c
    ld      c, a
    ld      a, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_VOLUME)
    ld      (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_VOLUME_PLAY), a
    ld      a, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_VOLUME_MINUS)
    ld      (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_VOLUME_FRAME), a
    bit     #SOUND_FLAG_NOISE_BIT, (hl)
    jr      z, 300$
    res     #0x03, c
    jr      302$
300$:
    ld      de, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_TONE_FREQUENCY)
    ld      a, d
    or      e
    jr      nz, 301$
    ld      (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_VOLUME_PLAY), a
    jr      303$
301$:
    ld      a, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_VOICE)
    or      a
    jr      nz, 303$
    res     #0x00, c
    ld      a, #0x00
    call    WRTPSG
    ld      e, d
    ld      a, #0x01
    call    WRTPSG
    xor     a
    ld      (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_TONE_FREQUENCY_H), a
302$:
    ld      a, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_VOLUME_PLAY)
    ld      e, a
    or      b
    ld      b, a
    ld      a, #0x08
    call    WRTPSG
303$:
    bit     #SOUND_FLAG_OPLL_BIT, (hl)
    jr      z, 309$
    ld      e, #0x00
    ld      a, #0x20
    call    WRTOPL
    ld      a, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_TONE_FREQUENCY_H)
    or      a
    jr      z, 309$
    ld      a, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_VOICE)
    or      a
    jr      z, 309$
    ld      e, a
    ld      a, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_VOLUME_PLAY)
    xor     #0x0f
    or      e
    ld      e, a
    ld      a, #0x30
    call    WRTOPL
    ld      de, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_TONE_FREQUENCY)
    ld      a, #0x10
    call    WRTOPL
    ld      e, d
    ld      a, #0x20
    call    WRTOPL
309$:

    ; チャンネルＢの設定
    ld      hl, #(_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_FLAG)
    bit     #SOUND_FLAG_UPDATE_BIT, (hl)
    jr      z, 319$
    ld      a, #0b00010010
    or      c
    ld      c, a
    ld      a, (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_VOLUME)
    ld      (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_VOLUME_PLAY), a
    ld      a, (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_VOLUME_MINUS)
    ld      (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_VOLUME_FRAME), a
    bit     #SOUND_FLAG_NOISE_BIT, (hl)
    jr      z, 310$
    res     #0x04, c
    jr      312$
310$:
    ld      de, (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_TONE_FREQUENCY)
    ld      a, d
    or      e
    jr      nz, 311$
    ld      (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_VOLUME_PLAY), a
    jr      313$
311$:
    ld      a, (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_VOICE)
    or      a
    jr      nz, 313$
    res     #0x01, c
    ld      a, #0x02
    call    WRTPSG
    ld      e, d
    ld      a, #0x03
    call    WRTPSG
    xor     a
    ld      (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_TONE_FREQUENCY_H), a
312$:
    ld      a, (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_VOLUME_PLAY)
    ld      e, a
    or      b
    ld      b, a
    ld      a, #0x09
    call    WRTPSG
313$:
    bit     #SOUND_FLAG_OPLL_BIT, (hl)
    jr      z, 319$
    ld      e, #0x00
    ld      a, #0x21
    call    WRTOPL
    ld      a, (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_TONE_FREQUENCY_H)
    or      a
    jr      z, 319$
    ld      a, (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_VOICE)
    or      a
    jr      z, 319$
    ld      e, a
    ld      a, (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_VOLUME_PLAY)
    xor     #0x0f
    or      e
    ld      e, a
    ld      a, #0x31
    call    WRTOPL
    ld      de, (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_TONE_FREQUENCY)
    ld      a, #0x11
    call    WRTOPL
    ld      e, d
    ld      a, #0x21
    call    WRTOPL
319$:

    ; チャンネルＤの設定
    ld      hl, #(_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_FLAG)
    bit     #SOUND_FLAG_UPDATE_BIT, (hl)
    jr      z, 329$
    ld      a, #0b00100100
    or      c
    ld      c, a
    ld      a, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_VOLUME)
    ld      (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_VOLUME_PLAY), a
    ld      a, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_VOLUME_MINUS)
    ld      (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_VOLUME_FRAME), a
    bit     #SOUND_FLAG_NOISE_BIT, (hl)
    jr      z, 320$
    res     #0x05, c
    jr      322$
320$:
    ld      de, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_TONE_FREQUENCY)
    ld      a, d
    or      e
    jr      nz, 321$
    ld      (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_VOLUME_PLAY), a
    jr      323$
321$:
    ld      a, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_VOICE)
    or      a
    jr      nz, 323$
    res     #0x02, c
    ld      a, #0x04
    call    WRTPSG
    ld      e, d
    ld      a, #0x05
    call    WRTPSG
    xor     a
    ld      (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_TONE_FREQUENCY_H), a
322$:
    ld      a, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_VOLUME_PLAY)
    ld      e, a
    or      b
    ld      b, a
    ld      a, #0x0a
    call    WRTPSG
323$:
    bit     #SOUND_FLAG_OPLL_BIT, (hl)
    jp      z, 339$
    ld      e, #0x00
    ld      a, #0x22
    call    WRTOPL
    ld      a, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_TONE_FREQUENCY_H)
    or      a
    jp      z, 339$
    ld      a, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_VOICE)
    or      a
    jp      z, 339$
    ld      e, a
    ld      a, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_VOLUME_PLAY)
    xor     #0x0f
    or      e
    ld      e, a
    ld      a, #0x32
    call    WRTOPL
    ld      de, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_TONE_FREQUENCY)
    ld      a, #0x12
    call    WRTOPL
    ld      e, d
    ld      a, #0x22
    call    WRTOPL
329$:

    ; チャンネルＣの設定
    ld      hl, #(_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_FLAG)
    bit     #SOUND_FLAG_UPDATE_BIT, (hl)
    jr      z, 339$
    ld      a, #0b00100100
    or      c
    ld      c, a
    ld      a, (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_VOLUME)
    ld      (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_VOLUME_PLAY), a
    ld      a, (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_VOLUME_MINUS)
    ld      (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_VOLUME_FRAME), a
    bit     #SOUND_FLAG_NOISE_BIT, (hl)
    jr      z, 330$
    res     #0x05, c
    jr      332$
330$:
    ld      de, (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_TONE_FREQUENCY)
    ld      a, d
    or      e
    jr      nz, 331$
    ld      (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_VOLUME_PLAY), a
    jr      333$
331$:
    ld      a, (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_VOICE)
    or      a
    jr      nz, 333$
    res     #0x02, c
    ld      a, #0x04
    call    WRTPSG
    ld      e, d
    ld      a, #0x05
    call    WRTPSG
    xor     a
    ld      (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_TONE_FREQUENCY_H), a
332$:
    ld      a, (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_VOLUME_PLAY)
    ld      e, a
    or      b
    ld      b, a
    ld      a, #0x0a
    call    WRTPSG
333$:
    bit     #SOUND_FLAG_OPLL_BIT, (hl)
    jr      z, 339$
    ld      e, #0x00
    ld      a, #0x22
    call    WRTOPL
    ld      a, (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_TONE_FREQUENCY_H)
    or      a
    jr      z, 339$
    ld      a, (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_VOICE)
    or      a
    jr      z, 339$
    ld      e, a
    ld      a, (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_VOLUME_PLAY)
    xor     #0x0f
    or      e
    ld      e, a
    ld      a, #0x32
    call    WRTOPL
    ld      de, (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_TONE_FREQUENCY)
    ld      a, #0x12
    call    WRTOPL
    ld      e, d
    ld      a, #0x22
    call    WRTOPL
339$:

    ; エンベロープ形状の設定
    bit     #0x04, b
    jr      z, 40$
    ld      a, (_sound + SOUND_PSG_ENVELOPE_PATTERN)
    ld      e, a
    ld      a, #0x0d
    call    WRTPSG
40$:
    
    ; ミキサの設定
    ld      a, c
    ld      (_sound + SOUND_PSG_MIXER), a
    ld      e, a
    ld      a, #0x07
    call    WRTPSG

    ; OPLL の完了
    ld      hl, #0x4000
    ld      a, (_slot + SLOT_PAGE1)
    call    ENASLT
    
    ; 設定の完了
    ld      hl, #(_soundChannel + SOUND_CHANNEL_FLAG)
    ld      de, #SOUND_CHANNEL_SIZE
    ld      b, #SOUND_CHANNEL_ENTRY
50$:
    res     #SOUND_FLAG_UPDATE_BIT, (hl)
    add     hl, de
    djnz    50$
    
    ; 更新の終了
90$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; MML : 非対応命令
;
SystemUpdateSoundMmlNull:
    
    scf
    ret

; 'S' : エンベロープ波形（S0 ～ S15）
;
SystemUpdateSoundMmlS:

    ld      a, (hl)
    inc     hl
    sub     #'0
    ld      (_sound + SOUND_PSG_ENVELOPE_PATTERN), a
    ld      a, (hl)
    sub     #'0
    cp      #0x0a
    jr      nc, 09$
    add     a, #0x0a
    ld      (_sound + SOUND_PSG_ENVELOPE_PATTERN), a
    inc     hl
09$:
    scf
    ret
    
; 'M' : エンベロープ周期（M0 ～ M9）
;
SystemUpdateSoundMmlM:

    ld      a, (hl)
    inc     hl
    push    hl
    sub     #'0
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundEnvelopeTable
    add     hl, de
    ld      a, (hl)
    ld      (_sound + SOUND_PSG_ENVELOPE_FREQUENCY_L), a
    inc     hl
    ld      a, (hl)
    ld      (_sound + SOUND_PSG_ENVELOPE_FREQUENCY_H), a
    pop     hl
    scf
    ret
    
; 'N' : ノイズ周波数（N0 ～ N9）
;
SystemUpdateSoundMmlN:

    ld      a, (hl)
    inc     hl
    push    hl
    sub     #'0
    ld      e, a
    ld      d, b
    ld      hl, #soundNoiseFrequencyTable
    add     hl, de
    ld      a, (hl)
    ld      (_sound + SOUND_PSG_NOISE_FREQUENCY), a
    pop     hl
    scf
    ret
    
; 'T' : テンポ（T1 ～ T8）
;
SystemUpdateSoundMmlT:

    ld      a, (hl)
    inc     hl
    sub     #'1
    ld      SOUND_CHANNEL_TEMPO(ix), a
    scf
    ret

; '@' : 音色（@0 〜 @15, @16 = random voice, @* = shuffle）
;
SystemUpdateSoundMmlAt:

    ld      a, (hl)
    inc     hl
    cp      #'*
    jr      nz, 00$
    call    _SystemGetRandom
    and     #0x0f
    ld      (_sound + SOUND_OPLL_VOICE), a
    jr      09$
00$:
    sub     #'0
    ld      SOUND_CHANNEL_VOICE(ix), a
    ld      a, (hl)
    sub     #'0
    cp      #0x0a
    jr      c, 01$
    ld      a, SOUND_CHANNEL_VOICE(ix)
    jr      02$
01$:
    add     a, #0x0a
    ld      SOUND_CHANNEL_VOICE(ix), a
    inc     hl
    cp      #0x10
    jr      c, 02$
    ld      a, (_sound + SOUND_OPLL_VOICE)
02$:
    and     SOUND_CHANNEL_VOICE_MASK(ix)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      SOUND_CHANNEL_VOICE(ix), a
09$:
    scf
    ret

; 'V' : 音量（V0 ～ V16）
;
SystemUpdateSoundMmlV:

    ld      a, (hl)
    inc     hl
    sub     #'0
    ld      SOUND_CHANNEL_VOLUME(ix), a
    ld      a, (hl)
    sub     #'0
    cp      #0x0a
    jr      nc, 00$
    add     a, #0x0a
    ld      SOUND_CHANNEL_VOLUME(ix), a
    inc     hl
00$:
    ld      a, (hl)
    cp      #',
    jr      nz, 01$
    inc     hl
    ld      a, (hl)
    sub     #'0
    inc     hl
    jr      02$
01$:
    xor     a
02$:
    ld      SOUND_CHANNEL_VOLUME_MINUS(ix), a
    ld      SOUND_CHANNEL_VOLUME_FRAME(ix), a
    scf
    ret
    
; 'O' : オクターブ（O1 ～ O8）
;
SystemUpdateSoundMmlO:

    ld      a, (hl)
    inc     hl
    sub     #'1
    ld      SOUND_CHANNEL_OCTAVE(ix), a
    scf
    ret
    
; 'L' : 音の長さ（L0 ～ L9）
;
SystemUpdateSoundMmlL:

    ld      a, (hl)
    inc     hl
    sub     #'0
    ld      SOUND_CHANNEL_LENGTH(ix), a
    scf
    ret
    
; 'R' : 休符
;
SystemUpdateSoundMmlR:

    xor     a
    ld      SOUND_CHANNEL_TONE_FREQUENCY_L(ix), a
    ld      SOUND_CHANNEL_TONE_FREQUENCY_H(ix), a
    res     #SOUND_FLAG_NOISE_BIT, SOUND_CHANNEL_FLAG(ix)
    or      a
    ret
    
; 'X' : ノイズ
;
SystemUpdateSoundMmlX:

    xor     a
    ld      SOUND_CHANNEL_TONE_FREQUENCY_L(ix), a
    ld      SOUND_CHANNEL_TONE_FREQUENCY_H(ix), a
    set     #SOUND_FLAG_NOISE_BIT, SOUND_CHANNEL_FLAG(ix)
    or      a
    ret
    
; 'A' : 音符
;
SystemUpdateSoundMmlA:

    sub     #(('C - '@) * 0x02)
    jr      nc, 00$
    add     a, #(0x07 * 0x02)
00$:
;   add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    push    hl
    ld      a, SOUND_CHANNEL_VOICE(ix)
    or      a
    jr      nz, 01$
    ld      hl, #(soundToneFrequencyPsgTable + 0x0004)
    jr      02$
01$:
    ld      hl, #(soundToneFrequencyOpllTable + 0x0004)
;   jr      02$
02$:
    add     hl, de
    ld      a, SOUND_CHANNEL_OCTAVE(ix)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
;   ld      d, #0x00
    add     hl, de
    ex      de, hl
    pop     hl
    ld      a, (hl)
    cp      #'+
    jr      nz, 03$
    inc     de
    inc     de
    inc     hl
    jr      04$
03$:
    cp      #'-
    jr      nz, 04$
    dec     de
    dec     de
    inc     hl
04$:
    ld      a, (de)
    ld      SOUND_CHANNEL_TONE_FREQUENCY_L(ix), a
    inc     de
    ld      a, (de)
    ld      SOUND_CHANNEL_TONE_FREQUENCY_H(ix), a
    res     #SOUND_FLAG_NOISE_BIT, SOUND_CHANNEL_FLAG(ix)
    or      a
    ret

; サウンドを停止する
;
_SystemStopSound::

    ; レジスタの保存
    push    bc
    push    de
    push    ix

    ; 再生の停止
    ld      ix, #_soundChannel
    ld      de, #SOUND_CHANNEL_SIZE
    ld      bc, #((SOUND_CHANNEL_ENTRY << 8) | 0x0000)
10$:
    ld      SOUND_CHANNEL_HEAD_L(ix), c
    ld      SOUND_CHANNEL_HEAD_H(ix), c
    ld      SOUND_CHANNEL_PLAY_L(ix), c
    ld      SOUND_CHANNEL_PLAY_H(ix), c
    ld      SOUND_CHANNEL_TONE_FREQUENCY_L(ix), c
    ld      SOUND_CHANNEL_TONE_FREQUENCY_H(ix), c
    res     #SOUND_FLAG_NOISE_BIT, SOUND_CHANNEL_FLAG(ix)
    add     ix, de
    djnz    10$

    ; サウンドの停止
    call    SystemMuteSound
    
    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    
    ; 終了
    ret

; サウンドを一時停止する
;
_SystemSuspendSound::
    
    ; レジスタの保存
    push    hl
    
    ; スリープの設定
    ld      hl, #_flag
    set     #FLAG_SOUND_SLEEP_BIT, (hl)
    
    ; サウンドの発声の停止
    call    SystemMuteSound

    ; レジスタの復帰
    pop     hl
    
    ; 終了
    ret

; サウンドを再開する
;
_SystemResumeSound::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    
    ; スリープの解除
    ld      hl, #_flag
    res     #FLAG_SOUND_SLEEP_BIT, (hl)
    
    ; サウンドの更新
    ld      hl, #(_soundChannel + SOUND_CHANNEL_FLAG)
    ld      de, #SOUND_CHANNEL_SIZE
    ld      b, #SOUND_CHANNEL_ENTRY
10$:
    set     #SOUND_FLAG_UPDATE_BIT, (hl)
    add     hl, de
    djnz    10$
    
    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; サウンドのチャンネルをクリアする
;
SystemClearSoundChannel:
    
    ; レジスタの保存
    push    af

    ; ix < sound channel
    
    ; チャンネルのクリア
    xor     a
    ld      SOUND_CHANNEL_TEMPO(ix), a
    ld      SOUND_CHANNEL_VOICE(ix), a
    ld      SOUND_CHANNEL_VOLUME(ix), #0x0f
    ld      SOUND_CHANNEL_VOLUME_PLAY(ix), #0x0f
    ld      SOUND_CHANNEL_VOLUME_MINUS(ix), a
    ld      SOUND_CHANNEL_OCTAVE(ix), #0x03
    ld      SOUND_CHANNEL_LENGTH(ix), #0x05
    ld      SOUND_CHANNEL_TONE_FREQUENCY_L(ix), a
    ld      SOUND_CHANNEL_TONE_FREQUENCY_H(ix), a
    ld      SOUND_CHANNEL_REST(ix), #0x01
    ld      a, #(SOUND_FLAG_NULL | SOUND_FLAG_OPLL)
    and     SOUND_CHANNEL_FLAG(ix)
    ld      SOUND_CHANNEL_FLAG(ix), a
    
    ; レジスタの復帰
    pop     af
    
    ; 終了
    ret

; サウンドの発声を停止する
;
SystemMuteSound:

    ; レジスタの保存
    push    hl
    push    de

    ; PSG の停止
    ld      e, #0b10111111
    ld      a, #0x07
    call    WRTPSG
    ld      e, #0b00000000
    inc     a
    call    WRTPSG
    inc     a
    call    WRTPSG
    inc     a
    call    WRTPSG

    ; OPLL の停止
    ld      a, (_slot + SLOT_OPLL)
    cp      #0xff
    jr      z, 20$
    di
    ld      hl, #0x4000
    call    ENASLT
    ld      e, #0x00
    ld      a, #0x20
    call    WRTOPL
    inc     a
    call    WRTOPL
    inc     a
    call    WRTOPL
    ld      a, #0x30
    call    WRTOPL
    inc     a
    call    WRTOPL
    inc     a
    call    WRTOPL
    ld      a, (_slot + SLOT_PAGE1)
    call    ENASLT
    ei
20$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; PAC から読み込む
;
_SystemReadPac::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; hl < data address
    ; bc < data length
    ; cf > 1 = error

    ; PAC を開く
    call    SystemOpenPac
    jr      c, 19$

    ; PAC は 1 から読み込む
    ld      de, #0x4000

    ; ID のチェック
    ld      a, (de)
    cp      #PAC_ID
    jr      nz, 17$
    inc     de

    ; サイズのチェック
    ld      a, (de)
    cp      c
    jr      nz, 17$
    inc     de
    ld      a, (de)
    cp      b
    jr      nz, 17$
    inc     de

    ; CRC のチェック
    push    hl
    ld      l, e
    ld      h, d
    inc     hl
    call    _SystemCalcCrc
    pop     hl
    ex      de, hl
    cp      (hl)
    jr      nz, 17$
    inc     hl

    ; データの読み込み
    ldir
    ld      a, #0x01
    jr      18$

    ; PAC を閉じる
17$:
    xor     a
18$:
    call    SystemClosePac
    rrca

    ; 読み込みの完了
19$:

    ; 割り込み禁止の解除
    ei

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; PAC へ書き込む
;
_SystemWritePac::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; hl < data address
    ; bc < data length
    ; cf > 1 = error

    ; PAC を開く
    call    SystemOpenPac
    jr      c, 19$

    ; PAC は 1 から書き込む
    ld      de, #0x4000

    ; ID の書き込み
    ld      a, #PAC_ID
    ld      (de), a
    inc     de

    ; サイズの書き込み
    ld      a, c
    ld      (de), a
    inc     de
    ld      a, b
    ld      (de), a
    inc     de

    ; CRC の書き込み
    call    _SystemCalcCrc
    ld      (de), a
    inc     de

    ; データの書き込み
    ldir

    ; PAC を閉じる
    call    SystemClosePac
    or      a

    ; 書き込みの完了
19$:

    ; 割り込み禁止の解除
    ei

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; PAC を開く
;
SystemOpenPac:

    ; 割り込みの禁止
    di

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy

    ; cf > 1 = no pac

    ; PAC の存在
    ld      a, (_slot + SLOT_PAC)
    cp      #0xff
    jr      nz, 10$
    scf
    jr      19$
10$:

    ; スロットの切り替え
    ld      hl, #0x4000
    call    ENASLT

    ; PAC への切り替え
    ld      hl, #0x694d
    ld      (0x5ffe), hl
    or      a

    ; 開くの完了
19$:

    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; PAC を閉じる
;
SystemClosePac:

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy

    ; PAC の存在
    ld      a, (_slot + SLOT_PAC)
    cp      #0xff
    jr      z, 19$

    ; PAC からの復帰
    ld      hl, #0xffff
    ld      (0x5ffe), hl

    ; スロットの復帰
    ld      hl, #0x4000
    ld      a, (_slot + SLOT_PAGE1)
    call    ENASLT

    ; 閉じるの完了
19$:

    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 割り込み禁止の解除
    ei

    ; 終了
    ret

; 乱数を取得する
;
_SystemGetRandom::
    
    ; レジスタの保存
    push    hl
    push    de

    ; a > random number
    
    ; 乱数の生成
    ld      hl, (random)
    ld      e, l
    ld      d, h
    add     hl, hl
    add     hl, hl
    add     hl, de
    ld      de, #0x2018
    add     hl, de
    ld      (random), hl
    ld      a, h
    
    ; レジスタの復帰
    pop     de
    pop     hl
    
    ; 終了
    ret

; CRC を計算する
;
_SystemCalcCrc::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; hl < data address
    ; bc < data length
    ; a  > crc

    ; CRC8: x^8 + x^7 + x^2 + 1 = 0x85
    ld      e, #0x85
    xor     a
10$:
    xor     (hl)
    ld      d, #0x08
11$:
    add     a, a
    jr      nc, 12$
    xor     e
12$:
    dec     d
    jr      nz, 11$
    inc     hl
    dec     bc
    ld      d, a
    ld      a, b
    or      c
    ld      a, d
    jr      nz, 10$

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; キー入力
;
inputKeyTable:
    
    .db     0x00
    .db     (1 << INPUT_KEY_UP)
    .db     (1 << INPUT_KEY_UP)    | (1 << INPUT_KEY_RIGHT)
    .db     (1 << INPUT_KEY_RIGHT)
    .db     (1 << INPUT_KEY_DOWN)  | (1 << INPUT_KEY_RIGHT)
    .db     (1 << INPUT_KEY_DOWN)
    .db     (1 << INPUT_KEY_DOWN)  | (1 << INPUT_KEY_LEFT)
    .db     (1 << INPUT_KEY_LEFT)
    .db     (1 << INPUT_KEY_UP)    | (1 << INPUT_KEY_LEFT)

; サウンド
;
soundEnvelopeTable:
    
    .dw        0,    128,   256,   512,  1024,  2048,  4096,  8192, 16384, 32768

soundToneFrequencyPsgTable:

    .dw     0x0000, 0x0000, 0x0d5d, 0x0c9c, 0x0be7, 0x0b3c, 0x0a9b, 0x0a02, 0x0a02, 0x0973, 0x08eb, 0x086b, 0x07f2, 0x0780, 0x0714, 0x06af  ; O1
    .dw     0x0000, 0x0714, 0x06af, 0x064e, 0x05f4, 0x059e, 0x054e, 0x0501, 0x0501, 0x04ba, 0x0476, 0x0436, 0x03f9, 0x03c0, 0x038a, 0x0357  ; O2
    .dw     0x0000, 0x038a, 0x0357, 0x0327, 0x02fa, 0x02cf, 0x02a7, 0x0281, 0x0281, 0x025d, 0x023b, 0x021b, 0x01fd, 0x01e0, 0x01c5, 0x01ac  ; O3
    .dw     0x0000, 0x01c5, 0x01ac, 0x0194, 0x017d, 0x0168, 0x0153, 0x0140, 0x0140, 0x012e, 0x011d, 0x010d, 0x00fe, 0x00f0, 0x00e3, 0x00d6  ; O4
    .dw     0x0000, 0x00e3, 0x00d6, 0x00ca, 0x00be, 0x00b4, 0x00aa, 0x00a0, 0x00a0, 0x0097, 0x008f, 0x0087, 0x007f, 0x0078, 0x0071, 0x006b  ; O5
    .dw     0x0000, 0x0071, 0x006b, 0x0065, 0x005f, 0x005a, 0x0055, 0x0050, 0x0050, 0x004c, 0x0047, 0x0043, 0x0040, 0x003c, 0x0039, 0x0035  ; O6
    .dw     0x0000, 0x0039, 0x0035, 0x0032, 0x0030, 0x002d, 0x002a, 0x0028, 0x0028, 0x0026, 0x0024, 0x0022, 0x0020, 0x001e, 0x001c, 0x001b  ; O7
    .dw     0x0000, 0x001c, 0x001b, 0x0019, 0x0018, 0x0016, 0x0015, 0x0014, 0x0014, 0x0013, 0x0012, 0x0011, 0x0010, 0x000d, 0x000e, 0x000d  ; O8

soundToneFrequencyOpllTable:

;   .dw     0x0000, 0x00ac, 0x00ac, 0x00b7, 0x00c2, 0x00cd, 0x00d9, 0x00e6, 0x00e6, 0x00f4, 0x0102, 0x0112, 0x0122, 0x0133, 0x0146, 0x0159
    .dw     0x0000, 0x10ac, 0x10ac, 0x10b7, 0x10c2, 0x10cd, 0x10d9, 0x10e6, 0x10e6, 0x10f4, 0x1102, 0x1112, 0x1122, 0x1133, 0x1146, 0x1159  ; O1
    .dw     0x0000, 0x12ac, 0x12ac, 0x12b7, 0x12c2, 0x12cd, 0x12d9, 0x12e6, 0x12e6, 0x12f4, 0x1302, 0x1312, 0x1322, 0x1333, 0x1346, 0x1359  ; 02
    .dw     0x0000, 0x14ac, 0x14ac, 0x14b7, 0x14c2, 0x14cd, 0x14d9, 0x14e6, 0x14e6, 0x14f4, 0x1502, 0x1512, 0x1522, 0x1533, 0x1546, 0x1559  ; O3
    .dw     0x0000, 0x16ac, 0x16ac, 0x16b7, 0x16c2, 0x16cd, 0x16d9, 0x16e6, 0x16e6, 0x16f4, 0x1702, 0x1712, 0x1722, 0x1733, 0x1746, 0x1759  ; O4
    .dw     0x0000, 0x18ac, 0x18ac, 0x18b7, 0x18c2, 0x18cd, 0x18d9, 0x18e6, 0x18e6, 0x18f4, 0x1902, 0x1912, 0x1922, 0x1933, 0x1946, 0x1959  ; O5
    .dw     0x0000, 0x1aac, 0x1aac, 0x1ab7, 0x1ac2, 0x1acd, 0x1ad9, 0x1ae6, 0x1ae6, 0x1af4, 0x1b02, 0x1b12, 0x1b22, 0x1b33, 0x1b46, 0x1b59  ; O6
    .dw     0x0000, 0x1cac, 0x1cac, 0x1cb7, 0x1cc2, 0x1ccd, 0x1cd9, 0x1ce6, 0x1ce6, 0x1cf4, 0x1d02, 0x1d12, 0x1d22, 0x1d33, 0x1d46, 0x1d59  ; O7
    .dw     0x0000, 0x1eac, 0x1eac, 0x1eb7, 0x1ec2, 0x1ecd, 0x1ed9, 0x1ee6, 0x1ee6, 0x1ef4, 0x1f02, 0x1f12, 0x1f22, 0x1f33, 0x1f46, 0x1f59  ; O8

soundNoiseFrequencyTable:
    
    .db      0,  1,  2,  4,  8, 12, 16, 20, 24, 31

soundLengthTable:
    
    .db     1       ; T1 L0 32
    .db     2       ; T1 L1 16
    .db     3       ; T1 L2 16.
    .db     4       ; T1 L3  8
    .db     6       ; T1 L4  8.
    .db     8       ; T1 L5  4
    .db     12      ; T1 L6  4.
    .db     16      ; T1 L7  2
    .db     24      ; T1 L8  2.
    .db     32      ; T1 L9  1
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     2       ; T2 L0 32
    .db     4       ; T2 L1 16
    .db     6       ; T2 L2 16.
    .db     8       ; T2 L3  8
    .db     12      ; T2 L4  8.
    .db     16      ; T2 L5  4
    .db     24      ; T2 L6  4.
    .db     32      ; T2 L7  2
    .db     48      ; T2 L8  2.
    .db     64      ; T2 L9  1
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     3       ; T3 L0 32
    .db     6       ; T3 L1 16
    .db     9       ; T3 L2 16.
    .db     12      ; T3 L3  8
    .db     18      ; T3 L4  8.
    .db     24      ; T3 L5  4
    .db     36      ; T3 L6  4.
    .db     48      ; T3 L7  2
    .db     72      ; T3 L8  2.
    .db     96      ; T3 L9  1
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     4       ; T4 L0 32
    .db     8       ; T4 L1 16
    .db     12      ; T4 L2 16.
    .db     16      ; T4 L3  8
    .db     24      ; T4 L4  8.
    .db     32      ; T4 L5  4
    .db     48      ; T4 L6  4.
    .db     64      ; T4 L7  2
    .db     96      ; T4 L8  2.
    .db     128     ; T4 L9  1
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     5       ; T5 L0 32
    .db     10      ; T5 L1 16
    .db     15      ; T5 L2 16.
    .db     20      ; T5 L3  8
    .db     30      ; T5 L4  8.
    .db     40      ; T5 L5  4
    .db     60      ; T5 L6  4.
    .db     80      ; T5 L7  2
    .db     120     ; T5 L8  2.
    .db     160     ; T5 L9  1
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     6       ; T6 L0 32
    .db     12      ; T6 L1 16
    .db     18      ; T6 L2 16.
    .db     24      ; T6 L3  8
    .db     32      ; T6 L4  8.
    .db     48      ; T6 L5  4
    .db     72      ; T6 L6  4.
    .db     96      ; T6 L7  2
    .db     144     ; T6 L8  2.
    .db     192     ; T6 L9  1
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     7       ; T7 L0 32
    .db     14      ; T7 L1 16
    .db     21      ; T7 L2 16.
    .db     28      ; T7 L3  8
    .db     42      ; T7 L4  8.
    .db     56      ; T7 L5  4
    .db     84      ; T7 L6  4.
    .db     112     ; T7 L7  2
    .db     168     ; T7 L8  2.
    .db     224     ; T7 L9  1
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     8       ; T8 L0 32
    .db     16      ; T8 L1 16
    .db     24      ; T8 L2 16.
    .db     32      ; T8 L3  8
    .db     48      ; T8 L4  8.
    .db     64      ; T8 L5  4
    .db     96      ; T8 L6  4.
    .db     128     ; T8 L7  2
    .db     192     ; T8 L8  2.
    .db     0       ; T8 L9  1
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;

soundMmlProc:

    .dw     SystemUpdateSoundMmlAt
    .dw     SystemUpdateSoundMmlA
    .dw     SystemUpdateSoundMmlA
    .dw     SystemUpdateSoundMmlA
    .dw     SystemUpdateSoundMmlA
    .dw     SystemUpdateSoundMmlA
    .dw     SystemUpdateSoundMmlA
    .dw     SystemUpdateSoundMmlA
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlL
    .dw     SystemUpdateSoundMmlM
    .dw     SystemUpdateSoundMmlN
    .dw     SystemUpdateSoundMmlO
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlR
    .dw     SystemUpdateSoundMmlS
    .dw     SystemUpdateSoundMmlT
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlV
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlX
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlNull


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; フラグ
;
_flag::
    
    .ds     0x01

; スロット
;
_slot::

    .ds     SLOT_SIZE

; キー入力
;
_input::
    
    .ds     INPUT_SIZE

; ビデオ
;
_videoPort::
    
    .ds     0x02

_videoRegister::
    
    .ds     0x08

; スプライト
;
_sprite::
    
    .ds     0x80

; パターンネーム
;
_patternName::

    .ds     0x0300

; サウンド
;
_sound::

    .ds     SOUND_SIZE

_soundChannel::

    .ds     SOUND_CHANNEL_SIZE * SOUND_CHANNEL_ENTRY

    .even
soundOpllWork:

    .ds     160

; 乱数
;
random:
    
    .ds     0x02
