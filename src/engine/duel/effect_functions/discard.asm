; ------------------------------------------------------------------------------
; Discard From Deck
; ------------------------------------------------------------------------------

; Discards N cards from the top of the turn holder's deck.
; Shows the details of each discarded card.
; input:
;   a: number of cards to discard
; output:
;   a: number of discarded cards
;   wDuelTempList: $ff-terminated list of discarded cards (by deck index)
; preserves: nothing
;   - push/pop de around DrawWideTextBox_WaitForInput to preserve it
DiscardFromDeckEffect:
  call DiscardCardsFromDeck
  ; push af
  ; call LoadTxRam3
  ; ldtx hl, DiscardedCardsFromDeckText
  ; call DrawWideTextBox_WaitForInput
  ; pop af
  ld hl, wDuelTempList
.loop
  ld a, [hli]
  cp $ff
  ret z
  call ShowDiscardedDeckCardDetails
  jr .loop


;
DiscardFromOpponentsDeckEffect:
  call SwapTurn
  call DiscardFromDeckEffect
  jp SwapTurn


; Discards N cards from the top of the turn holder's deck.
; input:
;   a: number of cards to discard
; output:
;   a: number of discarded cards
;   hl: number of discarded cards
;   wDuelTempList: $ff-terminated list of discarded cards (by deck index)
; preserves: nothing
;   - push/pop de around DrawWideTextBox_WaitForInput to preserve it
DiscardCardsFromDeck:
  ld c, a
  ld b, $00
  ld a, DUELVARS_NUMBER_OF_CARDS_NOT_IN_DECK
  call GetTurnDuelistVariable
  ld a, DECK_SIZE
  sub [hl]
  cp c
  jr nc, .start_discard
; only discard number of cards that are left in deck
  ld c, a

.start_discard
  push bc
  inc c
  ld hl, wDuelTempList
  jr .check_remaining

.loop
; discard top card from deck
; assume: deck size is already handled, this never returns carry
  call DrawCardFromDeck  ; preserves hl
  ; <- jr c would be done here
  ld [hli], a  ; deck index
  call nc, PutCardInDiscardPile  ; preserves af, hl, bc, de
.check_remaining
  dec c
  jr nz, .loop

; terminate wDuelTempList before using hl
  ld a, $ff
  ld [hl], a
; retrieve number of discarded cards
  pop hl
  ld a, l
  or a
  ret


; input:
;    a: deck index
ShowDiscardedDeckCardDetails:
  push hl
  ldtx hl, DiscardedFromDeckText
  bank1call DisplayCardDetailScreen
  or a
  pop hl
  ret


; ------------------------------------------------------------------------------
; Discard From Hand
; ------------------------------------------------------------------------------

; chooses a card at random from the opponents hand
; and moves it to the discard pile
; return carry if there are no cards to discard
; shows details of the card if it is not the Player's turn
Discard1RandomCardFromOpponentsHand:
  call Discard1RandomCardFromOpponentsHandEffect
  ret c  ; unable to discard
  ; fallthrough

ShowOpponentDiscardedCardDetails:
; deck index is already in a
; show respective card from the opposing player's deck
  call SwapTurn
	ldtx hl, DiscardedFromHandText
	bank1call DisplayCardDetailScreen
  call SwapTurn
  or a
  ret


; chooses a card at random from the opponents hand
; return carry if there are no cards
; returns deck index of selected card or $ff in a
Get1RandomCardFromOpponentsHand:
  call ExchangeRNG
  call SwapTurn
  call CreateHandCardList
  jr c, .get_deck_index  ; no cards in hand

; got number of cards in a
  ld hl, wDuelTempList
  cp 1
  jr z, .get_deck_index  ; there is only one card

; get random number between 0 and a (exclusive)
  call Random
; get a-th card from hand list
  ld c, a
  ld b, 0
  add hl, bc

.get_deck_index
  ld a, [hl]
  jp SwapTurn

; chooses a card at random from the opponents hand
; and moves it to the discard pile
; return carry if there are no cards to discard
; returns deck index of discarded card in a
Discard1RandomCardFromOpponentsHandEffect:
  call Get1RandomCardFromOpponentsHand
; could use MoveHandCardToDiscardPile here, but the check to avoid
; anything other than CARD_LOCATION_HAND is redundant;
; it is already done in CreateHandCardList
  call SwapTurn
  call RemoveCardFromHand
  call PutCardInDiscardPile
  or a
  jp SwapTurn


; ------------------------------------------------------------------------------
; Discard Energies
; ------------------------------------------------------------------------------



; ------------------------------------------------------------------------------
; Discard Other Cards
; ------------------------------------------------------------------------------

DiscardOpponentTools_DiscardEffect:
  ld a, DUELVARS_ARENA_CARD_ATTACHED_DEFENDER
	call GetTurnDuelistVariable
	xor a
	ld [hl], a
	ld de, DEFENDER
  ; FIXME this discards all tools, not just active
	; jp MoveCardToDiscardPileIfInPlayArea

  ld c, e
	ld b, d
	ld l, DUELVARS_CARD_LOCATIONS
.next_card
	ld a, [hl]
	cp CARD_LOCATION_ARENA
	jr z, .skip ; jump if card not in arena
	ld a, l
	call GetCardIDFromDeckIndex
	ld a, c
	cp e
	jr nz, .skip ; jump if not the card id provided in c
	ld a, b
	cp d ; card IDs are 8-bit so d is always 0
	jr nz, .skip
	ld a, l
	push bc
	call PutCardInDiscardPile
	pop bc
.skip
	inc l
	ld a, l
	cp DECK_SIZE
	jr c, .next_card
	ret
