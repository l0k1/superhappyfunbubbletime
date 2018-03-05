;Camera controls for when the player is out walking around.
;Store map data.
;Also, screenfades and other camera fun stuff.

INCLUDE "defines.asm"

EXPORT  Fade_In_Black
EXPORT  Fade_In_White
EXPORT  Fade_Out_Black
EXPORT  Fade_Out_White
EXPORT  Camera_Update
EXPORT  Load_Map_Data

   SECTION "Camera Update",ROM0
Camera_Update:
   ; tl;dr - load up the bg array with bg updates if needed
   ret
   
   SECTION "Load Map Data",ROM0
   ; Load in map data into known variables in the RAM
   ; Write a new BG map after warping.
   ; Map data should be pushed onto the stack like so:
   ; push BC - B = [x coord of player], C = [y coord of player]
   ; push BC - BC = [local map address]
   ; push BC - B = [local map bank]
Load_Map_Data:
   
   ; to simplify things, we are setting the bg window to 8,8
   ld A,$08
   ld [rSCX],A
   ld [rSCY],A

   ; first get the correct bank
   pop AF
   ld [MAP_BANK],A
   ld D,$01
   ld E,A
   call Switch_Bank

   ; put the mem position into HL
   pop HL

   ; save players new X/Y
   pop BC
   ld A,B
   ld [PPOSX],A
   ld A,C
   ld [PPOSY],A

   ; save the upper/lower addresses
   ld A,H
   ld [MAP_ADDR_U],A
   ld A,L
   ld [MAP_ADDR_L],A
   ; save map x/y dimensions
   ld A,[HL+]
   ld [MAPX],A
   ld A,[HL+]
   ld [MAPY],A
   ld A,[HL+]
   ld [MAP_TILESET],A
   ld A,[HL+]
   ld [MAPDEFAULTTILE],A

   ; save HL for a tad later
   push HL

   ; zero out E for data collection
   xor A
   ld E,A
   
   ; check the left side
   
   ld A,B                  ; B holds pposx still
   sub $0A                 ; if x pos - half the screen < 0 then
   jr nc,.left_else
   set 6,E                 ; left map needs to be loaded
   xor A
.left_else
   ld [MAPXLOADED],A
   
   ; check the up side
   
   ld A,C                  ; C should still hold pposy
   sub $0A                 ; if y pos - half the screen < 0 then
   jr nc,.up_else
   set 0,E                 ; upper screen needs to be loaded
   xor A
.up_else
   ld [MAPYLOADED],A

   ; check the right side

   bit 6,E                 ; if the left map hasn't been loaded,
   jr nz,.skip_right_load  ; check right
   ld A,B                  ; B still contains pposx
   add $10                 ; if x pos + half screen > x dim then
   ld HL,MAPX
   cp [HL]
   jr nc,.skip_right_load
   set 2,E                 ; load the right screen
.skip_right_load
   
   bit 0,E                 ; if the up map hasn't been loaded,
   jr nz,.skip_down_load   ; check down
   ld A,C                  ; C still contains pposy
   add $10                 ; if y pos + half Screen > ydim
   inc HL                  ; point HL at MAPY
   cp [HL]
   jr nc,.skip_down_load
   set 4,E                 ; load the bottom screen
.skip_down_load

   ; E should now contain the info we need to load the maps, where:
   ; bit 0 = top
   ; bit 2 = right
   ; bit 4 = bottom
   ; bit 6 = left

   ; save E in TEMP1
   ld A,E
   ld [MAPS_TO_LOAD_FLAGS],A

   ; disable the LCD so we can write lots to the background
   ld HL,GFX_UPDATE_FLAGS
   set 2,[HL]

   halt
   nop
   
   ; we need to load from top to bottom, and from left to right
   ; for every iteration, we need the starting address in the map being loaded, the starting address of the background array, how many lines to count, and how many tiles per line.
   ; for the map being loaded, use the formulas below to get mapx, mapy, number of tiles per line, and number of lines.
   ; for the background array, due to setting SCX,SCY to 8,8, we know to start loading the bg array at $8000 [BG Map 1]

   ; check top bit   
   bit 0,E
   jp z,.skip_top
   
.top_left_load
   ; we need to load the top. check the left bit first
   bit 6,E
   jp z,.top_center_load
   
   pop HL                        ; HL *should* contain the addy of the warp data
   push HL
   
   ; top-left map will be the first entry in the surrounding map data
   ld A,[HL+]
   or 0                          ; if the map bank is 0, load the default tile
   jr nz,.top_left_load_map
   
.top_left_load_default_tile

; loop to load the default tile.
; we need:
; DE = [D: #tiles per pass | E: #passes]
; HL = location in the BG map to load into

; writes respective coordinate (x or y) to B
; if X, writes tiles to load per pass to C
; if Y, writes number of passes to C
   call Top_Y_Map                ; number of passes to do into C
   ld E,C
   call Left_X_Map               ; number of tiles per pass into C
   ld D,C                        ; DE = [D:#tiles per pass | E:#passes]
   ld HL,$8000                   ; load the bg map location into HL
   call Default_Tile_Load_Loop
   jp .top_center_load

.top_left_load_map
   ; we need to switch to the correct bank
   ld A,[HL+]
   ld [LD_MAP_BANK],A
   ; point BC to the start of the map data, bypassing the metadata
   ld A,[HL+]
   ld B,A
   ld A,[HL+]
   ld C,A
   add $FC
   jr nc,.sc1
   inc B
.sc1

   push BC
   
   call Top_Y_Map                ; number of passes to do into C
                                 ; map Y coord into B
   ld A,C
   ld [NUM_LOOPS],A              ; save #passes into NUM_LOOPS
   ld E,B                        ; y coord into E

   call Left_X_Map               ; number of tiles to load into C
                                 ; map X coord int B
   ld A,C
   ld [NUM_TILES_PER_LOOP],A     ; save #tiles into NUM_TILES_PER_LOOP
   ld D,B                        ; DE has XY

   ;need to increment the address by (y * map_x_dim + x)
   ld A,[MAPX]
   ld H,A
   call Mul8b                    ; H * E, HL now has y * mapx
   pop BC                        ; put the starting map pos back into BC
   add HL,BC
   ld A,D                        ; add the X to HL
   add L
   jr nc,.sc2
   inc H
.sc2                             ; HL = address to load from

   ld BC,$8000
   ; BC = BG map starting address
   ; HL = map data starting address
   ; DE = [D: #tiles per pass | E: #passes]
   
.top_center_load
.skip_top_load_zero
.top_right_load
.skip_top
   ret

; loop to load from a map.
; the bank should be switched correctly before calling
; BC = map data starting address
; HL = location in the BG map to load
; [LD_MAP_BANK] = the bank to load map data from (the LSB, the HSB will always be $01)
; [NUM_LOOPS] = the number of loops to load
; [NUM_TILES_PER_LOOP] = number of tiles per loop
; [BG_MAP_INC] = how much to increment HL after each pass
Map_Tile_Load_Loop:
   ld A,[LD_MAP_BANK]
   ld E,A
   ld D,$01
   call Switch_Bank        ; switch the bank to the correct one
   
   ld A,[NUM_LOOPS]
   ld E,A
   ld A,[NUM_TILES_PER_LOOP]
   ld D,A
   
   ld A,$20
   sub D
   ld [BG_MAP_INC],A
   
.main_loop
   ld A,[BC]               ; take the tile from the map data
   ld [HL+],A              ; place it in the bg map
   inc BC
   dec D                   ; check if we've loaded all the tiles for this pass
   xor A
   cp D
   jr nz,.main_loop
   
   ld A,[NUM_TILES_PER_LOOP]
   ld D,A                  ; refresh D as we prep for a new pass
   ld A,[BG_MAP_INC]
   add L                   ; add A onto HL
   ld L,A
   jr nc,.sc1
   inc H
.sc1
   
   dec E                   ; decrement E
   cp E                    ; if we haven't done all the passes, back to the top.
   jr nz,.main_loop
   
   call Return_Bank
   ret
   


; loop to load the default tile.
; DE = [D: #tiles per pass | E: #passes]
; HL = location in the BG map to load
Default_Tile_Load_Loop:
   ld A,$20
   sub E
   ld C,A
   ld B,0                        ; BC = screen width - tiles to load per pass

   ld A,D
   ld [NUM_TILES_PER_LOOP],A
.main_loop
   ld A,[MAPDEFAULTTILE]
   ld [HL+],A
   dec E
   xor A
   or E
   jr nz,.main_loop
   add HL,BC                     ; increment HL by the screen width - tile count
   ld A,[NUM_TILES_PER_LOOP]     ; refresh #tiles
   ld E,A
   dec D
   xor A
   or D
   jr nz,Default_Tile_Load_Loop
   ret


; formulas for the map loading
; writes respective coordinate (x or y) to B
; if X, writes tiles to load per pass to C
; if Y, writes number of passes to C
; should work if the X,Y of the player
; on the screen is 10,9

Top_Y_Map:
   ; y = MAPY - 9 + PPOSY
   push AF
   
   ld B,$09
   ld A,[MAPY]
   sub B
   ld B,A
   ld A,[PPOSY]
   add B
   ld B,A
   
   ; lines to load = 9 - pposy
   ld A,[PPOSY]
   ld C,$09
   sub C
   ld C,A
   
   pop AF
   ret
   
Center_Y_Map:
   push AF
   push DE
   ; y = greater of 0 and PPOSY - 9
   ld B,$09
   ld A,[PPOSY]
   sub B
   jr nc,.skip_0_load_n0
   xor A
.skip_0_load_n0
   ld B,A
   
   ; lines to load is going to be done in 3 parts
   
   ; bottom side = greater of 0 or 11 - (MAPY - PPOSY)
   ld A,[PPOSY]
   ld C,A
   ld A,[MAPY]
   sub C
   jr c,.zero_load
   ld C,A
   ld A,$0B
   sub C
   jr nc,.skip_0_load_n1
.zero_load
   xor A
.skip_0_load_n1
   ld C,A
   
   ; top side = greater of 0 or pposy - 9
   ld D,$09
   ld A,[PPOSY]
   sub D
   jr nc,.skip_0_load_n2
   xor A
.skip_0_load_n2
   
   ; lines to load = top side - bottom side
   
   sub C
   ld C,A
   
   pop DE
   pop AF
   ret
   
Bottom_Y_Map:
   ; y is 0
   push AF
   
   xor A
   ld B,A
   
   ; lines to load is 11 - (MAPY - PPOSY)
   ld A,[PPOSY]
   ld C,A
   ld A,[MAPY]
   sub C
   ld C,A
   ld A,$0B
   sub C
   ld C,A
   
   pop AF
   
   ret
   
Left_X_Map:
   ; x = MAPX + (PPOSX - 10)
   push AF
   
   ld B,$0A
   ld A,[PPOSX]
   sub B
   ld B,A
   ld A,[MAPX]
   add B
   ld B,A
   
   ; tile count per pass = 10 - pposx
   ld A,[PPOSX]
   ld C,A
   ld A,$0A
   sub C
   ld C,A
   
   pop AF
   
   ret
   
Center_X_Map:
   push AF
   push DE
   ; x = greater of 0 or pposx - 10
   ld B,$0A
   ld A,[PPOSX]
   sub B
   jr nc,.skip_zero
   xor A
.skip_zero
   ld B,A
   
   ; tile_count is a two parter
   
   ; right side = greater of 0 or 12 - (MAPX - PPOSX)
   ld A,[PPOSX]
   ld D,A
   ld A,[MAPX]
   sub D
   jr c,.load_zero
   ld D,A
   ld A,$0C
   sub D
   jr nc,.skip_zero_n1
.load_zero
   xor A
.skip_zero_n1
   ld D,A
   
   ; left side = greater of 0 or pposx - 10
   ld C,$0A
   ld A,[PPOSX]
   sub C
   jr nc,.skip_zero_n2
   xor A
.skip_zero_n2
   
   ; final is left side - right side
   sub D
   ld C,A
   
   pop DE
   pop AF
   ret
   
Right_X_Map:
   push AF
   ; x = 0
   ld B,$00
   
   ; tile_count = pposx + 12 - MAPX
   
   ld A,[MAPX]
   ld C,A
   ld A,$0C
   sub C
   ld C,A
   ld A,[PPOSX]
   add C
   ld C,A
   
   pop AF
   ret

   SECTION "Screen Fades",ROM0
   ;setting the shift to happen at ~180ms intervals for now.
   ;for all of these, the timer needs to be at 4.096kHz, and enabled.
Fade_In_Black:
   ld A,%11111111             ;to fade in from black, the BG needs to be black *wink*
   ld [rBGP],A
   ld D,3                     ;we want to loop 3 times
   ld A,%11100100             ;need to push our updates in FILO order.
   push AF
   ld A,%11111001
   push AF
   ld A,%11111110
   push AF
   call Fade_Loop             ;call the fade loop.
   ret

Fade_Out_Black:
   ld A,%11100100             ;make sure rBGP is normal.
   ld [rBGP],A
   ld D,3                     ;loop three times again.
   ld A,%11111111             ;fades in FILO order.
   push AF
   ld A,%11111110
   push AF
   ld A,%11111001
   push AF
   call Fade_Loop
   ret

Fade_In_White:
   ld A,%00000000             ;make sure rBGP is white.
   ld [rBGP],A
   ld D,3                     ;loop three times again.
   ld A,%11100100             ;fades in FILO order.
   push AF
   ld A,%10010000
   push AF
   ld A,%01000000
   push AF
   call Fade_Loop
   ret

Fade_Out_White:
   ld A,%11100100             ;make sure rBGP is normal.
   ld [rBGP],A
   ld D,3                     ;loop three times again.
   ld A,%00000000             ;fades in FILO order.
   push AF
   ld A,%01000000
   push AF
   ld A,%10010000
   push AF
   call Fade_Loop
   ret

Fade_Loop:
   pop HL                     ;our return address for later
.out_loop
   xor A                      ;zero out timer 1
   ld [TIMERT],A
.in_loop
   halt                       ;less cpu usage is a good thing.
   nop
   ld A,[TIMERT]              ;wait 3 ticks, then load background data
   cp $03
   jr nz,.in_loop
   pop AF                     ;load our background data
   ld [rBGP],A
   ld [rOBP0],A
   ld [rOBP1],A
   dec D
   jp nz,.out_loop            ;if our count isn't zero, return
   
   xor A
   ld [TIMERT],A
.final_loop                   ;after the last pallete is set, we need to
   halt                       ;stall a little bit so the screen turns
   nop                        ;full on black-or-white.
   ld A,[TIMERT]
   cp $03                     ;wait 3 more ticks before returning
   jr nz,.final_loop
   push HL                    ;put the return address back on the stack
   ret
