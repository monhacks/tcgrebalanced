; return the turn holder's arena card's color in a, accounting for Pokemon Powers
GetArenaCardColor:
	xor a
;	fallthrough

; input: a = play area location offset (PLAY_AREA_*) of the desired card
; return the turn holder's card's color in a, accounting for Pokemon Powers
; preserves: hl, de, bc?
GetPlayAreaCardColor:
	push hl
	push de
	ld e, a
	add DUELVARS_ARENA_CARD_CHANGED_TYPE
	call GetTurnDuelistVariable
	bit HAS_CHANGED_COLOR_F, a
	jr nz, .has_changed_color
.regular_color
	ld a, e
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call GetCardIDFromDeckIndex
	call GetCardType
; OATS begin custom logic to support trainer subtypes
	; cp TYPE_TRAINER
	; jr nz, .got_type
	bit TYPE_TRAINER_F, a
	jr z, .got_type
; OATS end custom logic
	ld a, COLORLESS
.got_type
	pop de
	pop hl
	ret
.has_changed_color
	bit IS_PERMANENT_COLOR_F, a
	jr nz, .permanent_color
	ld a, e
	call CheckCannotUseDueToStatus_Anywhere
	jr c, .regular_color ; jump if can't use Shift
.permanent_color
	ld a, e
	add DUELVARS_ARENA_CARD_CHANGED_TYPE
	call GetTurnDuelistVariable
	pop de
	pop hl
	and $f
	ret

; return in a the weakness of the turn holder's arena or benchx Pokemon given the PLAY_AREA_* value in a
; if a == 0 and [DUELVARS_ARENA_CARD_CHANGED_WEAKNESS] != 0,
; return [DUELVARS_ARENA_CARD_CHANGED_WEAKNESS] instead
GetPlayAreaCardWeakness:
	or a
	jr z, GetArenaCardWeakness
	add DUELVARS_ARENA_CARD
	jr GetCardWeakness

; return in a the weakness of the turn holder's arena Pokemon
; if [DUELVARS_ARENA_CARD_CHANGED_WEAKNESS] != 0, return it instead
; preserves: bc, de
GetArenaCardWeakness:
	ld a, DUELVARS_ARENA_CARD_CHANGED_WEAKNESS
	call GetTurnDuelistVariable
	or a
	ret nz
	ld a, DUELVARS_ARENA_CARD
;	fallthrough

GetCardWeakness:
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Weakness]
	ret

; return in a the resistance of the turn holder's arena or benchx Pokemon given the PLAY_AREA_* value in a
; if a == 0 and [DUELVARS_ARENA_CARD_CHANGED_RESISTANCE] != 0,
; return [DUELVARS_ARENA_CARD_CHANGED_RESISTANCE] instead
GetPlayAreaCardResistance:
	or a
	jr z, GetArenaCardResistance
	add DUELVARS_ARENA_CARD
	jr GetCardResistance

; return in a the resistance of the arena Pokemon
; if [DUELVARS_ARENA_CARD_CHANGED_RESISTANCE] != 0, return it instead
GetArenaCardResistance:
	ld a, DUELVARS_ARENA_CARD_CHANGED_RESISTANCE
	call GetTurnDuelistVariable
	or a
	ret nz
	ld a, DUELVARS_ARENA_CARD
;	fallthrough

GetCardResistance:
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Resistance]
	ret


; convert a color to its equivalent WR_* (weakness/resistance) value
; preserves: hl, bc, de
TranslateColorToWR:
	push hl
	add LOW(InvertedPowersOf2)
	ld l, a
	ld a, HIGH(InvertedPowersOf2)
	adc $0
	ld h, a
	ld a, [hl]
	pop hl
	ret

InvertedPowersOf2:
	db $80, $40, $20, $10, $08, $04, $02, $01


; this function checks if turn holder's energy color override is active and,
; if so, turns all energies at wAttachedEnergies (except double colorless energies)
; into energies of the override color
; output:
;   a: total number of attached energies | $ff if no energy color override
; preserves: de
HandleEnergyColorOverride:
	; ld a, DUELVARS_ARENA_CARD
	; call GetTurnDuelistVariable
	; call GetCardIDFromDeckIndex
	; ld a, e
	; cp CHARIZARD
	; ret nz
	; call CheckCannotUseDueToStatus
	; ret c

	ld a, [wEnergyColorOverride]
	cp $ff
	ret z
	ld b, a

	ld hl, wAttachedEnergies
	ld c, NUM_COLORED_TYPES
	xor a
.zero_next_energy
	ld [hli], a
	dec c
	jr nz, .zero_next_energy
	ld c, b
	ld b, 0
	ld hl, wAttachedEnergies
	add hl, bc
	ld a, [wTotalAttachedEnergies]
	ld [hl], a
	ret
