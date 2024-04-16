DEF DEBUG_MODE EQU 0

DEF MAX_BENCH_POKEMON     EQU 5
DEF MAX_PLAY_AREA_POKEMON EQU 6 ; arena + bench
DEF MAX_HP                EQU 120
DEF HP_BAR_LENGTH         EQU MAX_HP / 10

DEF STARTING_HAND_SIZE EQU 7

; hWhoseTurn constants
DEF PLAYER_TURN   EQUS "HIGH(wPlayerDuelVariables)"
DEF OPPONENT_TURN EQUS "HIGH(wOpponentDuelVariables)"

; wDuelType constants
DEF DUELTYPE_LINK     EQU $1
DEF DUELTYPE_PRACTICE EQU $80
; for normal duels (vs AI), wDuelType is $80 + [wOpponentDeckID]

; wDuelFinished constants
DEF DUEL_NOT_FINISHED EQU $0
DEF TURN_PLAYER_WON   EQU $1
DEF TURN_PLAYER_LOST  EQU $2
DEF TURN_PLAYER_TIED  EQU $3

; wDuelResult constants
DEF DUEL_WIN  EQU $0
DEF DUEL_LOSS EQU $1

; wPlayerDuelVariables or wOpponentDuelVariables constants
DEF DUELVARS_CARD_LOCATIONS                   EQUS "LOW(wPlayerCardLocations)"               ; 00
DEF DUELVARS_PRIZE_CARDS                      EQUS "LOW(wPlayerPrizeCards)"                  ; 3c
DEF DUELVARS_HAND                             EQUS "LOW(wPlayerHand)"                        ; 42
DEF DUELVARS_DECK_CARDS                       EQUS "LOW(wPlayerDeckCards)"                   ; 7e
DEF DUELVARS_NUMBER_OF_CARDS_NOT_IN_DECK      EQUS "LOW(wPlayerNumberOfCardsNotInDeck)"      ; ba
DEF DUELVARS_ARENA_CARD                       EQUS "LOW(wPlayerArenaCard)"                   ; bb
DEF DUELVARS_BENCH                            EQUS "LOW(wPlayerBench)"                       ; bc
DEF DUELVARS_ARENA_CARD_FLAGS                 EQUS "LOW(wPlayerArenaCardFlags)"              ; c2
DEF DUELVARS_ARENA_CARD_HP                    EQUS "LOW(wPlayerArenaCardHP)"                 ; c8
DEF DUELVARS_BENCH1_CARD_HP                   EQUS "LOW(wPlayerBench1CardHP)"                ; c9
DEF DUELVARS_BENCH2_CARD_HP                   EQUS "LOW(wPlayerBench2CardHP)"                ; ca
DEF DUELVARS_BENCH3_CARD_HP                   EQUS "LOW(wPlayerBench3CardHP)"                ; cb
DEF DUELVARS_BENCH4_CARD_HP                   EQUS "LOW(wPlayerBench4CardHP)"                ; cc
DEF DUELVARS_BENCH5_CARD_HP                   EQUS "LOW(wPlayerBench5CardHP)"                ; cd
DEF DUELVARS_ARENA_CARD_STAGE                 EQUS "LOW(wPlayerArenaCardStage)"              ; ce
DEF DUELVARS_BENCH1_CARD_STAGE                EQUS "LOW(wPlayerBench1CardStage)"             ; cf
DEF DUELVARS_BENCH2_CARD_STAGE                EQUS "LOW(wPlayerBench2CardStage)"             ; d0
DEF DUELVARS_BENCH3_CARD_STAGE                EQUS "LOW(wPlayerBench3CardStage)"             ; d1
DEF DUELVARS_BENCH4_CARD_STAGE                EQUS "LOW(wPlayerBench4CardStage)"             ; d2
DEF DUELVARS_BENCH5_CARD_STAGE                EQUS "LOW(wPlayerBench5CardStage)"             ; d3
DEF DUELVARS_ARENA_CARD_CHANGED_TYPE          EQUS "LOW(wPlayerArenaCardChangedType)"        ; d4
DEF DUELVARS_BENCH1_CARD_CHANGED_COLOR        EQUS "LOW(wPlayerBench1CardChangedType)"       ; d5
DEF DUELVARS_BENCH2_CARD_CHANGED_COLOR        EQUS "LOW(wPlayerBench2CardChangedType)"       ; d6
DEF DUELVARS_BENCH3_CARD_CHANGED_COLOR        EQUS "LOW(wPlayerBench3CardChangedType)"       ; d7
DEF DUELVARS_BENCH4_CARD_CHANGED_COLOR        EQUS "LOW(wPlayerBench4CardChangedType)"       ; d8
DEF DUELVARS_BENCH5_CARD_CHANGED_COLOR        EQUS "LOW(wPlayerBench5CardChangedType)"       ; d9
DEF DUELVARS_ARENA_CARD_ATTACHED_TOOL         EQUS "LOW(wPlayerArenaCardAttachedTool)"       ; da
DEF DUELVARS_BENCH1_CARD_ATTACHED_TOOL        EQUS "LOW(wPlayerBench1CardAttachedTool)"      ; db
DEF DUELVARS_BENCH2_CARD_ATTACHED_TOOL        EQUS "LOW(wPlayerBench2CardAttachedTool)"      ; dc
DEF DUELVARS_BENCH3_CARD_ATTACHED_TOOL        EQUS "LOW(wPlayerBench3CardAttachedTool)"      ; dd
DEF DUELVARS_BENCH4_CARD_ATTACHED_TOOL        EQUS "LOW(wPlayerBench4CardAttachedTool)"      ; de
DEF DUELVARS_BENCH5_CARD_ATTACHED_TOOL        EQUS "LOW(wPlayerBench5CardAttachedTool)"      ; df
DEF DUELVARS_ARENA_CARD_UNUSED                EQUS "LOW(wPlayerArenaCardUnused)"             ; e0
DEF DUELVARS_BENCH1_CARD_UNUSED               EQUS "LOW(wPlayerBench1CardUnused)"            ; e1
DEF DUELVARS_BENCH2_CARD_UNUSED               EQUS "LOW(wPlayerBench2CardUnused)"            ; e2
DEF DUELVARS_BENCH3_CARD_UNUSED               EQUS "LOW(wPlayerBench3CardUnused)"            ; e3
DEF DUELVARS_BENCH4_CARD_UNUSED               EQUS "LOW(wPlayerBench4CardUnused)"            ; e4
DEF DUELVARS_BENCH5_CARD_UNUSED               EQUS "LOW(wPlayerBench5CardUnused)"            ; e5
DEF DUELVARS_ARENA_CARD_SUBSTATUS1            EQUS "LOW(wPlayerArenaCardSubstatus1)"         ; e7
DEF DUELVARS_ARENA_CARD_SUBSTATUS2            EQUS "LOW(wPlayerArenaCardSubstatus2)"         ; e8
DEF DUELVARS_ARENA_CARD_CHANGED_WEAKNESS      EQUS "LOW(wPlayerArenaCardChangedWeakness)"    ; e9
DEF DUELVARS_ARENA_CARD_CHANGED_RESISTANCE    EQUS "LOW(wPlayerArenaCardChangedResistance)"  ; ea
DEF DUELVARS_ARENA_CARD_SUBSTATUS3            EQUS "LOW(wPlayerArenaCardSubstatus3)"         ; eb
DEF DUELVARS_PRIZES                           EQUS "LOW(wPlayerPrizes)"                      ; ec
DEF DUELVARS_NUMBER_OF_CARDS_IN_DISCARD_PILE  EQUS "LOW(wPlayerNumberOfCardsInDiscardPile)"  ; ed
DEF DUELVARS_NUMBER_OF_CARDS_IN_HAND          EQUS "LOW(wPlayerNumberOfCardsInHand)"         ; ee
DEF DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA   EQUS "LOW(wPlayerNumberOfPokemonInPlayArea)"   ; ef
DEF DUELVARS_ARENA_CARD_STATUS                EQUS "LOW(wPlayerArenaCardStatus)"             ; f0
DEF DUELVARS_BENCH1_CARD_STATUS               EQUS "LOW(wPlayerBench1CardStatus)"            ; f1
DEF DUELVARS_BENCH2_CARD_STATUS               EQUS "LOW(wPlayerBench2CardStatus)"            ; f2
DEF DUELVARS_BENCH3_CARD_STATUS               EQUS "LOW(wPlayerBench3CardStatus)"            ; f3
DEF DUELVARS_BENCH4_CARD_STATUS               EQUS "LOW(wPlayerBench4CardStatus)"            ; f4
DEF DUELVARS_BENCH5_CARD_STATUS               EQUS "LOW(wPlayerBench5CardStatus)"            ; f5
DEF DUELVARS_DUELIST_TYPE                     EQUS "LOW(wPlayerDuelistType)"                 ; f6
DEF DUELVARS_ARENA_CARD_DISABLED_ATTACK_INDEX EQUS "LOW(wPlayerArenaCardDisabledAttackIndex)" ; f7
DEF DUELVARS_ARENA_CARD_LAST_TURN_DAMAGE      EQUS "LOW(wPlayerArenaCardLastTurnDamage)"     ; f8
DEF DUELVARS_ARENA_CARD_LAST_TURN_STATUS      EQUS "LOW(wPlayerArenaCardLastTurnStatus)"     ; f9
DEF DUELVARS_ARENA_CARD_LAST_TURN_SUBSTATUS2  EQUS "LOW(wPlayerArenaCardLastTurnSubstatus2)" ; fa
DEF DUELVARS_ARENA_CARD_LAST_TURN_CHANGE_WEAK EQUS "LOW(wPlayerArenaCardLastTurnChangeWeak)" ; fb
DEF DUELVARS_ARENA_CARD_LAST_TURN_EFFECT      EQUS "LOW(wPlayerArenaCardLastTurnEffect)"     ; fc
DEF DUELVARS_MISC_TURN_FLAGS                  EQUS "LOW(wPlayerMiscTurnFlags)"               ; fd

; card location constants (DUELVARS_CARD_LOCATIONS)
DEF CARD_LOCATION_DECK         EQU $00
DEF CARD_LOCATION_HAND         EQU $01
DEF CARD_LOCATION_DISCARD_PILE EQU $02
DEF CARD_LOCATION_PRIZE        EQU $08
DEF CARD_LOCATION_ARENA        EQU $10
DEF CARD_LOCATION_BENCH_1      EQU $11
DEF CARD_LOCATION_BENCH_2      EQU $12
DEF CARD_LOCATION_BENCH_3      EQU $13
DEF CARD_LOCATION_BENCH_4      EQU $14
DEF CARD_LOCATION_BENCH_5      EQU $15

; card location flags (DUELVARS_CARD_LOCATIONS)
DEF CARD_LOCATION_PLAY_AREA_F  EQU 4 ; includes arena and bench
DEF CARD_LOCATION_PLAY_AREA    EQU 1 << CARD_LOCATION_PLAY_AREA_F
DEF CARD_LOCATION_JUST_DRAWN_F EQU 6
DEF CARD_LOCATION_JUST_DRAWN   EQU 1 << CARD_LOCATION_JUST_DRAWN_F

; play area location offsets (CARD_LOCATION_* - CARD_LOCATION_PLAY_AREA)
DEF PLAY_AREA_ARENA   EQU $0
DEF PLAY_AREA_BENCH_1 EQU $1
DEF PLAY_AREA_BENCH_2 EQU $2
DEF PLAY_AREA_BENCH_3 EQU $3
DEF PLAY_AREA_BENCH_4 EQU $4
DEF PLAY_AREA_BENCH_5 EQU $5

; duelist types (DUELVARS_DUELIST_TYPE)
DEF DUELIST_TYPE_PLAYER   EQU $00
DEF DUELIST_TYPE_LINK_OPP EQU $01
DEF DUELIST_TYPE_AI_OPP   EQU $80 ; $80 + [wOpponentDeckID]

; status conditions (DUELVARS_ARENA_CARD_STATUS)
; two statuses can be combined if they are identified by a different nybble
DEF NO_STATUS       EQU $00
DEF CONFUSED        EQU $01
DEF ASLEEP          EQU $02
DEF PARALYZED       EQU $03
DEF POISONED        EQU $80
DEF DOUBLE_POISONED EQU $c0


DEF DOUBLE_POISONED_F EQU 6
DEF POISONED_F        EQU 7


DEF CNF_SLP_PRZ   EQU $0f ; confused, asleep or paralyzed
DEF PSN_DBLPSN    EQU $f0 ; poisoned or double poisoned
DEF PSN_DAMAGE    EQU 10
DEF DBLPSN_DAMAGE EQU 20


; TOOL constants (DUELVARS_ARENA_CARD_ATTACHED_TOOL)
; a value of zero means that there is no tool attached
	const_def 1
	const POKEMON_TOOL_PLUSPOWER          ; $01
	const POKEMON_TOOL_DEFENDER           ; $02


; substatus conditions (DUELVARS_ARENA_CARD_SUBSTATUS*)

; SUBSTATUS1 (DUELVARS_ARENA_CARD_SUBSTATUS1) are checked on a defending Pokemon
DEF SUBSTATUS1_NO_DAMAGE_FROM_BASIC  EQU $0c
DEF SUBSTATUS1_AGILITY      EQU $0d
DEF SUBSTATUS1_HARDEN       EQU $0e
DEF SUBSTATUS1_NO_DAMAGE    EQU $0f
DEF SUBSTATUS1_VULNERABLE_40 EQU $10
DEF SUBSTATUS1_NO_DAMAGE_11 EQU $11  ; unused
DEF SUBSTATUS1_REDUCE_BY_20 EQU $13
DEF SUBSTATUS1_BARRIER      EQU $14
DEF SUBSTATUS1_HALVE_DAMAGE EQU $15
DEF SUBSTATUS1_DESTINY_BOND EQU $16
DEF SUBSTATUS1_NEXT_TURN_UNABLE_ATTACK EQU $17
DEF SUBSTATUS1_NEXT_TURN_DOUBLE_DAMAGE EQU $19
DEF SUBSTATUS1_REDUCE_BY_10 EQU $1e

; SUBSTATUS2 (DUELVARS_ARENA_CARD_SUBSTATUS2) are checked on an attacking Pokemon
DEF SUBSTATUS2_ACCURACY       EQU $01
DEF SUBSTATUS2_UNUSED_1       EQU $02
DEF SUBSTATUS2_REDUCE_BY_20   EQU $03
DEF SUBSTATUS2_AMNESIA        EQU $04
DEF SUBSTATUS2_UNABLE_ATTACK  EQU $05
DEF SUBSTATUS2_RETREAT_PLUS_1 EQU $06
DEF SUBSTATUS2_REDUCE_BY_10   EQU $07
DEF SUBSTATUS2_UNUSED_3       EQU $08
DEF SUBSTATUS2_UNABLE_RETREAT EQU $09
DEF SUBSTATUS2_UNUSED_2       EQU $12

DEF SUBSTATUS3_THIS_TURN_DOUBLE_DAMAGE EQU 0
DEF SUBSTATUS3_HEADACHE                EQU 1
DEF SUBSTATUS3_THIS_TURN_ACTIVE        EQU 2
DEF SUBSTATUS3_THIS_TURN_CANNOT_ATTACK EQU 3

; DUELVARS_MISC_TURN_FLAGS constants
DEF TURN_FLAG_PKMN_POWERS_DISABLED_F EQU 0
DEF TURN_FLAG_TOSSED_TAILS_F         EQU 1
DEF TURN_FLAG_KO_OPPONENT_POKEMON_F  EQU 2

; DUELVARS_ARENA_CARD_FLAGS constants
DEF USED_PKMN_POWER_THIS_TURN_F  EQU 5
DEF UNABLE_TO_ATTACK_THIS_TURN_F EQU 6
DEF CAN_EVOLVE_THIS_TURN_F       EQU 7

DEF USED_PKMN_POWER_THIS_TURN   EQU 1 << USED_PKMN_POWER_THIS_TURN_F
DEF UNABLE_TO_ATTACK_THIS_TURN  EQU 1 << UNABLE_TO_ATTACK_THIS_TURN_F
DEF CAN_EVOLVE_THIS_TURN        EQU 1 << CAN_EVOLVE_THIS_TURN_F

; DUELVARS_ARENA_CARD_LAST_TURN_EFFECT constants
	const_def
	const LAST_TURN_EFFECT_NONE           ; $00
	const LAST_TURN_EFFECT_DISCARD_ENERGY ; $01
	const LAST_TURN_EFFECT_AMNESIA        ; $02

; wAlreadyPlayedEnergyOrSupporter constants
DEF PLAYED_ENERGY_THIS_TURN_F    EQU 0
DEF USED_RAIN_DANCE_THIS_TURN_F  EQU 1
DEF USED_FIRESTARTER_THIS_TURN_F EQU 2
DEF PLAYED_SUPPORTER_THIS_TURN_F EQU 4

DEF PLAYED_ENERGY_THIS_TURN    EQU 1 << PLAYED_ENERGY_THIS_TURN_F
DEF USED_RAIN_DANCE_THIS_TURN  EQU 1 << USED_RAIN_DANCE_THIS_TURN_F
DEF USED_FIRESTARTER_THIS_TURN EQU 1 << USED_FIRESTARTER_THIS_TURN_F
DEF PLAYED_SUPPORTER_THIS_TURN EQU 1 << PLAYED_SUPPORTER_THIS_TURN_F

; wEndOfTurnPowerVariables constants
DEF NUM_END_OF_TURN_POWERS EQU 8

; *_CHANGED_COLOR constants
DEF HAS_CHANGED_COLOR_F  EQU 7
DEF HAS_CHANGED_COLOR    EQU 1 << HAS_CHANGED_COLOR_F
DEF IS_PERMANENT_COLOR_F EQU 6
DEF IS_PERMANENT_COLOR   EQU 1 << IS_PERMANENT_COLOR_F

; wDamage constants
DEF MAX_DAMAGE EQU 250

; flags in wDamageFlags that indicates
; whether damage is unaffected by Weakness/Resistance
DEF UNAFFECTED_BY_WEAKNESS_F EQU 7
DEF UNAFFECTED_BY_RESISTANCE_F EQU 6
DEF UNAFFECTED_BY_POWERS_OR_EFFECTS_F EQU 5

; effect command constants (TryExecuteEffectCommandFunction)
; ordered by (roughly) execution time
DEF EFFECTCMDTYPE_INITIAL_EFFECT_1         EQU $01
DEF EFFECTCMDTYPE_INITIAL_EFFECT_2         EQU $02
DEF EFFECTCMDTYPE_DISCARD_ENERGY           EQU $06
DEF EFFECTCMDTYPE_REQUIRE_SELECTION        EQU $05
DEF EFFECTCMDTYPE_BEFORE_DAMAGE            EQU $03
DEF EFFECTCMDTYPE_AFTER_DAMAGE             EQU $04
DEF EFFECTCMDTYPE_INTERACTIVE_STEP         EQU $0b
DEF EFFECTCMDTYPE_AI_SELECTION             EQU $08
DEF EFFECTCMDTYPE_AI_SWITCH_DEFENDING_PKMN EQU $0a
DEF EFFECTCMDTYPE_PKMN_POWER_TRIGGER       EQU $07
DEF EFFECTCMDTYPE_AI                       EQU $09

; wDamageEffectiveness constants
DEF WEAKNESS   EQU 1
DEF RESISTANCE EQU 2

; wNoDamageOrEffect constants
DEF NO_DAMAGE_OR_EFFECT_UNUSED       EQU $01
DEF NO_DAMAGE_OR_EFFECT_BARRIER      EQU $02
DEF NO_DAMAGE_OR_EFFECT_AGILITY      EQU $03
DEF NO_DAMAGE_OR_EFFECT_TRANSPARENCY EQU $04
DEF NO_DAMAGE_OR_EFFECT_NSHIELD      EQU $05

; OppAction_* constants (OppActionTable)
	const_def
	const OPPACTION_ERROR                     ; $00
	const OPPACTION_PLAY_BASIC_PKMN           ; $01
	const OPPACTION_EVOLVE_PKMN               ; $02
	const OPPACTION_PLAY_ENERGY               ; $03
	const OPPACTION_ATTEMPT_RETREAT           ; $04
	const OPPACTION_FINISH_NO_ATTACK          ; $05
	const OPPACTION_PLAY_TRAINER              ; $06
	const OPPACTION_EXECUTE_TRAINER_EFFECTS   ; $07
	const OPPACTION_BEGIN_ATTACK              ; $08
	const OPPACTION_USE_ATTACK                ; $09
	const OPPACTION_ATTACK_ANIM_AND_DAMAGE    ; $0a
	const OPPACTION_DRAW_CARD                 ; $0b
	const OPPACTION_USE_PKMN_POWER            ; $0c
	const OPPACTION_EXECUTE_PKMN_POWER_EFFECT ; $0d
	const OPPACTION_FORCE_SWITCH_ACTIVE       ; $0e
	const OPPACTION_NO_ACTION_0F              ; $0f
	const OPPACTION_NO_ACTION_10              ; $10
	const OPPACTION_TOSS_COIN_A_TIMES         ; $11
	const OPPACTION_6B30                      ; $12
	const OPPACTION_NO_ACTION_13              ; $13
	const OPPACTION_USE_METRONOME_ATTACK      ; $14
	const OPPACTION_EXECUTE_EFFECT_STEP       ; $15
	const OPPACTION_DUEL_MAIN_SCENE           ; $16

; constants for PracticeDuelActionTable entries
	const_def 1
	const PRACTICEDUEL_DRAW_SEVEN_CARDS
	const PRACTICEDUEL_PLAY_GOLDEEN
	const PRACTICEDUEL_PUT_STARYU_IN_BENCH
	const PRACTICEDUEL_VERIFY_INITIAL_PLAY
	const PRACTICEDUEL_DONE_PUTTING_ON_BENCH
	const PRACTICEDUEL_PRINT_TURN_INSTRUCTIONS
	const PRACTICEDUEL_VERIFY_PLAYER_TURN_ACTIONS
	const PRACTICEDUEL_REPEAT_INSTRUCTIONS
	const PRACTICEDUEL_PLAY_STARYU_FROM_BENCH
	const PRACTICEDUEL_REPLACE_KNOCKED_OUT_POKEMON

; wEffectFailed constants
DEF EFFECT_FAILED_NO_EFFECT    EQU $01
DEF EFFECT_FAILED_UNSUCCESSFUL EQU $02

; wAnimationQueue length
DEF ANIMATION_QUEUE_LENGTH EQU 7

DEF PRIZES_1    EQU $01
DEF PRIZES_2    EQU $02
DEF PRIZES_3    EQU $03
DEF PRIZES_4    EQU $04
DEF PRIZES_5    EQU $05
DEF PRIZES_6    EQU $06

; constants to use as input to LookForCardInDeck
	const_def
 	const SEARCHEFFECT_POKEMON_OR_BASIC_ENERGY  ; $00
 	const SEARCHEFFECT_CARD_TYPE                ; $01
 	const SEARCHEFFECT_GRASS_CARD               ; $02
 	const SEARCHEFFECT_MATCHING_CARD_PATTERN    ; $03

; constant offsets for CardTypeTest_FunctionTable
	const_def
 	const CARDTEST_POKEMON                      ; $00
 	const CARDTEST_BASIC_POKEMON                ; $01
 	const CARDTEST_EVOLUTION_POKEMON            ; $02
 	const CARDTEST_BASIC_ENERGY                 ; $03
 	const CARDTEST_ENERGIZED_POKEMON            ; $04
 	const CARDTEST_NON_ENERGIZED_POKEMON        ; $05
 	const CARDTEST_MAGMAR                       ; $06
 	const CARDTEST_ENERGIZED_MAGMAR             ; $07
 	const CARDTEST_ELECTABUZZ                   ; $08
 	const CARDTEST_ENERGIZED_ELECTABUZZ         ; $09
 	const CARDTEST_EVOLVES_INTO                 ; $0a
	const CARDTEST_EVOLUTION_OF_PLAY_AREA       ; $0b

; [wAIAttackLogicFlags] constants
DEF AI_LOGIC_MIN_DAMAGE_CAN_KO_F     EQU 0
DEF AI_LOGIC_MAX_DAMAGE_CAN_KO_F     EQU 1
