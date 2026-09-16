/// @description cbt_stat_desc(key) -> [title, lines...] what a stat does (the sheet's stat popup, his ask 2026-09-15)
/// The numbers are cbt_balance's, said plainly (the same engine the
/// fights run: cbt_hit / cbt_fight_turn).
function cbt_stat_desc(_k) {
	var _b = cbt_balance();
	switch (_k) {
		case "hp":   return ["hp  -  hit points", string(_b.hp_per_point) + " a point, plus " + string(_b.hp_flat_add) + ". at zero the sprite is down for the rest of the fight (and naps it off at home). every hit taken also wears the maximum down a little for that fight."];
		case "mp":   return ["mp  -  magic points", "a point each. a fight opens at half; basic attacks BUILD mp (" + string(_b.mp_gain) + ", " + string(_b.mp_gain_qual) + " on a clean hit) and skills spend it. what is left rides home and out again."];
		case "atk":  return ["atk  -  attack", "the power behind a weapon swing. damage starts at atk x the skill's multiplier, then the target's def comes off it (a third, less when the hit lands clean)."];
		case "def":  return ["def  -  defence", "soaks steel: a third of def comes off every physical hit against you - a clean hit pierces it (down to " + string(_b.def_lerp_low * 100) + "%)."];
		case "mag":  return ["int  -  intellect", "the power behind spells and heals, the way atk is behind swings. magic is soaked by the target's res, not its def."];
		case "mdef": return ["res  -  resistance", "soaks magic the way def soaks steel: a third of res comes off every spell that lands on you."];
		case "spd":  return ["spd  -  speed", "how often a turn comes: " + string(_b.tic_spd_base) + " + sqrt(spd) / " + string(_b.tic_spd_div) + " a tick. and evasion is spd x " + string(_b.spd_to_eva) + " - the faster, the harder to hit. a hit also staggers the quick less."];
		case "luck": return ["luck", "the class's point or three, one more every five levels, one for the sly and the dreamy. half a point of crit a point; the crew's luck together leans the loot ladder toward the rare; the lucky throw fewer good things away."];
		case "hit":  return ["hit  -  accuracy", "against the target's evasion (spd x " + string(_b.spd_to_eva) + "): the chance a swing lands, and how CLEAN - one roll's margin sets the damage, the def pierced and the stagger. a studied foe (the notepad) adds to it."];
	}
	return [_k, "?"];
}
