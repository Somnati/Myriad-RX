/// @description ability_lane_desc(lane) -> { word, what } - the lane's
/// short word for a line ("+4.8% atk") and the sentence the tooltip
/// says (his report, 2026-09-17: "+4.8% to what?"). Every lane of the
/// big roster (2026-09-17) is here; a flag lane's word is "" (the line
/// is the name alone).
function ability_lane_desc(_ln) {
	switch (_ln) {
		case "hp": return { word : "max hp", what : "max hit points" };
		case "mp": return { word : "max mp", what : "max magic points" };
		case "atk": return { word : "atk", what : "attack power - every physical blow and physical skill" };
		case "mag": return { word : "int", what : "int - every spell" };
		case "def": return { word : "def", what : "defence against physical blows" };
		case "mdef": return { word : "res", what : "res - defence against spells" };
		case "spd": return { word : "spd", what : "speed - turn pace, and evasion with it" };
		case "hit": return { word : "hit", what : "hit - the chance a blow lands" };
		case "crit": return { word : "crit", what : "the chance a landed blow crits" };
		case "cnt": return { word : "counter", what : "the chance to hit straight back when struck" };
		case "luck": return { word : "luck", what : "luck - crits, finds, the tavern's dice, every roll of its own" };
		case "res_fire": return { word : "fire res", what : "damage taken from fire, less" };
		case "res_water": return { word : "water res", what : "damage taken from water, less" };
		case "res_nature": return { word : "nature res", what : "damage taken from nature, less" };
		case "res_all": return { word : "res to all", what : "damage taken from fire, water and nature, less" };
		case "immune_poison": return { word : "", what : "the venom never takes - poison cannot land on it" };
		case "immune_slow": return { word : "", what : "the chill never takes - it cannot be slowed" };
		case "immune_leech": return { word : "", what : "the mark never takes - it cannot be leeched" };
		case "immune_crit": return { word : "", what : "hits on it never crit" };
		case "ail_poison": return { word : "poison a bite", what : "each basic attack: the chance it leaves poison (4% of their max hp each of their turns, three turns)" };
		case "ail_slow": return { word : "slow a bite", what : "each basic attack: the chance it leaves a chill (they act at 60% pace, three turns)" };
		case "low_atk": return { word : "atk under a third hp", what : "attack power while it is under a third of its hit points" };
		case "boss": return { word : "vs titled foes", what : "damage against a titled foe - a chief, an elder, a king" };
		case "xp": return { word : "xp", what : "its share of every fight's and quest's xp" };
		case "tic": return { word : "pace", what : "turn pace, always - it acts sooner" };
		case "life": return { word : "of damage healed", what : "heals this share of every point of damage it deals" };
		case "elemdmg": return { word : "elemental", what : "its fire, water and nature skills hit this much harder" };
		case "regen": return { word : "hp an action", what : "max hp knitted back at each of its own actions" };
		case "once_more": return { word : "", what : "an action that would down it leaves it at 1 hp - as long as it had more than 1 going in" };
		case "eva": return { word : "eva", what : "evasion points, flat - on top of what spd gives" };
		case "mp0": return { word : "mp to start", what : "the mp a fight opens with, of max - on top of the usual half" };
		case "potion": return { word : "from potions", what : "what a red or a blue potion does for it" };
		case "pace": return { word : "road pace", what : "the crew's pace on every road while it walks with them" };
		case "finds": return { word : "drops", what : "the chance a won fight leaves something behind, with the crew" };
		case "inn": return { word : "", what : "inns: its bed is a credit cheaper (the bill never under half)" };
		case "haggle": return { word : "", what : "shops: it haggles a credit off everything" };
		case "bonds": return { word : "bonds", what : "how fast its friendships grow" };
		case "vs_full": return { word : "vs a target at full hp", what : "damage against a target still at full hp" };
		case "vs_low": return { word : "vs a target under half", what : "damage against a target under half its hp" };
		case "vs_ail": return { word : "vs an ailing target", what : "damage against a target that is poisoned, slowed or marked" };
		case "vs_undead": return { word : "vs the undead", what : "damage against the undead" };
		case "vs_slime": return { word : "vs slimes", what : "damage against slimes" };
		case "low_def": return { word : "def under a third hp", what : "defence while it is under a third of its hit points" };
		case "hi_def": return { word : "def above four fifths", what : "defence while it is above four fifths of its hit points" };
		case "low_eva": return { word : "evasion under a quarter", what : "evasion while it is under a quarter of its hit points" };
		case "crit_dmg": return { word : "crit damage", what : "the extra a crit deals, more" };
		case "low_crit_dmg": return { word : "crit damage under a quarter hp", what : "the extra a crit deals, while it is under a quarter of its hit points" };
		case "low_crit": return { word : "crit under a quarter hp", what : "crit chance, points, while it is under a quarter of its hit points" };
		case "cnt_pow": return { word : "counter damage", what : "the damage of its counter-attacks" };
		case "cnt_crit": return { word : "crit on counters", what : "crit chance, points, on its counter-attacks" };
		case "stagger": return { word : "stagger", what : "how far its blows knock the target's turn back" };
		case "steady": return { word : "less staggered", what : "how far blows knock its own turn back - less" };
		case "mp_gain": return { word : "mp a basic", what : "the mp a landed basic attack builds" };
		case "mp_haste": return { word : "max mp an action", what : "mp back at each of its own actions" };
		case "mp_rage": return { word : "max mp when hit", what : "mp back whenever it is hit - a heavy hit gives the most" };
		case "vaccine": return { word : "ailment resist", what : "the chance an ailment lands on it, less" };
		case "sure": return { word : "fewer wrong turns", what : "wrong turns and hours lost in the dark and the fog, with the crew" };
		case "night": return { word : "", what : "the dark: half the lost hours and wrong turns at night while it walks with the crew" };
		case "weather": return { word : "", what : "the weather: no slips and no wrong turns in rain, snow or fog while it walks with the crew" };
		case "hazard": return { word : "", what : "a hazard bites it half as hard when nothing else holds it" };
		case "wander": return { word : "xp per 10 km", what : "xp for the distance it walks - the road teaches" };
		case "low_xp": return { word : "xp from a close fight", what : "xp from a fight it ends under a quarter of its hit points" };
		case "frugal": return { word : "off skill costs", what : "the mp its skills cost, less (never under 1)" };
		case "heal_pow": return { word : "to its heals", what : "what its healing skills restore" };
		case "heal_recv": return { word : "to heals on it", what : "what healing skills restore on it" };
		case "rest_hp": return { word : "hp walking in", what : "max hp knitted back walking into each fight" };
		case "rest": return { word : "faster at home", what : "how fast it naps its hurts off at home" };
		case "gold": return { word : "the trip's pay", what : "the trip's pay at the door, with the crew" };
		case "loot": return { word : "loot luck", what : "leans every find's rarity up, the way luck does, with the crew" };
		case "first": return { word : "atk on the first action", what : "attack power on its first action of a fight" };
		case "pierce": return { word : "of def ignored", what : "the share of the target's defence its blows ignore" };
		case "taken": return { word : "damage taken", what : "damage it takes, more" };
		case "guard": return { word : "less damage taken", what : "damage it takes, less" };
		case "low_guard": return { word : "less damage under a quarter hp", what : "damage it takes while under a quarter of its hit points, less" };
		case "dark_pow": return { word : "to dark skills", what : "what its dark skills deal" };
		case "thick": return { word : "of max hp shrugged", what : "a hit under this share of its max hp does nothing at all" };
		case "absorb": return { word : "of damage taken healed", what : "heals this share of every hit it takes" };
		case "kill_heal": return { word : "max hp on a kill", what : "hp back when it downs a foe" };
		case "kill_mp": return { word : "max mp on a kill", what : "mp back when it downs a foe" };
		case "ail_dur": return { word : "action longer", what : "its poison, slow and mark last this many more of the victim's actions" };
		case "bleed": return { word : "hp bled a hit", what : "it bleeds this share of its max hp on every blow it lands" };
		case "graze": return { word : "grazes", what : "this many of its landed hits in a hundred land as grazes" };
		case "throes": return { word : "", what : "downed, it lowers the attack of every foe still standing" };
		case "momentum": return { word : "per hit in a row", what : "damage, per landed hit in a row - a miss resets it, five at most" };
		case "underdog": return { word : "vs a higher level", what : "attack power against a foe of a higher level than its own" };
		case "salvo": return { word : "on its first skill", what : "what its first skill of a fight deals" };
		case "ruse": return { word : "of mp spent healed", what : "heals this share of the hp-worth of every mp it spends" };
	}
	return { word : _ln, what : "" };
}
