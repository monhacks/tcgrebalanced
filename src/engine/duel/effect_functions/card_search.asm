; ------------------------------------------------------------------------------
; Card Search
; ------------------------------------------------------------------------------

; Searches through all Deck cards looking for a certain card or cards.
; Prints text depending on whether at least one was found.
; If none were found, asks the Player whether to look
; in the Deck anyway, and returns carry if No is selected.
; input:
;   a: CARDTEST_* constant of the card pattern to search for
;	  hl: text to print if Deck has card(s)
;	  bc: variable text to fill <RAMTEXT> in hl
; output:
;   a: deck index of the first matching card | $ff
;	  carry: set if no matching cards and refused to look at deck

; LookForCardsInDeck:
; 	ld [wDataTableIndex], a
; 	push hl
; 	push bc
; 	call CreateDeckCardList
; 	pop bc
; 	pop hl
; 	jr LookForCardsInDeckList.search


; Searches through wDuelTempList looking for a certain card or cards.
; Prints text depending on whether at least one was found.
; If none were found, asks the Player whether to look
; in the Deck anyway, and returns carry if No is selected.
; input:
;   a: CARDTEST_* constant of the card pattern to search for
;	  hl: text to print if Deck has card(s)
;	  bc: variable text to fill <RAMTEXT> in hl
;   [wDuelTempList]: list of cards to search
; output:
;   a: deck index of the first matching card | $ff
;	  carry: set if no matching cards and refused to look at deck
LookForCardsInDeckList:
	ld [wDataTableIndex], a
.search
	push hl
	push bc
	call SearchDuelTempListForMatchingCard.search
	jr c, .none_in_deck
	pop bc
	pop hl
	push af
	call DrawWideTextBox_WaitForInput
	pop af
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
	ld a, $ff
	ret


; returns carry 
; otherwise, returns deck index of the first matching card
; input:
;   a: CARDTEST_* constant of the card pattern to search for
;   [wDuelTempList]: list of cards to search
; output:
;   a: deck index of the first matching card | $ff
;   carry: set if no card matching the pattern is found
SearchDuelTempListForMatchingCard:
	ld [wDataTableIndex], a
.search
	ld hl, wDuelTempList
.loop
	ld a, [hl]
	cp $ff
	jr z, .set_carry
	call DynamicCardTypeTest
	ld a, [hli]
	jr nc, .loop
	or a
	ret
.set_carry
	scf
	ret


; output:
;   a: deck index of the first matching card | $ff
;   carry: set if no card matching the pattern is found
SearchDeck_BasicPokemon:
	call CreateDeckCardList
	; jr SearchDuelTempList_BasicPokemon
	; fallthrough

; input:
;   [wDuelTempList]: list of cards to search
; output:
;   a: deck index of the first matching card | $ff
;   carry: set if no card matching the pattern is found
SearchDuelTempList_BasicPokemon:
	ld a, CARDTEST_BASIC_POKEMON
	jr SearchDuelTempListForMatchingCard
