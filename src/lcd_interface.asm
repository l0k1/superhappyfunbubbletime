;LCD Interface and Graphics routines.

INCLUDE "defines.asm"

EXPORT   Wait_VBlank
EXPORT   Wait_VBlank_Beginning
EXPORT   Load_Tiles_Into_VRAM
EXPORT   Screen_Load_0_20x18
EXPORT   DMA
EXPORT   Background_Update
EXPORT   Disable_LCD

   SECTION "DMA",ROM0
   ;DMA: copies a dma routine to HRAM [$FF80], and then calls that routine.
   ;Interrupts are not enabled/disabled here.
   ;This routine destroys all registers.
   ;This routine overwrites $FF80 to $FF8A of HRAM.
   ;OAM_MIRROR_DMA is defined in globals.asm.
   ;556 cycles
DMA:
   ld HL,_HRAM
   ld BC,.dma_routine      ;we want the address that .dma_routine is at
   ld D,$0A                ;number of bytes in the .dma_routine
.load_dma_loop
   ld A,[BC]               ;copy .dma_loop to HRAM
   ld [HL+],A
   inc BC
   dec D
   jr nz,.load_dma_loop
   call _HRAM              ;call the DMA routine.
   ret
   
.dma_routine               ;this is the routine which will be copied to $FF80+
   ld A,HIGH(OAM_MIRROR)   ;2 bytes - this routine shouldn't be called directly.
   ldh [$46],A             ;2 bytes - need to be explicit with the "ldh". this is [rDMA]
   ld A,$28                ;2 bytes - waiting loop, 160 *micro*seconds
   dec A                   ;1 byte  -
   DB $20,$FD              ;2 bytes - opcode for jr nz,(go back to dec A) 
   ret                     ;1 byte

   SECTION "Wait VBlank",ROM0
   ;Wait for a VBlank. Exit if already in VBlank.
   ;IMPORTANT: This doesn't wait for the beginning of a VBlank.
   ;If waiting for the beginning is important, use the other wait function.
Wait_VBlank:
   push HL           ;we are using HL, so save the prior state
   ld HL,$FF41       ;load the address into HL
.loop
   bit 0,[HL]        ;check bit 0 in the stat register
   jr z,.loop        ;we want it to be 1. jump if 0.
   bit 1,[HL]        ;check bit 1 in the stat register.
   jr nz,.loop       ;we want it to be 0. jump if 1.
   ld A,[HL]
   cp $99            ;if LY is on it's last legs, we'll want to wait
                     ;until the next pass through, to prevent turning
                     ;off the LCD during not-vblank.
   jr z,.loop
   
   pop HL            ;return HL back
   ret               ;otherwise, we's good.

   SECTION "Wait VBlank Beginning",ROM0
   ;Wait for the beginning of a VBlank.
   ;This loop isn't good, use GFX_UPDATE flag instead.
Wait_VBlank_Beginning:
   push HL           ;save HL's state
   ld HL,rLY         ;load the LY register into HL for quicker accessing
   
.loop
   ld A,[HL]         ;check if LY is == 90. if it is, return.
   cp $90
   jr nz,.loop
   
   pop HL
   ret
   
   SECTION "Disable LCD",ROM0
   ; call this by setting bit 2 of GFX_UPDATE_FLAGS
Disable_LCD:
   ld HL,rLCDC                ; 12 cycles
   res 7,[HL]                 ; 16 cycles
   ret

   SECTION "20x18 Screen Load",ROM0
   ;Used for loading a map into the BG map area at $9800 that is 20x18 tiles.
   ;HL must be at the start of the tile data.
   ;Assumes rSCX & rSCY are at 0,0.
   ;LCD needs to remain on.
Screen_Load_0_20x18:
   ld DE,18                   ;this many y-lines.
   ld BC,_SCRN0-(12)          ;background tile map 0. subtracting 12, as it'll be added in again soon.
   call Wait_VBlank
.y_line_loop
   call Wait_VBlank           ;make sure we are still in vblank
   push DE                    ;Storing the Y-Line coord for later.
   ld DE,12                   ;first, we need to increase _SCRN0 location by 12*16, and ignore all the tiles off screen
.inc_bgmap_location
   inc BC
   dec DE
   ld A,E
   or D
   jp nz,.inc_bgmap_location
   
   ld DE,20                   ;x-length, 20 tiles at 16 bytes each
.x_line_loop
   call Wait_VBlank           ;make sure we are still in vblank
   ld A,[HL+]                 ;where the magic happens
   ld [BC],A
   inc BC
   dec DE
   ld A,E
   or D
   jp nz,.x_line_loop

   pop DE                     ;after we've got done loading an x-line, we need to check our y-line
   dec DE
   ld A,E
   or D
   jp nz,.y_line_loop
   ret


   SECTION "Load Tiles Into VRAM",ROM0
   ;Loads up tiles into VRAM.
   ;Currently overwrites all of VRAM.
   ;HL must point to tile 0
   ;DE is how many bytes to load into VRAM (# of tiles * $10)
   ;LCD needs to remain on
Load_Tiles_Into_VRAM:
   ld BC,_VRAM
.loop
   call Wait_VBlank
   ld A,[HL+]
   ld [BC],A
   inc BC
   dec DE
   ld A,D
   or E
   jr nz,.loop
   ret
   
   SECTION "Update Background",ROM0
   ; Used to load up the background at runtime.
   ; Put background updates at BG_UPDATE_ARRAY
   ; Data format for BG_UPDATE_ARRAY is 
   ; (low byte of address in bg Map) (high byte of address) (tile) (nop) - 4 bytes
   ; THIS CAN ONLY BE RAN IN VBLANK
   ; 1544 cycles in total.
Background_Update:
   ld [STACK_SAVE],SP               ; 20 cycles
   ld SP,BG_UPDATE_ARRAY_END - 1    ; 12 cycles
REPT 41                             ; 1476 cycles total
                                    ; 36 cycles per loop
   pop BC                           ; 12 cycles
   pop DE                           ; 12 cycles
   ld A,D                           ; 4 cycles
   ld [BC],A                        ; 8 cycles
ENDR
   ld HL,STACK_SAVE                 ; 12 cycles
   ld SP,HL                         ; 8 cycles
   ret                              ; 16 cycles
