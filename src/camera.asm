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
   
   ; first get the correct bank
   pop AF
   ld D,$01
   ld E,A
   call Switch_Bank

   ; put the mem position into HL and extract data
   pop HL
   ld A,[HL+]
   ld [MAPX],A
   ld A,[HL+]
   ld [MAPY],A
   ld A,[HL+]
   ld [MAP_TILESET],A

   ; get the player x/y position
   pop BC
   ld A,B
   ld [PPOSX],A
   ld A,C
   ld [PPOSY],A

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
