; Code for the opening screens.
; I'd eventually like to do a fade in/out with these.
; Maybe have a "fade screen" function in main.asm I can call.

   INCLUDE "main.asm"
   INCLUDE "fonts.asm"

   SECTION "Splash_Screen",ROMX,BANK[1]
Splash_Screen::
   ;Not using a full-screen map for this.
   call LCD_Off      ; We are writing to VRAM
   ld HL,Font_Main   ; Loading up the main font into VRAM
   ld BC,_VRAM
   ld E,$60          ; We want all the font, which has $5F chars.
.load_font_loop
   ld A,[HL+]
   ld [BC],A
   inc BC
   dec E
   or A
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
.klexos_loop
   ld A,[BC]
   ld [HL+],A
   dec E
   xor A
   cp E
   jr nz,.klexos_loop

;now do 19+8 more blank spaces
   ld B,0
   ld DE,19+8
   call Load_Blanks

;now do "Game"
   ld BC,Title_Screen_Map + $06
   ld E,4
.game_loop
   ld A,[BC]
   ld [HL+],A
   dec E
   xor A
   cp E
   jr nz,.game_loop

;now do 20 + 7 more blank spaces
   ld B,0
   ld DE,20+7
   call Load_Blanks

;A function for filling in with a certain tile
;Count needs to be in DE
;The tile needs to be in B
;HL needs to point at the BG Map area.
Load_Blanks:
.loop
   ld A,B
   ld [HL+],A
   ld A,E
   or D
   jr nz,.loop
   ret

End_Splash_Screen::