; Code for the opening screens.
; I'd eventually like to do a fade in/out with these.
; Maybe have a "fade screen" function in main.asm I can call

IF !DEF(OPENING_SCREENS_ASM)
OPENING_SCREENS_ASM SET 1

INCLUDE "globals.asm"
;INCLUDE "lcd_interface.asm"
INCLUDE "fonts.asm"


   SECTION "Splash_Screen",ROMX,BANK[1]
Splash_Screen::
   ;Not using a full-screen map for this.
   di
   call LCD_Off      ; We are writing to VRAM
   xor A             ; Set the bg screen coords to 0,0
   ld [rSCX],A
   ld [rSCY],A
   ld HL,Font_Main   ; Loading up the main font into VRAM
   ld DE,$60 * $10   ; We want all the font, which has $5F chars.
   call Load_Tiles_Into_VRAM  ; Load tiles into VRAM

;load in our variables, and call the load background subroutine.
   ld HL,Splash_Screen_Map
   call Screen_Load_0_20x18

;now we just need to turn the lcd back on again.
   ld A,%10010001    ;LCDC settings
   ld [rLCDC],A      ;load the settings.

;now exit the Splash_Screen function.
   ei
;and fade in.
   call Fade_In_Black

;we want this screen to display for ~2 seconds before fading out.
   xor A
   ld [TIMER1],A     ;reset timer1
.loop
   ld A,[TIMER1]
   cp $18            ;roughly a second and a half ($10 per second)
   jr nz,.loop
   call Fade_Out_Black

   ret

End_Splash_Screen::

   SECTION "Title Screen",ROMX,BANK[1]
   ;As this is being called right after Splash_Screen, we can assume that...
   ;The screen is faded out, interrupts are enabled,
   ;rSCX and rSCY are both at 0,
   ;and that the font info is still loaded into VRAM.
Title_Screen::
   di
   call LCD_Off
   
   ld HL,Title_Screen_Map
   call Screen_Load_0_20x18   ;load up our map
   
   ld A,%10010001             ;turn the LCD back on
   ld [rLCDC],A
   ei
   call Fade_In_Black         ;and now fade back in.

   xor A
   ld [TIMER1],A
.press_start_loop
   ld A,[JOYPAD]              ;first check if a not-directional button has been pressed.
   and $0F                    ;only care about first 4 bits.
   cp 0
   jp nz,.end
   ld A,[TIMER1]
   cp $10
   jr nz,.press_start_loop
   ;here, load in the "press start" text. wife is talking to me, can't think right now.
.wait
   ld A,[JOYPAD]
   and $0F
   cp 0
   jr z,.wait
.end
   call Fade_Out_Black
   ret

End_Title_Screen::

ENDC
