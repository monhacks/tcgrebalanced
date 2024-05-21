; ------------------------------------------------------------------------------
; Recoil
; ------------------------------------------------------------------------------

Recoil10Effect:
	ld a, 10
	jp DealRecoilDamageToSelf

Recoil20Effect:
	ld a, 20
	jp DealRecoilDamageToSelf


Recoil30UnlessActiveThisTurnEffect:
	call CheckEnteredActiveSpotThisTurn
	ret nc  ; entered the Active Spot this turn
	; fallthrough

Recoil30Effect:
	ld a, 30
	jp DealRecoilDamageToSelf

Recoil40Effect:
	ld a, 40
	jp DealRecoilDamageToSelf

Recoil50Effect:
	ld a, 50
	jp DealRecoilDamageToSelf


; ------------------------------------------------------------------------------
; Area Damage
; ------------------------------------------------------------------------------


; deal 10 damage to each of the opponent's Pokémon
DamageAllOpponentPokemon10Effect_ThunderAnim:
	ld a, ATK_ANIM_THUNDER_PLAY_AREA
	ld [wLoadedAttackAnimation], a
	ld de, 10
	jr DamageAllOpponentPokemon_DE

; deal 10 damage to each of the opponent's Pokémon
DamageAllOpponentPokemon10Effect:
	ld a, ATK_ANIM_BENCH_HIT
	ld [wLoadedAttackAnimation], a
	ld de, 10
	; jr DamageAllOpponentPokemon_DE
	; fallthrough

; deal 10 damage to each of the opponent's Pokémon
; input:
;   de: amount of damage to deal
;   [wLoadedAttackAnimation]: the animation of the effect
DamageAllOpponentPokemon_DE:
	call SwapTurn
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld c, a
	ld b, PLAY_AREA_ARENA
.loop
	; use the animation loaded into [wLoadedAttackAnimation]
	call DealDamageToPlayAreaPokemon  ; preserves bc, de
	inc b
	dec c
	jr nz, .loop
	jp SwapTurn


; deal 10 damage to each of the opponent's benched Pokémon
DamageAllOpponentBenched10Effect:
	ld de, 10
	jr DamageAllOpponentBenchedPokemon

; deal 20 damage to each of the opponent's benched Pokémon
DamageAllOpponentBenched20Effect:
	ld de, 20
	; jr DamageAllOpponentBenchedPokemon
	; fallthrough

; input:
;   de: amount of damage to deal to each Pokémon
DamageAllOpponentBenchedPokemon:
	call SwapTurn
	xor a
	ld [wIsDamageToSelf], a
	call DamageAllBenchedPokemon
	jp SwapTurn


; deal 10 damage to each of the turn holder's benched Pokémon
DamageAllFriendlyPokemon10Effect:
	ld de, 10
	jr DamageAllFriendlyPokemon

; deal 20 damage to each of the turn holder's benched Pokémon
DamageAllFriendlyPokemon20Effect:
	ld de, 20
	jr DamageAllFriendlyPokemon

; deal 30 damage to each of the turn holder's benched Pokémon
DamageAllFriendlyPokemon30Effect:
	ld de, 30
	; jr DamageAllFriendlyPokemon
	; fallthrough

; input:
;   de: amount of damage to deal to each Pokémon
DamageAllFriendlyPokemon:
	ld a, TRUE
	ld [wIsDamageToSelf], a
	; jr DamageAllBenchedPokemon
	; fallthrough


; deal damage to all the turn holder's benched Pokémon
; input:
;   de: amount of damage to deal to each Pokémon
DamageAllBenchedPokemon:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld c, a
	ld b, PLAY_AREA_ARENA
	jr .skip_to_bench
.loop
	push bc
	call DealDamageToPlayAreaPokemon_RegularAnim
	pop bc
.skip_to_bench
	inc b
	dec c
	jr nz, .loop
	ret


; deal damage to all the turn holder's benched Basic Pokémon
; input: de = amount of damage to deal to each Pokémon
DealDamageToAllBenchedBasicPokemon:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld c, a
	ld b, PLAY_AREA_ARENA
	jr .next
.loop
	ld a, DUELVARS_ARENA_CARD_STAGE
	add b
	call GetTurnDuelistVariable
	or a
	jr nz, .next  ; not a BASIC Pokémon
	push bc
	call DealDamageToPlayAreaPokemon_RegularAnim
	pop bc
.next
	inc b
	dec c
	jr nz, .loop
	ret


; deal 20 damage to each of the opponent's benched Basic Pokémon
DamageAllOpponentBenchedBasic20Effect:
	call SwapTurn
	xor a
	ld [wIsDamageToSelf], a
	ld de, 20
	call DealDamageToAllBenchedBasicPokemon
	jp SwapTurn


IfAttachedToolDamageOpponentBench10Effect:
	xor a  ; PLAY_AREA_ARENA
	call CheckPokemonHasNoToolsAttached
	ret nc  ; no Tool
	jp DamageAllOpponentBenched10Effect


RagingStorm_BenchDamageEffect:
	call CheckOpponentHasMorePrizeCardsRemaining
	ret c  ; opponent Prizes < user Prizes (losing)
	ret z  ; opponent Prizes = user Prizes (tied)
; opponent Prizes > user Prizes (winning)
	jp DamageAllOpponentBenched20Effect


; ------------------------------------------------------------------------------
; Targeted Damage
; ------------------------------------------------------------------------------


Deal10DamageToTarget_DamageEffect:
	ld de, 10
	jr DealDamageToTarget_DE_DamageEffect

Deal20DamageToTarget_DamageEffect:
	ld de, 20
	jr DealDamageToTarget_DE_DamageEffect

Deal40DamageToTarget_DamageEffect:
	ld de, 40
	jr DealDamageToTarget_DE_DamageEffect

Deal50DamageToTarget_DamageEffect:
	ld de, 50
	jr DealDamageToTarget_DE_DamageEffect

Deal30DamageToTarget_DamageEffect:
	ld de, 30
	; jr DealDamageToTarget_DE_DamageEffect
	; fallthrough

; Deals DE damage to 1 of the opponent's Pokémon
DealDamageToTarget_DE_DamageEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	cp $ff
	ret z
	; fallthrough

; Deals DE damage to 1 of the opponent's Pokémon
; in play area location A
DealDamageToTargetA_DE_DamageEffect:
	call SwapTurn
	; ldh a, [hTempPlayAreaLocation_ffa1]
	ld b, a
	; ld de, 30
	call DealDamageToPlayAreaPokemon_RegularAnim
	jp SwapTurn


; input:
;   a: ATK_ANIM_* constant
;   de: amount of damage
DealDamageToArenaPokemon_CustomAnim:
	ld [wLoadedAttackAnimation], a
	call SwapTurn
	; ld de, 30
	ld b, PLAY_AREA_ARENA
	call DealDamageToPlayAreaPokemon
	jp SwapTurn


;
TrampleEffect:
DealExcessDamageToTarget_DamageEffect:
	ld a, DUELVARS_ARENA_CARD_HP
	call GetNonTurnDuelistVariable
	or a
	ret nz
; the Defending Pokémon was Knocked Out
	ldh a, [hTemp_ffa0]
	ld e, a  ; previous HP
	ld a, [wDealtDamage]
	or a
	ret z  ; no damage was dealt
	sub e
	ret c  ; no excess damage (unlikely)
	ret z  ; no excess damage (exact)
	ld d, 0
	ld e, a  ; excess damage
	jr DealDamageToTarget_DE_DamageEffect


Deal10DamageToFriendlyTarget_DamageEffect:
	ld de, 10
	jr DealDamageToFriendlyTarget_DE_DamageEffect

Deal20DamageToFriendlyTarget_DamageEffect:
	ld de, 20
	jr DealDamageToFriendlyTarget_DE_DamageEffect

Deal30DamageToFriendlyTarget_DamageEffect:
	ld de, 30
	; jr DealDamageToFriendlyTarget_DE_DamageEffect
	; fallthrough

; Deals DE damage to 1 of the turn holder's Pokémon
DealDamageToFriendlyTarget_DE_DamageEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	cp $ff
	ret z
	ld b, a
	jp DealDamageToPlayAreaPokemon_RegularAnim


; ------------------------------------------------------------------------------
; Targeted Damage - Player Selection
; ------------------------------------------------------------------------------


; can choose any Pokémon in Play Area
DamageTargetPokemon_PlayerSelectEffect:
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ffa1], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetNonTurnDuelistVariable
	cp 2
	jr c, .done ; has no Bench Pokemon

	ldtx hl, ChoosePokemonToGiveDamageText
	call DrawWideTextBox_WaitForInput
	call SwapTurn
	bank1call HasAlivePokemonInPlayArea
	call DamageTargetBenchedPokemon_PlayerSelectEffect.loop_input
.done
	or a
	ret


DamageTargetBenchedPokemonIfAny_PlayerSelectEffect:
	ld a, $ff
	ldh [hTempPlayAreaLocation_ffa1], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetNonTurnDuelistVariable
	cp 2
	ret c ; has no Bench Pokemon
	; fallthrough

DamageTargetBenchedPokemon_PlayerSelectEffect:
	ldtx hl, ChoosePokemonInTheBenchToGiveDamageText
	call DrawWideTextBox_WaitForInput
	call SwapTurn
	bank1call HasAlivePokemonInBench

.loop_input
	bank1call OpenPlayAreaScreenForSelection
	jr c, .loop_input
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTempPlayAreaLocation_ffa1], a
	jp SwapTurn


DamageFriendlyBenchedPokemonIfAny_PlayerSelectEffect:
	call SwapTurn
	call DamageTargetBenchedPokemonIfAny_PlayerSelectEffect
	jp SwapTurn


SurpriseBite_PlayerSelectEffect:
	ldtx hl, ChoosePokemonInTheBenchToGiveDamageText
	call DrawWideTextBox_WaitForInput
	call SwapTurn
	ld a, CARDTEST_FULL_HP_POKEMON
	call HandlePlayerSelectionMatchingPokemonInBench_AllowCancel
	jp SwapTurn


; ------------------------------------------------------------------------------
; Targeted Damage - AI Selection
; ------------------------------------------------------------------------------


; can choose any Pokémon in Play Area
; output:
;   a: PLAY_AREA_* of the selected Pokémon
;   [hTempPlayAreaLocation_ffa1]: PLAY_AREA_* of the selected Pokémon
;   z: set if Arena is selected
;   nz: set if Bench is selected
DamageTargetPokemon_AISelectEffect:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetNonTurnDuelistVariable
	cp 2
	jr c, .arena  ; has no Bench Pokemon
; AI always picks Pokemon with lowest HP remaining
	call GetOpponentBenchPokemonWithLowestHP
; amount of HP remaining is in e
	ldh [hTempPlayAreaLocation_ffa1], a
	ld a, DUELVARS_ARENA_CARD_HP
	call GetNonTurnDuelistVariable
	ld a, e
	cp [hl]
	jr c, .done  ; got minimum
.arena
	xor a
	ldh [hTempPlayAreaLocation_ffa1], a
.done
	or a
	ret


DamageTargetBenchedPokemonIfAny_AISelectEffect:
	ld a, $ff
	ldh [hTempPlayAreaLocation_ffa1], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetNonTurnDuelistVariable
	cp 2
	ret c ; has no Bench Pokemon
	; fallthrough

DamageTargetBenchedPokemon_AISelectEffect:
; AI always picks Pokemon with lowest HP remaining
	call GetOpponentBenchPokemonWithLowestHP
	ldh [hTempPlayAreaLocation_ffa1], a
	ret


DamageFriendlyBenchedPokemonIfAny_AISelectEffect:
	ld a, $ff
	ldh [hTempPlayAreaLocation_ffa1], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	cp 2
	ret c ; has no Bench Pokemon
	; fallthrough

DamageFriendlyBenchedPokemon_AISelectEffect:
; AI always picks Pokemon with highest HP remaining
	call GetBenchPokemonWithHighestHP
	ldh [hTempPlayAreaLocation_ffa1], a
	ret


; ------------------------------------------------------------------------------
; Passive Damage - Pokémon Powers
; ------------------------------------------------------------------------------

SpikesDamageEffect:
	call ArePokemonPowersDisabled
	ret c  ; Powers are disabled
	call SwapTurn
	ld a, SANDSLASH
	call CountPokemonIDInPlayArea
	call SwapTurn
	or a
	ret z  ; no Sandslash in the opponent's Play Area

	; ld a, [wDuelDisplayedScreen]
	; cp DUEL_MAIN_SCENE
	; jr z, .main_scene
	; bank1call DrawDuelMainScene
; .main_scene
	ld e, PLAY_AREA_ARENA
	jp Put1DamageCounterOnTarget

	; ld a, DUELVARS_ARENA_CARD
	; call LoadCardNameAndLevelFromVarToRam2
	; ldtx hl, Received10DamageDueToSpikesText
	; jp DrawWideTextBox_WaitForInput


; ------------------------------------------------------------------------------
; Other Forms of Damage
; ------------------------------------------------------------------------------

KnockOutDefendingPokemonEffect:
	ld a, DUELVARS_ARENA_CARD_HP
	call GetNonTurnDuelistVariable
	or a
	ret z
	ld [hl], 0
	; push hl
	; call DrawDuelMainScene
	; call DrawDuelHUDs
	; pop hl
	ld l, DUELVARS_ARENA_CARD
	ld a, [hl]
	call LoadCardDataToBuffer2_FromDeckIndex
	ld hl, wLoadedCard2Name
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call LoadTxRam2
	ldtx hl, KnockedOutDueToDestinyBondText
	jp DrawWideTextBox_WaitForInput
