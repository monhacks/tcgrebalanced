; ------------------------------------------------------------------------------
; Choose Cards to Discard
; ------------------------------------------------------------------------------

; prompts the player to select a card from the hand to discard
; output:
;   a: deck index of the selected card
;   [hTempCardIndex_ff98]: deck index of the selected card
;   carry: set if the selection was cancelled
HandlePlayerSelection1HandCardToDiscard:
	ldtx hl, ChooseCardToDiscardFromHandText
	call DrawWideTextBox_WaitForInput
	call CreateHandCardList
	bank1call InitAndDrawCardListScreenLayout_MenuTypeSelectCheck
	bank1call DisplayCardList
	ldh a, [hTempCardIndex_ff98]
	ret

; prompts the player to select a card from the hand to discard,
; excluding the card that is currently being used.
; output:
;   a: deck index of the selected card
;   [hTempCardIndex_ff98]: deck index of the selected card
;   carry: set if the selection was cancelled
HandlePlayerSelection1HandCardToDiscardExcludeSelf:
	ldtx hl, ChooseCardToDiscardFromHandText
	call DrawWideTextBox_WaitForInput
	call CreateHandCardListExcludeSelf
	bank1call InitAndDrawCardListScreenLayout_MenuTypeSelectCheck
	bank1call DisplayCardList
	ldh a, [hTempCardIndex_ff98]
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
	call GetNextPositionInTempList_TrainerEffects
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

; Handles screen for the Player to choose an Item Trainer card
; from the Discard Pile.
; output:
;   a: deck index of the selected card
;   [hTempCardIndex_ff98]: deck index of the selected card
HandlePlayerSelectionItemTrainerFromDiscardPile:
	call CreateItemCardListFromDiscardPile
	bank1call InitAndDrawCardListScreenLayout_MenuTypeSelectCheck
	ldtx hl, PleaseSelectCardText
	ldtx de, PlayerDiscardPileText
	bank1call SetCardListHeaderText
.loop_input
	bank1call DisplayCardList
	jr c, .loop_input
	ldh a, [hTempCardIndex_ff98]
	ret

PlayerSelectAndStoreItemCardFromDiscardPile:
	call HandlePlayerSelectionItemTrainerFromDiscardPile
	ldh [hTempPlayAreaLocation_ffa1], a
	ret