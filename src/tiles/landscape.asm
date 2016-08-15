;landscape tiles - all the outdoor tiles!
;programmer art mostly. don't hate me!
;these have been done at work with paint/excel. 
;i need to put these into .gbr format, and upload for later use.

EXPORT grass1
EXPORT grass2
EXPORT flower1
EXPORT flower2
EXPORT boulder1
EXPORT tree1_upperleft
EXPORT tree1_lowerleft
EXPORT tree1_upperright
EXPORT tree1_lowerright
EXPORT rockwall_left
EXPORT rockwall_bottomleft
EXPORT rockwall_bottom
EXPORT rockwall_bottomright
EXPORT rockwall_right
EXPORT rockwall_topright
EXPORT rockwall_top
EXPORT rockwall_topleft


 SECTION "Normal Tileset - Grass Tiles", HOME

;grass1, standard grass tile
grass1:
DB $00,$00,$00,$00,$50,$00,$50,$00
DB $00,$00,$0A,$00,$0A,$00,$00,$00

;grass2, same as grass1 but upside down
grass2:
DB $00,$00,$0A,$00,$0A,$00,$00,$00
DB $00,$00,$00,$00,$50,$00,$50,$00

;flower1, some subdued flowers
flower1:
DB $00,$00,$20,$00,$50,$00,$24,$00
DB $0A,$00,$44,$00,$A0,$00,$40,$00

;flower2, mirrored flower1
flower2:
DB $00,$00,$04,$00,$0A,$00,$24,$00
DB $50,$00,$22,$00,$05,$00,$02,$00

;boulder1, just a big ol rock.
boulder1:
DB $3E,$3E,$C1,$C1,$89,$81,$85,$81
DB $A1,$81,$91,$81,$81,$81,$42,$7E

;tree1, a smallish deciduous tree. prime example of programmer art.
tree1_upperleft:
DB $0F,$0F,$30,$30,$42,$40,$91,$80
DB $8A,$80,$51,$40,$88,$80,$80,$80

tree1_lowerleft:
DB $60,$60,$1F,$1F,$04,$04,$04,$05
DB $04,$05,$04,$04,$04,$04,$08,$08

tree1_upperright:
DB $68,$68,$94,$94,$02,$02,$22,$02
DB $91,$01,$09,$01,$91,$01,$09,$01

tree1_lowerright:
DB $82,$82,$7C,$7C,$20,$20,$20,$20
DB $20,$60,$20,$60,$30,$30,$08,$08

rockwall_left:
DB $02,$02,$04,$04,$04,$04,$04,$04
DB $04,$04,$02,$02,$02,$02,$02,$02

rockwall_bottomleft:
DB $02,$02,$03,$03,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00

rockwall_bottom:
DB $00,$00,$CF,$CF,$30,$30,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00

rockwall_bottomright:
DB $40,$40,$C0,$C0,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00

rockwall_right:
DB $40,$40,$40,$40,$20,$20,$10,$10
DB $20,$20,$20,$20,$40,$40,$40,$40

rockwall_topright:
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$C0,$C0,$40,$40

rockwall_top:
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$26,$26,$D9,$D9,$00,$00

rockwall_topleft:
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$03,$03,$02,$02
