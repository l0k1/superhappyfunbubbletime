;;;MAIN CHARACTER SPRITES WOO
;Done by hand, at work, in a spreadsheet. May create .gbr file later for DAT VISUAL.
;DOING THIS BY HAND TAKES FOREVS
;To make walking animation:
;   The second to last byte is $24. Alternate this between $20 and $04.
;   Will be done dynamically at runtime.

EXPORT Main_Char_Face_Down_Spr
EXPORT Main_Char_Face_Left_Spr
EXPORT Main_Char_Face_Right_Spr
EXPORT Main_Char_Face_Up_Spr

 SECTION "Main Character Sprites", HOME

Main_Char_Face_Down_Spr:
DB $00,$3C,$00,$3C,$3C,$24,$24,$18
DB $5A,$24,$00,$3C,$00,$3C,$24,$00

Main_Char_Face_Left_Spr:
DB $00,$3C,$00,$3C,$3C,$14,$34,$08
DB $5A,$24,$00,$3C,$00,$3C,$24,$00

Main_Char_Face_Right_Spr:
DB $00,$3C,$00,$3C,$3C,$28,$2C,$10
DB $5A,$24,$00,$3C,$00,$3C,$24,$00

Main_Char_Face_Up_Spr:
DB $00,$3C,$00,$3C,$3C,$00,$34,$00
DB $42,$3C,$00,$3C,$00,$3C,$24,$00
