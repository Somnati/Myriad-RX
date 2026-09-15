/// @description cbt_hazards() -> the roster of hazards: [{ key, name, lane, f, kinds, inside, gear, cls, hold, bite, col }]
/// A PLACE'S HAZARD (his pick from the review, 2026-09-15: "let biome
/// shape the threats so gear and skills counter something"): a crew that
/// is BARE to it fights with one stat lane cut (lane x f - the foes are
/// native and never mind it); a member HOLDS it off by wearing a gear
/// FAMILY from the hazard's list (the silly names are the families in
/// disguise: a bathrobe is a robe) or by being of its class. kinds = the
/// node kinds that carry it; inside = only at the place, never on its
/// roads (the dark is indoors). hold = what holds it (the prep page and
/// the diary's reason on a loss), bite = what a bare member cannot do
/// (the diary, after the names: "Ola can barely see"). col = its word's
/// colour everywhere.
function cbt_hazards() {
	static _h = [
		{ key : "dark", name : "the dark", lane : "hit", f : .6,  kinds : ["dungeon", "crypt", "mine"], inside : true,
		  gear : ["torch", "lantern"], cls : ["rogue"],
		  hold : "a torch, a lantern, or a rogue", bite : "can barely see", col : rgb(160, 140, 210) },
		{ key : "damp", name : "the damp", lane : "mag", f : .6,  kinds : ["marsh"], inside : false,
		  gear : ["robe", "cloak", "lantern"], cls : ["ranger"],
		  hold : "a robe, a cloak, a lantern, or a ranger", bite : "cannot get a spell to take", col : rgb(90, 175, 160) },
		{ key : "heat", name : "the heat", lane : "spd", f : .6,  kinds : ["desert"], inside : false,
		  gear : ["cloak", "leather", "bead"], cls : ["cleric"],
		  hold : "a cloak, leather, a bead, or a cleric", bite : "cannot keep the pace", col : c_horange },
		{ key : "cold", name : "the cold", lane : "atk", f : .65, kinds : ["tundra", "mountains"], inside : false,
		  gear : ["hide", "robe", "torch"], cls : ["warrior"],
		  hold : "hide, a robe, a torch, or a warrior", bite : "cannot grip a weapon properly", col : rgb(190, 215, 235) },
	];
	return _h;
}
