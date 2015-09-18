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
   ret

;A function for loading up the chars.
;HL is the location in the BG map.
;BC needs to be the start address.
;E needs to be the number of letters.
Load_Chars:
.loop
   ld A,[BC]
   ld [HL+],A
   inc BC
   dec DE
   ld A,E
   or D
   jr nz,.loop
   ret

;A function for filling in with a certain tile
;Count needs to be in DE
;The tile needs to be in B
;HL needs to point at the BG Map area.
Load_Blanks:
.loop
   ld A,B
   ld [HL+],A
   dec DE
   ld A,E
   or D
   jr nz,.loop
   ret

End_Splash_Screen::

ENDC
