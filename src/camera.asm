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
   ;first find the upper left X position on the map
   ld HL,PPOSX
   ld A,[HL+]
   sub $0F
   ld B,A
   ld A,[MAPXLOADED]
   cp B                    ; if the X pos of the up-left tile doesn't match,
   jp nz,.update_map       ; then we need to do a map update
   ld A,[HL+]              ; HL should be pointed at PPOSY
   sub $0F
   ld B,A
   ld A,[MAPYLOADED]
   cp B
   jp nz,.update_map       ; same thing, but checking the Y pos
.positional_shift_x        ; now make sure that the x/y pixel setting is where we want it
   ld A,[HL]               ; HL should be pointed at PPOSBIT
   and $0F
   ld B,A
   ld A,[PPOSBIT]
   ld C,A
   and $0F
   cp B
   jp nz,camera_shift_x_bit
.positional_shift_y        ; check y pixel
   ld A,[HL+]              ; HL still pointed at PPOSBIT
   and $F0
   ld B,A
   ld A,C
   and $F0
   cp B
   jp nz,.camera_shift_y_bit
.directional_shift         ; make sure the camera is pointed in the right direction
   ld A,[rSCX]             ; store current screen X/Y values in B/C
   ld B,A
   ld A,[rSCY]
   ld C,A
   ld A,[HL]               ; HL should be pointed at PDIR
   bit 1,A                 ; only check bits for left/up/right,
   jp nz,.c_left           ; camera down will be default if nothing else
   bit 2,A
   jp nz,.c_up
   bit 3,A
   jp nz,.c_right

; move by length_to_destination / 2 every iteration
; D = desired X, E = desired Y
.c_down
   ld D,$2C
   ld E,$4C
   jp .move_camera_pixels

.c_left
   ld D,$11
   ld E,$34
   jp .move_camera_pixels

.c_right
   ld D,$44
   ld E,$34
   jp .move_camera_pixels
   
.c_up
   ld D,$44
   ld E,$2E

.move_camera_pixels
   ld A,D
   sub B
   jr z,.y
   jr nc,.x_cont
   cpl
   add A,$1
.x_cont
   rrca
   add A,B
   ld [rSCX],A
.y
   ld A,E
   sub C
   jp z,.exit
   jr nc,.y_cont
   cpl
   add A,$1
.y_cont
   rrca
   add A,C
   ld [rSCY],A
   jp .exit

.exit
   ret
   
   SECTION "Load Map Data",HOME
   ; Load the address of the map into BC, then call this function
   ; Assumes map meta data is in the following format:
   ; map x dimension most-significant byte, map x dimension least significant byte
   ; map y dimension MSB, map y dimension LSB
   ; map default tile
   ; then actual map layout data
   ; sets MAPUPPER and MAPLOWER to start of actual map data
Load_Map_Data
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
