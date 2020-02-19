;* This file contains global variables/ram allocation

   SECTION "Globals",WRAM0
; Joypad Data, stored in format: 1 - button pressed, 0 - button not pressed.
JOYPAD:: DS 1
; Check main.asm for timing/interval info.
TIMERT:: DS 1
TIMER1:: DS 1
TIMER2:: DS 1
TIMER3:: DS 1
TIMER4:: DS 1
RANDOM1:: DS 1
RANDOM2:: DS 1
;RAM pointers
VRAMSP:: DS 1           ;vram sprite pointer (tdt1)
VRAMBP:: DS 1           ;vram bg pointer     (tdt2)
OAMRAMP:: DS 1           ;oam mirror ram pointer ($CF00)
ERAMPH:: DS 1           ;external ram pointer - high byte
ERAMPL:: DS 1           ;external ram pointer - low byte
IRAMPH:: DS 1           ;internal ram pointer - high byte
IRAMPL:: DS 1           ;internal ram pointer - low byte

; Store the address of which map/area we currently have loaded
MAPUPPER::  DS 1
MAPLOWER::  DS 1

; Map XY info
; map dimensions
MAPX::      DS 1
MAPY::      DS 1

MAP_TILESET::  DS 1

; currently loaded map bank
MAP_BANK::  DS 1
MAP_ADDR_U::   DS 1
MAP_ADDR_L::   DS 1

; Map default tile
MAPDEFAULTTILE:: DS 1

; Map x/y position currently loaded
; x/y of upper left-most tile
MAPXLOADED:: DS 1
MAPYLOADED:: DS 1


; Player position in the map
PPOSX::     DS 1        ; upper x coord of the tile the player is on
PPOSY::     DS 1        ; upper y coord
PPOSBIT::   DS 1        ; first four bits are which x pixel the player is at
                        ; second four bits are for the y pixel
PDIR::      DS 1        ; player direction - may include more data in this later
                        ; LSB:
                        ; %0001 -> player facing down
                        ; %0010 -> player facing left
                        ; %0100 -> player facing up
                        ; %1000 -> player facing right
PPOSX_SCREEN:: DS 1       ; X location of the player on the screen
PPOSY_SCREEN:: DS 1       ; Y location of the player on the screen
                        
CBANKU::    DS 1        ; current bank MSB
CBANKL::    DS 1        ; current bank LSB
PBANKU::    DS 1        ; previous bank MSB
PBANKL::    DS 1        ; previous bank LSB

; "dynamic" memory allocations, available to be rewritten
UNION

TEMP1::     DS 1
TEMP2::     DS 1
TEMP3::     DS 1
TEMP4::     DS 1
TEMP5::     DS 1

NEXTU

LD_MAP_BANK::        DS 1
MAPS_TO_LOAD_FLAGS:: DS 1
NUM_LOOPS::          DS 1
NUM_TILES_PER_LOOP:: DS 1
BG_MAP_INC::         DS 1
BG_MAP_X_LOADED::    DS 1
BG_MAP_Y_LOADED::    DS 1
BG_MAP_LOAD_MSB::    DS 1
BG_MAP_LOAD_LSB::    DS 1

ENDU
STACK_SAVE:: DS 2
;GFX update flags
;if bit 0 = 1, perform DMA update.
;if bit 1 = 1, perform background update.
;if bit 2 = 1, disable LCD
GFX_UPDATE_FLAGS:: DS 1

   SECTION "BG UPDATE ARRAY",WRAM0
; Array format is 
; (low byte of address in bg Map) (high byte of address) (tile) (nop)
BG_UPDATE_ARRAY:: DS 164
BG_UPDATE_ARRAY_END:: DS 1

   SECTION "OAM Mirror",WRAM0,ALIGN[8]
;OAM Mirror. Put sprite updates here.
OAM_MIRROR:: DS $A0
;same as OAM_MIRROR, but for use in the DMA routine.
;Used to update the background.
;format is (high byte of address in bg Map) (low byte of address) (tile) - 3 bytes
;there is exactly 41 ($29) bytes between here and $DF00, so just enough
;room with no overlap.
