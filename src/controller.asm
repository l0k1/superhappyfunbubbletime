;Controller routines

IF !DEF(CONTROLLER_ASM)
CONTROLLER_ASM SET 1

   SECTION "Controller Status",HOME
Controller::
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
End_Controller::

ENDC