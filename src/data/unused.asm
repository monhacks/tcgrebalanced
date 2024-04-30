

; attack 2
energy DARKNESS, 1, COLORLESS, 2 ; energies
tx LeechLifeName ; name
tx LeechLifeDescription ; description
dw NONE ; description (cont)
db 30 ; damage
db DAMAGE_NORMAL ; category
dw LeechLifeEffectCommands ; effect commands
db NONE ; flags 1
db HEAL_USER ; flags 2
db NONE ; flags 3
db 3
db ATK_ANIM_DRAIN ; animation


; attack 2
energy WATER, 1, COLORLESS, 1 ; energies
tx AquaBurstName ; name
tx OptionalDiscard1Energy10BonusDamageDescription ; description
dw NONE ; description (cont)
db 20 ; damage
db DAMAGE_PLUS ; category
dw IfDiscardedEnergy10BonusDamageEffectCommands ; effect commands
db NONE ; flags 1
db DISCARD_ENERGY ; flags 2
db NONE ; flags 3
db 3
db ATK_ANIM_WATER_GUN ; animatio


; attack 2
energy WATER, 2, COLORLESS, 2 ; energies
tx RagingStormName ; name
tx DoubleDamageIfMorePrizesDescription ; description
dw NONE ; description (cont)
db 50 ; damage
db DAMAGE_PLUS ; category
dw DoubleDamageIfMorePrizesEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_THUNDERSTORM ; animation
; db ATK_ANIM_WHIRLPOOL ; alt animation


energy COLORLESS, 1 ; energies
	tx HardenName ; name
	tx HardenDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db RESIDUAL ; category
	dw HardenEffectCommands ; effect commands
	db NONE ; flags 1
	db NULLIFY_OR_WEAKEN_ATTACK ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_PROTECT ; animation


; attack 1
energy COLORLESS, 1 ; energies
tx DefensiveStanceName ; name
tx DefensiveStanceDescription ; description
dw NONE ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw DefensiveStanceEffectCommands ; effect commands
db NONE ; flags 1
db HEAL_USER ; flags 2
db SPECIAL_AI_HANDLING ; flags 3
db 2
db ATK_ANIM_PROTECT ; animation


; attack 2
energy FIGHTING, 1, COLORLESS, 1 ; energies
tx LowKickName ; name
tx ConstrictDescription ; description
dw NONE ; description (cont)
db 10 ; damage
db DAMAGE_PLUS ; category
dw ConstrictEffectCommands ; effect commands
db NONE ; flags 1
db FLAG_2_BIT_6 ; flags 2
db NONE ; flags 3
db 1
db ATK_ANIM_HIT ; animation




PoliwhirlCard:
	db TYPE_PKMN_WATER ; type
	gfx PoliwhirlCardGfx ; gfx
	tx PoliwhirlName ; name
	db DIAMOND ; rarity
	db LABORATORY | NONE ; sets
	db POLIWHIRL
	db 70 ; hp
	db STAGE1 ; stage
	tx PoliwagName ; pre-evo name

	; attack 1
	energy 0 ; energies
	tx MudSportName ; name
	tx Retrieve1WaterOrFightingEnergyFromDiscardDescription ; description
	tx PokemonPowerDescriptionCont ; description (cont)
	db 0 ; damage
	db POKEMON_POWER ; category
	dw MudSportEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_PKMN_POWER_1 ; animation

	; attack 2
	energy COLORLESS, 2 ; energies
	tx RainSplashName ; name
	tx DoubleDamageIfAttachedEnergyDescription ; description
	dw NONE ; description (cont)
	db 20 ; damage
	db DAMAGE_PLUS ; category
	dw DoubleDamageIfAttachedEnergyEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_WATER_GUN ; animation

	db 1 ; retreat cost
	db WR_LIGHTNING ; weakness
	db NONE ; resistance
	tx TadpoleName ; category
	db 61 ; Pokedex number
	db 0
	db 28 ; level
	db 3, 4 ; length
	dw 44 * 10 ; weight
	tx PoliwhirlDescription ; description
	db 16




KinglerCard:
	db TYPE_PKMN_WATER ; type
	gfx KinglerCardGfx ; gfx
	tx KinglerName ; name
	db DIAMOND ; rarity
	db EVOLUTION | FOSSIL ; sets
	db KINGLER
	db 80 ; hp
	db STAGE1 ; stage
	tx KrabbyName ; pre-evo name

	; attack 1
	energy COLORLESS, 2 ; energies
	tx RendName ; name
	tx Bonus20IfOpponentIsDamagedDescription ; description
	dw NONE ; description (cont)
	db 20 ; damage
	db DAMAGE_PLUS ; category
	dw RendEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_HIT ; animation

	; attack 2
	energy WATER, 1, COLORLESS, 2 ; energies
	tx CrabhammerName ; name
	tx CrabhammerDescription ; description
	dw NONE ; description (cont)
	db 40 ; damage
	db DAMAGE_PLUS ; category
	dw CrabhammerEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_HIT ; animation

	db 1 ; retreat cost
	db WR_LIGHTNING ; weakness
	db NONE ; resistance
	tx PincerName ; category
	db 99 ; Pokedex number
	db 0
	db 27 ; level
	db 4, 3 ; length
	dw 132 * 10 ; weight
	tx KinglerDescription ; description
	db 0



SlowpokeLv9Card:
	db TYPE_PKMN_PSYCHIC ; type
	gfx SlowpokeLv9CardGfx ; gfx
	tx SlowpokeName ; name
	db PROMOSTAR ; rarity
	db PROMOTIONAL | PRO ; sets
	db SLOWPOKE_LV9
	db 50 ; hp
	db BASIC ; stage
	dw NONE ; pre-evo name

	; attack 1
	energy PSYCHIC, 1 ; energies
	tx AmnesiaName ; name
	tx AmnesiaDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db DAMAGE_NORMAL ; category
	dw AmnesiaEffectCommands ; effect commands
	db NONE ; flags 1
	db FLAG_2_BIT_6 ; flags 2
	db NONE ; flags 3
	db 2
	db ATK_ANIM_AMNESIA ; animation

	; attack 2
	energy COLORLESS, 2 ; energies
	tx ConfusionWaveName ; name
	tx ConfusionWaveDescription ; description
	dw NONE ; description (cont)
	db 10 ; damage
	db DAMAGE_NORMAL ; category
	dw ConfusionWaveEffectCommands ; effect commands
	db INFLICT_CONFUSION ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_PSYCHIC_HIT ; animation

	db 0 ; retreat cost
	db WR_DARKNESS ; weakness
	db NONE ; resistance
	tx DopeyName ; category
	db 79 ; Pokedex number
	db 0
	db 9 ; level
	db 3, 11 ; length
	dw 79 * 10 ; weight
	tx SlowpokeDescription ; description
	db 19




MeowthLv14Card:
	db TYPE_PKMN_COLORLESS ; type
	gfx MeowthLv14CardGfx ; gfx
	tx MeowthName ; name
	db CIRCLE ; rarity
	db COLOSSEUM | GB ; sets
	db MEOWTH_LV14
	db 50 ; hp
	db BASIC ; stage
	dw NONE ; pre-evo name

	; attack 1
	energy 0 ; energies
	tx LuckyTailsName ; name
	tx LuckyTailsDescription ; description
	tx PokemonPowerDescriptionCont ; description (cont)
	db 0 ; damage
	db POKEMON_POWER ; category
	dw PassivePowerEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_NONE ; animation

	; attack 2
	energy COLORLESS, 1 ; energies
	tx FurySwipesName ; name
	tx FlipUntilTails10xDescription ; description
	dw NONE ; description (cont)
	db 10 ; damage
	db DAMAGE_X ; category
	dw FurySwipesEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_MULTIPLE_SLASH ; animation

	db 0 ; retreat cost
	db WR_FIGHTING ; weakness
	db NONE ; resistance
	tx ScratchCatName ; category
	db 52 ; Pokedex number
	db 0
	db 14 ; level
	db 1, 4 ; length
	dw 9 * 10 ; weight
	tx MeowthDescription ; description
	db 16




MagnemiteLv13Card:
	db TYPE_PKMN_LIGHTNING ; type
	gfx MagnemiteLv13CardGfx ; gfx
	tx MagnemiteName ; name
	db CIRCLE ; rarity
	db COLOSSEUM | NONE ; sets
	db MAGNEMITE_LV13
	db 50 ; hp
	db BASIC ; stage
	dw NONE ; pre-evo name

	; attack 1
	energy COLORLESS, 1 ; energies
	tx MagneticChargeName ; name
	tx MagneticChargeDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db RESIDUAL ; category
	dw MagneticChargeEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db SPECIAL_AI_HANDLING ; flags 3
	db 0
	db ATK_ANIM_GLOW_EFFECT ; animation

	; attack 2
	energy LIGHTNING, 1, COLORLESS, 1 ; energies
	tx ThundershockName ; name
	tx MayInflictParalysisDescription ; description
	dw NONE ; description (cont)
	db 20 ; damage
	db DAMAGE_NORMAL ; category
	dw Paralysis50PercentEffectCommands ; effect commands
	db INFLICT_PARALYSIS ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_THUNDERSHOCK ; animation

	; energy COLORLESS, 1 ; energies
	; tx SonicboomName ; name
	; tx SonicboomDescription ; description
	; dw NONE ; description (cont)
	; db 10 ; damage
	; db DAMAGE_NORMAL ; category
	; dw SonicboomEffectCommands ; effect commands
	; db NONE ; flags 1
	; db NONE ; flags 2
	; db NONE ; flags 3
	; db 0
	; db ATK_ANIM_TEAR ; animation

	db 0 ; retreat cost
	db WR_FIGHTING ; weakness
	db WR_GRASS ; resistance
	tx MagnetName ; category
	db 81 ; Pokedex number
	db 0
	db 13 ; level
	db 1, 0 ; length
	dw 13 * 10 ; weight
	tx MagnemiteDescription ; description
	db 19



PikachuAltLv16Card:
	db TYPE_PKMN_LIGHTNING ; type
	gfx PikachuAltLv16CardGfx ; gfx
	tx PikachuName ; name
	db PROMOSTAR ; rarity
	db PROMOTIONAL | PRO ; sets
	db PIKACHU_ALT_LV16
	db 50 ; hp
	db BASIC ; stage
	dw NONE ; pre-evo name

	; attack 1
	energy COLORLESS, 1 ; energies
	tx CollectName ; name
	tx Draw2CardsDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db RESIDUAL ; category
	dw Draw2CardsEffectCommands ; effect commands
	db DRAW_CARD ; flags 1
	db NONE ; flags 2
	db SPECIAL_AI_HANDLING ; flags 3
	db 0
	db ATK_ANIM_GLOW_EFFECT ; animation

	; attack 2
	energy COLORLESS, 2 ; energies
	tx SwiftName ; name
	tx SonicboomDescription ; description
	dw NONE ; description (cont)
	db 20 ; damage
	db DAMAGE_NORMAL ; category
	dw SonicboomEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_HIT ; animation

	db 0 ; retreat cost
	db WR_FIGHTING ; weakness
	db NONE ; resistance
	tx MouseName ; category
	db 25 ; Pokedex number
	db 0
	db 16 ; level
	db 1, 4 ; length
	dw 13 * 10 ; weight
	tx PikachuDescription ; description
	db 16
