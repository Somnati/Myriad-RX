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
/// luck (2026-09-16): the class's flat luck - sprite_luck adds the levels and the temperament
function sprite_classes() {
	static _c = [
		{ key : "warrior", name : "warrior", col : c_hred,
		  shape : { hp : 7, mp : 3, atk : 7, mag : 1, def : 6, mdef : 2, spd : 4, hit : 7 },   // eff 8+3+8+1+6+2+4+8 = 40
		  crit : 6,  cmulti : 1.6, cnt : 8,  armor : 2, talis : 1, magic : false, luck : 1,
		  w1 : ["sword", "axe", "mace", "spear"], w2 : ["shield", "buckler"],
		  skill : "strike", tmpls : [0, 3, 6] },
		{ key : "mage", name : "mage", col : c_hpurple,
		  shape : { hp : 4, mp : 6, atk : 2, mag : 8, def : 2, mdef : 6, spd : 4, hit : 6 },   // eff 4+6+2+10+2+6+4+6 = 40
		  crit : 5,  cmulti : 1.8, cnt : 2,  armor : 1, talis : 2, magic : true, luck : 2,
		  w1 : ["staff", "wand"], w2 : ["tome", "lantern"],
		  skill : "bolt", tmpls : [4, 4, 7, 1] },
		{ key : "rogue", name : "rogue", col : c_horange,
		  shape : { hp : 5, mp : 4, atk : 6, mag : 2, def : 4, mdef : 3, spd : 7, hit : 7 },   // eff 5+4+6+2+4+3+8+8 = 40
		  crit : 14, cmulti : 1.8, cnt : 10, armor : 1, talis : 1, magic : false, luck : 3,
		  w1 : ["dagger", "sword"], w2 : ["dagger", "torch"],
		  skill : "concuss", tmpls : [1, 3, 5, 7] },
		{ key : "cleric", name : "cleric", col : c_gold,
		  shape : { hp : 6, mp : 6, atk : 3, mag : 6, def : 5, mdef : 6, spd : 3, hit : 5 },   // eff 40, all under the cap
		  crit : 3,  cmulti : 1.5, cnt : 3,  armor : 1, talis : 2, magic : true, luck : 2,
		  w1 : ["mace", "staff"], w2 : ["tome", "shield"],
		  skill : "mend", tmpls : [2, 4, 6, 8] },
		{ key : "ranger", name : "ranger", col : c_sgreen,
		  shape : { hp : 5, mp : 4, atk : 6, mag : 3, def : 4, mdef : 4, spd : 6, hit : 7 },   // eff 5+4+6+3+4+4+6+8 = 40
		  crit : 10, cmulti : 1.7, cnt : 6,  armor : 1, talis : 1, magic : false, luck : 2,
		  w1 : ["bow", "spear"], w2 : ["dagger", "lantern"],
		  skill : "strike", tmpls : [3, 0, 5] },
		// THE THIRTEEN (q312, his ask: "more class types so there's more variety") - APPENDED: a sheet keeps its class by
		// index. Every shape on the forty budget (sprite_twin checks it); the templates each may roll (cbt_skill_gen)
		{ key : "knight", name : "knight", col : c_steelblue,
		  shape : { hp : 7, mp : 2, atk : 5, mag : 1, def : 8, mdef : 5, spd : 3, hit : 6 },   // eff 8+2+5+1+10+5+3+6 = 40
		  crit : 4,  cmulti : 1.5, cnt : 9,  armor : 2, talis : 1, magic : false, luck : 1,
		  w1 : ["sword", "mace", "spear"], w2 : ["shield", "shield"],
		  skill : "bulwark", tmpls : [9, 0, 6, 3] },
		{ key : "berserker", name : "berserker", col : c_hred,
		  shape : { hp : 8, mp : 2, atk : 8, mag : 1, def : 3, mdef : 4, spd : 5, hit : 5 },   // eff 10+2+10+1+3+4+5+5 = 40
		  crit : 9,  cmulti : 1.8, cnt : 6,  armor : 1, talis : 1, magic : false, luck : 1,
		  w1 : ["axe", "axe", "sword"], w2 : ["axe", "torch"],
		  skill : "rage", tmpls : [15, 0, 17, 11] },
		{ key : "valkyrie", name : "valkyrie", col : c_gold,
		  shape : { hp : 6, mp : 3, atk : 7, mag : 2, def : 5, mdef : 4, spd : 6, hit : 6 },   // eff 6+3+8+2+5+4+6+6 = 40
		  crit : 8,  cmulti : 1.6, cnt : 8,  armor : 2, talis : 1, magic : false, luck : 2,
		  w1 : ["spear", "spear", "sword"], w2 : ["shield", "buckler"],
		  skill : "lunge", tmpls : [16, 0, 3, 6] },
		{ key : "samurai", name : "samurai", col : c_horange,
		  shape : { hp : 5, mp : 3, atk : 7, mag : 1, def : 4, mdef : 3, spd : 6, hit : 8 },   // eff 5+3+8+1+4+3+6+10 = 40
		  crit : 16, cmulti : 2.0, cnt : 8,  armor : 1, talis : 1, magic : false, luck : 2,
		  w1 : ["sword", "sword"], w2 : ["dagger", "lantern"],
		  skill : "iai", tmpls : [0, 16, 3, 14] },
		{ key : "brawler", name : "brawler", col : c_sgreen,
		  shape : { hp : 6, mp : 4, atk : 6, mag : 1, def : 6, mdef : 3, spd : 7, hit : 6 },   // eff 6+4+6+1+6+3+8+6 = 40
		  crit : 8,  cmulti : 1.6, cnt : 14, armor : 1, talis : 1, magic : false, luck : 2,
		  w1 : ["claws", "mace"], w2 : ["claws", "buckler"],
		  skill : "flurry", tmpls : [17, 3, 15, 0] },
		{ key : "ninja", name : "ninja", col : c_hpurple,
		  shape : { hp : 4, mp : 3, atk : 7, mag : 1, def : 3, mdef : 3, spd : 8, hit : 7 },   // eff 4+3+8+1+3+3+10+8 = 40
		  crit : 12, cmulti : 1.8, cnt : 10, armor : 1, talis : 1, magic : false, luck : 3,
		  w1 : ["dagger", "sword"], w2 : ["dagger", "dagger"],
		  skill : "smoke", tmpls : [14, 5, 3, 21] },
		{ key : "thief", name : "thief", col : c_horange,
		  shape : { hp : 5, mp : 3, atk : 6, mag : 2, def : 4, mdef : 4, spd : 7, hit : 7 },   // eff 5+3+6+2+4+4+8+8 = 40
		  crit : 12, cmulti : 1.7, cnt : 8,  armor : 1, talis : 1, magic : false, luck : 5,
		  w1 : ["dagger", "dagger", "bow"], w2 : ["dagger", "torch"],
		  skill : "pilfer", tmpls : [18, 5, 14, 3] },
		{ key : "witch", name : "witch", col : c_hpurple,
		  shape : { hp : 5, mp : 6, atk : 1, mag : 8, def : 3, mdef : 5, spd : 4, hit : 6 },   // eff 5+6+1+10+3+5+4+6 = 40
		  crit : 5,  cmulti : 1.8, cnt : 2,  armor : 1, talis : 2, magic : true, luck : 2,
		  w1 : ["wand", "staff"], w2 : ["tome", "lantern"],
		  skill : "hex", tmpls : [7, 1, 21, 12, 4] },
		{ key : "sage", name : "sage", col : c_sblue,
		  shape : { hp : 5, mp : 5, atk : 1, mag : 8, def : 3, mdef : 6, spd : 4, hit : 6 },   // eff 5+5+1+10+3+6+4+6 = 40
		  crit : 3,  cmulti : 1.5, cnt : 2,  armor : 1, talis : 2, magic : true, luck : 2,
		  w1 : ["staff", "tome"], w2 : ["tome", "lantern"],
		  skill : "barrier", tmpls : [10, 4, 19, 2] },
		{ key : "priest", name : "priest", col : c_gold,
		  shape : { hp : 6, mp : 5, atk : 2, mag : 7, def : 4, mdef : 6, spd : 4, hit : 5 },   // eff 6+5+2+8+4+6+4+5 = 40
		  crit : 3,  cmulti : 1.5, cnt : 3,  armor : 1, talis : 2, magic : true, luck : 2,
		  w1 : ["mace", "staff"], w2 : ["tome", "shield"],
		  skill : "manaward", tmpls : [2, 8, 13, 20, 23] },
		{ key : "paladin", name : "paladin", col : c_gold,
		  shape : { hp : 7, mp : 3, atk : 6, mag : 3, def : 6, mdef : 5, spd : 3, hit : 6 },   // eff 8+3+6+3+6+5+3+6 = 40
		  crit : 5,  cmulti : 1.5, cnt : 7,  armor : 2, talis : 1, magic : false, luck : 2,
		  w1 : ["sword", "mace"], w2 : ["shield", "tome"],
		  skill : "smite", tmpls : [23, 9, 2, 0] },
		{ key : "bard", name : "bard", col : c_sblue,
		  shape : { hp : 5, mp : 4, atk : 6, mag : 2, def : 4, mdef : 3, spd : 7, hit : 7 },   // eff 5+4+6+2+4+3+8+8 = 40
		  crit : 6,  cmulti : 1.6, cnt : 4,  armor : 1, talis : 2, magic : false, luck : 3,
		  w1 : ["dagger", "wand"], w2 : ["lantern", "tome"],
		  skill : "song", tmpls : [17, 22, 6, 20, 21] },
		{ key : "druid", name : "druid", col : c_sgreen,
		  shape : { hp : 6, mp : 5, atk : 3, mag : 7, def : 4, mdef : 4, spd : 4, hit : 6 },   // eff 6+5+3+8+4+4+4+6 = 40
		  crit : 4,  cmulti : 1.6, cnt : 4,  armor : 1, talis : 2, magic : true, luck : 2,
		  w1 : ["staff", "spear"], w2 : ["tome", "torch"],
		  skill : "regrowth", tmpls : [13, 4, 5, 19] },
	];
	return _c;
}
