; ------------------------------------------------------------------------------
; Card Search
; ------------------------------------------------------------------------------

; searches through Deck in wDuelTempList looking for
; a certain card or cards, and prints text depending
; on whether at least one was found.
; if none were found, asks the Player whether to look
; in the Deck anyway, and returns carry if No is selected.
; uses SEARCHEFFECT_* as input which determines what to search for:
;	SEARCHEFFECT_CARD_ID = search for card ID in e
;	SEARCHEFFECT_POKEMON_OR_BASIC_ENERGY = search for either a Pokémon or a Basic Energy
;	SEARCHEFFECT_GRASS_CARD = search for any Grass card
; input:
;	  d = SEARCHEFFECT_* constant
;	  e = (optional) card ID, play area location or other search parameters
;	  hl = text to print if Deck has card(s)
;	  bc = variable text to fill <RAMTEXT> in hl
; output:
;   a: TRUE if cards were found; FALSE otherwise
;	  carry set if refused to look at deck
LookForCardsInDeck:
	push hl
	push bc
	ld a, [wDuelTempList]
	cp $ff
	jr z, .none_in_deck
	ld a, d
	ld hl, CardSearch_FunctionTable
	call JumpToFunctionInTable
	jr c, .none_in_deck
	pop bc
	pop hl
	call DrawWideTextBox_WaitForInput
	ld a, TRUE
	or a
	ret

.none_in_deck
	pop hl
	call LoadTxRam2
	pop hl
	ldtx hl, ThereIsNoInTheDeckText
	call DrawWideTextBox_WaitForInput
	ldtx hl, WouldYouLikeToCheckTheDeckText
	call YesOrNoMenuWithText_SetCursorToYes
	ld a, FALSE
	ret


CardSearch_FunctionTable:
	dw .SearchDuelTempListForCardID
	dw .SearchDuelTempListForPokemonOrBasicEnergy
	dw .SearchDuelTempListForCardType
	dw .SearchDuelTempListForGrassCard
	dw .SearchDuelTempListMatchingCardPattern

.set_carry
	scf
	ret

; returns carry if no card with same card ID as e is found
.SearchDuelTempListForCardID
	ld hl, wDuelTempList
.loop_list_e
	ld a, [hli]
	cp $ff
	jr z, .set_carry
	push de
	call GetCardIDFromDeckIndex
	ld a, e
	pop de
	cp e
	jr nz, .loop_list_e
	or a
	ret

; returns carry if no Pokémon or Basic Energy card is found
.SearchDuelTempListForPokemonOrBasicEnergy
	ld hl, wDuelTempList
.loop_list_pkmn_or_basic_energy
	ld a, [hli]
	cp $ff
	jr z, .set_carry
	call GetCardIDFromDeckIndex
	call GetCardType
	cp TYPE_ENERGY_DOUBLE_COLORLESS
	jr .loop_list_pkmn_or_basic_energy
.found_pkmn_or_basic_energy
	or a
	ret

; returns carry if no Trainer Item cards are found
.SearchDuelTempListForCardType
	ld hl, wDuelTempList
.loop_list_card_type
	ld a, [hli]
	cp $ff
	jr z, .set_carry
	push de
	call GetCardIDFromDeckIndex
	call GetCardType
	pop de
	cp e
	jr nz, .loop_list_card_type
	or a
	ret

; returns carry if no Grass cards are found
.SearchDuelTempListForGrassCard
	ld hl, wDuelTempList
.loop_list_grass
	ld a, [hli]
	cp $ff
	jp z, .set_carry
	call GetCardIDFromDeckIndex
	call GetCardType
	cp TYPE_ENERGY_GRASS
	jr z, .found_grass_card
	cp TYPE_PKMN_GRASS
	jr nz, .loop_list_grass
.found_grass_card
	or a
	ret


; returns carry if no card matching the pattern is found
; otherwise, returns deck index of the first matching card
; input:
;   e: CARDTEST_* constant to test each card
.SearchDuelTempListMatchingCardPattern
	ld a, e
	ld [wDataTableIndex], a
	ld hl, wDuelTempList
.loop_list_pattern_match
	ld a, [hl]
	cp $ff
	jr z, .set_carry
	call DynamicCardTypeTest
	ld a, [hli]
	jr nc, .loop_list_pattern_match
	or a
	ret



; Displays a list of all cards currently in the Player's deck.
; Expects the Player to choose one card.
; Meant to be called right after LookForCardsInDeck.
; input:
;   hl: pointer to a "Choose X card text"
; example:
;   ldtx hl, ChooseBasicEnergyCardText
; DisplayPlayerDeckForSearch:
; 	bank1call InitAndDrawCardListScreenLayout_MenuTypeSelectCheck
; 	ldtx hl, ChooseBasicEnergyCardText
; 	ldtx de, DuelistDeckText
; 	bank1call SetCardListHeaderText
; 	ret
