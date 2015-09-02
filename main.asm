;*	Blank Simple Source File
;*
;*	Includes
	INCLUDE	"gbhw.inc"

;*	user data (constants)
JOYPAD   EQU   $C000
;*	equates

;*	cartridge header

	SECTION	"Org $00",HOME[$00]
RST_00:	
	jp $100

	SECTION	"Org $08",HOME[$08]
RST_08:	
	jp $100

	SECTION	"Org $10",HOME[$10]
RST_10:
	jp $100

	SECTION	"Org $18",HOME[$18]
RST_18:
	jp $100

	SECTION	"Org $20",HOME[$20]
RST_20:
	jp $100

	SECTION	"Org $28",HOME[$28]
RST_28:
	jp $100

	SECTION	"Org $30",HOME[$30]
RST_30:
	jp $100

	SECTION	"Org $38",HOME[$38]
RST_38:
	jp $100

	SECTION	"V-Blank IRQ Vector",HOME[$40]
VBL_VECT:
	reti
	
	SECTION	"LCD IRQ Vector",HOME[$48]
LCD_VECT:
	reti

	SECTION	"Timer IRQ Vector",HOME[$50]
TIMER_VECT:
	reti

	SECTION	"Serial IRQ Vector",HOME[$58]
SERIAL_VECT:
	reti

	SECTION	"Joypad IRQ Vector",HOME[$60]
JOYPAD_VECT:
	reti
	
	SECTION	"Start",HOME[$100]
	nop
	jp Main

	; $0104-$0133 (Nintendo logo - do _not_ modify the logo data here or the GB will not run the program)
	DB	$CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
	DB	$00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
	DB	$BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

	; $0134-$013E (Game title - up to 11 upper case ASCII characters; pad with $00)
	DB	"SHFBT",0,0,0,0,0,0
		;0123456789A

	; $013F-$0142 (Product code - 4 ASCII characters, assigned by Nintendo, just leave blank)
	DB	"    "
		;0123

	; $0143 (Color GameBoy compatibility code)
	DB	$00	; $00 - DMG 
			; $80 - DMG/GBC
			; $C0 - GBC Only cartridge

	; $0144 (High-nibble of license code - normally $00 if $014B != $33)
	DB	$0F

	; $0145 (Low-nibble of license code - normally $00 if $014B != $33)
	DB	$0F

	; $0146 (GameBoy/Super GameBoy indicator)
	DB	$00	; $00 - GameBoy

	; $0147 (Cartridge type - all Color GameBoy cartridges are at least $19)
	DB	$1B	; $1B - ROM + MBC5 + RAM + BATT

	; $0148 (ROM size)
	DB	$08	; $08 - 64MBit = 8MByte = 512 Banks

	; $0149 (RAM size)
	DB	$04	; $04 - 1 Mbit = 128kB = 16 Banks

	; $014A (Destination code)
	DB	$01	; $01 - All others
			; $00 - Japan

	; $014B (Licensee code - this _must_ be $33)
	DB	$33	; $33 - Check $0144/$0145 for Licensee code.

	; $014C (Mask ROM version - handled by RGBFIX)
	DB	$00

	; $014D (Complement check - handled by RGBFIX)
	DB	$00

	; $014E-$014F (Cartridge checksum - handled by RGBFIX)
	DW	$00


;*	Program Start

	SECTION "Program Start",HOME[$0150]
Main::

	di

	ld SP, $FFFF		;init the stack pointer
	ld A,%11100100		;set the pallete color to standard.
	ld [$FF47],A

	ei

	jr Main

	SECTION "Wait VBlank",HOME
Wait_VBlank:
	ld HL,$FF41			;load the address into HL
.loop
	bit 0,[HL]			;check bit 0 in the stat register
	jr z,.loop			;we want it to be 1. jump if 0.
	bit 1,[HL]			;check bit 1 in the stat register.
	jr nz,.loop			;we want it to be 0. jump if 1.
	ld A,[HL]
	cp $99				;if LY is on it's last legs, we'll want to wait
							;until the next pass through, to prevent turning
							;off the LCD during vblank.
	jr z,.loop
	ret					;otherwise, we's good.

	SECTION "LCD Off",HOME	
LCD_Off:
	ld A,[$FF40]
	rlca
	ret nc			;Screen already off, return.

	call Wait_VBlank	;need to wait for vblank to turn off screen.

	ld A,[$FF40]		;load LCD controller data into A
	res 7,A			;set bit 7 of A to 0 to stop LCD.
	ld [$FF40],A		;reload A back into LCD controller
	ret

	SECTION "Controller Status",HOME
Controller:
	push AF		;Push AF onto the stack to restore later.
	push BC		;Push B onto the stack to restore later.
	ld A,%00100000	;Load 0010 0000 into A.
	ld [$FF00],A	;We are checking P14 first.
	ld A,[$FF00]
	ld A,[$FF00]	;Wait a few cycles, compensate for bounce.
	cpl		;Complement A.
	and $0F		;Only keep the LSB.
	swap A		;Move those 4 bits up front.
	ld B,A		;Store it in B
	ld A,%00010000	;Load 0001 0000 into A.
	ld [$FF00],A	;Now check P15.
	ld A,[$FF00]
	ld A,[$FF00]
	ld A,[$FF00]
	ld A,[$FF00]
	ld A,[$FF00]
	ld A,[$FF00]	;Wait a few cycles to compensate for bounce.
	cpl		;Complement A.
	and $0F		;Keep only the LSB.
	or B		;Combine registers A and B into A.
	ld [JOYPAD],A	;JOYPAD is a constant set to $FF80 at the top of this file.
	ld A,%00110000	;Deselect both P14 and P15.
	ld [$FF00],A	;Reset joypad.
	pop BC		;Restore B.
	pop AF		;Restore AF.
	ret		;Exit
