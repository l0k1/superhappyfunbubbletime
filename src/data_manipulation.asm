;manipulate that data, yo.

Include "globals.asm"

Export Copy_Data

   SECTION "Data Copier",ROM0
;To avoid having to repeat this function EVERYWHERE, here's a copier function.
;Data to be copied address in BC, destination in HL, how many bytes in DE.
;Obviously, this is destructive. Push/pop before calling if that's important.
Copy_Data:
.loop
   ld A,[BC]
   ld [HL+],A
   inc BC
   dec DE
   ld A,E
   or D
   jr nz,.loop
   ret
