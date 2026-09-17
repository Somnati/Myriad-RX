/// @description ability_lane_desc(lane) -> { word, what } - the lane's
/// short word for a line ("+4.8% atk") and the sentence the tooltip
/// says (his report, 2026-09-17: "+4.8% to what?")
function ability_lane_desc(_ln) {
	switch (_ln) {
		case "hp":   return { word : "max hp",   what : "max hit points" };
		case "atk":  return { word : "atk",      what : "attack power - every physical blow and physical skill" };
		case "mag":  return { word : "int",      what : "int - every spell" };
		case "def":  return { word : "def",      what : "defence against physical blows" };
		case "mdef": return { word : "res",      what : "res - defence against spells" };
		case "spd":  return { word : "spd",      what : "speed - turn pace, and evasion with it" };
		case "hit":  return { word : "hit",      what : "hit - the chance a blow lands" };
		case "crit": return { word : "crit",     what : "the chance a landed blow crits" };
		case "cnt":  return { word : "counter",  what : "the chance to hit straight back when struck" };
		case "luck": return { word : "luck",     what : "luck - crits, finds, the tavern's dice, every roll of its own" };
		case "res_fire":   return { word : "fire res",   what : "damage taken from fire, less" };
		case "res_water":  return { word : "water res",  what : "damage taken from water, less" };
		case "res_nature": return { word : "nature res", what : "damage taken from nature, less" };
		case "res_all":    return { word : "res to all", what : "damage taken from fire, water and nature, less" };
		case "immune_poison": return { word : "", what : "the venom never takes - poison cannot land on it" };
		case "immune_slow":   return { word : "", what : "the chill never takes - it cannot be slowed" };
		case "immune_leech":  return { word : "", what : "the mark never takes - it cannot be leeched" };
		case "ail_poison": return { word : "poison a bite", what : "each basic attack: the chance it leaves poison (4% of their max hp each of their turns, three turns)" };
		case "ail_slow":   return { word : "slow a bite",   what : "each basic attack: the chance it leaves a chill (they act at 60% pace, three turns)" };
		case "low_atk": return { word : "atk under a third hp", what : "attack power while it is under a third of its hit points" };
		case "boss":    return { word : "vs titled foes",       what : "damage against a titled foe - a chief, an elder, a king" };
		case "xp":      return { word : "xp",                  what : "its share of every fight's and quest's xp" };
		case "tic":     return { word : "pace",                what : "turn pace, always - it acts sooner" };
		case "life":    return { word : "of damage healed",    what : "heals this share of every point of damage it deals" };
		case "elemdmg": return { word : "elemental",           what : "its fire, water and nature skills hit this much harder" };
		case "regen":   return { word : "hp an action",        what : "max hp knitted back at each of its own actions" };
		case "undying": return { word : "", what : "once a fight, the blow that would down it leaves it at 1 hp" };
	}
	return { word : _ln, what : "" };
}
