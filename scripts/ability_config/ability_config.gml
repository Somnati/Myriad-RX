/// @description ability_config() -> the roster of ABILITIES (his ask,
/// 2026-09-17, Disgaea's evilities): PASSIVE traits a sprite or a foe
/// carries in four slots. Each kind has a TIER (the unlock rung it enters
/// the pool at - see ability_unlocks), a band for its number at common
/// (rarity multiplies it, ability_rarity_mult) and a LANE - the one place
/// its number lands (ability_effects sums the lanes; the pawns read them).
///
/// Lanes: hp / atk / mag / def / mdef / spd / hit (percent of the stat),
/// crit / cnt (points), luck (points), res_fire / res_water / res_nature /
/// res_all (resistance points), immune (poison / slow / leech), ail
/// (the basic attack leaves it: the band is the chance), low_atk (atk up
/// under 35% hp), boss (damage to bosses), xp (a share more xp), tic
/// (atb rate), life (heals this share of damage dealt), elemdmg
/// (elemental skills), regen (max hp an action), undying (once a fight,
/// a killing blow leaves 1 hp), def2 (a second lane for berserk's cost).
function ability_config() {
	static _c = [
		// ---- tier 1 ----
		{ key : "stout",      name : "stout",       tier : 1, lane : "hp",   band : [4, 8],   unit : "%",   help : "more hit points" },
		{ key : "brawn",      name : "brawn",       tier : 1, lane : "atk",  band : [4, 8],   unit : "%",   help : "hits harder" },
		{ key : "bookish",    name : "bookish",     tier : 1, lane : "mag",  band : [4, 8],   unit : "%",   help : "casts harder" },
		{ key : "thickskin",  name : "thick skin",  tier : 1, lane : "def",  band : [4, 8],   unit : "%",   help : "takes less from blows" },
		{ key : "warded",     name : "warded",      tier : 1, lane : "mdef", band : [4, 8],   unit : "%",   help : "takes less from spells" },
		{ key : "quick",      name : "quick",       tier : 1, lane : "spd",  band : [4, 8],   unit : "%",   help : "faster, and harder to hit" },
		{ key : "keeneye",    name : "keen eye",    tier : 1, lane : "hit",  band : [4, 8],   unit : "%",   help : "lands more" },
		{ key : "lucky",      name : "lucky",       tier : 1, lane : "luck", band : [1, 1],   unit : " luck", help : "a point of luck" },
		{ key : "fireproof",  name : "fireproof",   tier : 1, lane : "res_fire",   band : [6, 10], unit : " res", help : "resists fire" },
		{ key : "waterproof", name : "waterproof",  tier : 1, lane : "res_water",  band : [6, 10], unit : " res", help : "resists water" },
		{ key : "thornproof", name : "thornproof",  tier : 1, lane : "res_nature", band : [6, 10], unit : " res", help : "resists nature" },
		// ---- tier 2 ----
		{ key : "vicious",    name : "vicious",     tier : 2, lane : "crit", band : [3, 6],   unit : "% crit", help : "crits more" },
		{ key : "spiteful",   name : "spiteful",    tier : 2, lane : "cnt",  band : [4, 8],   unit : "% counter", help : "hits back more" },
		{ key : "venomous",   name : "venomous",    tier : 2, lane : "ail_poison", band : [10, 18], unit : "% a bite", help : "its blows poison" },
		{ key : "chilling",   name : "chilling",    tier : 2, lane : "ail_slow",   band : [10, 18], unit : "% a bite", help : "its blows slow" },
		{ key : "antidote",   name : "antidote",    tier : 2, lane : "immune_poison", band : [1, 1], unit : "", help : "cannot be poisoned" },
		{ key : "surefoot",   name : "sure-footed", tier : 2, lane : "immune_slow",   band : [1, 1], unit : "", help : "cannot be slowed" },
		{ key : "unmarked",   name : "unmarkable",  tier : 2, lane : "immune_leech",  band : [1, 1], unit : "", help : "cannot be marked" },
		{ key : "adrenal",    name : "adrenaline",  tier : 2, lane : "low_atk", band : [15, 30], unit : "% atk", help : "hits harder under a third of its hp" },
		{ key : "mending",    name : "mending",     tier : 2, lane : "regen", band : [1, 2],   unit : "% an action", help : "knits a little every action" },
		// ---- tier 3 ----
		{ key : "fleet",      name : "fleet",       tier : 3, lane : "tic",  band : [8, 14],  unit : "% pace", help : "acts sooner, always" },
		{ key : "bane",       name : "bane",        tier : 3, lane : "boss", band : [12, 20], unit : "% to bosses", help : "the big ones bleed more" },
		{ key : "scholar",    name : "scholar",     tier : 3, lane : "xp",   band : [15, 30], unit : "% xp", help : "learns faster" },
		{ key : "aegis",      name : "aegis",       tier : 3, lane : "res_all", band : [5, 8], unit : " res all", help : "resists everything a little" },
		{ key : "vampiric",   name : "vampiric",    tier : 3, lane : "life", band : [8, 15],  unit : "% of damage", help : "heals off what it deals" },
		{ key : "elemental",  name : "elementalist", tier : 3, lane : "elemdmg", band : [8, 15], unit : "% elemental", help : "its fire, water and nature skills hit harder" },
		{ key : "berserk",    name : "berserk",     tier : 3, lane : "atk",  band : [15, 25], unit : "% atk", help : "hits much harder, guards less", cost : { lane : "def", v : -8 } },
		// ---- tier 4 ----
		{ key : "titan",      name : "titan",       tier : 4, lane : "atk",  band : [12, 18], unit : "% atk and def", help : "big", also : "def" },
		{ key : "savant",     name : "savant",      tier : 4, lane : "mag",  band : [12, 18], unit : "% int and res", help : "learned", also : "mdef" },
		{ key : "undying",    name : "undying",     tier : 4, lane : "undying", band : [1, 1], unit : "", help : "once a fight, a killing blow leaves it at 1 hp" },
		{ key : "swift",      name : "swift death", tier : 4, lane : "crit", band : [6, 10],  unit : "% crit and pace", help : "quick and cruel", also : "tic" },
	];
	return _c;
}
