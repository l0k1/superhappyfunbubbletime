; Maps for the opening screens

IF !DEF(OPENING_MAPS_ASM)
OPENING_MAPS_ASM SET 1

   SECTION "Title_Screen_Map",ROMX,BANK[1]
Title_Screen_Map::
;the first 5 lines $5F
;line 6 is all $00
;line 7: "Klexos" (7 spaces before, 19 after)
DB $2B,$4C,$45,$58,$4F,$53
;line 8: "Game" (8 spaces before, 20 after)
DB $27,$41,$4D,$45
;line 9: "Studio" (7 spaces before, 19 after)
DB $33,$54,$55,$44,$49,$4F
;lines 10 - 11 are blank
;line 12: "Presents" (6 spaces before, 18 after)
DB $30,$52,$45,$53,$45,$4E,$54,$53
;line 13 is blank
;lines 14-18 are $5F
End_Title_Screen_Map::

ENDC