; ------------------------------------------------------------------------------
; Choose Cards to Discard
; ------------------------------------------------------------------------------

; prompts the player to select a card from the hand to discard
; output:
;   a: deck index of the selected card | $ff
;   [hTempCardIndex_ff98]: deck index of the selected card
;   carry: set if the selection was cancelled
HandlePlayerSelection1HandCardToDiscard:
	; consider refactoring this to use HandlePlayerSelectionFromCardList_AllowCancel
	; the difference is that the function above sets card location headers
	ldtx hl, ChooseCardToDiscardFromHandText
.got_text
	call DrawWideTextBox_WaitForInput
	call CreateHandCardList
	bank1call InitAndDrawCardListScreenLayout_MenuTypeSelectCheck
	bank1call DisplayCardList
	ldh a, [hTempCardIndex_ff98]
	ret nc
	ld a, $ff
	ret

; prompts the player to select a card from the hand to discard,
; excluding the card that is currently being used.
; output:
;   a: deck index of the selected card | $ff
;   [hTempCardIndex_ff98]: deck index of the selected card
;   carry: set if the selection was cancelled
HandlePlayerSelection1HandCardToDiscardExcludeSelf:
	ldtx hl, ChooseCardToDiscardFromHandText
	call DrawWideTextBox_WaitForInput
	call CreateHandCardListExcludeSelf
	bank1call InitAndDrawCardListScreenLayout_MenuTypeSelectCheck
	bank1call DisplayCardList
	ldh a, [hTempCardIndex_ff98]
	ret nc
	ld a, $ff
	ret


; handles screen for Player to select 2 cards from the hand to discard.
; first prints text informing Player to choose cards to discard
; then runs HandlePlayerSelection2HandCardsExcludeSelf routine.
HandlePlayerSelection2HandCardsToDiscardExcludeSelf:
	ldtx hl, Choose2CardsFromHandToDiscardText
	ldtx de, ChooseTheCardToDiscardText
;	fallthrough

; handles screen for Player to select 2 cards from the hand
; to activate some Trainer card effect.
; assumes Trainer card index being used is in [hTempCardIndex_ff9f].
; stores selection of cards in hTempList.
; returns carry if Player cancels operation.
; input:
;	hl = text to print in text box;
;	de = text to print in screen header.
HandlePlayerSelection2HandCardsExcludeSelf:
	push de
	call DrawWideTextBox_WaitForInput

; remove the Trainer card being used from list
; of cards to select from hand.
	call CreateHandCardListExcludeSelf

	xor a
	ldh [hCurSelectionItem], a
	pop hl
.loop
	push hl
	bank1call InitAndDrawCardListScreenLayout_MenuTypeSelectCheck
	pop hl
	bank1call SetCardListInfoBoxText
	push hl
	bank1call DisplayCardList
	pop hl
	jr c, .set_carry ; was B pressed?
	push hl
	call GetNextPositionInTempList
	ldh a, [hTempCardIndex_ff98]
	ld [hl], a
	call RemoveCardFromDuelTempList
	pop hl
	ldh a, [hCurSelectionItem]
	cp 2
	jr c, .loop ; is selection over?
	or a
	ret
.set_carry
	scf
	ret


; ------------------------------------------------------------------------------
; Choose Cards From Discard Pile
; ------------------------------------------------------------------------------

; Handles screen for the Player to choose an Item Trainer card from the Discard Pile.
; output:
;   a: deck index of the selected card | $ff
;   [hTempCardIndex_ff98]: deck index of the selected card | $ff
;   carry: set if Player cancelled selection
HandlePlayerSelectionFromDiscardPile_ItemTrainer:
	call CreateItemCardListFromDiscardPile
	jr HandlePlayerSelectionFromDiscardPileList_AllowCancel


; Handles screen for the Player to choose a Basic Pokémon card from the Discard Pile.
; output:
;   a: deck index of the selected card
;   [hTempCardIndex_ff98]: deck index of the selected card
;   carry: set if Player cancelled selection
HandlePlayerSelectionFromDiscardPile_BasicPokemon:
	call CreateBasicPokemonCardListFromDiscardPile
	jr HandlePlayerSelectionFromDiscardPileList_AllowCancel


; Handles screen for the Player to choose a Pokémon card from the Discard Pile.
; output:
;   a: deck index of the selected card
;   [hTempCardIndex_ff98]: deck index of the selected card
;   carry: set if Player cancelled selection
HandlePlayerSelectionFromDiscardPile_AnyPokemon:
	call CreatePokemonCardListFromDiscardPile
	jr HandlePlayerSelectionFromDiscardPileList_AllowCancel


; Handles screen for the Player to choose a Basic Energy card from the Discard Pile.
; output:
;   a: deck index of the selected card
;   [hTempCardIndex_ff98]: deck index of the selected card
;   carry: set if Player cancelled selection
HandlePlayerSelectionFromDiscardPile_BasicEnergy:
	call CreateEnergyCardListFromDiscardPile_OnlyBasic
	jr HandlePlayerSelectionFromDiscardPileList_AllowCancel


; Handles screen for the Player to choose any card from the Discard Pile.
; output:
;   a: deck index of the selected card
;   [hTempCardIndex_ff98]: deck index of the selected card
;   carry: set if Player cancelled selection
HandlePlayerSelectionFromDiscardPile_AnyCard:
	call CreateDiscardPileCardList
	; jr HandlePlayerSelectionFromDiscardPileList_AllowCancel
	; fallthrough


; Handles screen for the Player to choose any card from a pre-built Discard Pile list.
; input:
;   [wDuelTempList]: $ff terminated list of cards to choose from
; output:
;   a: deck index of the selected card
;   [hTempCardIndex_ff98]: deck index of the selected card
;   carry: set if Player cancelled selection
HandlePlayerSelectionFromDiscardPileList_AllowCancel:
	; call CreateDiscardPileCardList
	ldtx de, PlayerDiscardPileText
	bank1call HandlePlayerSelectionFromCardList_AllowCancel
	ret


; HandlePlayerSelectionPokemonFromDiscardPile_Forced:
; 	call CreatePokemonCardListFromDiscardPile
; 	jr HandlePlayerSelectionFromDiscardPileList_Forced


; Handles screen for the Player to choose a Basic Energy card from the Discard Pile.
; output:
;   a: deck index of the selected card
;   [hTempCardIndex_ff98]: deck index of the selected card
;   carry: set if Player cancelled selection
HandlePlayerSelectionFromDiscardPile_BasicEnergy_Forced:
	call CreateEnergyCardListFromDiscardPile_OnlyBasic
	jr HandlePlayerSelectionFromDiscardPileList_Forced


; Handles screen for the Player to choose any card from a pre-built Discard Pile list.
; The selection is forced. The Player cannot cancel by pressing B.
; input:
;   [wDuelTempList]: $ff terminated list of cards to choose from
; output:
;   a: deck index of the selected card
;   [hTempCardIndex_ff98]: deck index of the selected card
HandlePlayerSelectionFromDiscardPileList_Forced:
	; call CreateDiscardPileCardList
	ldtx de, PlayerDiscardPileText
	bank1call HandlePlayerSelectionFromCardList_Forced
	ret


; ------------------------------------------------------------------------------
; Choose Cards From Deck
; ------------------------------------------------------------------------------

; Handles screen for the Player to choose an Item Trainer card from the Deck.
; output:
;   a: deck index of the selected card
;   [hTempCardIndex_ff98]: deck index of the selected card
HandlePlayerSelectionItemTrainerFromDeck:
	ld a, TYPE_TRAINER
	jr HandlePlayerSelectionCardTypeFromDeckToHand


; Handles screen for the Player to choose a Supporter card from the Deck.
; output:
;   a: deck index of the selected card
;   [hTempCardIndex_ff98]: deck index of the selected card
HandlePlayerSelectionSupporterFromDeck:
	ld a, TYPE_TRAINER_SUPPORTER
	; jr HandlePlayerSelectionCardTypeFromDeckToHand
	; fallthrough


; Handles screen for the Player to choose a card of given type from the Deck.
; input:
;   a: TYPE_* constant of the card to be selected
; output:
;   a: deck index of the selected card | $ff
;   [hTempCardIndex_ff98]: deck index of the selected card | $ff
HandlePlayerSelectionCardTypeFromDeckToHand:
	push af
	call CreateDeckCardList
	jr HandlePlayerSelectionCardTypeFromDeckListToHand.show_ui

; Handles screen for the Player to choose a card of given type from a Deck list
; input:
;   a: TYPE_* constant of the card to be selected
; output:
;   a: deck index of the selected card | $ff
;   [hTempCardIndex_ff98]: deck index of the selected card | $ff
HandlePlayerSelectionCardTypeFromDeckListToHand:
	push af
.show_ui
	ldtx hl, ChooseCardToPlaceInHandText
	ldtx de, DuelistDeckText
.read_input
	bank1call DisplayCardList_PrintText
; if B was pressed, either there are no cards or Player does not want any
	jr c, .no_cards
	ldh a, [hTempCardIndex_ff98]
	call LoadCardDataToBuffer2_FromDeckIndex
	ld hl, wLoadedCard2Type
	pop af
	cp [hl]
	jr nz, .play_sfx ; can't select card of another type
	ldh a, [hTempCardIndex_ff98]
	; ldh [hTemp_ffa0], a
	or a
	ret

.no_cards
	pop af
	ld a, $ff
	ldh [hTempCardIndex_ff98], a
	; ldh [hTemp_ffa0], a
	or a
	ret

.play_sfx
	push af
	call PlaySFX_InvalidChoice
	jr .read_input


; Handles screen for the Player to choose a card from a list of Deck cards.
; output:
;   a: deck index of the selected card | $ff
;   [hTempCardIndex_ff98]: deck index of the selected card | $ff
HandlePlayerSelectionAnyCardFromDeckToHand:
	call CreateDeckCardList
	; fallthrough


; Handles screen for the Player to choose a card from a list of Deck cards.
; input:
;   [wDuelTempList]: populated deck list
; output:
;   a: deck index of the selected card | $ff
;   [hTempCardIndex_ff98]: deck index of the selected card | $ff
HandlePlayerSelectionAnyCardFromDeckListToHand:
	ldtx hl, ChooseCardToPlaceInHandText
	ldtx de, DuelistDeckText
.loop_input
	bank1call DisplayCardList_PrintText
; if B was pressed, either there are no cards or Player does not want any
	jr c, .no_cards
	ldh a, [hTempCardIndex_ff98]
	or a
	ret

.no_cards
	ld a, $ff
	ldh [hTempCardIndex_ff98], a
	or a
	ret


HandlePlayerSelectionBasicEnergyFromDeck:
; create the list of cards in deck
	call CreateDeckCardList
	; fallthrough

; input:
;   wDuelTempList: list of deck cards to search
; output:
;   a: deck index of the selected card | $ff
;   [hTempCardIndex_ff98]: deck index of the selected card
;   carry: set if there are no Energy or the Player cancelled the selection
;   nz: set if there are no Energy in the deck
HandlePlayerSelectionBasicEnergyFromDeckList:
	ld a, CARDTEST_BASIC_ENERGY
	ldtx hl, ChooseBasicEnergyCardText
	jr HandlePlayerSelectionFromDeckList


HandlePlayerSelectionBasicPokemonFromDeck:
; create the list of cards in deck
	call CreateDeckCardList
	; fallthrough

; input:
;   wDuelTempList: list of deck cards to search
; output:
;   a: deck index of the selected card | $ff
;   [hTempCardIndex_ff98]: deck index of the selected card
;   carry: set if there are no Pokémon or the Player cancelled the selection
;   nz: set if there are no Pokémon in the deck
HandlePlayerSelectionBasicPokemonFromDeckList:
	ld a, CARDTEST_BASIC_POKEMON
	ldtx hl, ChoosePokemonCardText
	jr HandlePlayerSelectionFromDeckList


HandlePlayerSelectionPokemonFromDeck:
; create the list of cards in deck
	call CreateDeckCardList
	; fallthrough

; input:
;   wDuelTempList: list of deck cards to search
; output:
;   a: deck index of the selected card | $ff
;   [hTempCardIndex_ff98]: deck index of the selected card
;   carry: set if there are no Pokémon or the Player cancelled the selection
;   nz: set if there are no Pokémon in the deck
HandlePlayerSelectionPokemonFromDeckList:
	ld a, CARDTEST_POKEMON
	ldtx hl, ChoosePokemonCardText
	; jr HandlePlayerSelectionFromDeckList
	; fallthrough


; input:
;   wDuelTempList: list of deck cards to search
;   a: table index of a function to use as a test for the desired card type
;   hl: text pointer with the card type to choose
; output:
;   a: deck index of the selected card | $ff
;   [hTempCardIndex_ff98]: deck index of the selected card
;   carry: set if there are no valid cards or the Player cancelled the selection
;   nz: set if there are no valid cards in the deck
HandlePlayerSelectionFromDeckList:
	ld [wDataTableIndex], a
; handle input
	ldtx de, DuelistDeckText
.read_input
	bank1call DisplayCardList_PrintText
; if B was pressed, either there are no cards or Player does not want any
	jr c, .try_cancel
	ldh a, [hTempCardIndex_ff98]
	call DynamicCardTypeTest
	jr nc, .play_sfx  ; invalid card choice
; got a valid card
	ldh a, [hTempCardIndex_ff98]
	or a
	ret

.play_sfx
	call PlaySFX_InvalidChoice
	jr .read_input

.try_cancel
; Player tried exiting screen, check if there are any cards to select
	call CheckThereIsCardTypeInDeck
	jr c, .none_in_deck
; cancelled selection, but there were valid options
	xor a  ; ensure z flag
	ld a, $ff
	scf
	ret
.none_in_deck
	ld a, $ff
	or a  ; ensure nz flag
	scf
	ret


; ------------------------------------------------------------------------------
; Choose Pokémon In Play Area
; ------------------------------------------------------------------------------

HandlePlayerSelectionPokemonInPlayArea_AllowCancel:
	bank1call HasAlivePokemonInPlayArea
.select
	bank1call OpenPlayAreaScreenForSelection
	ld a, $ff
	ret c
	ldh a, [hTempPlayAreaLocation_ff9d]
	ret

HandlePlayerSelectionPokemonInBench_AllowCancel:
	bank1call HasAlivePokemonInBench
	jr HandlePlayerSelectionPokemonInPlayArea_AllowCancel.select


HandlePlayerSelectionPokemonInPlayArea:
	bank1call HasAlivePokemonInPlayArea
.loop_input
	bank1call OpenPlayAreaScreenForSelection
	jr c, .loop_input
	ldh a, [hTempPlayAreaLocation_ff9d]
	ret

HandlePlayerSelectionPokemonInBench:
	bank1call HasAlivePokemonInBench
	jr HandlePlayerSelectionPokemonInPlayArea.loop_input


; input:
;   a: how to test the selected Pokémon (CARDTEST_* constants)
; output:
;   a: PLAY_AREA_* of the selected card | $ff
;   carry: set if the Player cancelled selection
HandlePlayerSelectionMatchingPokemonInPlayArea_AllowCancel:
	ld d, a
	bank1call HasAlivePokemonInPlayArea  ; preserves de
.loop_input
	push de
	bank1call OpenPlayAreaScreenForSelection
	pop de
	ld a, $ff
	ret c
	ldh a, [hTempPlayAreaLocation_ff9d]
	ld e, a  ; play area location
	ld a, d  ; card type test
	push de
	call CheckPlayAreaPokemonMatchesPattern
	pop de
	ld a, e  ; play area location
	ret nc   ; found a match
	jr .loop_input  ; no match

HandlePlayerSelectionMatchingPokemonInBench_AllowCancel:
	ld d, a
	bank1call HasAlivePokemonInBench  ; preserves de
	jr HandlePlayerSelectionMatchingPokemonInPlayArea_AllowCancel.loop_input


; uses de and bc
HandlePlayerSelectionDamagedPokemonInPlayArea:
	bank1call HasAlivePokemonInPlayArea
.loop_input
	bank1call OpenPlayAreaScreenForSelection
	jr c, .loop_input
	ldh a, [hTempPlayAreaLocation_ff9d]
	ld e, a
	call GetCardDamageAndMaxHP
	or a
	jr z, .loop_input ; has no damage counters
	ldh a, [hTempPlayAreaLocation_ff9d]
	ret


HandlePlayerSelectionOpponentPokemonInPlayArea:
	call SwapTurn
	call HandlePlayerSelectionPokemonInPlayArea
	jp SwapTurn

HandlePlayerSelectionOpponentPokemonInBench:
	call SwapTurn
	call HandlePlayerSelectionPokemonInBench
	jp SwapTurn


PlayerSelectAndStorePokemonInPlayArea:
	call HandlePlayerSelectionPokemonInPlayArea
	ldh [hTemp_ffa0], a
	ret

PlayerSelectAndStorePokemonInBench:
	call HandlePlayerSelectionPokemonInBench
	ldh [hTemp_ffa0], a
	ret

PlayerSelectAndStoreOpponentPokemonInPlayArea:
	call HandlePlayerSelectionOpponentPokemonInPlayArea
	ldh [hTemp_ffa0], a
	ret

PlayerSelectAndStoreOpponentPokemonInBench:
	call HandlePlayerSelectionOpponentPokemonInBench
	ldh [hTemp_ffa0], a
	ret


; output:
;   [hTempPlayAreaLocation_ffa1]: PLAY_AREA_* of the selected card | $ff
;   carry: set if the Player cancelled selection
DevolvePlayAreaPokemon_PlayerSelectEffect:
	ldtx hl, ChooseEvolvedPokemonInPlayAreaText
	call DrawWideTextBox_WaitForInput
	ld a, CARDTEST_EVOLVED_POKEMON
	call HandlePlayerSelectionMatchingPokemonInPlayArea_AllowCancel
	; a: PLAY_AREA_* of the selected card | $ff
	ldh [hTempPlayAreaLocation_ffa1], a
	ret


; ------------------------------------------------------------------------------
; Choose Cards in Play Area
; ------------------------------------------------------------------------------

; handles Player selection for Pokemon in Play Area,
; then opens screen to choose one of the energy cards
; attached to that selected Pokemon.
; outputs the selection in:
;	[hTemp_ffa0] = play area location
;	[hTempPlayAreaLocation_ffa1] = index of energy card
HandlePokemonAndEnergySelectionScreen:
	bank1call HasAlivePokemonInPlayArea
	bank1call OpenPlayAreaScreenForSelection
	ret c ; exit if B is pressed
	ld e, a
	call GetPlayAreaCardAttachedEnergies
	ld a, [wTotalAttachedEnergies]
	or a
	jr nz, .has_energy
	ldtx hl, NoEnergyCardsText
	call DrawWideTextBox_WaitForInput
	jr HandlePokemonAndEnergySelectionScreen ; loop back to start

.has_energy
	ldh a, [hCurMenuItem]
	call CreateArenaOrBenchEnergyCardList
	ldh a, [hCurMenuItem]
	bank1call DisplayEnergyDiscardScreen
	bank1call HandleEnergyDiscardMenuInput
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTemp_ffa0], a
	ldh a, [hTempCardIndex_ff98]
	ldh [hTempPlayAreaLocation_ffa1], a
	ret

; handles Player selection for Pokemon in Play Area,
; then opens screen to choose one of the Basic energy cards
; attached to that selected Pokemon.
; outputs the selection in:
;	[hTemp_ffa0] = play area location
;	[hTempPlayAreaLocation_ffa1] = index of energy card
HandlePokemonAndBasicEnergySelectionScreen:
	bank1call HasAlivePokemonInPlayArea
	bank1call OpenPlayAreaScreenForSelection
	ret c ; exit if B is pressed
	ld e, a
	call HandleAttachedBasicEnergySelectionScreen
	jr c, .maybe_no_energy

	; ldh a, [hTempCardIndex_ff98]
	ldh [hTempPlayAreaLocation_ffa1], a
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTemp_ffa0], a
	ret

.maybe_no_energy
	jr nz, .no_energy
	ret  ; cancelled selection

.no_energy
	ldtx hl, NoEnergyCardsText
	call DrawWideTextBox_WaitForInput
	jr HandlePokemonAndBasicEnergySelectionScreen ; loop back to start


; input:
;   e: PLAY_AREA_* of selected card
; output:
;   a: deck index of selected card | $ff
;   [hTempCardIndex_ff98]: deck index of selected card | $ff
;   carry: set if no Basic Energy cards or B pressed
;   nz: set if no Basic Energy cards
HandleAttachedBasicEnergySelectionScreen:
	call GetPlayAreaCardAttachedEnergies
	ld a, [wTotalAttachedEnergies]
	or a
	jr z, .no_energy
	ld e, a
	ld a, [wAttachedEnergies + COLORLESS]
	cp e
	jr nz, .has_energy
; only has colorless energy
.no_energy
	ld a, $ff
	or a
	scf
	ret

.has_energy
	ldh a, [hCurMenuItem]
	call CreateArenaOrBenchEnergyCardList
	ld c, DOUBLE_COLORLESS_ENERGY
	call RemoveCardIDFromCardList
	ldh a, [hCurMenuItem]
	bank1call DisplayEnergyDiscardScreen
	bank1call HandleEnergyDiscardMenuInput
	; ldh a, [hTempCardIndex_ff98]
	ret


; ------------------------------------------------------------------------------
; Helper Functions
; ------------------------------------------------------------------------------

InitializeListForReordering:
; wDuelTempList + 10 will be filled with numbers
; from 1 to N (whatever the maximum order card is),
; so that the first item in that list corresponds to the first card
; the second item corresponds to the second card, etc.
; and the number in the list corresponds to the ordering number.
	call CountCardsInDuelTempList
	ld b, a
	ld a, 1
; fill order list with zeroes
	ldh [hCurSelectionItem], a
	ld hl, wDuelTempList + 10
	xor a
.loop_init
	ld [hli], a
	dec b
	jr nz, .loop_init
	ld [hl], $ff ; terminating byte
	ret
