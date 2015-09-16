; Code for the opening screens.
; I'd eventually like to do a fade in/out with these.
; Maybe have a "fade screen" function in main.asm I can call

IF !DEF(OPENING_SCREENS_ASM)
OPENING_SCREENS_ASM SET 1

INCLUDE "globals.asm"
INCLUDE "lcd_interface.asm"
INCLUDE "fonts.asm"

   SECTION "Splash_Screen",ROMX,BANK[1]
Splash_Screen::
   ;Not using a full-screen map for this.
   call LCD_Off      ; We are writing to VRAM
   ld HL,Font_Main   ; Loading up the main font into VRAM
   ld BC,_VRAM
   ld DE,$60 * $10   ; We want all the font, which has $5F chars.
.load_font_loop
   ld A,[HL+]
   ld [BC],A
   inc BC
   dec DE
   ld A,D
   or E
   jr nz,.load_font_loop

;fill up the first 5 rows with a solid block
   ld HL,_SCRN0      ; Loading the map into screen 0
   ld BC,Title_Screen_Map
   ld DE,32*5        ; 32 * 5 = first 5 rows
   ld B,$5F
   call Load_Blanks

;line 6, and the first 7 spaces of line 7, are blank.
   ld DE,32+7         ; One entire line + 7 on the next line
   ld B,0
   call Load_Blanks

;now load in "Klexos"
   ld BC,Title_Screen_Map
   ld E,6
   call Load_Chars

;now do 19+8 more blank spaces
   ld B,0
   ld DE,19+8
   call Load_Blanks

;now do "Game"
   ld BC,Title_Screen_Map + $06
   ld E,4
   call Load_Chars

;now do 20 + 7 more blank spaces
   ld B,0
   ld DE,20+7
   call Load_Blanks

;now do "Studio"
   ld BC,Title_Screen_Map + $0A
   ld E,6
   call Load_Chars

;19 + 32 * 2 (the next two lines) + 6 are blank
   ld B,0
   ld DE,32*2+19+6
   call Load_Blanks

;"presents"
   ld BC,Title_Screen_Map + $10
   ld E,8
   call Load_Chars

;18 + 32 more blanks
   ld B,0
   ld DE,32+18
   call Load_Blanks

;now lines 14-18 (5*32) are blocked out
   ld B,$5F
   ld DE,32*5
   call Load_Blanks

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
