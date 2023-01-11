;-----------------------------------------
; Zumi's MBC3/MBC30 Test ROM
; Memory
;-----------------------------------------

	section "ram", BSS[$c000]

wSuccessfulBanks::	db
wFailingBanks:: db
wLastBankTested::	db
wLastBankFailed:: db

	section "hram", HRAM

hVblankAcknowledged:: db

