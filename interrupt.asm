;-----------------------------------------
; Zumi's MBC3/MBC30 Test ROM
; Interrupts
;-----------------------------------------

	include "include/constants.inc"
	include "include/hardware.inc"

	import hVblankAcknowledged, hGBType, wCGB_BGP

	section "rst 0", HOME[$00]
rst_00:: nop
	reti

	section "rst 8", HOME[$08]
rst_08:: reti

	section "rst 10", HOME[$10]
rst_10:: reti

	section "rst 18", HOME[$18]
rst_18:: reti

	section "rst 20", HOME[$20]
rst_20:: reti

	section "rst 28", HOME[$28]
rst_28:: reti

	section "rst 30", HOME[$30]
rst_30:: reti

	section "rst 38", HOME[$38]
rst_38:: reti

	section "vblank", HOME[$40]
_vblank:: jp VBlank

	section "lcdc", HOME[$48]
_lcdc:: reti

	section "timer", HOME[$50]
_timer:: reti

	section "serial", HOME[$58]
_serial:: reti

	section "hilo", HOME[$60]
_hilo:: reti

	section "interrupts", HOME
VBlank::
	push af
; mark vblank acknowlegement
		ld a, 1
		ldh [hVblankAcknowledged], a

; update GBC palette if applicable
		ldh a, [hGBType]
		cp GAMEBOY_COLOR
		jr nz, .exit
		push hl
		push bc
			ld hl, wCGB_BGP
			ld b, 8 palettes
			ld a, $80
			ldh [rBGPI], a
.copy_gbc_pals
			ld a, [hl+]
			ldh [rBGPD], a
			dec b
			jr nz, .copy_gbc_pals
		pop bc
		pop hl
.exit
	pop af
	reti
