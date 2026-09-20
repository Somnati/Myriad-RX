/// @description region_kinds() -> the node kinds: { key : { name, col, r, civ, wild } }
/// What a node can be (his pitch, 2026-09-14: "a node might be a little
/// town, big city, dungeon, empty field, forest, desert, mountains etc
/// with each one having their own purpose"). civ = a place people live
/// (shops / rest, slice three), wild = the land between. r = the dot's
/// radius on the debug map; col its colour.
function region_kinds() {
	static _k = {
		landing    : { name : "landing zone", col : c_white,              r : 3, civ : false, wild : false },
		settlement : { name : "settlement",   col : c_gold,               r : 3, civ : true,  wild : false },
		village    : { name : "village",      col : rgb(255, 200, 120),   r : 3, civ : true,  wild : false },
		town       : { name : "town",         col : c_horange,            r : 4, civ : true,  wild : false },
		city       : { name : "city",         col : rgb(255, 120, 80),    r : 5, civ : true,  wild : false },
		camp       : { name : "bandit camp",  col : c_hred,               r : 3, civ : false, wild : false },
		dungeon    : { name : "dungeon",      col : c_hpurple,            r : 3, civ : false, wild : false },
		crypt      : { name : "crypt",        col : rgb(175, 155, 205),   r : 3, civ : false, wild : false },   // a dungeon of the dead (skeletons, wisps)
		sewer      : { name : "sewer",        col : rgb(110, 140, 95),    r : 3, civ : false, wild : false },   // under a city (and a town, sometimes): the drains, a dungeon of vermin (his ask, 2026-09-16)
		ruin       : { name : "ruin",         col : rgb(160, 160, 175),   r : 2, civ : false, wild : true },
		shrine     : { name : "shrine",       col : c_lavender,           r : 2, civ : false, wild : true },
		mine       : { name : "mine",         col : c_steelblue,          r : 2, civ : false, wild : true },
		field      : { name : "field",        col : rgb(120, 200, 90),    r : 2, civ : false, wild : true },
		forest     : { name : "forest",       col : rgb(50, 140, 70),     r : 2, civ : false, wild : true },
		hills      : { name : "hills",        col : rgb(170, 140, 100),   r : 2, civ : false, wild : true },
		marsh      : { name : "marsh",        col : rgb(90, 160, 150),    r : 2, civ : false, wild : true },
		desert     : { name : "desert",       col : rgb(230, 200, 130),   r : 2, civ : false, wild : true },
		mountains  : { name : "mountains",    col : rgb(200, 200, 215),   r : 2, civ : false, wild : true },
		tundra     : { name : "tundra",       col : rgb(200, 225, 240),   r : 2, civ : false, wild : true },
		coast      : { name : "coast",        col : rgb(150, 200, 220),   r : 2, civ : false, wild : true },
		isle       : { name : "island",       col : rgb(120, 210, 200),   r : 2, civ : false, wild : true },   // off a coast, by boat (region_gen)
		pass       : { name : "border pass",  col : rgb(225, 205, 130),   r : 2, civ : false, wild : false },  // the way into the next territory (q291)
	};
	return _k;
}
