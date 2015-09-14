;LCD Interface routines.

IF !DEF(LCD_INTERFACE_ASM)
LCD_INTERFACE_ASM SET 1

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

ENDC