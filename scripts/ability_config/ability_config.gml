/// @description ability_config() -> the roster of ABILITIES (his ask,
/// 2026-09-17, Disgaea's evilities): PASSIVE traits a sprite or a foe
/// carries in four slots. Each kind has a TIER (the unlock rung it enters
/// the pool at - see ability_unlocks), a band for its number at common
/// (rarity multiplies it, ability_rarity_mult) and a LANE - the one place
/// its number lands (ability_effects sums the lanes; the pawns and the
/// road read them). `also` = a second lane the same number lands on;
/// `cost` = a lane it costs (berserk's def, the gambler's grazes).
///
/// THE BIG ROSTER (2026-09-17, his ask: Disgaea 7's common evilities and
/// Kingdom Hearts' support abilities, read across the games, translated
/// onto the hooks the fight engine and the road already have): 99 kinds
/// in four tiers. Every lane's meaning is in ability_lane_desc; every
/// consumer is marked "(2026-09-17)" where it reads the lane - cbt_hit
/// (the fight lanes), cbt_fight_turn (mp haste / frugal / the ruse / the
/// salvo's count), cbt_status (lingering), cbt_heal (gentle hands / good
/// patient), sprite_stats (the stat lanes, mp's too), sprite_pawn (eager),
/// exped_agent (long legs / pathfinder / owl-eyed / all-weather / the
/// wanderer), exped_fight_new (well-rested / danger sense), exped_fight_loot
/// + exped_loot_roll (magpie / treasure sense), exped_tick_one (golden
/// touch), exped_bond_add (good company), exped_shop / exped_act_step
/// (haggler / the regular), exped_drink (gourmet), exped_xp_grant (hard
/// lessons), sprites_tick (second wind).
/// ⚖️ Once more replaced undying (Kingdom Hearts' rule: any action that
/// would down it leaves it at 1 hp while it had more than 1 going in).
/// ⚖️ Adding a kind reshuffles which kind every seed picks - every sprite's
/// list changes with the roster (accepted, 2026-09-17).
function ability_config() {
	static _c = [
		{ key : "stout", name : "stout", tier : 1, lane : "hp", band : [4, 8], help : "more hit points" },
		{ key : "brawn", name : "brawn", tier : 1, lane : "atk", band : [4, 8], help : "hits harder" },
		{ key : "bookish", name : "bookish", tier : 1, lane : "mag", band : [4, 8], help : "casts harder" },
		{ key : "thickskin", name : "thick skin", tier : 1, lane : "def", band : [4, 8], help : "takes less from blows" },
		{ key : "warded", name : "warded", tier : 1, lane : "mdef", band : [4, 8], help : "takes less from spells" },
		{ key : "quick", name : "quick", tier : 1, lane : "spd", band : [4, 8], help : "faster, and harder to hit" },
		{ key : "keeneye", name : "keen eye", tier : 1, lane : "hit", band : [4, 8], help : "lands more" },
		{ key : "lucky", name : "lucky", tier : 1, lane : "luck", band : [1, 1], help : "a point of luck" },
		{ key : "fireproof", name : "fireproof", tier : 1, lane : "res_fire", band : [6, 10], help : "resists fire" },
		{ key : "waterproof", name : "waterproof", tier : 1, lane : "res_water", band : [6, 10], help : "resists water" },
		{ key : "thornproof", name : "thornproof", tier : 1, lane : "res_nature", band : [6, 10], help : "resists nature" },
		{ key : "nimble", name : "nimble", tier : 1, lane : "eva", band : [2, 4], help : "a little harder to hit, flat" },
		{ key : "deepwell", name : "deep well", tier : 1, lane : "mp", band : [6, 10], help : "more magic points" },
		{ key : "eager", name : "eager", tier : 1, lane : "mp0", band : [15, 25], help : "walks into a fight with more mp" },
		{ key : "gourmet", name : "gourmet", tier : 1, lane : "potion", band : [20, 35], help : "gets more out of a potion" },
		{ key : "longlegs", name : "long legs", tier : 1, lane : "pace", band : [5, 10], help : "the crew walks quicker with it along" },
		{ key : "magpie", name : "magpie", tier : 1, lane : "finds", band : [8, 15], help : "fights leave more behind" },
		{ key : "regular", name : "the regular", tier : 1, lane : "inn", band : [1, 1], help : "innkeepers know it: a credit off the bed" },
		{ key : "haggler", name : "haggler", tier : 1, lane : "haggle", band : [1, 1], help : "a credit off everything in a shop" },
		{ key : "goodcompany", name : "good company", tier : 1, lane : "bonds", band : [20, 40], help : "friendships come easy" },
		{ key : "vicious", name : "vicious", tier : 2, lane : "crit", band : [3, 6], help : "crits more" },
		{ key : "spiteful", name : "spiteful", tier : 2, lane : "cnt", band : [4, 8], help : "hits back more" },
		{ key : "venomous", name : "venomous", tier : 2, lane : "ail_poison", band : [10, 18], help : "its blows poison" },
		{ key : "chilling", name : "chilling", tier : 2, lane : "ail_slow", band : [10, 18], help : "its blows slow" },
		{ key : "antidote", name : "antidote", tier : 2, lane : "immune_poison", band : [1, 1], help : "cannot be poisoned" },
		{ key : "surefoot", name : "sure-footed", tier : 2, lane : "immune_slow", band : [1, 1], help : "cannot be slowed" },
		{ key : "unmarked", name : "unmarkable", tier : 2, lane : "immune_leech", band : [1, 1], help : "cannot be marked" },
		{ key : "adrenal", name : "adrenaline", tier : 2, lane : "low_atk", band : [15, 30], help : "hits harder under a third of its hp" },
		{ key : "mending", name : "mending", tier : 2, lane : "regen", band : [1, 2], help : "knits a little every action" },
		{ key : "ambusher", name : "ambusher", tier : 2, lane : "vs_full", band : [10, 18], help : "the first blow is the worst one" },
		{ key : "butcher", name : "butcher", tier : 2, lane : "vs_low", band : [10, 18], help : "finishes what is half done" },
		{ key : "turtle", name : "turtle", tier : 2, lane : "low_def", band : [15, 30], help : "curls up when it is hurt" },
		{ key : "dragonscale", name : "dragonscale", tier : 2, lane : "hi_def", band : [10, 20], help : "hard to scratch while it is whole" },
		{ key : "cornered", name : "cornered", tier : 2, lane : "low_eva", band : [20, 40], help : "slippery when it is nearly done" },
		{ key : "vitalstrike", name : "vital strike", tier : 2, lane : "crit_dmg", band : [20, 35], help : "its crits cut deeper" },
		{ key : "retaliator", name : "retaliator", tier : 2, lane : "cnt_pow", band : [15, 30], help : "its counters hit like blows" },
		{ key : "heavyhand", name : "heavy hand", tier : 2, lane : "stagger", band : [15, 30], help : "its blows knock the wind out" },
		{ key : "unshakable", name : "unshakable", tier : 2, lane : "steady", band : [15, 30], help : "blows do not knock it off its stride" },
		{ key : "battery", name : "battery", tier : 2, lane : "mp_gain", band : [15, 30], help : "every landed blow charges it" },
		{ key : "mphaste", name : "mp haste", tier : 2, lane : "mp_haste", band : [3, 6], help : "the well refills on its own" },
		{ key : "vaccinated", name : "vaccinated", tier : 2, lane : "vaccine", band : [25, 40], help : "ailments have trouble taking" },
		{ key : "pathfinder", name : "pathfinder", tier : 2, lane : "sure", band : [20, 40], help : "the crew loses the road less with it along" },
		{ key : "owleyed", name : "owl-eyed", tier : 2, lane : "night", band : [1, 1], help : "the dark costs the crew half as much" },
		{ key : "allweather", name : "all-weather", tier : 2, lane : "weather", band : [1, 1], help : "rain, snow and fog do not trip the crew" },
		{ key : "dangersense", name : "danger sense", tier : 2, lane : "hazard", band : [1, 1], help : "a hazard bites it half as hard" },
		{ key : "wanderer", name : "wanderer", tier : 2, lane : "wander", band : [1, 2], help : "the road teaches it" },
		{ key : "hardlessons", name : "hard lessons", tier : 2, lane : "low_xp", band : [50, 100], help : "learns most from the fights it nearly lost" },
		{ key : "hulking", name : "hulking", tier : 2, lane : "hp", band : [8, 14], help : "a great deal more hit points" },
		{ key : "ironhide", name : "iron hide", tier : 2, lane : "def", band : [8, 14], help : "takes a great deal less from blows" },
		{ key : "frugal", name : "frugal", tier : 2, lane : "frugal", band : [15, 25], help : "its skills cost less" },
		{ key : "gentlehands", name : "gentle hands", tier : 2, lane : "heal_pow", band : [15, 25], help : "its healing goes further" },
		{ key : "goodpatient", name : "good patient", tier : 2, lane : "heal_recv", band : [15, 25], help : "healing goes further on it" },
		{ key : "wellrested", name : "well-rested", tier : 2, lane : "rest_hp", band : [8, 15], help : "a little back walking into every fight" },
		{ key : "secondwind", name : "second wind", tier : 2, lane : "rest", band : [50, 100], help : "naps its hurts off twice as fast" },
		{ key : "goldentouch", name : "golden touch", tier : 2, lane : "gold", band : [10, 20], help : "the trip pays better with it along" },
		{ key : "treasuresense", name : "treasure sense", tier : 2, lane : "loot", band : [1, 2], help : "the crew's finds lean rarer with it along" },
		{ key : "fleet", name : "fleet", tier : 3, lane : "tic", band : [8, 14], help : "acts sooner, always" },
		{ key : "bane", name : "bane", tier : 3, lane : "boss", band : [12, 20], help : "the big ones bleed more" },
		{ key : "scholar", name : "scholar", tier : 3, lane : "xp", band : [15, 30], help : "learns faster" },
		{ key : "aegis", name : "aegis", tier : 3, lane : "res_all", band : [5, 8], help : "resists everything a little" },
		{ key : "vampiric", name : "vampiric", tier : 3, lane : "life", band : [8, 15], help : "heals off what it deals" },
		{ key : "elemental", name : "elementalist", tier : 3, lane : "elemdmg", band : [8, 15], help : "its fire, water and nature skills hit harder" },
		{ key : "berserk", name : "berserk", tier : 3, lane : "atk", band : [15, 25], help : "rage: much more attack, a little less defence", cost : { lane : "def", v : -8 } },
		{ key : "opportunist", name : "opportunist", tier : 3, lane : "vs_ail", band : [15, 25], help : "kicks them while they are down" },
		{ key : "firstblood", name : "first blood", tier : 3, lane : "first", band : [20, 35], help : "opens hard" },
		{ key : "graverobber", name : "grave-robber", tier : 3, lane : "vs_undead", band : [20, 35], help : "knows where the bones are" },
		{ key : "slimesquasher", name : "slime-squasher", tier : 3, lane : "vs_slime", band : [20, 35], help : "knows what a slime is made of" },
		{ key : "piercer", name : "piercer", tier : 3, lane : "pierce", band : [15, 25], help : "finds the gaps in armour" },
		{ key : "reckless", name : "reckless", tier : 3, lane : "atk", band : [15, 25], help : "swings hard and wild", cost : { lane : "hit", v : -10 } },
		{ key : "tothedeath", name : "to the death", tier : 3, lane : "atk", band : [15, 25], help : "gives everything and guards nothing", cost : { lane : "taken", v : 15 } },
		{ key : "darktouched", name : "dark-touched", tier : 3, lane : "dark_pow", band : [12, 20], help : "its dark skills bite deeper" },
		{ key : "thickhide", name : "thick hide", tier : 3, lane : "thick", band : [3, 5], help : "does not feel the small ones" },
		{ key : "stoneskin", name : "stoneskin", tier : 3, lane : "guard", band : [10, 15], help : "hard to hurt, slow to move", cost : { lane : "spd", v : -10 } },
		{ key : "safe", name : "safe", tier : 3, lane : "immune_crit", band : [1, 1], help : "hits on it never crit" },
		{ key : "resilient", name : "resilient", tier : 3, lane : "absorb", band : [10, 20], help : "shakes off a share of every blow" },
		{ key : "grimharvest", name : "grim harvest", tier : 3, lane : "kill_heal", band : [8, 15], help : "a kill puts something back" },
		{ key : "souleater", name : "soul-eater", tier : 3, lane : "kill_mp", band : [15, 30], help : "a kill refills the well" },
		{ key : "vendetta", name : "vendetta", tier : 3, lane : "cnt_crit", band : [10, 20], help : "its counters go for the throat" },
		{ key : "lingering", name : "lingering", tier : 3, lane : "ail_dur", band : [1, 1], help : "what it inflicts stays longer" },
		{ key : "arcane", name : "arcane", tier : 3, lane : "mag", band : [8, 14], help : "casts a great deal harder" },
		{ key : "wardedthrough", name : "warded through", tier : 3, lane : "mdef", band : [8, 14], help : "takes a great deal less from spells" },
		{ key : "windquick", name : "wind-quick", tier : 3, lane : "spd", band : [8, 14], help : "a great deal faster" },
		{ key : "hawkeyed", name : "hawk-eyed", tier : 3, lane : "hit", band : [8, 14], help : "lands a great deal more" },
		{ key : "twoedged", name : "two-edged", tier : 3, lane : "atk", band : [20, 30], help : "hits much harder and bleeds for it", cost : { lane : "bleed", v : 2 } },
		{ key : "titan", name : "titan", tier : 4, lane : "atk", band : [12, 18], help : "the frame of a titan: attack and defence both", also : "def" },
		{ key : "savant", name : "savant", tier : 4, lane : "mag", band : [12, 18], help : "a lifetime of study: int and res both", also : "mdef" },
		{ key : "swift", name : "swift death", tier : 4, lane : "crit", band : [6, 10], help : "quick and cruel: crits and pace both", also : "tic" },
		{ key : "oncemore", name : "once more", tier : 4, lane : "once_more", band : [1, 1], help : "what would down it leaves it at 1 hp instead" },
		{ key : "bulwark", name : "bulwark", tier : 4, lane : "def", band : [12, 18], help : "a wall against steel and spell both", also : "mdef" },
		{ key : "deathwind", name : "death wind", tier : 4, lane : "low_crit_dmg", band : [60, 100], help : "its crits are terrible when it is nearly done" },
		{ key : "gambler", name : "gambler", tier : 4, lane : "crit_dmg", band : [80, 120], help : "twice the crit, half the hits graze", cost : { lane : "graze", v : 50 } },
		{ key : "deaththroes", name : "death throes", tier : 4, lane : "throes", band : [1, 1], help : "going down, it takes the fight out of them" },
		{ key : "mprage", name : "mp rage", tier : 4, lane : "mp_rage", band : [8, 15], help : "every hit it takes feeds the well" },
		{ key : "damagecontrol", name : "damage control", tier : 4, lane : "low_guard", band : [30, 50], help : "hard to finish" },
		{ key : "grandslam", name : "grand slam", tier : 4, lane : "low_crit", band : [15, 25], help : "crits far more when it is nearly done" },
		{ key : "momentum", name : "momentum", tier : 4, lane : "momentum", band : [4, 7], help : "each blow in a row hits harder than the last" },
		{ key : "underdog", name : "underdog", tier : 4, lane : "underdog", band : [12, 20], help : "rises to the bigger foe" },
		{ key : "salvo", name : "opening salvo", tier : 4, lane : "salvo", band : [25, 40], help : "its first skill of a fight is its best" },
		{ key : "ruse", name : "wizard's ruse", tier : 4, lane : "ruse", band : [15, 25], help : "every mp it spends knits a little" },
	];
	return _c;
}
