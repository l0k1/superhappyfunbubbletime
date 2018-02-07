;manipulate that data, yo.

Include "globals.asm"

Export Copy_Data
Export Switch_Bank
Export Return_Bank

   SECTION "Data Copier",ROM0
   ; To avoid having to repeat this function EVERYWHERE, here's a copier function.
   ; Data to be copied address in BC, destination in HL, how many bytes in DE.
   ; Obviously, this is destructive. Push/pop before calling if that's important.
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

   SECTION "Bank Switcher",ROM0
   ; Save the current bank in a memory spot so we can go back to it later
   ; The bank to be switched to should be in DE.
Switch_Bank:
   pop AF
   pop HL
   
   ; first switch the current bank to the previous bank in RAM
   ld HL,CBANKU
   ld A,[HL+]
   ld [PBANKU],A
   ld A,[HL]
   ld [PBANKL],A
   
   ; next, put DE into CBANKU and CBANKL, and switch banks
   ld A,D
   ld [CBANKU],A
   ld [rROMB1],A
   ld A,E
   ld [CBANKL],A
   ld [rROMB0],A
   
   push HL
   push AF
   ret
   
   SECTION "Return to Previous Bank",ROM0
   ; Switch the current bank to the previous bank.
Return_Bank:
   pop AF
   pop DE
   pop HL
   
   ; save the current bank we are in to DE
   ld HL,CBANKU
   ld D,[HL]
   inc HL
   ld E,[HL]
   
   ; switch the bank to the previous bank and write that to the current bank
   ld HL,PBANKU
   ld A,[HL]
   ld [rROMB1],A
   ld [CBANKU],A
   ld [HL],D         ; update PBANKU with the old CBANKU
   
   ; now the same with PBANKL
   inc HL
   ld A,[HL]
   ld [rROMB0],A
   ld [CBANKL],A
   ld [HL],E         ; update PBANKL with the old CBANKL
   
   push HL
   push DE
   push AF
   
   ret