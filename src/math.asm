; Math functions

EXPORT Mul8
EXPORT Mul8b
EXPORT Mul16
EXPORT Div8

   SECTION "Math",HOME
   ;Multiplies DE and A, stores result in HL.
   ;Destructive
   ;taken from http://sgate.emt.bme.hu/patai/publications/z80guide/part4.html
   ;with modifications specific to gbz80
Mul8:
   xor H
   xor L
   ld B,8
.mul8loop
   rrca
   jr nc,.mul8skip
   add HL,DE
.mul8skip
   sla E
   rl D
   dec B
   jr nz,Mul8
   ret
    
   ;Multiply H * E, stores result in HL
   ;Destructive
   ;taken from http://sgate.emt.bme.hu/patai/publications/z80guide/part4.html
   ;with modifications specific to gbz80
Mul8b:
   xor D
   xor L
   ld B,8
.mul8bloop
   add hl,hl                      ; advancing a bit
   jp nc,.mul8bskip
   add hl,de
.mul8bskip
   dec B
   jr nz,.mul8bloop
   ret
  
   ;Divide HL/D, store result in HL
   ;Destructive
   ;taken from http://sgate.emt.bme.hu/patai/publications/z80guide/part4.html
   ;with modifications specific to gbz80
Div8:
   xor A
   ld B,16
.div8loop
   add HL,HL
   rla
   cp D
   jr c,.div8nextbit
   sub D
   inc l
.div8nextbit
   dec B
   jr nz,.div8loop
   ret
   
   ;Multiply BC and DE, store the result in DE, HL
   ;Destructive
   ;taken from http://sgate.emt.bme.hu/patai/publications/z80guide/part4.html
   ;with modifications specific to gbz80
Mul16:
   xor H
   xor L
   ld a,16
.mul16loop
   add hl,hl
   rl e
   rl d
   jr nc,.nomul16
   add hl,bc
   jr nc,.nomul16
   inc de
.nomul16
   dec a
   jr nz,.mul16loop
   ret
