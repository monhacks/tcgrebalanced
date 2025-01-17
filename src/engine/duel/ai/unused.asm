; ------------------------------------------------------------------------------
; Pokémon Powers
; ------------------------------------------------------------------------------




HandleAIDualTypeFighting:
	ld a, c
	or a
	ret nz ; return if this is not Arena card

	ldh [hTemp_ffa0], a
	call GetArenaCardColor
	call TranslateColorToWR
	ld b, a
	call SwapTurn
	call GetArenaCardWeakness
	ld [wAIDefendingPokemonWeakness], a
	call SwapTurn
	or a
	ret z ; return if Defending Pokemon has no weakness
	and b
	ret nz ; return if this is already Defending card's weakness type

	ld a, b
	cp WR_FIGHTING
	jr nz, .other_color

; already fighting type
	call SwapTurn
	call GetArenaCardResistance
	call SwapTurn
	cp WR_FIGHTING
	ret nz
	jp HandleAIDecideToUsePokemonPower  ; change type if resistant to Fighting

.other_color
	ld a, [wAIDefendingPokemonWeakness]
	cp WR_FIGHTING
	ret nz
; change type if weak to Fighting
	jp HandleAIDecideToUsePokemonPower




; checks whether AI uses Peek.
; input:
;	c = Play Area location (PLAY_AREA_*) of Mankey.
HandleAIPeek:
	ld a, c
	ldh [hTemp_ffa0], a
	ld a, 50
	call Random
	cp 3
	ret nc ; return 47 out of 50 times

; choose what to use Peek on at random
	ld a, 3
	call Random
	or a
	jr z, .check_ai_prizes
	cp 2
	jr c, .check_player_hand

; check Player's Deck
	ld a, DUELVARS_NUMBER_OF_CARDS_NOT_IN_DECK
	call GetNonTurnDuelistVariable
	cp DECK_SIZE - 1
	ret nc ; return if Player has one or no cards in Deck
	ld a, AI_PEEK_TARGET_DECK
	jr .use_peek

.check_ai_prizes
	ld a, DUELVARS_PRIZES
	call GetTurnDuelistVariable
	ld hl, wAIPeekedPrizes
	and [hl]
	ld [hl], a
	or a
	ret z ; return if no prizes

	ld c, a
	ld b, $1
	ld d, 0
.loop_prizes
	ld a, c
	and b
	jr nz, .found_prize
	sla b
	inc d
	jr .loop_prizes
.found_prize
; remove this prize's flag from the prize list
; and use Peek on first one in list (lowest bit set)
	ld a, c
	sub b
	ld [hl], a
	ld a, AI_PEEK_TARGET_PRIZE
	add d
	jr .use_peek

.check_player_hand
	call SwapTurn
	call CreateHandCardList
	call SwapTurn
	or a
	ret z ; return if no cards in Hand
; shuffle list and pick the first entry to Peek
	ld hl, wDuelTempList
	call CountCardsInDuelTempList
	call ShuffleCards
	ld a, [wDuelTempList]
	or AI_PEEK_TARGET_HAND

.use_peek
	push af
	ld a, [wAITempVars]
	ldh [hTempCardIndex_ff9f], a
	ld a, OPPACTION_USE_PKMN_POWER
	bank1call AIMakeDecision
	pop af
	ldh [hAIPkmnPowerEffectParam], a
	ld a, OPPACTION_EXECUTE_PKMN_POWER_EFFECT
	bank1call AIMakeDecision
	ld a, OPPACTION_DUEL_MAIN_SCENE
	bank1call AIMakeDecision
	ret



; handles AI logic for attaching energy cards
HandleAIRainDanceEnergy:
	; ld a, [wAlreadyPlayedEnergyOrSupporter]
	; and USED_RAIN_DANCE_THIS_TURN
	; ret nz ; return if Rain Dance was used this turn

	ld a, WARTORTLE
	call CountPokemonIDInPlayArea
	ret nc ; return if no Wartortle

	call ArePokemonPowersDisabled
	ret c ; return if there's Weezing in play

; play all the energy cards that is needed.
.loop
	farcall AIProcessAndTryToPlayEnergy
	jr c, .loop
	ret


; AI logic for Damage Swap to transfer damage from Arena card
; to a card in Bench with more than 10 HP remaining
; and with no energy cards attached.
HandleAIDamageSwap:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	dec a
	ret z ; return if no Bench Pokemon

	farcall AIChooseRandomlyNotToDoAction
	ret c

	ld a, ALAKAZAM
	call CountPokemonIDInPlayArea
	ret nc ; return if no Alakazam
	call ArePokemonPowersDisabled
	ret c ; return if there's Weezing in play

; only take damage off certain cards in Arena
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call GetCardIDFromDeckIndex
	ld a, e
	cp ALAKAZAM
	jr z, .ok
	cp KADABRA
	jr z, .ok
	cp ABRA
	jr z, .ok
	cp MR_MIME
	ret nz

.ok
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
	or a
	ret z ; return if no damage

	call ConvertHPToCounters
	ld [wce06], a
	ld a, ALAKAZAM
	ld b, PLAY_AREA_BENCH_1
	farcall LookForCardIDInPlayArea_Bank5
	jr c, .is_in_bench

; Alakazam is Arena card
	xor a
.is_in_bench
	ld [wAITempVars], a
	call .CheckForDamageSwapTargetInBench
	ret c ; return if not found

; use Damage Swap
	ld a, [wAITempVars]
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	ldh [hTempCardIndex_ff9f], a
	ld a, [wAITempVars]
	ldh [hTemp_ffa0], a
	ld a, OPPACTION_USE_PKMN_POWER
	bank1call AIMakeDecision
	ld a, OPPACTION_EXECUTE_PKMN_POWER_EFFECT
	bank1call AIMakeDecision

	ld a, [wce06]
	ld e, a
.loop_damage
	ld d, 30
	call AIDelayFrames_D

	push de
	call .CheckForDamageSwapTargetInBench
	jr c, .no_more_target

	ldh [hTempRetreatCostCards], a
	xor a ; PLAY_AREA_ARENA
	ldh [hAIPkmnPowerEffectParam], a
	ld a, OPPACTION_EXECUTE_EFFECT_STEP
	bank1call AIMakeDecision
	pop de
	dec e
	jr nz, .loop_damage

.done
; return to main scene
	ld d, 60
	call AIDelayFrames_D
	ld a, OPPACTION_DUEL_MAIN_SCENE
	bank1call AIMakeDecision
	ret

.no_more_target
	pop de
	jr .done

; looks for a target in the bench to receive damage counters.
; returns carry if one is found, and outputs remaining HP in a.
.CheckForDamageSwapTargetInBench ; 2273c (8:673c)
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld b, a
	ld c, PLAY_AREA_BENCH_1
	lb de, $ff, $ff

; look for candidates in bench to get the damage counters
; only target specific card IDs.
.loop_bench
	ld a, c
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	push de
	call GetCardIDFromDeckIndex
	ld a, e
	pop de
	cp CHANSEY
	jr z, .found_candidate
	cp KANGASKHAN
	jr z, .found_candidate
	cp SNORLAX
	jr z, .found_candidate
	cp MR_MIME
	jr z, .found_candidate

.next_play_area
	inc c
	ld a, c
	cp b
	jr nz, .loop_bench

; done
	ld a, e
	cp $ff
	jr nz, .no_carry
	ld a, d
	cp $ff
	jr z, .set_carry
.no_carry
	or a
	ret

.found_candidate
; found a potential candidate to receive damage counters
	ld a, DUELVARS_ARENA_CARD_HP
	add c
	call GetTurnDuelistVariable
	cp 20
	jr c, .next_play_area ; ignore cards with only 10 HP left

	ld d, c ; store damage
	push de
	push bc
	ld e, c
	farcall CountNumberOfEnergyCardsAttached
	pop bc
	pop de
	or a
	jr nz, .next_play_area ; ignore cards with attached energy
	ld e, c ; store deck index
	jr .next_play_area

.set_carry
	scf
	ret


; checks whether AI uses Curse.
; input:
;	c = Play Area location (PLAY_AREA_*) of Gengar.
HandleAICurse:
	ld a, c
	ldh [hTemp_ffa0], a

; loop Player's Play Area and checks their damage.
; finds the card with lowest remaining HP and
; stores its HP and its Play Area location
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetNonTurnDuelistVariable
	ld d, a
	ld e, PLAY_AREA_ARENA
	lb bc, 0, $ff
	ld h, PLAY_AREA_ARENA
	call SwapTurn
.loop_play_area_1
	push bc
	call GetCardDamageAndMaxHP
	pop bc
	or a
	jr z, .next_1

	inc b
	ld a, e
	add DUELVARS_ARENA_CARD_HP
	push hl
	call GetTurnDuelistVariable
	pop hl
	cp c
	jr nc, .next_1
	; lower HP than one stored
	ld c, a ; store this HP
	ld h, e ; store this Play Area location

.next_1
	inc e
	ld a, e
	cp d
	jr nz, .loop_play_area_1 ; reached end of Play Area

	ld a, 1
	cp b
	jr nc, .failed ; return if less than 2 cards with damage

; card in Play Area with lowest HP remaining was found.
; look for another card to take damage counter from.
	ld a, h
	ldh [hTempRetreatCostCards], a
	ld b, a
	ld a, 10
	cp c
	jr z, .hp_10_remaining
	; if has more than 10 HP remaining,
	; skip Arena card in choosing which
	; card to take damage counter from.
	ld e, PLAY_AREA_BENCH_1
	jr .second_card

.hp_10_remaining
	; if Curse can KO, then include
	; Player's Arena card to take
	; damage counter from.
	ld e, PLAY_AREA_ARENA

.second_card
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld d, a
.loop_play_area_2
	ld a, e
	cp b
	jr z, .next_2 ; skip same Pokemon card
	push bc
	call GetCardDamageAndMaxHP
	pop bc
	jr nz, .use_curse ; has damage counters, choose this card
.next_2
	inc e
	ld a, e
	cp d
	jr nz, .loop_play_area_2

.failed
	call SwapTurn
	or a
	ret

.use_curse
	ld a, e
	ldh [hAIPkmnPowerEffectParam], a
	call SwapTurn
	ld a, [wAITempVars]
	ldh [hTempCardIndex_ff9f], a
	ld a, OPPACTION_USE_PKMN_POWER
	bank1call AIMakeDecision
	ld a, OPPACTION_EXECUTE_PKMN_POWER_EFFECT
	bank1call AIMakeDecision
	ld a, OPPACTION_DUEL_MAIN_SCENE
	bank1call AIMakeDecision
	ret


; ------------------------------------------------------------------------------
; Trainer Cards
; ------------------------------------------------------------------------------

AIDecide_ComputerSearch_RockCrusher:
; if number of cards in hand is equal to 3,
; target Professor Oak in deck
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetTurnDuelistVariable
	cp 3
	jr nz, .graveler

	ld e, PROFESSOR_OAK
	ld a, CARD_LOCATION_DECK
	call LookForCardIDInLocation
	jr c, .find_discard_cards_1
	; no Professor Oak in deck, fallthrough

.no_carry
	or a
	ret

.find_discard_cards_1
	ld [wce06], a
	ld a, $ff
	ld [wce1a], a
	ld [wce1b], a

	call CreateHandCardList
	ld hl, wDuelTempList
	ld de, wce1a
.loop_hand_1
	ld a, [hli]
	cp $ff
	jr z, .check_discard_cards

	ld c, a
	call LoadCardDataToBuffer1_FromDeckIndex

; if any of the following cards are in the hand,
; return no carry.
	cp PROFESSOR_OAK
	jr z, .no_carry
	cp FIGHTING_ENERGY
	jr z, .no_carry
	cp DOUBLE_COLORLESS_ENERGY
	jr z, .no_carry
	cp DIGLETT
	jr z, .no_carry
	cp GEODUDE
	jr z, .no_carry
	cp ONIX
	jr z, .no_carry
	cp RHYHORN
	jr z, .no_carry

; if it's same as wAITrainerCardToPlay, skip this card.
	ld a, [wAITrainerCardToPlay]
	ld b, a
	ld a, c
	cp b
	jr z, .loop_hand_1

; store this card index in memory
	ld [de], a
	inc de
	jr .loop_hand_1

.check_discard_cards
; check if two cards were found
; if so, output in a the deck index
; of Professor Oak card found in deck and set carry.
	ld a, [wce1b]
	cp $ff
	jr z, .no_carry
	ld a, [wce06]
	scf
	ret

; more than 3 cards in hand, so look for
; specific evolution cards.

; checks if there is a Graveler card in the deck to target.
; if so, check if there's Geodude in hand or Play Area,
; and if there's no Graveler card in hand, proceed.
; also removes Geodude from hand list so that it is not discarded.
.graveler
	ld e, GRAVELER
	ld a, CARD_LOCATION_DECK
	call LookForCardIDInLocation
	jr nc, .golem
	ld [wce06], a
	ld a, GEODUDE
	call LookForCardIDInHandAndPlayArea
	jr nc, .golem
	ld a, GRAVELER
	call LookForCardIDInHandList_Bank8
	jr c, .golem
	call CreateHandCardList
	ld hl, wDuelTempList
	ld e, GEODUDE
	farcall RemoveCardIDInList
	jr .find_discard_cards_2

; checks if there is a Golem card in the deck to target.
; if so, check if there's Graveler in Play Area,
; and if there's no Golem card in hand, proceed.
.golem
	ld e, GOLEM
	ld a, CARD_LOCATION_DECK
	call LookForCardIDInLocation
	jr nc, .dugtrio
	ld [wce06], a
	ld a, GRAVELER
	call LookForCardIDInPlayArea_Bank8
	jr nc, .dugtrio
	ld a, GOLEM
	call LookForCardIDInHandList_Bank8
	jr c, .dugtrio
	call CreateHandCardList
	ld hl, wDuelTempList
	jr .find_discard_cards_2

; checks if there is a Dugtrio card in the deck to target.
; if so, check if there's Diglett in Play Area,
; and if there's no Dugtrio card in hand, proceed.
.dugtrio
	ld e, DUGTRIO
	ld a, CARD_LOCATION_DECK
	call LookForCardIDInLocation
	jp nc, .no_carry
	ld [wce06], a
	ld a, DIGLETT
	call LookForCardIDInPlayArea_Bank8
	jp nc, .no_carry
	ld a, DUGTRIO
	call LookForCardIDInHandList_Bank8
	jp c, .no_carry
	call CreateHandCardList
	ld hl, wDuelTempList
	jr .find_discard_cards_2

.find_discard_cards_2
	ld a, $ff
	ld [wce1a], a
	ld [wce1b], a

	ld bc, wce1a
	ld d, $00 ; start considering Trainer cards only

; stores wAITrainerCardToPlay in e so that
; all routines ignore it for the discard effects.
	ld a, [wAITrainerCardToPlay]
	ld e, a

; this loop will store in wce1a cards to discard from hand.
; at the start it will only consider Trainer cards,
; then if there are still needed to discard,
; move on to Pokemon cards, and finally to Energy cards.
.loop_hand_2
	call RemoveFromListDifferentCardOfGivenType
	jr c, .found
	inc d ; move on to next type (Pokemon, then Energy)
	ld a, $03
	cp d
	jp z, .no_carry ; no more types to look
	jr .loop_hand_2
.found
; store this card in memory,
; and if there's still one more card to search for,
; jump back into the loop.
	ld [bc], a
	inc bc
	ld a, [wce1b]
	cp $ff
	jr z, .loop_hand_2

; output in a Computer Search target and set carry.
	ld a, [wce06]
	scf
	ret

AIDecide_ComputerSearch_WondersOfScience:
; if number of cards in hand < 5, target Professor Oak in deck
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetTurnDuelistVariable
	cp 5
	jr nc, .look_in_hand

; target Professor Oak for Computer Search
	ld e, PROFESSOR_OAK
	ld a, CARD_LOCATION_DECK
	call LookForCardIDInLocation
	jp nc, .look_in_hand ; can be a jr
	ld [wce06], a
	jr .find_discard_cards

; Professor Oak not in deck, move on to
; look for other cards instead.
; if Koffing or Weezing are not in hand,
; check whether to use Computer Search on them.
.look_in_hand
	ld a, KOFFING
	call LookForCardIDInHandList_Bank8
	jr nc, .target_koffing
	ld a, WEEZING
	call LookForCardIDInHandList_Bank8
	jr nc, .target_weezing

.no_carry
	or a
	ret

; first check Koffing
; if in deck, check cards to discard.
.target_koffing
	ld e, KOFFING
	ld a, CARD_LOCATION_DECK
	call LookForCardIDInLocation
	jp nc, .no_carry ; can be a jr
	ld [wce06], a
	jr .find_discard_cards

; first check Weezing
; if in deck, check cards to discard.
.target_weezing
	ld e, WEEZING
	ld a, CARD_LOCATION_DECK
	call LookForCardIDInLocation
	jp nc, .no_carry ; can be a jr
	ld [wce06], a

; only discard Trainer cards from hand.
; if there are less than 2 Trainer cards to discard,
; then return with no carry.
; else, store the cards to discard and the
; target card deck index, and return carry.
.find_discard_cards
	call CreateHandCardList
	ld hl, wDuelTempList
	ld d, $00 ; first consider Trainer cards

; ignore wAITrainerCardToPlay for the discard effects.
	ld a, [wAITrainerCardToPlay]
	ld e, a
	call RemoveFromListDifferentCardOfGivenType
	jr nc, .no_carry
	ld [wce1a], a
	call RemoveFromListDifferentCardOfGivenType
	jr nc, .no_carry
	ld [wce1b], a
	ld a, [wce06]
	scf
	ret

AIDecide_ComputerSearch_FireCharge:
; pick target card in deck from highest to lowest priority.
; if not found in hand, go to corresponding branch.
	ld a, CHANSEY
	call LookForCardIDInHandList_Bank8
	jr nc, .chansey
	ld a, TAUROS
	call LookForCardIDInHandList_Bank8
	jr nc, .tauros
	ld a, JIGGLYPUFF
	call LookForCardIDInHandList_Bank8
	jr nc, .jigglypuff
	; fallthrough

.no_carry
	or a
	ret

; for each card targeted, check if it's in deck and,
; if not, then return no carry.
; else, look for cards to discard.
.chansey
	ld e, CHANSEY
	ld a, CARD_LOCATION_DECK
	call LookForCardIDInLocation
	jp nc, .no_carry
	ld [wce06], a
	jr .find_discard_cards
.tauros
	ld e, TAUROS
	ld a, CARD_LOCATION_DECK
	call LookForCardIDInLocation
	jp nc, .no_carry
	ld [wce06], a
	jr .find_discard_cards
.jigglypuff
	ld e, JIGGLYPUFF
	ld a, CARD_LOCATION_DECK
	call LookForCardIDInLocation
	jp nc, .no_carry
	ld [wce06], a

; only discard Trainer cards from hand.
; if there are less than 2 Trainer cards to discard,
; then return with no carry.
; else, store the cards to discard and the
; target card deck index, and return carry.
.find_discard_cards
	call CreateHandCardList
	ld hl, wDuelTempList
	ld d, $00 ; first consider Trainer cards

; ignore wAITrainerCardToPlay for the discard effects.
	ld a, [wAITrainerCardToPlay]
	ld e, a
	call RemoveFromListDifferentCardOfGivenType
	jr nc, .no_carry
	ld [wce1a], a
	call RemoveFromListDifferentCardOfGivenType
	jr nc, .no_carry
	ld [wce1b], a
	ld a, [wce06]
	scf
	ret

AIDecide_ComputerSearch_Anger:
; for each of the following cards,
; first run a check if there's a pre-evolution in
; Play Area or in the hand. If there is, choose it as target.
; otherwise, check if the evolution card is in
; hand and if so, choose it as target instead.
	ld b, RATTATA
	ld a, RATICATE
	call LookForCardIDInDeck_GivenCardIDInHandAndPlayArea
	jr c, .find_discard_cards
	ld a, RATTATA
	ld b, RATICATE
	call LookForCardIDInDeck_GivenCardIDInHand
	jr c, .find_discard_cards
	ld b, GROWLITHE
	ld a, ARCANINE_LV34
	call LookForCardIDInDeck_GivenCardIDInHandAndPlayArea
	jr c, .find_discard_cards
	ld a, GROWLITHE
	ld b, ARCANINE_LV34
	call LookForCardIDInDeck_GivenCardIDInHand
	jr c, .find_discard_cards
	ld b, DODUO
	ld a, DODRIO
	call LookForCardIDInDeck_GivenCardIDInHandAndPlayArea
	jr c, .find_discard_cards
	ld a, DODUO
	ld b, DODRIO
	call LookForCardIDInDeck_GivenCardIDInHand
	jr c, .find_discard_cards
	; fallthrough

.no_carry
	or a
	ret

; only discard Trainer cards from hand.
; if there are less than 2 Trainer cards to discard,
; then return with no carry.
; else, store the cards to discard and the
; target card deck index, and return carry.
.find_discard_cards
	ld [wce06], a
	call CreateHandCardList
	ld hl, wDuelTempList
	ld d, $00 ; first consider Trainer cards

; ignore wAITrainerCardToPlay for the discard effects.
	ld a, [wAITrainerCardToPlay]
	ld e, a
	call RemoveFromListDifferentCardOfGivenType
	jr nc, .no_carry
	ld [wce1a], a
	call RemoveFromListDifferentCardOfGivenType
	jr nc, .no_carry
	ld [wce1b], a
	ld a, [wce06]
	scf
	ret



;

AIPlay_SuperEnergyRemoval:
	ld a, [wAITrainerCardToPlay]
	ldh [hTempCardIndex_ff9f], a
	ld a, [wAITrainerCardParameter]
	ldh [hTemp_ffa0], a
	ld a, [wce1a]
	ldh [hTempPlayAreaLocation_ffa1], a
	ld a, [wce1b]
	ldh [hTempRetreatCostCards], a
	ld a, [wce1c]
	ldh [hTempRetreatCostCards + 1], a
	ld a, [wce1d]
	ldh [hTempRetreatCostCards + 2], a
	ld a, $ff
	ldh [hTempRetreatCostCards + 3], a
	ld a, OPPACTION_EXECUTE_TRAINER_EFFECTS
	bank1call AIMakeDecision
	ret

; picks two energy cards in the player's Play Area to remove
AIDecide_SuperEnergyRemoval:
	ld e, PLAY_AREA_BENCH_1
.loop_1
; first find an Arena card with a color energy card
; to discard for card effect
; return immediately if no Arena cards
	ld a, DUELVARS_ARENA_CARD
	add e
	call GetTurnDuelistVariable
	cp $ff
	jr z, .exit

	ld d, a
	push de
	call .LookForNonDoubleColorless
	pop de
	jr c, .not_double_colorless
	inc e
	jr .loop_1

; returns carry if an energy card other than double colorless
; is found attached to the card in play area location e
.LookForNonDoubleColorless
	ld a, e
	call CreateArenaOrBenchEnergyCardList
	ld hl, wDuelTempList
.loop_2
	ld a, [hli]
	cp $ff
	ret z
	call LoadCardDataToBuffer1_FromDeckIndex
	cp DOUBLE_COLORLESS_ENERGY
	; any basic energy card
	; will set carry flag here
	jr nc, .loop_2
	ret

.exit
	or a
	ret

; card in Play Area location e was found with
; a basic energy card
.not_double_colorless
	ld a, e
	ld [wce0f], a

; check if the current active card can KO player's card
; if it's possible to KO, then do not consider the player's
; active card to remove its attached energy
	xor a ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ff9d], a
	farcall CheckIfAnyAttackKnocksOutDefendingCard
	jr nc, .cannot_ko
	farcall CheckIfSelectedAttackIsUnusable
	jr nc, .can_ko
	farcall LookForEnergyNeededForAttackInHand
	jr nc, .cannot_ko

.can_ko
	; start checking from the bench
	call SwapTurn
	ld e, PLAY_AREA_BENCH_1
	jr .loop_3
.cannot_ko
	; start checking from the arena card
	call SwapTurn
	ld e, PLAY_AREA_ARENA

; loop each card and check if it has enough energy to use any attack
; if it does, then proceed to pick energy cards to remove
.loop_3
	ld a, DUELVARS_ARENA_CARD
	add e
	call GetTurnDuelistVariable
	cp $ff
	jr z, .no_carry

	ld d, a
	call .CheckIfFewerThanTwoEnergyCards
	jr c, .next_1
	call .CheckIfNotEnoughEnergyToAttack
	jr nc, .found_card ; jump if enough energy to attack
.next_1
	inc e
	jr .loop_3

.found_card
; a play area card was picked to remove energy
; if this is not the Arena Card, then check
; entire bench to pick the highest damage
	ld a, e
	or a
	jr nz, .check_bench_damage

; store the picked energy card to remove in wce1a
; and set carry
.pick_energy
	ld [wce1b], a
	call PickTwoAttachedEnergyCards
	ld [wce1c], a
	ld a, b
	ld [wce1d], a
	call SwapTurn
	ld a, [wce0f]
	push af
	call AIPickEnergyCardToDiscard
	ld [wce1a], a
	pop af
	scf
	ret

; check what attack on player's Play Area is highest damaging
; and pick an energy card attached to that Pokemon to remove
.check_bench_damage
	xor a
	ld [wce06], a
	ld [wAITempVars], a

	ld e, PLAY_AREA_BENCH_1
.loop_4
	ld a, DUELVARS_ARENA_CARD
	add e
	call GetTurnDuelistVariable
	cp $ff
	jr z, .found_damage

	ld d, a
	call .CheckIfFewerThanTwoEnergyCards
	jr c, .next_2
	call .CheckIfNotEnoughEnergyToAttack
	jr c, .next_2
	call .FindHighestDamagingAttack
.next_2
	inc e
	jr .loop_4

.found_damage
	ld a, [wAITempVars]
	or a
	jr z, .no_carry
	jr .pick_energy
.no_carry
	call SwapTurn
	or a
	ret

; returns carry if the number of energy cards attached
; is fewer than 2, or if all energy combined yields
; fewer than 2 energy
.CheckIfFewerThanTwoEnergyCards
	call GetPlayAreaCardAttachedEnergies
	ld a, [wTotalAttachedEnergies]
	cp 2
	ret c ; return if fewer than 2 attached cards

; count all energy attached
; i.e. colored energy card = 1
; and double colorless energy card = 2
	xor a
	ld b, NUM_COLORED_TYPES
	ld hl, wAttachedEnergies
.loop_5
	add [hl]
	inc hl
	dec b
	jr nz, .loop_5
	ld b, [hl]
	srl b
	add b
	cp 2
	ret

; returns carry if this card does not
; have enough energy for either of its attacks
.CheckIfNotEnoughEnergyToAttack
	push de
	xor a ; FIRST_ATTACK_OR_PKMN_POWER
	ld [wSelectedAttack], a
	ld a, e
	ldh [hTempPlayAreaLocation_ff9d], a
	farcall CheckEnergyNeededForAttack
	jr nc, .enough_energy
	pop de

	push de
	ld a, SECOND_ATTACK
	ld [wSelectedAttack], a
	ld a, e
	ldh [hTempPlayAreaLocation_ff9d], a
	farcall CheckEnergyNeededForAttack
	jr nc, .check_surplus
	pop de

; neither attack has enough energy
	scf
	ret

.enough_energy
	pop de
	or a
	ret

; first attack doesn't have enough energy (or is just a Pokemon Power)
; but second attack has enough energy to be used
; check if there's surplus energy for attack and, if so,
; return carry if this surplus energy is at least 2
.check_surplus
	farcall CheckIfNoSurplusEnergyForAttack
	cp 2
	jr c, .enough_energy
	pop de
	scf
	ret

; stores in wce06 the highest damaging attack
; for the card in play area location in e
; and stores this card's location in wAITempVars
.FindHighestDamagingAttack
	push de
	ld a, e
	ldh [hTempPlayAreaLocation_ff9d], a

	xor a ; FIRST_ATTACK_OR_PKMN_POWER
	farcall EstimateDamage_VersusDefendingCard
	ld a, [wDamage]
	or a
	jr z, .skip_1
	ld e, a
	ld a, [wce06]
	cp e
	jr nc, .skip_1
	ld a, e
	ld [wce06], a ; store this damage value
	pop de
	ld a, e
	ld [wAITempVars], a ; store this location
	jr .second_attack

.skip_1
	pop de

.second_attack
	push de
	ld a, e
	ldh [hTempPlayAreaLocation_ff9d], a

	ld a, SECOND_ATTACK
	farcall EstimateDamage_VersusDefendingCard
	ld a, [wDamage]
	or a
	jr z, .skip_2
	ld e, a
	ld a, [wce06]
	cp e
	jr nc, .skip_2
	ld a, e
	ld [wce06], a ; store this damage value
	pop de
	ld a, e
	ld [wAITempVars], a ; store this location
	ret
.skip_2
	pop de
	ret



;

AIPlay_SuperEnergyRetrieval:
	ld a, [wCurrentAIFlags]
	or AI_FLAG_MODIFIED_HAND
	ld [wCurrentAIFlags], a
	ld a, [wAITrainerCardToPlay]
	ldh [hTempCardIndex_ff9f], a
	ld a, [wAITrainerCardParameter]
	ldh [hTemp_ffa0], a
	ld a, [wce1a]
	ldh [hTempPlayAreaLocation_ffa1], a
	ld a, [wce1b]
	ldh [hTempRetreatCostCards], a
	ld a, [wce1c]
	ldh [$ffa3], a
	cp $ff
	jr z, .asm_20fbb
	ld a, [wce1d]
	ldh [$ffa4], a
	cp $ff
	jr z, .asm_20fbb
	ld a, [wce1e]
	ldh [$ffa5], a
	cp $ff
	jr z, .asm_20fbb
	ld a, $ff
	ldh [$ffa6], a
.asm_20fbb
	ld a, OPPACTION_EXECUTE_TRAINER_EFFECTS
	bank1call AIMakeDecision
	ret

AIDecide_SuperEnergyRetrieval:
; return no carry if no cards in hand
	farcall CreateEnergyCardListFromHand
	jp nc, .no_carry

; handle Rain Dance deck
; return no carry if there's no Weezing card in play and
; if there's no Wartortle card in Play Area
; if there's a Weezing in play, continue as normal
	; ld a, [wOpponentDeckID]
	; cp GO_GO_RAIN_DANCE_DECK_ID
	; jr nz, .start
	call ArePokemonPowersDisabled
	jr c, .start
	ld a, WARTORTLE
	call CountPokemonIDInPlayArea
	jp nc, .no_carry

.start
; find duplicate cards in hand
	call CreateHandCardList
	ld hl, wDuelTempList
	call FindDuplicateCards
	jp c, .no_carry

; remove the duplicate card in hand
; and run the hand check again
	ld [wce06], a
	ld hl, wDuelTempList
	call FindAndRemoveCardFromList
	call FindDuplicateCards
	jp c, .no_carry

	ld [wAITempVars], a
	ld a, CARD_LOCATION_DISCARD_PILE
	call FindBasicEnergyCardsInLocation
	jp c, .no_carry

; some basic energy cards were found in Discard Pile
	ld a, $ff
	ld [wce1b], a
	ld [wce1c], a
	ld [wce1d], a
	ld [wce1e], a
	ld [wce1f], a

	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld d, a
	ld e, PLAY_AREA_ARENA

; first check if there are useful energy cards in the list
; and choose them for retrieval first
.loop_play_area
	ld a, DUELVARS_ARENA_CARD
	add e
	push de

; load this card's ID in wTempCardID
; and this card's Type in wTempCardType
	call GetTurnDuelistVariable
	call GetCardIDFromDeckIndex
	ld a, e
	ld [wTempCardID], a
	call LoadCardDataToBuffer1_FromCardID
	pop de
	ld a, [wLoadedCard1Type]
	or TYPE_ENERGY
	ld [wTempCardType], a

; loop the energy cards in the Discard Pile
; and check if they are useful for this Pokemon
	ld hl, wDuelTempList
.loop_energy_cards_1
	ld a, [hli]
	cp $ff
	jr z, .next_play_area

	ld b, a
	push hl
	farcall CheckIfEnergyIsUseful
	pop hl
	jr nc, .loop_energy_cards_1

; first energy
	ld a, [wce1b]
	cp $ff
	jr nz, .second_energy_1
	ld a, b
	ld [wce1b], a
	call RemoveCardFromList
	jr .next_play_area

.second_energy_1
	ld a, [wce1c]
	cp $ff
	jr nz, .third_energy_1
	ld a, b
	ld [wce1c], a
	call RemoveCardFromList
	jr .next_play_area

.third_energy_1
	ld a, [wce1d]
	cp $ff
	jr nz, .fourth_energy_1
	ld a, b
	ld [wce1d], a
	call RemoveCardFromList
	jr .next_play_area

.fourth_energy_1
	ld a, b
	ld [wce1e], a
	jr .set_carry

.next_play_area
	inc e
	dec d
	jr nz, .loop_play_area

; next, if there are still energy cards left to choose,
; loop through the energy cards again and select
; them in order.
	ld hl, wDuelTempList
.loop_energy_cards_2
	ld a, [hli]
	cp $ff
	jr z, .check_chosen
	ld b, a
	ld a, [wce1b]
	cp $ff
	jr nz, .second_energy_2
	ld a, b

; first energy
	ld [wce1b], a
	call RemoveCardFromList
	jr .loop_energy_cards_2

.second_energy_2
	ld a, [wce1c]
	cp $ff
	jr nz, .third_energy_2
	ld a, b
	ld [wce1c], a
	call RemoveCardFromList
	jr .loop_energy_cards_2

.third_energy_2
	ld a, [wce1d]
	cp $ff
	jr nz, .fourth_energy
	ld a, b
	ld [wce1d], a
	call RemoveCardFromList
	jr .loop_energy_cards_2

.fourth_energy
	ld a, b
	ld [wce1e], a
	jr .set_carry

; will set carry if at least one has been chosen
.check_chosen
	ld a, [wce1b]
	cp $ff
	jr nz, .set_carry

.no_carry
	or a
	ret
.set_carry
	ld a, [wAITempVars]
	ld [wce1a], a
	ld a, [wce06]
	scf
	ret


;

AIPlay_ItemFinder:
	ld a, [wCurrentAIFlags]
	or AI_FLAG_MODIFIED_HAND
	ld [wCurrentAIFlags], a
	ld a, [wAITrainerCardToPlay]
	ldh [hTempCardIndex_ff9f], a
	ld a, [wce1a]
	ldh [hTemp_ffa0], a
	ld a, [wce1b]
	ldh [hTempPlayAreaLocation_ffa1], a
	ld a, [wAITrainerCardParameter]
	ldh [hTempRetreatCostCards], a
	ld a, OPPACTION_EXECUTE_TRAINER_EFFECTS
	bank1call AIMakeDecision
	ret

; checks whether there's Energy Removal in Discard Pile.
; if so, find duplicate cards in hand to discard
; that are not Mr Mime and Pokemon Trader cards.
; this logic is suitable only for Strange Psyshock deck.
AIDecide_ItemFinder:
; skip if no Discard Pile.
	call CreateDiscardPileCardList
	jr c, .no_carry

; look for Energy Removal in Discard Pile
	ld hl, wDuelTempList
.loop_discard_pile
	ld a, [hli]
	cp $ff
	jr z, .no_carry
	ld b, a
	call LoadCardDataToBuffer1_FromDeckIndex
	cp ENERGY_REMOVAL
	jr nz, .loop_discard_pile
; found, store this deck index
	ld a, b
	ld [wce06], a

; before looking for cards to discard in hand,
; remove any Mr Mime and Pokemon Trader cards.
; this way these are guaranteed to not be discarded.
	call CreateHandCardList
	ld hl, wDuelTempList
.loop_hand
	ld a, [hli]
	cp $ff
	jr z, .choose_discard
	ld b, a
	call LoadCardDataToBuffer1_FromDeckIndex
	cp MR_MIME
	jr nz, .pkmn_trader
	call RemoveCardFromList
	jr .loop_hand
.pkmn_trader
	cp POKEMON_TRADER
	jr nz, .loop_hand
	call RemoveCardFromList
	jr .loop_hand

; choose cards to discard from hand.
.choose_discard
	ld hl, wDuelTempList

; do not discard wAITrainerCardToPlay
	ld a, [wAITrainerCardToPlay]
	call FindAndRemoveCardFromList
; find any duplicates, if not found, return no carry.
	call FindDuplicateCards
	jp c, .no_carry

; store the duplicate found in wce1a and
; remove it from the hand list.
	ld [wce1a], a
	ld hl, wDuelTempList
	call FindAndRemoveCardFromList
; find duplicates again, if not found, return no carry.
	call FindDuplicateCards
	jp c, .no_carry

; store the duplicate found in wce1b.
; output the card to be recovered from the Discard Pile.
	ld [wce1b], a
	ld a, [wce06]
	scf
	ret

.no_carry
	or a
	ret


;

AIPlay_Lass:
	ld a, [wCurrentAIFlags]
	or AI_FLAG_MODIFIED_HAND
	ld [wCurrentAIFlags], a
	ld a, [wAITrainerCardToPlay]
	ldh [hTempCardIndex_ff9f], a
	ld a, OPPACTION_EXECUTE_TRAINER_EFFECTS
	bank1call AIMakeDecision
	ret

AIDecide_Lass:
; skip if player has less than 7 cards in hand
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetNonTurnDuelistVariable
	cp 7
	jr c, .no_carry

; look for Trainer cards in hand (except for Lass)
; if any is found, return no carry.
; otherwise, return carry.
	call CreateHandCardList
	ld hl, wDuelTempList
.loop
	ld a, [hli]
	cp $ff
	jr z, .set_carry
	ld b, a
	call LoadCardDataToBuffer1_FromDeckIndex
	cp LASS
	jr z, .loop
	ld a, [wLoadedCard1Type]
; OATS begin support trainer subtypes
	cp TYPE_TRAINER
	jr c, .loop  ; original: jr nz
; OATS end support trainer subtypes
.no_carry
	or a
	ret
.set_carry
	scf
	ret
