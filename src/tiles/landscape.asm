;landscape tiles - all the outdoor tiles!
;programmer art mostly. don't hate me!
;these have been done at work with paint/excel. 
;i need to put these into .gbr format, and upload for later use.

Export Normal_Landscape


 SECTION "Normal Tileset - Grass Tiles", HOME

Normal_Landscape:
;grass1, standard grass tile
DB $00,$00,$00,$00,$50,$00,$50,$00
DB $00,$00,$0A,$00,$0A,$00,$00,$00

;grass2, same as grass1 but upside down
DB $00,$00,$0A,$00,$0A,$00,$00,$00
DB $00,$00,$00,$00,$50,$00,$50,$00

;flower1, some subdued flowers
DB $00,$00,$20,$00,$50,$00,$24,$00
DB $0A,$00,$44,$00,$A0,$00,$40,$00

;flower2, mirrored flower1
DB $00,$00,$04,$00,$0A,$00,$24,$00
DB $50,$00,$22,$00,$05,$00,$02,$00

;boulder1, just a big ol rock.
DB $3E,$3E,$C1,$C1,$89,$81,$85,$81
DB $A1,$81,$91,$81,$81,$81,$42,$7E

;tree1, a smallish deciduous tree. prime example of programmer art.
;upperleft
DB $0F,$0F,$30,$30,$42,$40,$91,$80
DB $8A,$80,$51,$40,$88,$80,$80,$80

;lowerleft
DB $60,$60,$1F,$1F,$04,$04,$04,$05
DB $04,$05,$04,$04,$04,$04,$08,$08

;upperright
DB $68,$68,$94,$94,$02,$02,$22,$02
DB $91,$01,$09,$01,$91,$01,$09,$01

;lowerright
DB $82,$82,$7C,$7C,$20,$20,$20,$20
DB $20,$60,$20,$60,$30,$30,$08,$08

;rockwalls to do "mountains" or border areas
;left
DB $02,$02,$04,$04,$04,$04,$04,$04
DB $04,$04,$02,$02,$02,$02,$02,$02

;bottomleft
DB $02,$02,$03,$03,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00

;bottom
DB $00,$00,$CF,$CF,$30,$30,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00

;bottomright
DB $40,$40,$C0,$C0,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00

;right
DB $40,$40,$40,$40,$20,$20,$10,$10
DB $20,$20,$20,$20,$40,$40,$40,$40

;topright
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$C0,$C0,$40,$40

;rockwall_top
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$26,$26,$D9,$D9,$00,$00

;rockwall_topleft
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$03,$03,$02,$02
