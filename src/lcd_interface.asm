;LCD Interface and Graphics routines.

IF !DEF(LCD_INTERFACE_ASM)
LCD_INTERFACE_ASM SET 1

INCLUDE "globals.asm"

   SECTION "Wait VBlank",HOME
Wait_VBlank:
   ld HL,$FF41       ;load the address into HL
.loop
   bit 0,[HL]        ;check bit 0 in the stat register
   jr z,.loop        ;we want it to be 1. jump if 0.
   bit 1,[HL]        ;check bit 1 in the stat register.
   jr nz,.loop       ;we want it to be 0. jump if 1.
   ld A,[HL]
   cp $99            ;if LY is on it's last legs, we'll want to wait
                     ;until the next pass through, to prevent turning
                     ;off the LCD during vblank.
   jr z,.loop
   ret               ;otherwise, we's good.

   SECTION "LCD Off",HOME  
LCD_Off:
   ld A,[$FF40]
   rlca
   ret nc            ;Screen already off, return.

   call Wait_VBlank  ;need to wait for vblank to turn off screen.

   ld A,[$FF40]      ;load LCD controller data into A
   res 7,A           ;set bit 7 of A to 0 to stop LCD.
   ld [$FF40],A      ;reload A back into LCD controller
   ret

   SECTION "20x18 Screen Load",HOME
   ;Used for loading a map into the BG map area at $9800 that is 20x18 tiles.
   ;HL must be at the start of the tile data.
   ;Assumes rSCX & rSCY are at 0,0.
Screen_Load_0_20x18::
   ld DE,18                   ;this many y-lines.
   ld BC,_SCRN0-(12)          ;background tile map 0. subtracting 12, as it'll be added in again soon.
.y_line_loop
   push DE           ;Storing the Y-Line coord for later.
   ld DE,12          ;first, we need to increase _SCRN0 location by 12*16, and ignore all the tiles off screen
.inc_bgmap_location
   inc BC
   dec DE
   ld A,E
   or D
   jp nz,.inc_bgmap_location
   
   ld DE,20          ;x-length, 20 tiles at 16 bytes each
.x_line_loop
   ld A,[HL+]        ;where the magic happens
   ld [BC],A
   inc BC
   dec DE
   ld A,E
   or D
   jp nz,.x_line_loop

   pop DE            ;after we've got done loading an x-line, we need to check our y-line
   dec DE
   ld A,E
   or D
   jp nz,.y_line_loop
   ret


   SECTION "Load Tiles Into VRAM",HOME
   ;Loads up tiles into VRAM.
   ;Currently overwrites all of VRAM.
   ;HL must point to tile 0
   ;DE is how many bytes to load into VRAM (# of tiles * $10)
Load_Tiles_Into_VRAM::
   ld BC,_VRAM
.loop
   ld A,[HL+]
   ld [BC],A
   inc BC
   dec DE
   ld A,D
   or E
   jr nz,.loop
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
   xor A                      ;zero out timer 1
   ld [TIMER1],A
.loop
   ld A,[TIMER1]              ;wait 3 ticks, then load background data
   cp 3
   jp nz,.loop
   pop AF                     ;load our background data
   ld [rBGP],A
   dec D
   jp nz,Fade_Loop            ;if our count isn't zero, return
   push HL                    ;put the return address back on the stack
   ret

ENDC
