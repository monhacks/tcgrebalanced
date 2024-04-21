; ------------------------------------------------------------------------------
; General
; ------------------------------------------------------------------------------

; return carry if Player is the Turn Duelist
; preserves: bc, de
IsPlayerTurn:
	ld a, DUELVARS_DUELIST_TYPE
	call GetTurnDuelistVariable
	cp DUELIST_TYPE_PLAYER
	jr z, .player
	or a
	ret
.player
	scf
	ret


; ------------------------------------------------------------------------------
; Deck
; ------------------------------------------------------------------------------

; returns carry if Deck is empty
; preserves: bc, de
CheckDeckIsNotEmpty:
	ld a, DUELVARS_NUMBER_OF_CARDS_NOT_IN_DECK
	call GetTurnDuelistVariable
	ldtx hl, NoCardsLeftInTheDeckText
	cp DECK_SIZE
	ccf
	ret


; input:
;   wDataTableIndex: function index in CardTypeTest_FunctionTable
; output:
;   carry: set if there are no valid cards in deck
;   a: deck index of the first valid card | $ff
CheckThereIsCardTypeInDeck:
	ld a, DUELVARS_CARD_LOCATIONS
	call GetTurnDuelistVariable
.loop_deck
	ld a, [hl]
	cp CARD_LOCATION_DECK
	jr nz, .next_card
	ld a, l
	call DynamicCardTypeTest
	jr nc, .next_card  ; not a card of the desired type
; there are valid cards
	ld a, l
	ccf
	ret
.next_card
	inc l
	ld a, l
	cp DECK_SIZE
	jr c, .loop_deck
; none in deck
	ld a, $ff
	scf
	ret


; ------------------------------------------------------------------------------
; Prize Cards
; ------------------------------------------------------------------------------

; Returns carry if the opponent has less prize cards remaining.
; Alt: Returns carry if the opponent has taken more prize cards.
; output:
;   a: opponent's remaining Prizes
;   z: set if the number of Prizes is the same on both sides
CheckOpponentHasMorePrizeCardsRemaining:
	call CountPrizes  ; turn holder's remaining Prizes
	ld c, a
	call SwapTurn
	call CountPrizes  ; opponent's remaining Prizes
	call SwapTurn
	cp c  ; carry <- (opponent's Prizes < turn holder's Prizes)
	ret


; ------------------------------------------------------------------------------
; Hand Cards
; ------------------------------------------------------------------------------


; returns carry if there are less than 4 cards in hand
CheckHandSizeGreaterThan3:
	ld c, 4
	jr CheckHandSizeIsAtLeastC

; returns carry if there are less than 3 cards in hand
CheckHandSizeGreaterThan2:
	ld c, 3
	jr CheckHandSizeIsAtLeastC

; returns carry if there are less than 2 cards in hand
CheckHandSizeGreaterThan1:
	ld c, 2
	jr CheckHandSizeIsAtLeastC

; returns carry if there are no cards in hand
CheckHandIsNotEmpty:
	ld c, 1
	; jr CheckHandSizeIsAtLeastC
	; fallthrough

; returns carry if there are less than c cards in hand
; input:
;   c: threshold number of cards
; output:
;   a: number of cards in hand
;   carry: set if the number of cards in hand is less than input c
;   hl: error text
CheckHandSizeIsAtLeastC:
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetTurnDuelistVariable
	cp c
	ldtx hl, NotEnoughCardsInHandText
	ret

; returns carry if there are at least c cards in hand
; input:
;   c: threshold number of cards
; output:
;   a: number of cards in hand
;   carry: set if the number of cards in hand is more than (or equal to) input c
;   hl: error text
CheckHandSizeIsLessThanC:
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetTurnDuelistVariable
	cp c
	ldtx hl, TooManyCardsInHandText
	ccf
	ret

; returns carry if the player does not have more cards in hand than the opponent
; output:
;   a: number of cards in hand
;   carry: set if the number of cards in hand <= opponent's
;   hl: error text
CheckHandSizeGreaterThanOpponents:
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetNonTurnDuelistVariable
	ld c, a
	inc c
	jr CheckHandSizeIsAtLeastC

; returns carry if the player does not have less cards in hand than the opponent
; output:
;   a: number of cards in hand
;   carry: set if the number of cards in hand >= opponent's
;   hl: error text
CheckHandSizeLesserThanOpponents:
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetNonTurnDuelistVariable
	ld c, a
	jr CheckHandSizeIsLessThanC


; returns carry if the player does not have Mysterious Fossil in hand
; output:
;   a: deck index of Mysterious Fossil | $ff
;   carry: set if there is no Mysterious Fossil in hand
CheckMysteriousFossilInHand:
	call CreateHandCardList
	ld hl, wDuelTempList
.loop_hand
	ld a, [hli]
	cp $ff
	jr z, .none
	call GetCardIDFromDeckIndex  ; preserves hl
	ld a, e
	cp MYSTERIOUS_FOSSIL
	jr nz, .loop_hand

; found a Mysterious Fossil in hand
	dec hl
	ld a, [hl]
	ret

.none
	scf
	ret


; ------------------------------------------------------------------------------
; Discard Pile
; ------------------------------------------------------------------------------


; return carry if the Discard Pile is empty
CheckDiscardPileNotEmpty:
	call CreateDiscardPileCardList
	ldtx hl, ThereAreNoCardsInTheDiscardPileText
	ret


; return carry if the opponent's Discard Pile is empty
CheckOpponentDiscardPileNotEmpty:
	call SwapTurn
	call CheckDiscardPileNotEmpty
	jp SwapTurn


; return carry if no Basic Energy cards in Discard Pile
CheckDiscardPileHasBasicEnergyCards:
	; call CreateEnergyCardListFromDiscardPile_AllEnergy
  jp CreateEnergyCardListFromDiscardPile_OnlyBasic


; return carry if no Water Energy cards in Discard Pile
CheckDiscardPileHasWaterEnergyCards:
  jp CreateEnergyCardListFromDiscardPile_OnlyWater


; return carry if no Fire Energy cards in Discard Pile
CheckDiscardPileHasFireEnergyCards:
  jp CreateEnergyCardListFromDiscardPile_OnlyFire


; return carry if no Lightning Energy cards in Discard Pile
CheckDiscardPileHasLightningEnergyCards:
  jp CreateEnergyCardListFromDiscardPile_OnlyLightning


; return carry if no Pokémon cards in Discard Pile
CheckDiscardPileHasPokemonCards:
  call CreatePokemonCardListFromDiscardPile
  ldtx hl, ThereAreNoPokemonInDiscardPileText
  ret


; return carry if no Basic Pokémon cards in Discard Pile
CheckDiscardPileHasBasicPokemonCards:
  call CreateBasicPokemonCardListFromDiscardPile
  ldtx hl, ThereAreNoPokemonInDiscardPileText
  ret



; ------------------------------------------------------------------------------
; Play Area
; ------------------------------------------------------------------------------

; return carry if no cards in the Bench.
CheckBenchIsNotEmpty:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ldtx hl, EffectNoPokemonOnTheBenchText
	cp 2
	ret


; return carry if opponent has no Bench Pokemon.
CheckOpponentBenchIsNotEmpty:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetNonTurnDuelistVariable
	ldtx hl, EffectNoPokemonOnTheBenchText
	cp 2
	ret


; return carry if the Bench is full
CheckBenchIsNotFull:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ldtx hl, NoSpaceOnTheBenchText
	cp MAX_PLAY_AREA_POKEMON
	ccf
	ret


; return carry if there are two Pokémon of the same color in the Play Area
CheckNoDuplicateColorsInPlayArea:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld b, a
	xor a
	ld c, a  ; color bit mask
	ld e, a  ; PLAY_AREA_ARENA
.loop
	ld a, e
	call GetPlayAreaCardColor
	call TranslateColorToWR
	ld d, a
	and c
	jr nz, .duplicate
	ld a, c
	or d
	ld c, a
	inc e
	dec b
	jr nz, .loop
	ret
.duplicate
	scf
	ret


; returns carry if the given Pokémon has a Tool attached to it
; input:
;   a: PLAY_AREA_* of the card to check
CheckPokemonHasNoToolsAttached:
	add DUELVARS_ARENA_CARD_ATTACHED_TOOL
	call GetTurnDuelistVariable
	or a
	ret z
; there is an attached tool
	ldtx hl, AlreadyHasAToolAttachedText
	scf
	ret


; unreferenced
; return carry if Turn Duelist has no Evolution cards in Play Area
; Evolution cards played as Basic Pokémon count for this check
; CheckSomeEvolutionPokemonCardsInPlayArea:
; 	ld a, CARDTEST_EVOLUTION_POKEMON
; 	call CheckSomeMatchingPokemonInPlayArea
; ; carry set if there is no evolved Pokémon
; 	ldtx hl, ThereAreNoEvolvedPokemonInPlayAreaText
; 	ret


; returns carry if Turn Duelist
; has no Stage1 or Stage2 cards in Play Area.
CheckSomeEvolvedPokemonInPlayArea:
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	ld d, h
	ld e, DUELVARS_ARENA_CARD_STAGE
.loop
	ld a, [hli]
	cp $ff
	jr z, .set_carry
	ld a, [de]
	inc de
	or a
	jr z, .loop ; is Basic Stage
	ret
.set_carry
	ldtx hl, ThereAreNoEvolvedPokemonInPlayAreaText
	scf
	ret


; input:
;   a: how to test the selected Pokémon (CARDTEST_* constants)
; output:
;   a: PLAY_AREA_* of the first matching Pokémon | $ff
;   [hTempPlayAreaLocation_ff9d]: PLAY_AREA_* of the first matching Pokémon | $ff
;   carry: set if there is no matching Pokémon
CheckSomeMatchingPokemonInPlayArea:
	ld [wDataTableIndex], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld d, PLAY_AREA_ARENA
	ld e, a
	ld l, DUELVARS_ARENA_CARD
.loop
	ld a, d  ; load current play area location
	ldh [hTempPlayAreaLocation_ff9d], a
	ld a, [hli]
	push de
	call DynamicCardTypeTest  ; preserves hl
	pop de
	ld a, d  ; load current play area location
	ccf
	ret nc  ; found matching card
.next
	inc d
	dec e
	jr nz, .loop
	ld a, $ff
	ldh [hTempPlayAreaLocation_ff9d], a
	scf
	ret


; input:
;   a: how to test the selected Pokémon (CARDTEST_* constants)
; output:
;   a: PLAY_AREA_* of the first matching Pokémon | $ff
;   [hTempPlayAreaLocation_ff9d]: PLAY_AREA_* of the first matching Pokémon | $ff
;   carry: set if there is no matching Pokémon
CheckSomeMatchingPokemonInBench:
	ld [wDataTableIndex], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld d, PLAY_AREA_ARENA
	ld e, a
	ld l, DUELVARS_BENCH
	jr CheckSomeMatchingPokemonInPlayArea.next


; input:
;   a: how to test the selected Pokémon (CARDTEST_* constants)
;   e: PLAY_AREA_* of the tested Pokémon
; output:
;   a: PLAY_AREA_* of the first matching Pokémon | $ff
;   carry: set if there is no match
CheckPlayAreaPokemonMatchesPattern:
	ld [wDataTableIndex], a
	ld a, DUELVARS_ARENA_CARD
	add e
	call GetTurnDuelistVariable
	call DynamicCardTypeTest
	ccf
	ret


; output:
;   carry: set if the Pokémon did not enter the Active Spot this turn
; preserves: bc, de
CheckEnteredActiveSpotThisTurn:
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS3
	call GetTurnDuelistVariable
	bit SUBSTATUS3_THIS_TURN_ACTIVE, a
	ret nz  ; moved to active spot this turn
	scf
	ret


; returns carry if the Pokémon at play area location in [hTempPlayAreaLocation_ff9d]
; is not on the bench
CheckTriggeringPokemonIsOnTheBench:
	ldh a, [hTempPlayAreaLocation_ff9d]
	or a
	ret nz  ; not PLAY_AREA_ARENA
	ldtx hl, CanOnlyBeUsedOnTheBenchText
	scf
	ret


; ------------------------------------------------------------------------------
; Damage
; ------------------------------------------------------------------------------

; returns carry if every Pokémon in the Play Area has damage counters.
CheckSomePokemonWithoutDamage:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld d, a
	ld e, PLAY_AREA_ARENA
.loop_play_area
	call GetCardDamageAndMaxHP
	or a
	ret z ; found undamaged
	inc e
	dec d
	jr nz, .loop_play_area
	; damage found
	ldtx hl, NoPokemonWithoutDamageCountersText
	scf
	ret


CheckSomeOpponentPokemonWithoutDamage:
	call SwapTurn
	call CheckSomePokemonWithoutDamage
	jp SwapTurn



; returns carry if the Active Pokémon has no damage counters.
CheckArenaPokemonHasAnyDamage:
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
	ldtx hl, NoDamageCountersText
	cp 10
	ret


; returns carry if the opponent's Active Pokémon has no damage counters.
CheckOpponentArenaPokemonHasAnyDamage:
	call SwapTurn
	call CheckArenaPokemonHasAnyDamage
	jp SwapTurn


; Returns carry if the Pokémon at location
; in [hTempPlayAreaLocation_ff9d] has no damage counters.
; Useful for Pokémon Powers.
CheckTempLocationPokemonHasAnyDamage:
  ldh a, [hTempPlayAreaLocation_ff9d]
	ld e, a
	call GetCardDamageAndMaxHP
	ldtx hl, NoDamageCountersText
	cp 10
	ret


; returns carry if Play Area has no damage counters
; and sets the error message in hl
CheckIfPlayAreaHasAnyDamage:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld d, a
	ld e, PLAY_AREA_ARENA
.loop_play_area
	call GetCardDamageAndMaxHP
	or a
	ret nz ; found damage
	inc e
	dec d
	jr nz, .loop_play_area
	; no damage found
	ldtx hl, NoPokemonWithDamageCountersText
	scf
	ret


; returns carry if Play Area has no damage counters
; and sets the error message in hl
; excludes the location in [hTempPlayAreaLocation_ff9d]
CheckIfPlayAreaHasAnyDamage_ExcludeTempLocation:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld d, a
	ld e, PLAY_AREA_ARENA
.loop_play_area
	ldh a, [hTempPlayAreaLocation_ff9d]
	cp e
	jr z, .next
	call GetCardDamageAndMaxHP
	or a
	ret nz ; found damage
.next
	inc e
	dec d
	jr nz, .loop_play_area
	; no damage found
	ldtx hl, NoPokemonWithDamageCountersText
	scf
	ret


; returns carry if Strange Behavior cannot be used
StrangeBehavior_CheckDamage:
; can Pkmn Power be used?
	ldh a, [hTempPlayAreaLocation_ff9d]
	call CheckCannotUseDueToStatus_Anywhere
	ret c
; does Play Area have any damage counters?
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTemp_ffa0], a
.check_damage
	call CheckIfPlayAreaHasAnyDamage_ExcludeTempLocation
	ret c
; can this Pokémon receive any damage counters without KO-ing?
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	ldtx hl, CannotUseBecauseItWillBeKnockedOutText
	cp 10 + 10
	ret


GetMad_CheckDamage:
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ff9d], a
	jr StrangeBehavior_CheckDamage.check_damage


; output:
;   carry: set if the Defending Pokémon has more than 50 HP remaining
CheckDefendingPokemonHas50HpOrLess:
	ld a, DUELVARS_ARENA_CARD_HP
	call GetNonTurnDuelistVariable
	cp 51
	ccf
	ret


; ------------------------------------------------------------------------------
; Status and Effects
; ------------------------------------------------------------------------------


; returns carry if the Pokémon Power has already been used in this turn.
; inputs:
;   [hTempPlayAreaLocation_ff9d]: PLAY_AREA_* of the Pokémon using the Power
CheckPokemonPowerCanBeUsed:
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD_FLAGS
	call GetTurnDuelistVariable
	and USED_PKMN_POWER_THIS_TURN
	jr nz, .already_used

	ldh a, [hTempPlayAreaLocation_ff9d]
	jp CheckCannotUseDueToStatus_Anywhere

.already_used
	ldtx hl, OnlyOncePerTurnText
	scf
	ret


; return carry if the turn holder's Arena card has no status conditions
CheckArenaPokemonHasStatus:
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
	or a
	ret nz
	ldtx hl, NotAffectedByPoisonSleepParalysisOrConfusionText
	scf
	ret


; return carry if opponent's Arena card has no status conditions
CheckOpponentHasStatus:
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetNonTurnDuelistVariable
	or a
	ret nz
	ldtx hl, NotAffectedByPoisonSleepParalysisOrConfusionText
	scf
	ret


; Loop over turn holder's Pokemon and return whether any have status conditions.
; Returns:
;    a: first status condition found or zero if none found
;    hl: first Pokémon status variable with status conditions or error text
;    carry: set if no Pokémon have status conditions
CheckIfPlayAreaHasAnyStatus:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	or a
	jr z, .set_carry  ; no Pokémon in play area

	ld b, a  ; loop counter
	ld l, DUELVARS_ARENA_CARD_STATUS
.loop_play_area
	ld a, [hl]
	or a
	ret nz  ; found status
	inc hl
	dec b
	jr nz, .loop_play_area
.set_carry
	ldtx hl, NotAffectedByPoisonSleepParalysisOrConfusionText
	scf
	ret


FullHeal_CheckPlayAreaStatus:
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS2
	call GetTurnDuelistVariable
	or a
	ret nz  ; substatus found
	jr CheckIfPlayAreaHasAnyStatus


; ------------------------------------------------------------------------------
; Energy
; ------------------------------------------------------------------------------

CheckArenaPokemonHasAnyEnergiesAttached:
	xor a  ; PLAY_AREA_ARENA
	; jr CheckPlayAreaPokemonHasAnyEnergiesAttached
	; fallthrough

; input:
;   a: PLAY_AREA_* of the Pokémon to check
; output:
;   carry: set if there are no attached energies
; preserves: bc
CheckPlayAreaPokemonHasAnyEnergiesAttached:
	ldtx hl, NoEnergyCardsText
	jp IsNonEnergizedPokemon  ; preserves hl, bc


;
CheckIfPlayAreaHasAnyEnergies:
	call CheckIfThereAreAnyEnergyCardsAttached
	ldtx hl, NoEnergyCardsAttachedToPokemonInYourPlayAreaText
	ret


; return carry if has less than 2 Energy cards
Check2EnergiesAttached:
	ld a, 2
	ldtx hl, NotEnoughEnergyCardsText
	jr GetNumAttachedEnergiesAtMostA_Arena


; return carry if less than a Energy cards
GetNumAttachedEnergiesAtMostA_Arena:
	ld e, PLAY_AREA_ARENA

; input:
;   a: max number of energy cards to test against
;   e: PLAY_AREA_* of target
; output:
;   a: total number of attached energy cards, capped at input a
;   carry: set if attached Energy cards < cap
GetNumAttachedEnergiesAtMostA:
	ld d, a
	call GetPlayAreaCardAttachedEnergies
	ld a, [wTotalAttachedEnergies]
	cp d
	ret c
	ld a, d
	ret


; return carry if no energy cards of the given type
;   d:  which type of energy to check (FIRE, LIGHTNING, etc.)
; CheckArenaPokemonHasEnergiesOfType:
; 	ld e, PLAY_AREA_ARENA
; 	call GetPlayAreaCardAttachedEnergies  ; preserves hl, bc, de
; 	call HandleEnergyColorOverride  ; preserves de
; 	; ldtx hl, NotEnoughFireEnergyText
; 	ld e, d
; 	ld d, 0
; 	ld hl, wAttachedEnergies
; 	add hl, de
; 	ld a, [hl]
; 	cp 1
; 	ldtx hl, NotEnoughEnergyCardsText
; 	ret


; unreferenced
CheckIfCardHasDarknessEnergyAttached:
	ld c, TYPE_ENERGY_DARKNESS
	jr CheckIfCardHasSpecificEnergyAttached

CheckIfCardHasGrassEnergyAttached:
	ld c, TYPE_ENERGY_GRASS
	; jr CheckIfCardHasSpecificEnergyAttached
	; fallthrough

; returns carry if no Energy cards of the given type in c
; are attached to card in Play Area location of a.
; input:
;	a = PLAY_AREA_* of location to check
; c = TYPE_ENERGY_* constant
CheckIfCardHasSpecificEnergyAttached:
	or CARD_LOCATION_PLAY_AREA
	ld e, a

	ld a, DUELVARS_CARD_LOCATIONS
	call GetTurnDuelistVariable
.loop
	ld a, [hl]
	cp e
	jr nz, .next
	push de
	push hl
	ld a, l
	call GetCardIDFromDeckIndex
	call GetCardType
	pop hl
	pop de
	cp c
	jr z, .no_carry
.next
	inc l
	ld a, l
	cp DECK_SIZE
	jr c, .loop
	scf
	ret
.no_carry
	ld a, l
	or a
	ret


; returns carry if the turn holder did not play any energy cards
; during their turn
CheckPlayedEnergyThisTurn:
	ld a, [wAlreadyPlayedEnergyOrSupporter]
	and PLAYED_ENERGY_THIS_TURN
	ret nz  ; played energy
	ld a, [wAlreadyPlayedEnergyOrSupporter]
	and USED_RAIN_DANCE_THIS_TURN
	ret nz  ; played energy with Rain Dance
	scf
	ret


; ------------------------------------------------------------------------------
; Card Types
; ------------------------------------------------------------------------------


; input:
;   a: argument (e.g., deck index) to pass to a function in CardTypeTest_FunctionTable
;   [wDataTableIndex]: CARDTEST_* constant
;   [hTempPlayAreaLocation_ff9d]: PLAY_AREA_* location (if applicable)
; preserves:
;   hl: always
;   bc, de: if the test function also does
DynamicCardTypeTest:
	ld [wDynamicFunctionArgument], a
	ld a, [wDataTableIndex]
	push hl
	ld hl, CardTypeTest_FunctionTable
	call JumpToFunctionInTable
	pop hl
	ret


CardTypeTest_FunctionTable:
	dw CardTypeTest_Pokemon                ; CARDTEST_POKEMON
	dw CardTypeTest_BasicPokemon           ; CARDTEST_BASIC_POKEMON
	dw CardTypeTest_EvolutionPokemon       ; CARDTEST_EVOLUTION_POKEMON
	dw CardTypeTest_BasicEnergy            ; CARDTEST_BASIC_ENERGY
	dw CardTypeTest_IsEnergizedPokemon     ; CARDTEST_ENERGIZED_POKEMON
	dw CardTypeTest_IsNonEnergizedPokemon  ; CARDTEST_NON_ENERGIZED_POKEMON
	dw CardTypeTest_IsMagmar               ; CARDTEST_MAGMAR
	dw CardTypeTest_IsEnergizedMagmar      ; CARDTEST_ENERGIZED_MAGMAR
	dw CardTypeTest_IsElectabuzz           ; CARDTEST_ELECTABUZZ
	dw CardTypeTest_IsEnergizedElectabuzz  ; CARDTEST_ENERGIZED_ELECTABUZZ
	dw CardTypeTest_EvolvesIntoStoredCard  ; CARDTEST_EVOLVES_INTO
	dw CardTypeTest_IsEvolutionOfPlayArea  ; CARDTEST_EVOLUTION_OF_PLAY_AREA
	dw CardTypeTest_IsGrassCard            ; CARDTEST_GRASS_CARD


CardTypeTest_Pokemon:
	ld a, [wDynamicFunctionArgument]
	; fallthrough

; input:
;   a: deck index of the card
; output:
;   carry: set if the given card is a Pokémon
; preserves: hl, bc, de
IsPokemonCard:
	call LoadCardDataToBuffer2_FromDeckIndex  ; preserves hl, bc, de
	ld a, [wLoadedCard2Type]
	cp TYPE_PKMN + 1
	ret


CardTypeTest_BasicPokemon:
	ld a, [wDynamicFunctionArgument]
	; fallthrough

; input:
;   a: deck index of the card
; output:
;   carry: set if the given card is a Basic Pokémon
; preserves: hl, bc, de
IsBasicPokemonCard:
	call LoadCardDataToBuffer2_FromDeckIndex  ; preserves hl, bc, de
	ld a, [wLoadedCard2Type]
	cp TYPE_PKMN + 1
	ret nc  ; not a Pokémon card
	ld a, [wLoadedCard2Stage]
	or a    ; BASIC
	ret nz  ; not a Basic Pokémon
	scf
	ret


CardTypeTest_EvolutionPokemon:
	ld a, [wDynamicFunctionArgument]
	; fallthrough

; input:
;   a: deck index of the card
; output:
;   carry: set if the given card is an Evolution Pokémon
; preserves: hl, bc, de
IsEvolutionPokemonCard:
	call LoadCardDataToBuffer2_FromDeckIndex  ; preserves hl, bc, de
	ld a, [wLoadedCard2Type]
	cp TYPE_PKMN + 1
	ret nc  ; not a Pokémon card
	ld a, [wLoadedCard2Stage]
	or a   ; BASIC
	ret z  ; not an Evolution Pokémon
	scf
	ret


CardTypeTest_BasicEnergy:
	ld a, [wDynamicFunctionArgument]
	; fallthrough

; input:
;   a: deck index of the card
; output:
;   carry: set if the given card is a Basic Energy
; preserves: hl, bc, de
IsBasicEnergyCard:
	call LoadCardDataToBuffer2_FromDeckIndex  ; preserves hl, bc, de
	ld a, [wLoadedCard2Type]
	cp TYPE_ENERGY_DOUBLE_COLORLESS
	ret nc  ; not a Basic Energy card
	and TYPE_ENERGY
	ret z  ; not a Basic Energy card
	scf
	ret


; input:
;   [hTempPlayAreaLocation_ff9d]: PLAY_AREA_* of the Pokémon to check
CardTypeTest_IsEnergizedPokemon:
	ldh a, [hTempPlayAreaLocation_ff9d]
	push de
	jp IsEnergizedPokemon  ; preserves hl, bc
	pop de
	ret

; input:
;   a: PLAY_AREA_* of the Pokémon to check
; output:
;   carry: set if the Pokémon at the given location has some attached energies
; preserves: hl, bc
IsEnergizedPokemon:
	ld e, a
	call GetPlayAreaCardAttachedEnergies  ; preserves hl, bc, de
	ld a, [wTotalAttachedEnergies]
	cp 1
	ccf
	ret


; input:
;   [hTempPlayAreaLocation_ff9d]: PLAY_AREA_* of the Pokémon to check
CardTypeTest_IsNonEnergizedPokemon:
	ldh a, [hTempPlayAreaLocation_ff9d]
	push de
	jp IsNonEnergizedPokemon  ; preserves hl, bc
	pop de
	ret

; input:
;   a: PLAY_AREA_* of the Pokémon to check
; output:
;   carry: set if the Pokémon at the given location does not have attached energies
; preserves: hl, bc
IsNonEnergizedPokemon:
	ld e, a
	call GetPlayAreaCardAttachedEnergies  ; preserves hl, bc, de
	ld a, [wTotalAttachedEnergies]
	cp 1
	ret


CardTypeTest_IsMagmar:
	ld a, [wDynamicFunctionArgument]
	; fallthrough

; input:
;   a: deck index of the card
; output:
;   carry: set if the given card is Magmar
; preserves: hl, bc, de
IsMagmarCard:
	call LoadCardDataToBuffer2_FromDeckIndex  ; preserves hl, bc, de
	; ld a, [wLoadedCard2Type]
	; cp TYPE_PKMN + 1
	; ret nc  ; not a Pokémon card
	ld a, [wLoadedCard2ID]
	cp MAGMAR_LV24
	jr z, .found
	cp MAGMAR_LV31
	jr z, .found
; must avoid accidental carry because of smaller ID number
	or a
	ret  ; not a Magmar card
.found
	scf
	ret


; input:
;   [wDynamicFunctionArgument]: deck index of the Pokémon card
;   [hTempPlayAreaLocation_ff9d]: PLAY_AREA_* of the Pokémon to check
; output:
;   carry: set if the given Pokémon is a Magmar with some attached energies
; preserves: hl, bc, de
CardTypeTest_IsEnergizedMagmar:
	ld a, [wDynamicFunctionArgument]
	call IsMagmarCard  ; preserves hl, bc, de
	ret nc  ; not a Magmar card
	ldh a, [hTempPlayAreaLocation_ff9d]
	push de
	call IsEnergizedPokemon  ; preserves hl, bc
	pop de
	ret


CardTypeTest_IsElectabuzz:
	ld a, [wDynamicFunctionArgument]
	; fallthrough

; input:
;   a: deck index of the card
; output:
;   carry: set if the given card is Electabuzz
; preserves: hl, bc, de
IsElectabuzzCard:
	call LoadCardDataToBuffer2_FromDeckIndex  ; preserves hl, bc, de
	; ld a, [wLoadedCard2Type]
	; cp TYPE_PKMN + 1
	; ret nc  ; not a Pokémon card
	ld a, [wLoadedCard2ID]
	cp ELECTABUZZ_LV20
	jr z, .found
	cp ELECTABUZZ_LV35
	jr z, .found
; must avoid accidental carry because of smaller ID number
	or a
	ret  ; not an Electabuzz card
.found
	scf
	ret


; input:
;   [wDynamicFunctionArgument]: deck index of the Pokémon card
;   [hTempPlayAreaLocation_ff9d]: PLAY_AREA_* of the Pokémon to check
; output:
;   carry: set if the given Pokémon is an Electabuzz with some attached energies
; preserves: hl, bc, de
CardTypeTest_IsEnergizedElectabuzz:
	ld a, [wDynamicFunctionArgument]
	call IsElectabuzzCard  ; preserves hl, bc, de
	ret nc  ; not an Electabuzz card
	ldh a, [hTempPlayAreaLocation_ff9d]
	push de
	call IsEnergizedPokemon  ; preserves hl, bc
	pop de
	ret


; input:
;   [hTempPlayAreaLocation_ff9d]: PLAY_AREA_* of the Pokémon to check
;   [hTempCardIndex_ff98]: deck index of the desired Evolution Pokémon
; output:
;   carry: set if the given Pokémon can evolve into the stored Pokémon card
; preserves: hl, bc, de
CardTypeTest_EvolvesIntoStoredCard:
	push hl
	push de
	ldh a, [hTempPlayAreaLocation_ff9d]
	ld e, a
	ldh a, [hTempCardIndex_ff98]
	ld d, a
	call CheckIfCanEvolveInto
	pop de
	pop hl
	ccf
	ret c  ; compatible evolution
	ret z  ; incompatible evolution
	scf
	ret    ; unable to evolve, but only due to being played this turn


; input:
;   [wDynamicFunctionArgument]: deck index of the Evolution card to check
;   [hTempPlayAreaLocation_ff9d]: PLAY_AREA_* of the evolving Pokémon
; output:
;   carry: set if the given card is an evolution of the stored Play Area Pokémon
; preserves: hl, bc, de
CardTypeTest_IsEvolutionOfPlayArea:
	push hl
	push de
	ldh a, [hTempPlayAreaLocation_ff9d]
	ld e, a
	ld a, [wDynamicFunctionArgument]
	ld d, a
	call CheckIfCanEvolveInto
	pop de
	pop hl
	ccf
	ret c  ; compatible evolution
	ret z  ; incompatible evolution
	scf
	ret    ; unable to evolve, but only due to being played this turn


CardTypeTest_IsGrassCard:
	ld a, [wDynamicFunctionArgument]
	; fallthrough

; input:
;   a: deck index of the card
; output:
;   a: TYPE_* of the given card
;   carry: set if the given card is a Grass Pokémon or Energy
; preserves: hl, bc, de
IsGrassCard:
	call LoadCardDataToBuffer2_FromDeckIndex  ; preserves hl, bc, de
	ld a, [wLoadedCard2Type]
	cp TYPE_PKMN_GRASS
	jr z, .match
	cp TYPE_ENERGY_GRASS
	jr z, .match
	or a  ; reset carry
	ret   ; not a Grass card
.match
	scf
	ret


; ------------------------------------------------------------------------------
; Compound Checks
; ------------------------------------------------------------------------------

ThunderWave_PreconditionCheck:
	call CheckEnteredActiveSpotThisTurn
	ret nc  ; active this turn
	jp CheckArenaPokemonHasAnyEnergiesAttached


MagneticCharge_PreconditionCheck:
	call CheckBenchIsNotEmpty
	ret c  ; no bench
	jp CreateEnergyCardListFromDiscardPile_OnlyBasic


WickedTentacle_PreconditionCheck:
	call SwapTurn
	call CheckBenchIsNotEmpty
	call nc, CheckArenaPokemonHasAnyEnergiesAttached
	jp SwapTurn
