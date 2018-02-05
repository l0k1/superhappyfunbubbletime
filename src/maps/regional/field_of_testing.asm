; Field of Testing regional map
; Just the main 32x32 field for now

; regional map format:
; $ID $XX $YY $TT
; $ID is the regional map ID (must be unique)
; $XX is the x dimension
; $YY is the y dimension
; $TT is the tileset

   SECTION "FoT Regional Map",RAMX,BANK[$101]

fot_regional_map_meta:
   DB $00   ; this map's ID
   DB $01   ; 1 map wide
   DB $01   ; 1 map high
   DB $00   ; tileset of $00
fot_regional_map:
   DB $01, $02
