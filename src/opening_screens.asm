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
   ld BC,_SCRN0      ; Loading the map into screen 0
   ld DE,32*5        ; 32 * 5 = first 5 rows
.first_five_loop
   ld A,$5F          ; $5F is the solid block char.
   ld [BC],A
   dec DE
   ld A,D
   or E
   jr nz,.first_five_loop

End_Splash_Screen::