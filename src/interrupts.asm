;Controller routines
;dulr - stseba
;JOYPAD data is stored as:
;   1 - pressed, 0 - not pressed
;   Bit 7 - Down
;   Bit 6 - Up
;   Bit 5 - Left
;   Bit 4 - Right
;   Bit 3 - Start
;   Bit 2 - Select
;   Bit 1 - B-button
;   Bit 0 - A-button

INCLUDE "globals.asm"
EXPORT Controller
EXPORT V_Blank_Int
EXPORT Timer_Update

   SECTION "Controller Status",ROM0
Controller:
   push AF           ;Push AF onto the stack to restore later.
   push BC           ;Push B onto the stack to restore later.
   ld A,%00100000    ;Load 0010 0000 into A.
   ld [rP1],A        ;We are checking P14 first.
   ld A,[rP1]
   ld A,[rP1]        ;Wait a few cycles, compensate for bounce.
   cpl               ;Complement A.
   and $0F           ;Only keep the LSB.
   swap A            ;Move those 4 bits up front.
   ld B,A            ;Store it in B
   ld A,%00010000    ;Load 0001 0000 into A.
   ld [rP1],A        ;Now check P15.
   ld A,[rP1]
   ld A,[rP1]
   ld A,[rP1]
   ld A,[rP1]
   ld A,[rP1]
   ld A,[rP1]        ;Wait a few cycles to compensate for bounce.
   cpl               ;Complement A.
   and $0F           ;Keep only the LSB.
   or B              ;Combine registers A and B into A.
   ld [JOYPAD],A     ;JOYPAD is a constant set in globals.asm
   ld A,%00110000    ;Deselect both P14 and P15.
   ld [rP1],A        ;Reset joypad.
   pop BC            ;Restore B.
   pop AF            ;Restore AF.
   ret               ;Exit

   SECTION "V Blank Interrupt",ROM0
   ; DMA and Background_Update are both in lcd_interface.asm
   ; VBlank lasts ~4530 cycles
   ; All code in the interrupt must be less than 4530 cycles
   ; If my counting is right, this is currently at a maximum
   ; of 2552 cycles if all code is ran.
   
                                 ; initial call is 24 cycles
V_Blank_Int:
   push AF                       ; 64 cycles for pushing
   push BC
   push DE
   push HL
   
   ld A,[GFX_UPDATE_FLAGS]       ; 16 cycles
   bit 0,A                       ; 8 cycles
   call nz,DMA                   ; 24 if condition - routine is 556 cycles
   bit 1,A                       ; 8 cycles
   call nz,Background_Update     ; 24 if condition - routine is 1668 cycles
   bit 2,A                       ; 8 cycles
   call nz,Disable_LCD           ; 24 if condition - routine is 28
   xor A                         ; 4 cycles
   ld [GFX_UPDATE_FLAGS],A       ; 16 cycles
   
   pop HL                        ; 48 cycles for popping
   pop DE
   pop BC
   pop AF
   
   ret                           ; 16 + 16 for reti in main.asm
   
   SECTION "Timer Update",ROM0
   ;keeping 4 timers running for usage.
   ;the numbers - seconds indicates how long 1 "tick" takes.
Timer_Update:

   push AF               ;push our registers
   push BC
   push DE
   push HL

   ;TIMERT is a temp timer, that can be freely reset.
   ;Same tick rate as TIMER1.
   ld A,[TIMERT]
   inc A
   ld [TIMERT],A

   ;00 - .0625 seconds
   ;01 - .0009765625 seconds
   ;10 - .00390625 seconds
   ;11 - .015625 seconds
   ld A,[TIMER1]
   inc A
   ld [TIMER1],A
   jp nz,.end
   
   ;00 - 16 seconds
   ;01 - .25 seconds
   ;10 - 1 second
   ;11 - 4 seconds
   ld A,[TIMER2]
   inc A
   ld [TIMER2],A
   jp nz,.end
   
   ;00 - 4096 seconds
   ;01 - 64 seconds
   ;10 - 256 seconds
   ;11 - 1024 seconds
   ld A,[TIMER3]
   inc A
   ld [TIMER3],A
   jp nz,.end
   
   ;00 - 1048576 seconds
   ;01 - 16384 seconds
   ;10 - 65536 seconds
   ;11 - 262144 seconds
   ld A,[TIMER4]
   inc A
   ld [TIMER4],A
   jp nz,.end
   
.end
   pop HL              ;restore dem registers.
   pop DE
   pop BC
   pop AF

   ret
