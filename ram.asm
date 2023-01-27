;-----------------------------------------
; Zumi's MBC3/MBC30 Test ROM
; Memory
;-----------------------------------------

	section "ram", BSS[$c000]

wSuccessfulBanks::	db
wFailingBanks:: db
wLastBankTested::	db
wLastBankFailed:: db
wCGB_BGP:: ds 8 * 8
wActualByte:: db

	section "hram", HRAM

hVblankAcknowledged:: db
hGBType:: db
