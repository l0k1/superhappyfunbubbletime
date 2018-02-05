; high level regional map directory
; format for directory entries is as follows:
; $ID BANK ADDY
; ...where...
; ID is the regional map's ID
; BANK is the bank in which the regional map resides
; ADDY is the memory location in said bank. 

   SECTION "Regional Map Directory",ROMX,BANK[$100]

reg_map_directory:

;field of testing, bank 101, addy 00
DB $00, $01,$01, $00,$00
