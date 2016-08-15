;***************************************** SUPER HAPPY FUN BUBBLE TIME

INCLUDE  "globals.asm"

;***************************************** cartridge header

   SECTION  "Org $00",HOME[$00]
RST_00:  
   jp $100

   SECTION  "Org $08",HOME[$08]
RST_08:  
   jp $100

   SECTION  "Org $10",HOME[$10]
RST_10:
   jp $100

   SECTION  "Org $18",HOME[$18]
RST_18:
   jp $100

   SECTION  "Org $20",HOME[$20]
RST_20:
   jp $100

   SECTION  "Org $28",HOME[$28]
RST_28:
   jp $100

   SECTION  "Org $30",HOME[$30]
RST_30:
   jp $100

   SECTION  "Org $38",HOME[$38]
RST_38:
   jp $100

   SECTION  "V-Blank IRQ Vector",HOME[$40]
VBL_VECT:
   call V_Blank_Int
   reti
   
   SECTION  "LCD IRQ Vector",HOME[$48]
LCD_VECT:
   reti

   SECTION  "Timer IRQ Vector",HOME[$50]
TIMER_VECT:
   call Timer_Update
   reti

   SECTION  "Serial IRQ Vector",HOME[$58]
SERIAL_VECT:
   reti

   SECTION  "Joypad IRQ Vector",HOME[$60]
JOYPAD_VECT:
   call Controller                        ;in seperate file named "controller.asm"
   reti
   
   SECTION  "Start",HOME[$100]
   nop
   jp Main

   ; $0104-$0133 (Nintendo logo - do _not_ modify the logo data here or the GB will not run the program)
   DB $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
   DB $00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
   DB $BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

   ; $0134-$013E (Game title - up to 11 upper case ASCII characters; pad with $00)
   DB "SHFBT",0,0,0,0,0,0
      ;0123456789A

   ; $013F-$0142 (Product code - 4 ASCII characters, assigned by Nintendo, just leave blank)
   DB "    "
      ;0123

   ; $0143 (Color GameBoy compatibility code)
   DB $00   ; $00 - DMG 
         ; $80 - DMG/GBC
         ; $C0 - GBC Only cartridge

   ; $0144 (High-nibble of license code - normally $00 if $014B != $33)
   DB $0F

   ; $0145 (Low-nibble of license code - normally $00 if $014B != $33)
   DB $0F

   ; $0146 (GameBoy/Super GameBoy indicator)
   DB $00   ; $00 - GameBoy

   ; $0147 (Cartridge type - all Color GameBoy cartridges are at least $19)
   DB $1B   ; $1B - ROM + MBC5 + RAM + BATT

   ; $0148 (ROM size)
   DB $08   ; $08 - 64MBit = 8MByte = 512 Banks

   ; $0149 (RAM size)
   DB $04   ; $04 - 1 Mbit = 128kB = 16 Banks

   ; $014A (Destination code)
   DB $01   ; $01 - All others
         ; $00 - Japan

   ; $014B (Licensee code - this _must_ be $33)
   DB $33   ; $33 - Check $0144/$0145 for Licensee code.

   ; $014C (Mask ROM version - handled by RGBFIX)
   DB $00

   ; $014D (Complement check - handled by RGBFIX)
   DB $00

   ; $014E-$014F (Cartridge checksum - handled by RGBFIX)
   DW $00


;***************************************** INITIALIZATION

   SECTION "Initialization",HOME[$0150]
Main:

   di

   ld SP, $FFFF      ;init the stack pointer
   ld A,%11100100    ;set the pallete color to standard.
   ld [rBGP],A
   ld [rOBP0],A
   ld [rOBP1],A
   
   ;setup/start timers
   xor A
   ld [rIF],A        ;set all interrupt flags to 0.
   ld [rTMA],A       ;set timer modulo to zero
   ld A,%00000100    ;turn on timer, set it to 4.096 kHz
   ld [rTAC],A
   ld [rIE],A        ;set the timer interrupt flag.

   ld HL,$C000       ;init the internal ram from $C000 to $CFFF
   ld DE,$1000
.ram_init
   xor A
   ld [HL+],A
   dec DE
   ld A,E
   or D
   jp nz,.ram_init
   
   call DMA          ;clear out the OAM_RAM to all zeros.

   ld A,$01          ;make sure rom bank 1 is selected.
   ld [rROMB0],A
   xor A
   ld [rROMB1],A

   ld [VRAMSP],A     ;init ram pointers
   ld [OAMRAMP],A    ;see globals.asm for specifics
   ld [ERAMP],A
   ld [IRAMP],A
   
   ld A,$FF
   ld [VRAMP],A
   
   ei

;***************************************** OPENING SCREENS

;***** disabling the opning screens for quicker testing

   call Fade_Out_Black  ;fade out the nintendo logo
   
   ;call Splash_Screen   ;fade in a screen that says "klexos game studios presents", then fade it out.

   ;xor A                ;set the IF register to 0
   ld [rIF],A
   ld A,%00010100       ;set the timer and joypad interrupts
   ld [rIE],A

   ;call Title_Screen    ;fade in the title screen, wait for the player to press start, then fade it out.
   
   ;call Main_Menu       ;fade in the main menu. only "start game" will function for now. fades out.
   
   call Main_Game_Loop  ;the main loop of the game.
   
;***************************************** MAIN GAME LOOP
   SECTION "Main Game Loop",HOME
Main_Game_Loop:

.main_init              ;in the future, this'll be where the saves are loaded, etc.
                        ;right now, we're just loading up the testing arena, getting everything set up, etc.

   nop
   
   jp Main_Game_Loop
