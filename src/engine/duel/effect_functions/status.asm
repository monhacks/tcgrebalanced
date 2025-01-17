; ------------------------------------------------------------------------------
; Status Effects
; ------------------------------------------------------------------------------

ParalysisIfSelectedCardEffect:
	ldh a, [hTemp_ffa0]
	cp $ff
	ret z  ; nothing to do
	jr ParalysisEffect


PoisonEffect: ; 2c007 (b:4007)
	lb bc, CNF_SLP_PRZ, POISONED
	jr ApplyStatusEffect

; Defending Pokémon becomes double poisoned (takes 20 damage per turn rather than 10)
DoublePoisonEffect:
	lb bc, CNF_SLP_PRZ, DOUBLE_POISONED
	jr ApplyStatusEffect

; Defending Pokémon becomes burned
BurnEffect:
	lb bc, CNF_SLP_PRZ, BURNED
	jr ApplyStatusEffect

Paralysis50PercentEffect: ; 2c011 (b:4011)
	ldtx de, ParalysisCheckText
	call TossCoin_BankB
	ret nc

ParalysisEffect: ; 2c018 (b:4018)
	lb bc, PSN_DBLPSN_BRN, PARALYZED
	jr ApplyStatusEffect

Confusion50PercentEffect: ; 2c01d (b:401d)
	ldtx de, ConfusionCheckText
	call TossCoin_BankB
	ret nc

ConfusionEffect: ; 2c024 (b:4024)
	lb bc, PSN_DBLPSN_BRN, CONFUSED
	jr ApplyStatusEffect

Sleep50PercentEffect: ; 2c029 (b:4029)
	ldtx de, SleepCheckText
	call TossCoin_BankB
	ret nc

SleepEffect: ; 2c030 (b:4030)
	lb bc, PSN_DBLPSN_BRN, ASLEEP
	jr ApplyStatusEffect


ApplyStatusEffect: ; 2c035 (b:4035)
	ldh a, [hWhoseTurn]
	ld hl, wWhoseTurn
	cp [hl]
	jr nz, .can_induce_status
	ld a, [wTempNonTurnDuelistCardID]
	cp CLEFAIRY_DOLL
	jr z, .cant_induce_status
	cp MYSTERIOUS_FOSSIL
	jr z, .cant_induce_status
	; Snorlax's Thick Skinned prevents it from being statused...
	cp SNORLAX
	jr nz, .can_induce_status
	call SwapTurn
	; ...unless already so, or if affected by Toxic Gas
	call CheckCannotUseDueToStatus
	call SwapTurn
	jr c, .can_induce_status

.cant_induce_status
	ld a, c
	ld [wNoEffectFromWhichStatus], a
	call SetNoEffectFromStatus
	or a
	ret

.can_induce_status
	ld hl, wEffectFunctionsFeedbackIndex
	push hl
	ld e, [hl]
	ld d, $0
	ld hl, wEffectFunctionsFeedback
	add hl, de
	call SwapTurn
	ldh a, [hWhoseTurn]
	ld [hli], a
	call SwapTurn
	ld [hl], b ; mask of status conditions not to discard on the target
	inc hl
	ld [hl], c ; status condition to inflict to the target
	pop hl
	; advance wEffectFunctionsFeedbackIndex
	inc [hl]
	inc [hl]
	inc [hl]
	scf
	ret


; ------------------------------------------------------------------------------
; Status Attacks
; ------------------------------------------------------------------------------

; Poison; Confusion if Poisoned.
JellyfishSting_PoisonConfusionEffect:
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetNonTurnDuelistVariable
	and DOUBLE_POISONED
	jp z, PoisonEffect  ; not yet Poisoned
	jp ConfusionEffect


; Poison + Smokescreen
SmogEffect:
	call ReduceAccuracyEffect
	jp PoisonEffect


; If heads, defending Pokemon becomes confused
SupersonicEffect:
	call Confusion50PercentEffect
	call nc, SetNoEffectFromStatus
	ret

; Defending Pokémon and user become confused.
; Defending Pokémon also becomes Poisoned.
FoulOdorEffect:
	call PoisonEffect
	; fallthrough

ConfusionWaveEffect:
	call ConfusionEffect
	; fallthrough

SelfConfusionEffect:
	call SwapTurn
	call ConfusionEffect
	jp SwapTurn

SelfPoisonEffect:
	call SwapTurn
	call PoisonEffect
	jp SwapTurn

; If heads, Poison + Paralysis.
; If tails, Poison + Sleep.
PollenFrenzy_Status50PercentEffect:
	ldtx de, ParalysisCheckText
	call TossCoin_BankB
	jr nc, .tails
; heads
	call ParalysisEffect
	jp PoisonEffect
.tails
	call SleepEffect
	jp PoisonEffect

; If heads, defending Pokémon becomes asleep.
; If tails, defending Pokémon becomes poisoned.
SleepOrPoisonEffect:
	ldtx de, AsleepIfHeadsPoisonedIfTailsText
	call TossCoin_BankB
	jp c, SleepEffect
	jp PoisonEffect

; Poisons the Defending Pokémon if an evolution card was chosen.
PoisonEvolution_PoisonEffect:
	ldh a, [hTemp_ffa0]
	cp $ff
	ret z ; skip if no evolution card was chosen
	jp PoisonEffect

; If the Defending Pokémon is Basic, it is Paralyzed
ParalysisIfBasicEffect:
	ld a, DUELVARS_ARENA_CARD_STAGE
	call GetNonTurnDuelistVariable
	or a
	jp z, ParalysisEffect  ; BASIC
	ret


; ------------------------------------------------------------------------------
; Play Area Status Effects
; ------------------------------------------------------------------------------

TargetedPoisonEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	cp $ff
	ret z
	ld e, a
	call SwapTurn
	call PoisonEffect_PlayArea
	jp SwapTurn

; input e: PLAY_AREA_* of the target Pokémon
PoisonEffect_PlayArea:
	lb bc, CNF_SLP_PRZ, POISONED
	jr ApplyStatusEffectToPlayAreaPokemon

; input e: PLAY_AREA_* of the target Pokémon
DoublePoisonEffect_PlayArea:
	lb bc, CNF_SLP_PRZ, DOUBLE_POISONED
	jr ApplyStatusEffectToPlayAreaPokemon

; input e: PLAY_AREA_* of the target Pokémon
BurnEffect_PlayArea:
	lb bc, CNF_SLP_PRZ, BURNED
	jr ApplyStatusEffectToPlayAreaPokemon

; input e: PLAY_AREA_* of the target Pokémon
ParalysisEffect_PlayArea:
	lb bc, PSN_DBLPSN_BRN, PARALYZED
	jr ApplyStatusEffectToPlayAreaPokemon

; input e: PLAY_AREA_* of the target Pokémon
ConfusionEffect_PlayArea:
	lb bc, PSN_DBLPSN_BRN, CONFUSED
	jr ApplyStatusEffectToPlayAreaPokemon

; input e: PLAY_AREA_* of the target Pokémon
SleepEffect_PlayArea:
	lb bc, PSN_DBLPSN_BRN, ASLEEP
	jr ApplyStatusEffectToPlayAreaPokemon


; assumes:
;   - SwapTurn if needed to change to the correct play area
; input:
;   b: mask of status conditions to preserve on the target
;   c: status condition to inflict to the target
;   e: PLAY_AREA_* of the target Pokémon
; outputs:
;   [wNoEffectFromWhichStatus]: set with the input status condition
;   carry: set if able to apply status
ApplyStatusEffectToPlayAreaPokemon:
	ld a, DUELVARS_ARENA_CARD
	add e
	call GetTurnDuelistVariable
	cp $ff
	jr z, .cant_induce_status
	push de
	call GetCardIDFromDeckIndex
	ld a, e
	pop de
	cp CLEFAIRY_DOLL
	jr z, .cant_induce_status
	cp MYSTERIOUS_FOSSIL
	jr z, .cant_induce_status
	; Snorlax's Thick Skinned prevents it from being statused...
	cp SNORLAX
	jr nz, .can_induce_status
	; ...unless already so, or if affected by Toxic Gas
	call CheckCannotUseDueToStatus
	jr c, .can_induce_status

.cant_induce_status
	ld a, c
	ld [wNoEffectFromWhichStatus], a
	call SetNoEffectFromStatus
	or a
	ret

.can_induce_status
	ld a, DUELVARS_ARENA_CARD_STATUS
	add e
	call GetTurnDuelistVariable  ; current status
	and b  ; status condition to preserve
	or c  ; status to apply on top
	ld [hl], a
	scf
	ret


; assumes:
;   - SwapTurn if needed to change to the correct play area
; input:
;   b: mask of status conditions to preserve on the target
;   c: status condition to inflict to the target
ApplyStatusEffectToAllPlayAreaPokemon:
	call ApplyStatusEffect
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld d, a
	ld e, PLAY_AREA_ARENA
	jr .next
.loop_play_area
	call ApplyStatusEffectToPlayAreaPokemon
.next
	inc e
	dec d
	ret z
	jr .loop_play_area


; assumes:
;   - SwapTurn if needed to change to the correct play area
; input:
;   b: mask of status conditions to preserve on the target
;   c: status condition to inflict to the target
ApplyStatusEffectToAllBenchedPokemon:
	call ApplyStatusEffect
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	dec a
	ld d, a
	ld e, PLAY_AREA_BENCH_1
	jr .next
.loop_play_area
	call ApplyStatusEffectToPlayAreaPokemon
.next
	inc e
	dec d
	ret z
	jr .loop_play_area


; input:
;   b: mask of status conditions to preserve on the target
;   c: status condition to inflict to the target
ApplyStatusEffectToAllOpponentBenchedPokemon:
	call SwapTurn
	call ApplyStatusEffectToAllBenchedPokemon
	jp SwapTurn


; ------------------------------------------------------------------------------
; Utility Functions
; ------------------------------------------------------------------------------

; returns in a the number of Asleep Pokémon
; in the turn holder's Play Area
; sets carry if there is at least one
; preserves: de
; outputs:
;   b: 0
;   c: number of sleeping Pokémon in Play Area
;   a: number of sleeping Pokémon in Play Area
CountSleepingPokemonInPlayArea:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld b, a
	ld c, 0
	or a
	ret z

; status conditions are all stored consecutively; just use hl to loop
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
.loop_play_area
	ld a, [hli]  ; get status and move to next
	and CNF_SLP_PRZ
	cp ASLEEP
	jr nz, .next
	inc c
.next
	dec b
	jr nz, .loop_play_area
	ld a, c
	cp 1
	ccf
	ret


; returns in a the number of Poisoned Pokémon
; in the turn holder's Play Area
; sets carry if there is at least one
; preserves: de
; outputs:
;   b: 0
;   c: number of poisoned Pokémon in Play Area
;   a: number of poisoned Pokémon in Play Area
CountPoisonedPokemonInPlayArea:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld b, a
	ld c, 0
	or a
	ret z

; status conditions are all stored consecutively; just use hl to loop
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
.loop_play_area
	ld a, [hli]  ; get status and move to next
	and DOUBLE_POISONED
	jr z, .next
	inc c
.next
	dec b
	jr nz, .loop_play_area
	ld a, c
	cp 1
	ccf
	ret
