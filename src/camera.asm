;Camera controls for when the player is out walking around.
;Store map data.
;Also, screenfades and other camera fun stuff.

INCLUDE "globals.asm"

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

   ; disable the LCD so we can write lots to the background
   ld HL,GFX_UPDATE_FLAGS
   set 2,[HL]
   
   halt
   nop

   ; load top
   
   bit 0,E
   jp z,.skip_top
   ; for loading the top,
   ; y in the map is y_dim - (halfscreen - pposy)
   ; y in the bg array is 0
   ; x in the map is the greater of player_x - screenwidth and 0
   ; x in the bg array is the lesser of player_x - screenwidth and 0
   
   ; first step is to check if there is an upper map to load. otherwise we are using the default tile.
   
   ; the stack should still be pointed at the pos containing map data
   
   pop HL
   push HL           ; save the map legend location right away

   ld A,[HL+]
   cp 0
   jp z,.load_default_tile_top
   ; we are loading in the top map
   ; jump to that memory spot
   ld D,$01
   ld E,A
   call Switch_Bank
   ld A,[HL+]
   ld B,A
   ld A,[HL]
   ld C,A
   ; DE contains bank, BC contains memory address
   
   ; formula for tile addy is:
   ; x = pposx - halfscreen, if carry then 0
   ; tile = ((y_dim - pposy - halfscreeny) * y_dim) + x
   ; tile = tile + 100 ( to account for metadata)
   ; accumulate our sum into BC

   ld A,[PPOSY]
   ld H,A         ;use this later in the multiplication
   ld E,A
   ld A,[MAPY]
   sub E
   sub $0A
   ld E,A
   push AF        ; A holds the y coord
   call Mul8b     ; H*E, stores in HL
   
   ld A,[PPOSX]
   sub $0B
   jr nc,.skupgtz ; it's a mnemonic, i swear.
   xor A
.skupgtz
   ld A,E
   ld D,$01       ; to account for metadata
   
   ; now BC contains the map starting address, DE contains the "x" portion and metadata skipping amount, and HL contains the "y" portion
   
   add HL,BC
   add HL,DE

   ; HL now contains our starting address 
   ; start loading bgmap at halfscreen - pposx, if carry then 0
   ld A,[PPOSX]
   ld E,A
   ld A,$0B
   sub E
   jr nc,.skupgtzt
   xor A
.skupgtzt         ; another mnemonic, i think.
   ld E,A         ; E now holds the starting pos
   ld D,$98       ; there, DE points to the starting pos in the BG map
   ld A,$16
   sub E          ; $16 - startpoint = bytes to load
   pop BC         ; B now holds the y coord (see the push above).
   ld C,A         ; C = bytes to load
   ld A,[MAPY]    ; y_dim - y_coord(B) = y lines to load
   sub B
   ld B,A         ; load "C" amount of tiles, "B" times, from HL, to DE

   push BC        ; save it

.up_loading_lollapalooza
   ld A,[HL]
   ld [DE],A
   dec C
   jr nz,.up_loading_lollapalooza
   dec B
   jp z,.up_exit
   ld A,B         ; refresh the C register with
   pop BC         ; the count of tiles we need to load
   push BC
   ld B,A         ; B needs to be saved tho
   ld A,E         ; increment DE by $20
   add $20
   jr nc,.up_skip_inc_d
   inc D
.up_skip_inc_d
   push DE        ; now we need to increment HL by MAPY
   ld D,H
   ld E,L
   ld A,[MAPY]
   add E
   jr nc,.up_skip_inc_d_2
   inc D
.up_skip_inc_d_2
   ld H,D
   ld L,E
   pop DE
   jp .up_loading_lollapalooza 

.up_exit          ; clean up.
   pop BC         ; we don't need that on the stack no more. hallelujah.
   call Return_Bank
   jp .up_exit_final


.load_default_tile_top  ; much like above, but we don't have to worry about internal maps.

   ; start loading bgmap at halfscreen - pposx, if carry then 0
   ld A,[PPOSX]
   ld E,A
   ld A,$0B
   sub E
   jr nc,.skupdgtzt
   xor A
.skupdgtzt        ; another mnemonic, i think.
   ld E,A         ; E now holds the starting pos
   ld D,$98       ; there, DE points to the starting pos in the BG map
   ld A,$16
   sub E          ; $16 - startpoint = bytes to load
   ld C,A         ; C = bytes to load
   ; start loading bgmap at y = 0
   ; load halfscreen - pposy

   ld A,[PPOSY]
   ld B,A
   ld A,$0A
   sub B          ; in theory this'll never carry?
   ld B,A         ; B = y lines to load
                  ; load "C" default tiles, "B" times, to DE
   push BC        ; save it

   ld A,[MAPDEFAULTTILE]

.up_loading_default_lollapalooza
   ld [DE],A
   dec C
   jr nz,.up_loading_default_lollapalooza
   dec B
   jp z,.up_default_exit
   ld A,B         ; refresh the C register with
   pop BC         ; the count of tiles we need to load
   push BC
   ld B,A         ; B needs to be saved tho
   ld A,E         ; increment DE by $20
   add $20
   jr nc,.up_default_skip_inc_d
   inc D
.up_default_skip_inc_d
   jp .up_loading_lollapalooza 

.up_default_exit
   pop BC         ; get this off the stack

.up_exit_final    ; fokkin' hallelujah
   
   
 
   ; one problem to be accounted for is if the map dimensions are small enough that loading the current map and the surrounding map(s) aren't enought to cover the whole screen. therefore, starting at y = 0, load default tile from 0 to halfscreen - (y_dim + pposy).   

.skip_top

; upper_left load = 
;     ...load the upper_left map, starting with coords [left_x], [up_y], going to [dim_x] and [dim_y]
; left load = 
;     ...load the left map, starting with coords [left_x], [center_map_y], going to [dim_x] and [bottom of the screen or dim_y]
; upper load = 
;     ...load the upper map, starting with coords [center_map_x],[up_y], going to [right of the screen or dim_x],[dim_y]
; upper right load =
;     ... load the upper_right map, starting with coords [right_x], [up_y], going to [right of the screen],[dim_y]
; etc etc



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
