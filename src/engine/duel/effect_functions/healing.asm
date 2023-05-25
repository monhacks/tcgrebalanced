; ------------------------------------------------------------------------------
; Healing
; ------------------------------------------------------------------------------

Heal10DamageEffect:
	ld hl, wDealtDamage
	ld a, [hli]
	or a
	ret z ; return if no damage dealt
	ld de, 10
	call ApplyAndAnimateHPRecovery
	ret

Heal20DamageEffect:
	ld hl, wDealtDamage
	ld a, [hli]
	or a
	ret z ; return if no damage dealt
	ld de, 20
	call ApplyAndAnimateHPRecovery
	ret

Heal30DamageEffect:
	ld hl, wDealtDamage
	ld a, [hli]
	or a
	ret z ; return if no damage dealt
	ld de, 30
	call ApplyAndAnimateHPRecovery
	ret

; applies HP recovery on Pokemon after an attack
; with HP recovery effect, and handles its animation.
; input:
;	d = damage effectiveness
;	e = HP amount to recover
ApplyAndAnimateHPRecovery:
	push de
	ld hl, wccbd
	ld [hl], e
	inc hl
	ld [hl], d

; get Arena card's damage
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
	pop de
	or a
	ret z ; return if no damage

; load correct animation
	push de
	ld a, ATK_ANIM_HEAL
	ld [wLoadedAttackAnimation], a
	ld bc, $01 ; arrow
	bank1call PlayAttackAnimation

; compare HP to be restored with max HP
; if HP to be restored would cause HP to
; be larger than max HP, cap it accordingly
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
	ld b, $00
	pop de
	ld a, DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	add e
	ld e, a
	ld a, 0
	adc d
	ld d, a
	; de = damage dealt + current HP
	; bc = max HP of card
	call CompareDEtoBC
	jr c, .skip_cap
	; cap de to value in bc
	ld e, c
	ld d, b

.skip_cap
	ld [hl], e ; apply new HP to arena card
	bank1call WaitAttackAnimation
	ret

; input:
;   e: amount to heal
HealUserHP_NoAnimation:
	push de
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
	or a
	pop de
	ret z ; no damage counters

	ld a, DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	add e
	cp c  ; c contains max HP from GetCardDamageAndMaxHP
	jr c, .store
	ld a, c  ; cap HP
.store
	ld [hl], a
	ret

; heals amount of damage in register e for card in
; Play Area location in [hTempPlayAreaLocation_ff9d], only if there is any
; damage to heal.
; plays healing animation and prints text with card's name.
; input:
;	   a: amount of HP to heal
;	  [hTempPlayAreaLocation_ff9d]: Play Area location of card to heal
HealPlayAreaCardHP_IfDamaged:
	ld d, a
	ldh a, [hTempPlayAreaLocation_ff9d]
	ld e, a
	call GetCardDamageAndMaxHP
	or a
	ret z ; no damage
	ld a, d
	; fallthrough

; heals amount of damage in register e for card in
; Play Area location in [hTempPlayAreaLocation_ff9d].
; plays healing animation and prints text with card's name.
; input:
;	   a: amount of HP to heal
;	  [hTempPlayAreaLocation_ff9d]: Play Area location of card to heal
HealPlayAreaCardHP:
	ld e, a
	ld d, $00

; play heal animation
	push de
	bank1call Func_7415
	ld a, ATK_ANIM_HEALING_WIND_PLAY_AREA
	ld [wLoadedAttackAnimation], a
	ldh a, [hTempPlayAreaLocation_ff9d]
	ld b, a
	ld c, $01
	ldh a, [hWhoseTurn]
	ld h, a
	bank1call PlayAttackAnimation
	bank1call WaitAttackAnimation
	pop hl

; print Pokemon card name and damage healed
	push hl
	call LoadTxRam3
; OATS trying to refactor some code
	; ld hl, $0000
	; call LoadTxRam2
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD
	call LoadCardNameAndLevelFromVarToRam2
	; call GetTurnDuelistVariable
	; call LoadCardDataToBuffer1_FromDeckIndex
	; ld a, 18
	; call CopyCardNameAndLevel
	; ld [hl], $00 ; terminating character on end of the name
	ldtx hl, PokemonHealedDamageText
	call DrawWideTextBox_WaitForInput
	pop de

; heal the target Pokemon
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	add e
	ld [hl], a
	ret

Heal10DamageFromAll_HealEffect:
	ld c, 10
	jr HealDamageFromAll

Heal20DamageFromAll_HealEffect:
	ld c, 20
	jr HealDamageFromAll

; Heals some damage to all friendly Pokémon in Play Area (Active and Benched).
; input:
;   c - amount to heal
HealDamageFromAll:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld d, a
	ld e, PLAY_AREA_ARENA

; go through every Pokemon in the Play Area and heal 10 damage.
.loop_play_area
; check its damage
	ld a, e
	ldh [hTempPlayAreaLocation_ff9d], a
	push bc
	call GetCardDamageAndMaxHP
	pop bc
	or a
	jr z, .next_pkmn ; if no damage, skip Pokemon

	cp c
	jr c, .heal ; is damage lower than amount to heal?
	ld a, c     ; heal at most c damage
.heal
	push de
	call HealPlayAreaCardHP
	pop de
.next_pkmn
	inc e
	dec d
	jr nz, .loop_play_area
	ret

HealingWind_InitialEffect:
	scf
	ret

HealingWind_PlayAreaHealEffect:
; play initial animation
	ldh a, [hTempPlayAreaLocation_ff9d]
	ld b, a
	ld c, $00
	ldh a, [hWhoseTurn]
	ld h, a
	bank1call PlayAttackAnimation
	bank1call WaitAttackAnimation
	ld a, ATK_ANIM_HEALING_WIND_PLAY_AREA
	ld [wLoadedAttackAnimation], a

	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld d, a
	ld e, PLAY_AREA_ARENA
.loop_play_area
	push de
	ld a, e
	ldh [hTempPlayAreaLocation_ff9d], a
	call GetCardDamageAndMaxHP
	or a
	jr z, .next_pkmn ; skip if no damage

; if less than 20 damage, cap recovery at 10 damage
	ld de, 20
	cp e
	jr nc, .heal
	ld e, a

.heal
; add HP to this card
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	add e
	ld [hl], a

; play heal animation
	ldh a, [hTempPlayAreaLocation_ff9d]
	ld b, a
	ld c, $01
	ldh a, [hWhoseTurn]
	ld h, a
	bank1call PlayAttackAnimation
	bank1call WaitAttackAnimation
.next_pkmn
	pop de
	inc e
	dec d
	jr nz, .loop_play_area
	ret