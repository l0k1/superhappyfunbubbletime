; Code for the opening screens.
; I'd eventually like to do a fade in/out with these.

INCLUDE "globals.asm"
EXPORT  Title_Screen
EXPORT  Splash_Screen
EXPORT  Main_Menu


   SECTION "Splash_Screen",ROMX,BANK[1]
Splash_Screen:
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
   ld [TIMERT],A     ;reset timer1
.loop
   ld A,[TIMERT]
   cp $18            ;roughly a second and a half ($10 per second)
   jr nz,.loop
   call Fade_Out_Black

   ret

   SECTION "Title Screen",ROMX,BANK[1]
   ;As this is being called right after Splash_Screen, we can assume that...
   ;The screen is faded out, interrupts are enabled,
   ;rSCX and rSCY are both at 0,
   ;and that the font info is still loaded into VRAM.
   
Title_Screen:
   di
   call LCD_Off
   
   ld HL,Title_Screen_Map
   call Screen_Load_0_20x18   ;load up our map
   
   ld A,%10010001             ;turn the LCD back on
   ld [rLCDC],A
   ei
   call Fade_In_Black         ;and now fade back in.

   xor A
   ld [TIMERT],A
.press_start_loop
   ld A,[JOYPAD]              ;first check if a not-directional button has been pressed.
   and $0F                    ;only care about first 4 bits.
   cp 0
   jp nz,.end
   ld A,[TIMERT]
   cp $10
   jr nz,.press_start_loop

   call LCD_Off               ;time to load the "press start" text
   ld HL,_SCRN0+(32*11)+4    ;this is where i want the lettering to start
   ld A,$50                   ;gonna unroll this one, $50 is "p"
   ld [HL+],A
   ld A,$52                   ;"r"
   ld [HL+],A
   ld A,$45                   ;"e"
   ld [HL+],A
   ld A,$53
   ld [HL+],A
   ld [HL+],A
   xor A
   ld [HL+],A
   ld A,$53
   ld [HL+],A
   ld A,$54
   ld [HL+],A
   ld A,$41
   ld [HL+],A
   ld A,$52
   ld [HL+],A
   ld A,$54
   ld [HL+],A

   ld A,%10010001             ;time to turn the LCD back on
   ld [rLCDC],A


.wait
   ld A,[JOYPAD]
   and $0F
   cp 0
   jr z,.wait
.end
   call Fade_Out_Black
   ret

   SECTION "Main Menu",ROMX,BANK[1]
Main_Menu:
   di
   call LCD_Off
   
   ld HL,Main_Menu_Map
   call Screen_Load_0_20x18
   
   ld A,%10010001                ;turn the LCD back on
   ld [rLCDC],A
   
                                 ;need to load a sprite here as a pointer. can't do that till the map is done.
   
   ei
   call Fade_In_Black

.input_wait_loop
   ld A,[JOYPAD]
   
   bit J_DOWN,A
   jp nz,.down_pressed

   bit J_UP,A
   jp nz,.up_pressed
   
   bit J_A,A
   jp nz,.menu_item_select
   bit J_START,A
   jp nz,.menu_item_select
   bit J_SELECT,A
   jp nz,.menu_item_select
   
   jr .input_wait_loop
   
.down_pressed
   ;move the sprite
   jp .delay
.up_pressed
   ;move the sprite
   jp .delay

.delay
   xor A
   ld [TIMERT],A
.delay_loop
   ld A,[TIMERT]
   cp 2
   jr nz,.delay_loop
   jp .input_wait_loop

.menu_item_select
   ;check which menu item.
   
