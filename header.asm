;-----------------------------------------
; Zumi's MBC3/MBC30 Test ROM
; Header data
;-----------------------------------------

	import Init

	section "entryPoint", HOME[$100]
	nop
	jp Init

	section "header", HOME[$134]
	db "MBC TESTING    "
	db $80 ; cgb enabled
	db "ZD" ; new licensee code
	db $00 ; sgb enable
	db $13 ; cart type
	db $00 ; rom size
	db $05 ; ram size
	db $01 ; international
	db $33 ; use new code
	db $00 ; rom version
	db 0   ; header chksum, handled by linker
	dw 0   ; global chksum, handled by linker
