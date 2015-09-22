;* This file contains global constants.

; Make sure all this data is only loaded once.
   IF !DEF(GLOBALS_ASM)
GLOBALS_ASM SET 1

; Joypad Data, stored in format: 1 - button pressed, 0 - button not pressed.
JOYPAD   EQU $C000
; Check main.asm for timing/interval info.
TIMERT   EQU $C001
TIMER1   EQU $C002
TIMER2   EQU $C003
TIMER3   EQU $C004
TIMER4   EQU $C005
RANDOM1  EQU $C006
RANDOM2  EQU $C007
;RAM pointers
VRAMPL   EQU $C008
VRAMPH   EQU $C009
OAMRAMPL EQU $C00A
OAMRAMPH EQU $C00B
WRAMPL   EQU $C00C
WRAMPH   EQU $C00D

;* Hardware definitions
;* Slimmed down, from Jeff Frohwein's include files.
;Global constants

_HW           EQU $FF00

_VRAM         EQU  $8000 ; $8000->$A000
_SCRN0        EQU  $9800 ; $9800->$9BFF
_SCRN1        EQU  $9C00 ; $9C00->$9FFF
_RAM          EQU  $C000 ; $C000->$E000
_OAMRAM       EQU  $FE00 ; $FE00->$FE9F
_AUD3WAVERAM  EQU  $FF30 ; $FF30->$FF3F
_HRAM         EQU  $FF80 ; $FF80->$FFFE
_WPRAM        EQU  _AUD3WAVERAM


; *** MBC5 Equates ***

rRAMG         EQU  $0000 ; $0000->$1fff
rROMB0        EQU  $2000 ; $2000->$2fff
rROMB1        EQU  $3000 ; $3000->$3fff
rRAMB         EQU  $4000 ; $4000->$5fff

;* Custom registers

; -- Register for reading joy pad info.    (R/W)
rP1 EQU $FF00

; -- Serial Transfer Data (R/W)
rSB EQU $FF01

; -- Serial I/O Control (R/W)
rSC EQU $FF02

; -- Divider register (R/W)
rDIV EQU $FF04

; -- Timer counter (R/W)
rTIMA EQU $FF05

; -- Timer modulo (R/W)
rTMA EQU $FF06

; -- Timer control (R/W)
rTAC EQU $FF07

; -- Interrupt Flag (R/W)
rIF EQU $FF0F

; -- LCD Control (R/W)
rLCDC EQU $FF40

; -- LCDC Status   (R/W)
rSTAT EQU $FF41

; -- Scroll Y (R/W)
rSCY  EQU $FF42

; -- Scroll X (R/W)
rSCX  EQU $FF43

; -- LCDC Y-Coordinate (R)
rLY EQU $FF44

; -- LY Compare (R/W)
rLYC  EQU $FF45

; -- DMA Transfer and Start Address (W)
rDMA  EQU $FF46

; -- BG Palette Data (W)
rBGP  EQU $FF47

; -- Object Palette 0 Data (W)
rOBP0 EQU $FF48

; -- Object Palette 1 Data (W)
rOBP1 EQU $FF49

; -- Window Y Position (R/W)
rWY EQU $FF4A

; -- Window X Position (R/W)
rWX EQU $FF4B

; -- Interrupt Enable (R/W)
rIE EQU $FFFF

;* Screen related
SCRN_X     EQU  160 ; Width of screen in pixels
SCRN_Y     EQU  144 ; Height of screen in pixels
SCRN_X_B   EQU  20  ; Width of screen in bytes
SCRN_Y_B   EQU  18  ; Height of screen in bytes

SCRN_VX    EQU  256 ; Virtual width of screen in pixels
SCRN_VY    EQU  256 ; Virtual height of screen in pixels
SCRN_VX_B  EQU  32  ; Virtual width of screen in bytes
SCRN_VY_B  EQU  32  ; Virtual height of screen in bytes

ENDC