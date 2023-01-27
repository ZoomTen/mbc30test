;-----------------------------------------
; Zumi's MBC3/MBC30 Test ROM
; Main Program
;-----------------------------------------

	include "include/hardware.inc"
	include "include/constants.inc"
	include "include/macros.inc"

	import Font, States
	import wSuccessfulBanks, wLastBankTested, wLastBankFailed, wFailingBanks
	import hVblankAcknowledged, hGBType, wCGB_BGP, wActualByte

	section "main", HOME[$150]
Init::
; set gameboy type
	ldh [hGBType], a

; clear WRAM
	di
	xor a
	ld hl, $c000
	ld b, ($e000-$c000)/$100
	call FillBlocks

; reset scroll
	ldh [rSCX], a
	ldh [rSCY], a

; set stack
	ld sp, $dfff

; init palettes
	ldh a, [hGBType]
	cp $11
	jr nz, .dmg
;.gbc
	ld hl, {
	RGB 31,31,31
	RGB 31,31,31
	RGB 31,31,31
	RGB 10,05,14
}
	ld de, wCGB_BGP
	ld bc, 1 palettes
	call Copy
	jr .palette_ok

.dmg
	ld a, %11100100
	ld [rBGP], a
	ld [rOBP0], a

.palette_ok
; reset audio
	ldh [rNR52], a

	call DisableLCD

; copy over graphics we need
	ld hl, Font
	ld de, vChars0 + ($20 tiles)
	ld bc, ($60 tiles)/2
	call CopyDouble

	ld hl, States
	ld de, vChars0
	ld bc, (2 tiles)/2
	call CopyDouble

; enable vblank only
	ld a, (1<<VBLANK)
	ldh [rIE], a
	ei

;----------------------------------------------------
;
; MBC30 4MB ROM Test (banks $00 - $ff)
;
;----------------------------------------------------

ROM_Test::
	call MakeHexTable

; put header
	ld de, vBGMap0
	ld hl, { db "ROM TEST@" }
	call PutString
	call ClearTestVariables
	call EnableLCD

; c = bank counter
	ld c, 0
.loop
; reset failed indicator
	xor a
	ld [wLastBankFailed], a

; get which bank to test
	ld a, c

; special cases
	and a
	jr z, .home ; bank 00

; check bank:4000, is it equal to the bank number?
	ld [MBC3RomBank], a
	ld a, [$4000]
	ld [wActualByte], a ; for checking
	cp c
	jr nz, .fail

.not_fail
	ld a, [wSuccessfulBanks]
	inc a
	ld [wSuccessfulBanks], a
	jr .increment

; contents differ
.fail
	ld a, 1
	ld [wLastBankFailed], a
	ld a, [wFailingBanks]
	inc a
	ld [wFailingBanks], a

.increment
	ld a, c
	ld [wLastBankTested], a
	call PlaceTestResult

	inc c
	jr nz, .loop
	jr .TellResult

.home
	ld a, [0]
	cp c
	jr nz, .fail
	jr .not_fail

.TellResult
	ld de, vBGMap0
	ld a, [wSuccessfulBanks]
	and a ; all banks
	jr z, .mbc30_ok
	cp 128
	jr z, .mbc1_3_ok
;	cp 16
;	jr z, .mbc2_ok
	jr .failed

.mbc30_ok
	ld a, [wFailingBanks]
	and a
	jr nz, .failed
	ld hl, { db "MBC30 ROM OK!@" }
	jr .put

.mbc1_3_ok
	ld hl, { db "MBC3 ROM OK!@" }
	jr .put

;.mbc2_ok
;	ld hl, { db "MBC2 ROM OK!@" }
;	jr .put

.failed
	ld hl, { db "UNKNOWN ROM FAIL@" }
	;jr .put
.put
	call PutString

;----------------------------------------------------
;
; MBC30 64kB SRAM Test (banks $00 - $07)
;
;----------------------------------------------------

	call Intermission
SRAM_Test::
	call MakeHexTable

; put header
	ld de, vBGMap0
	ld hl, { db "SRAM TEST@" }
	call PutString
	call ClearTestVariables
	call EnableLCD

; first, write bank numbers to SRAM
; c = bank counter
	ld c, 0
.write_loop
	call WaitVBlank
	ld a, c
	cp NUM_SRAM_BANKS
	jr z, .done_writing ; maxed out
	call OpenSRAM
	ld [$a000], a
	call WaitVBlank
	call CloseSRAM
	inc c
	jr nz, .write_loop

; then, verify that the bank numbers are right
; c = bank counter
.done_writing
	ld c, 0
.loop
	ld a, c
	cp NUM_SRAM_BANKS
	jr z, .TellResult ; maxed out

	call WaitVBlank
	ld a, c
	call OpenSRAM
	ld a, [$a000]
	ld [wActualByte], a ; for checking
	cp c
	jr nz, .fail

.not_fail
	ld a, [wSuccessfulBanks]
	inc a
	ld [wSuccessfulBanks], a
	jr .increment

.fail
	ld a, 1
	ld [wLastBankFailed], a
	ld a, [wFailingBanks]
	inc a
	ld [wFailingBanks], a

.increment
	ld a, c
	ld [wLastBankTested], a
	call PlaceTestResult
	call CloseSRAM

	inc c
	jr nz, .loop
	jr .TellResult

; if MBC30 is unsupported, the bank numbers
; will wrap around, e.g. SRAM 01 has 04 written to it,
; SRAM 02 = 05, etc.
.TellResult
	ld de, vBGMap0
	ld a, [wSuccessfulBanks]
	cp 8
	jr z, .mbc30_ok
	cp 4
	jr z, .mbc1_3_ok
	jr .failed
;	cp 16
;	jr z, .mbc2_ok

.mbc30_ok
	ld a, [wFailingBanks]
	and a
	jr nz, .failed
	ld hl, { db "MBC30 SRAM OK!@" }
	jr .put

.mbc1_3_ok
	ld hl, { db "MBC3 SRAM OK!@" }
	jr .put

;.mbc2_ok
;	ld hl, { db "MBC2 ROM OK!@" }
;	jr .put

.failed
	ld hl, { db "UNKNOWN SRAM FAIL@" }
	;jr .put
.put
	call PutString
	call Intermission
	jp ROM_Test

;----------------------------------------------------
;
; Helper functions
;
;----------------------------------------------------

Intermission::
	ld c, 60*4
	call WaitFrames
	jp DisableLCD

ClearTestVariables::
	xor a
	ld [wSuccessfulBanks], a
	ld [wFailingBanks], a
	ld [wLastBankTested], a
	ld [wLastBankFailed], a
	ret

;--
; @param	wLastBankTested	position of the result
; @param	wLastBankFailed	00 = show a ".", 01 = show a "X"
;--
PlaceTestResult::
	push bc
		ld hl, vBGMap0 + (SCREEN_WIDTH*2) + 3 ; starting point

; determine y position first
		ld a, [wLastBankTested]
; get upper nybble
		swap a
		and %1111
		jr z, .shift_x
		ld c, a
		ld de, SCREEN_WIDTH
.keep_shifting_down
		add hl, de ; y+1
		dec c
		jr nz, .keep_shifting_down

; then the x
.shift_x
		ld a, [wLastBankTested]
; get lower nybble
		and %1111
		jr z, .show_result ; don't shift right
		ld e, a
		ld d, 0 ; .
		add hl, de ; x+de
.show_result
		call WaitVBlank
		ld a, [wLastBankFailed]
		ld [hl], a
	pop bc
	ret

;;--
;; Prepare a row and column header marked with hex digits.
;;--
MakeHexTable::
	call ClearScreen
; horizontal hex table
	ld de, vBGMap0 + (SCREEN_WIDTH*1) + 3
	ld hl, { db "0123456789ABCDEF@" }
	call PutString
; vertical hex table
	ld de, vBGMap0 + (SCREEN_WIDTH*2) + 2
	ld hl, { db "0`1`2`3`4`5`6`7`8`9`A`B`C`D`E`F@" }
	call PutString
	ret

;----------------------------------------------------
;
; Utility functions
;
;----------------------------------------------------

;;--
;; Enable SRAM and switch to bank a
;; 
;; @param	a	SRAM bank
;;--
OpenSRAM::
	push af
; latch clock data
		ld a, 1
		ld [MBC3LatchClock], a
; enable sram/clock write
		ld a, SRAM_ENABLE
		ld [MBC3SRamEnable], a
	pop af
	ld [MBC3SRamBank], a
	ret

;;--
;; Disable SRAM
;;--
CloseSRAM::
	ld a, SRAM_DISABLE
	ld [MBC3LatchClock], a
	ld [MBC3SRamEnable], a
	ret


;;--
;; Clears 256 consecutive bytes with the
;; value of A for every cycle
;; 
;; @param	a	Value to clear with
;; @param	b	How many cycles to run
;; @param	hl	Where to start
;; 
;; @return	hl	(hl + (256 * b))
;; @return	bc	0
;;--
FillBlocks::
.clr1:
	ld c, $ff
.clr2:
	ld [hl+], a
	dec c
	jr nz, .clr2
	ld [hl+], a
	dec b
	ret z
	jr .clr1

;;--
;; Turns off the LCD with respect to VBlank.
;;--
DisableLCD::
	di
.wait
	ld a, [rLY]
	cp LY_VBLANK
	jr nc, .disable
	jr .wait
.disable
	ld a, [rLCDC]
	res LCD_ENABLE_BIT, a
	ld [rLCDC], a
	reti

;;--
;; Turn on the screen with a saved preset.
;;--
EnableLCD::
	ld a, LCD_ENABLE | LCD_WIN_DISABLE | LCD_SET_8000 | LCD_MAP_9800 | LCD_OBJ_DISABLE | LCD_BG_ENABLE
	ldh [rLCDC], a
	ret

;;--
;; Wait C number of frames.
;; 
;; @param	c	amount of frames to wait (> 0)
;;--
WaitFrames::
.wait
	call WaitVBlank
	dec c
	jr nz, .wait
	ret

;;--
;; Wait until the next VBlank.
;;--
WaitVBlank::
	ld a, 0
	ldh [hVblankAcknowledged], a
.wait
	halt
	nop
	ldh a, [hVblankAcknowledged]
	cp 1
	ret nc
	jr .wait

;;--
;; Copies a block of data, but each byte is doubled.
;; Used to copy 1bpp data to VRAM.
;; 
;; @param	hl	Source
;; @param	de	Destination
;; @param	bc	Length of source
;;--
CopyDouble::
.loop:
	ld a, [hl+]
	ld [de], a
	inc de
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	ret z
	jr .loop

;;--
;; Copies a block of data from de to hl for bc bytes.
;; 
;; @param	hl	Source
;; @param	de	Destination
;; @param	bc	Length of source
;;--
Copy::
.loop
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, c
	or b
	jr nz, .loop
	ret

;;--
;; Clears BG map 0. Best used when the screen is disabled.
;;--
ClearScreen::
	ld a, " "
	ld hl, vBGMap0
	ld b, (vBGMap1-vBGMap0)/$100
	jp FillBlocks

;;--
;; Prints a string pointed by HL at DE.
;; Special commands are: @ (terminate) and ` (new line)
;; 
;; @param	hl	Source
;; @param	de	Dest
;;--
PutString::
	push de
.loop
		ld a, [hl+]
		cp "@"
		jr z, .done ; @ = string terminator
		cp "`"
		jr nz, .no_line
; ` = move down 1 line
		ld a, [hl+]
	pop de
	push hl
		ld hl, SCREEN_WIDTH
		add hl, de
		ld d, h
		ld e, l
	pop hl
	push de
.no_line
		ld [de], a
		inc de
		jr .loop
.done
	pop de
	ret

