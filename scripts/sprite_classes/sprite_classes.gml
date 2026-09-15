/// @description sprite_classes() -> the class roster (his pitch, 2026-09-14)
/// Each class is a SHAPE: eight primaries (hp mp atk mag def mdef spd hit)
/// on the tech demo's budget - EFFECTIVE 40: a point costs one up to six
/// and TWO past it (the demo's soft cap; without it the atk / def / hp
/// shapes walk over the fast and the clever - the twin proved it,
/// datafiles/sprite_twin.py) - scaled by level (sprite_stats), so every
/// class is fair by construction and identity is the distribution. Plus the garnish (crit / crit multi / counter),
/// how many armor and talisman slots it wears, which weapon families
/// it favours (gear_score weighs by the shape; these are for shops and
/// the sheet's words), whether its basic attack is magic (mag vs
/// mdef), the library skill it starts with and which skill_gen
/// templates it may roll.
///   warrior  high atk / def / hp, slow, poor against magic; 2 armor 1 talisman
///   mage     spells, a staff, little hp / def; 1 armor 2 talismans
///   rogue    fast, accurate, crits and counters; 1 / 1
///   cleric   heals, sturdy against magic, slow; 1 / 2
///   ranger   fast and accurate at range; 1 / 1
function sprite_classes() {
	static _c = [
		{ key : "warrior", name : "warrior", col : c_hred,
		  shape : { hp : 7, mp : 3, atk : 7, mag : 1, def : 6, mdef : 2, spd : 4, hit : 7 },   // eff 8+3+8+1+6+2+4+8 = 40
		  crit : 6,  cmulti : 1.6, cnt : 8,  armor : 2, talis : 1, magic : false,
		  w1 : ["sword", "axe", "mace", "spear"], w2 : ["shield", "buckler"],
		  skill : "strike", tmpls : [0, 3] },
		{ key : "mage", name : "mage", col : c_hpurple,
		  shape : { hp : 4, mp : 6, atk : 2, mag : 8, def : 2, mdef : 6, spd : 4, hit : 6 },   // eff 4+6+2+10+2+6+4+6 = 40
		  crit : 5,  cmulti : 1.8, cnt : 2,  armor : 1, talis : 2, magic : true,
		  w1 : ["staff", "wand"], w2 : ["tome", "lantern"],
		  skill : "bolt", tmpls : [4, 1] },
		{ key : "rogue", name : "rogue", col : c_horange,
		  shape : { hp : 5, mp : 4, atk : 6, mag : 2, def : 4, mdef : 3, spd : 7, hit : 7 },   // eff 5+4+6+2+4+3+8+8 = 40
		  crit : 14, cmulti : 1.8, cnt : 10, armor : 1, talis : 1, magic : false,
		  w1 : ["dagger", "sword"], w2 : ["dagger", "torch"],
		  skill : "concuss", tmpls : [1, 3] },
		{ key : "cleric", name : "cleric", col : c_gold,
		  shape : { hp : 6, mp : 6, atk : 3, mag : 6, def : 5, mdef : 6, spd : 3, hit : 5 },   // eff 40, all under the cap
		  crit : 3,  cmulti : 1.5, cnt : 3,  armor : 1, talis : 2, magic : true,
		  w1 : ["mace", "staff"], w2 : ["tome", "shield"],
		  skill : "mend", tmpls : [2, 4] },
		{ key : "ranger", name : "ranger", col : c_sgreen,
		  shape : { hp : 5, mp : 4, atk : 6, mag : 3, def : 4, mdef : 4, spd : 6, hit : 7 },   // eff 5+4+6+3+4+4+6+8 = 40
		  crit : 10, cmulti : 1.7, cnt : 6,  armor : 1, talis : 1, magic : false,
		  w1 : ["bow", "spear"], w2 : ["dagger", "lantern"],
		  skill : "strike", tmpls : [3, 0] },
	];
	return _c;
}
