/// @description gear_quirks() -> the roster of QUIRKS: [{ key, adjs, sufs, desc, val, [hold], [crit], [cnt], [erode], [mp0], [budget, hole] }]
/// THE PROC-GEAR PASS (2026-09-15): a quirk is a property that DOES
/// something and NAMES the item (an adjective or a suffix off its
/// lists). hold = the hazard the item holds off (cbt_hazard_hold reads
/// it - any item can be a lantern's equal); crit / cnt add to the
/// wearer's garnish, erode scales the wear, mp0 adds to the mp a fight
/// opens with (sprite_pawn); cursed = the budget x1.35 with one line
/// cut to .6 (gear_gen). val = what the sprite's eye adds for it
/// (gear_score). desc = the popup's line.
function gear_quirks() {
	static _q = [
		{ key : "bright",   hold : "dark", adjs : ["very shiny", "glowing (a bit)", "lit"],            sufs : ["of the small light", "of the last candle"],   desc : "it gives off a little light - enough to see the floor by, which is where most things are.", val : 1.5 },
		{ key : "oiled",    hold : "damp", adjs : ["oiled", "waxed", "well-greased"],                   sufs : ["of the dry cellar", "of the bog"],            desc : "it keeps the damp off. it smells of the stuff that does that.", val : 1.5 },
		{ key : "cool",     hold : "heat", adjs : ["cool to the touch", "shaded", "pale"],              sufs : ["of the shade", "of the deep well"],           desc : "it stays cool, somehow, and so, a little, does whoever holds it.", val : 1.5 },
		{ key : "warm",     hold : "cold", adjs : ["alarmingly warm", "toasty", "ember-lined"],         sufs : ["of probably fire", "of the hearth"],          desc : "it is warm. nobody knows why. nobody is asking, in the cold.", val : 1.5 },
		{ key : "keen",     crit : 4,      adjs : ["keen", "sharp-ish", "pointed"],                     sufs : ["of the sudden edge", "of the lucky angle"],   desc : "it finds the soft spot more often than it should.", val : 2 },
		{ key : "spiteful", cnt : 6,       adjs : ["spiteful", "rude", "quick-tempered"],               sufs : ["of the quick reply", "of the last word"],     desc : "it hits back. the one holding it has less say in this than you would think.", val : 2 },
		{ key : "sturdy",   erode : .5,    adjs : ["sturdy", "regulation", "over-built"],               sufs : ["of surprising heft", "of the long haul"],     desc : "it takes the wear so the wearer does not, mostly.", val : 1.5 },
		{ key : "eager",    mp0 : .25,     adjs : ["restless", "loud", "twitchy"],                      sufs : ["of the early start", "of the first move"],    desc : "it wants to begin. fights open with more in the tank.", val : 1.5 },
		// THE ELEMENTS PASS (2026-09-17): armour and talismans can be PROOFED
		// (+res_quirk in one element for the wearer); a weapon can CARRY one
		// (every basic attack is that element). gear_gen keeps each to its slots
		{ key : "fireproof",  res : "fire",   adjs : ["fireproof", "ash-grey", "kiln-fired"],        sufs : ["of the cold hearth", "of the doused coal"],  desc : "it takes a tenth less from fire", val : 1.5 },
		{ key : "waterproof", res : "water",  adjs : ["waxed-tight", "salt-stiff", "dry"],           sufs : ["of the dry riverbed", "of the long drought"], desc : "it takes a tenth less from water", val : 1.5 },
		{ key : "thornproof", res : "nature", adjs : ["thornproof", "thick-hided", "bramble-worn"],   sufs : ["of the clear path", "of the calm sky"],       desc : "it takes a tenth less from nature", val : 1.5 },
		{ key : "burning",    elem : "fire",   adjs : ["burning", "smouldering", "ember-lit"],         sufs : ["of the kiln", "of the last fire"],            desc : "every swing is fire", val : 1.5 },
		{ key : "soaked",     elem : "water",  adjs : ["dripping", "rimed", "tide-cold"],              sufs : ["of the deep pool", "of the first frost"],     desc : "every swing is water", val : 1.5 },
		{ key : "thorned",    elem : "nature", adjs : ["thorned", "sap-green", "buzzing"],             sufs : ["of the wild hedge", "of the storm"],          desc : "every swing is nature", val : 1.5 },
		{ key : "cursed",   budget : 1.35, hole : .6, adjs : ["lightly cursed", "haunted (a little)", "suspicious"], sufs : ["of moderate doom", "of the unpaid debt"], desc : "there is more in it than there should be, and a hole where something was taken.", val : 0 },
	];
	return _q;
}
