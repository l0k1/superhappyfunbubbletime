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

   SECTION "Camera Update",HOME
Camera_Update:
   ; tl;dr - load up the bg array with bg updates if needed
   ; assumes player can't be facing left/right at same time
   ; assumes player can't be facing up/down at same time
   ld A,[PPOSBIT]
   bit 0,A
   call move_y_down
   bit 1,A
   call move_x_left
   bit 2,A
   call move_y_up
   bit 3,A
   call move_x_right
   
   ret
   
move_x_right:
   ld A,[MAPY]             ; check if the tile to load is above/below map bounds
   ld B,A
   ld A,[PPOSY_MAP]
   cp B                    ; check below player
   jr nc,.check_x_bounds   ; if it is, check x bound
   cp $A                   ; check above player
   jr nc,.check_x_bounds
   
.check_x_bounds            ; only need to check to the right of player
   ld A,[MAPX]
   ld B,A
   ld A,[PPOSX_MAP]
   cp B
   jr nc,.no_default
   
   ld A,[PPOSX_MAP]        ; load the default tile
   ld A,[MAPDEFAULTTILE]
   jr .tdt_pos
.no_default
   ld A,[MAPUPPER]
   ld H,A
   ld A,[MAPLOWER]
   ld L,A
   
   ld A,[PPOST_MAP_U]      ; load players tile into DE
   ld D,A
   ld A,[PPOST_MAP_L]
   add $B                  ; increase it by 11 to get to the right side of the screen
   ld E,A
   jr nc,.skip0            ; check if add(x) = 0 results in carry flag
   inc D
.skip0
   
   ;left off here. trying to think of better way to do default tile.
   
   
.tdt_pos
   
   SECTION "Load Map Data",HOME
   ; Load the address of the map into BC, then call this function
   ; Assumes map meta data is in the following format:
   ; map x dimension most-significant byte, map x dimension least significant byte
   ; map y dimension MSB, map y dimension LSB
   ; map default tile
   ; then actual map layout data
   ; sets MAPUPPER and MAPLOWER to start of actual map data
Load_Map_Data:
    push AF
    push HL
    
    ld HL,MAPUPPER
    ld A,B
    ld [HL+],A      ; save map upper address
    ld A,C
    ld [HL+],A      ; save map lower address
    ld A,[BC]
    ld [HL+],A      ; map x msb dimension
    inc BC
    ld A,[BC]
    ld [HL+],A      ; map x lsb dimension
    inc BC
    ld A,[BC]
    ld [HL+],A      ; map y msb dimension
    inc bc
    ld A,[BC]
    ld [HL+],A      ; map y lsb dimension
    inc bc
    ld A,[BC]
    ld [HL+],A      ; map default tile
    
    pop HL
    pop AF
    ret
   
   
   SECTION "Screen Fades",HOME
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
