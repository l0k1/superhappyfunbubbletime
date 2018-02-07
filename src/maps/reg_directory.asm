; high level regional map directory
; format for directory entries is as follows:
; $BANK ADDY
; ...where...
; BANK is the bank in which the regional map resides
; ADDY is the memory location in said bank. 

EXPORT reg_map_directory

   SECTION "Regional Map Directory",ROMX,BANK[$100]

reg_map_directory:

;ID #: 00 - field of testing, bank 101, addy 00
DB $01,$01, $00,$00
