/// @description foe_roster() -> the roster: [{ name, shape, crit, cmulti, cnt, erode, magic, skill, gear, col, lands }]
/// THE FOES PASS (2026-09-15): thirty kinds, each with the LANDS it haunts
/// (region_kinds' keys; "road" = any road) - foe_kinds_at picks by the
/// land, so the marsh has its own things and so does the desert. Shapes
/// on the sprites' budget (eight lines summing ~36-38 - the old seven's
/// measure), scaled by level in foe_gen. skill = a library skill
/// (cbt_skills) or "". gear = the chance it is armed (gear_gen). The
/// first seven are the old roster, untouched: a seed still makes the
/// same goblin.
function foe_roster() {
	static _ros = [
		{ name : "goblin",    shape : { hp : 5, mp : 3, atk : 6, mag : 2, def : 5, mdef : 3, spd : 7, hit : 7 }, crit : 8,  cmulti : 1.6, cnt : 8,  erode : 1,   magic : false, skill : "concuss", gear : .3, col : rgb(120, 160, 70),  lands : ["field", "forest", "hills", "dungeon", "camp", "road"] },
		{ name : "bandit",    shape : { hp : 6, mp : 3, atk : 7, mag : 1, def : 6, mdef : 3, spd : 5, hit : 7 }, crit : 7,  cmulti : 1.6, cnt : 7,  erode : 1,   magic : false, skill : "strike",  gear : .8, col : rgb(170, 120, 90),  lands : ["hills", "field", "forest", "camp", "road", "coast", "desert"] },
		{ name : "wolf",      shape : { hp : 6, mp : 2, atk : 7, mag : 1, def : 3, mdef : 2, spd : 8, hit : 7 }, crit : 10, cmulti : 1.7, cnt : 5,  erode : 1,   magic : false, skill : "",        gear : 0,  col : rgb(150, 150, 160), lands : ["forest", "hills", "field", "tundra", "road"] },
		{ name : "slime",     shape : { hp : 8, mp : 6, atk : 3, mag : 3, def : 6, mdef : 6, spd : 2, hit : 4 }, crit : 5,  cmulti : 1.5, cnt : 4,  erode : .25, magic : false, skill : "reform",  gear : 0,  col : c_seagreen,          lands : ["dungeon", "marsh", "mine", "ruin"] },
		{ name : "skeleton",  shape : { hp : 6, mp : 4, atk : 8, mag : 1, def : 6, mdef : 4, spd : 3, hit : 6 }, crit : 8,  cmulti : 1.8, cnt : 6,  erode : 1,   magic : false, skill : "strike",  gear : .5, col : rgb(205, 205, 210), lands : ["crypt", "ruin"] },
		{ name : "wisp",      shape : { hp : 3, mp : 6, atk : 2, mag : 8, def : 2, mdef : 6, spd : 5, hit : 6 }, crit : 6,  cmulti : 1.8, cnt : 2,  erode : 1,   magic : true,  skill : "drain",   gear : 0,  col : rgb(150, 110, 220), lands : ["crypt", "marsh", "ruin"] },
		{ name : "rat",       shape : { hp : 5, mp : 4, atk : 6, mag : 1, def : 4, mdef : 2, spd : 7, hit : 8 }, crit : 10, cmulti : 1.6, cnt : 12, erode : 1,   magic : false, skill : "concuss", gear : .1, col : rgb(180, 145, 110), lands : ["dungeon", "ruin", "field", "mine", "road", "village", "town", "city"] },
		// ---- the pass: the green ----
		{ name : "boar",      shape : { hp : 7, mp : 2, atk : 7, mag : 1, def : 5, mdef : 2, spd : 6, hit : 6 }, crit : 6,  cmulti : 1.7, cnt : 4,  erode : 1,   magic : false, skill : "concuss", gear : 0,  col : rgb(110, 85, 60),   lands : ["forest", "hills", "field"] },
		{ name : "hornets",   shape : { hp : 4, mp : 2, atk : 6, mag : 1, def : 2, mdef : 2, spd : 10, hit : 9 }, crit : 8, cmulti : 1.4, cnt : 14, erode : 1,   magic : false, skill : "",        gear : 0,  col : rgb(220, 180, 50),  lands : ["field", "forest", "hills"] },
		{ name : "spider",    shape : { hp : 5, mp : 3, atk : 6, mag : 2, def : 4, mdef : 3, spd : 7, hit : 7 }, crit : 9,  cmulti : 1.7, cnt : 8,  erode : 1,   magic : false, skill : "concuss", gear : 0,  col : rgb(70, 60, 70),    lands : ["forest", "dungeon", "mine", "ruin"] },
		{ name : "bear",      shape : { hp : 9, mp : 2, atk : 8, mag : 1, def : 6, mdef : 2, spd : 4, hit : 5 }, crit : 7,  cmulti : 1.8, cnt : 6,  erode : 1,   magic : false, skill : "strike",  gear : 0,  col : rgb(90, 70, 55),    lands : ["forest", "mountains", "hills"] },
		{ name : "kobold",    shape : { hp : 5, mp : 3, atk : 5, mag : 2, def : 5, mdef : 3, spd : 7, hit : 7 }, crit : 7,  cmulti : 1.6, cnt : 7,  erode : 1,   magic : false, skill : "concuss", gear : .4, col : rgb(150, 100, 80),  lands : ["mine", "dungeon", "hills"] },
		// ---- the marsh ----
		{ name : "toad",      shape : { hp : 8, mp : 4, atk : 5, mag : 3, def : 5, mdef : 4, spd : 4, hit : 5 }, crit : 5,  cmulti : 1.6, cnt : 6,  erode : 1,   magic : false, skill : "concuss", gear : 0,  col : rgb(110, 130, 60),  lands : ["marsh"] },
		{ name : "leech",     shape : { hp : 7, mp : 2, atk : 6, mag : 1, def : 4, mdef : 3, spd : 6, hit : 7 }, crit : 6,  cmulti : 1.5, cnt : 5,  erode : 1,   magic : true,  skill : "drain",   gear : 0,  col : rgb(120, 40, 50),   lands : ["marsh", "coast"] },
		{ name : "bogling",   shape : { hp : 7, mp : 4, atk : 6, mag : 3, def : 6, mdef : 5, spd : 3, hit : 4 }, crit : 5,  cmulti : 1.6, cnt : 6,  erode : .5,  magic : false, skill : "reform",  gear : .1, col : rgb(80, 90, 60),    lands : ["marsh"] },
		{ name : "mudcrab",   shape : { hp : 7, mp : 2, atk : 5, mag : 1, def : 8, mdef : 4, spd : 3, hit : 6 }, crit : 6,  cmulti : 1.6, cnt : 12, erode : 1,   magic : false, skill : "",        gear : 0,  col : rgb(110, 120, 130), lands : ["marsh", "coast"] },
		// ---- the desert ----
		{ name : "scorpion",  shape : { hp : 5, mp : 2, atk : 7, mag : 1, def : 6, mdef : 3, spd : 6, hit : 7 }, crit : 12, cmulti : 1.8, cnt : 8,  erode : 1,   magic : false, skill : "concuss", gear : 0,  col : rgb(180, 140, 80),  lands : ["desert"] },
		{ name : "jackal",    shape : { hp : 5, mp : 2, atk : 6, mag : 1, def : 3, mdef : 2, spd : 9, hit : 8 }, crit : 9,  cmulti : 1.6, cnt : 5,  erode : 1,   magic : false, skill : "",        gear : 0,  col : rgb(190, 160, 110), lands : ["desert", "hills"] },
		{ name : "sandworm",  shape : { hp : 9, mp : 3, atk : 7, mag : 2, def : 6, mdef : 3, spd : 3, hit : 4 }, crit : 6,  cmulti : 1.9, cnt : 4,  erode : 1,   magic : false, skill : "strike",  gear : 0,  col : rgb(215, 195, 150), lands : ["desert"] },
		{ name : "vulture",   shape : { hp : 4, mp : 2, atk : 5, mag : 1, def : 3, mdef : 3, spd : 9, hit : 9 }, crit : 8,  cmulti : 1.6, cnt : 4,  erode : 1,   magic : false, skill : "",        gear : 0,  col : rgb(80, 70, 70),    lands : ["desert", "mountains"] },
		{ name : "mummy",     shape : { hp : 7, mp : 4, atk : 6, mag : 3, def : 6, mdef : 6, spd : 2, hit : 4 }, crit : 5,  cmulti : 1.7, cnt : 5,  erode : .5,  magic : false, skill : "drain",   gear : .3, col : rgb(200, 185, 150), lands : ["crypt", "ruin"] },
		// ---- the high and the cold ----
		{ name : "harpy",     shape : { hp : 5, mp : 4, atk : 5, mag : 3, def : 3, mdef : 4, spd : 8, hit : 6 }, crit : 8,  cmulti : 1.6, cnt : 6,  erode : 1,   magic : false, skill : "concuss", gear : 0,  col : rgb(160, 130, 170), lands : ["mountains", "coast"] },
		{ name : "goat",      shape : { hp : 6, mp : 2, atk : 6, mag : 1, def : 5, mdef : 3, spd : 7, hit : 6 }, crit : 6,  cmulti : 1.6, cnt : 6,  erode : 1,   magic : false, skill : "concuss", gear : 0,  col : rgb(200, 195, 185), lands : ["mountains", "hills"] },
		{ name : "yeti",      shape : { hp : 9, mp : 3, atk : 8, mag : 1, def : 6, mdef : 3, spd : 3, hit : 4 }, crit : 7,  cmulti : 1.9, cnt : 5,  erode : 1,   magic : false, skill : "strike",  gear : 0,  col : rgb(225, 230, 240), lands : ["mountains", "tundra"] },
		{ name : "snow wolf", shape : { hp : 6, mp : 2, atk : 7, mag : 1, def : 4, mdef : 3, spd : 8, hit : 6 }, crit : 10, cmulti : 1.7, cnt : 5,  erode : 1,   magic : false, skill : "",        gear : 0,  col : rgb(210, 220, 235), lands : ["tundra"] },
		{ name : "wraith",    shape : { hp : 3, mp : 6, atk : 2, mag : 8, def : 2, mdef : 7, spd : 5, hit : 5 }, crit : 6,  cmulti : 1.9, cnt : 2,  erode : 1,   magic : true,  skill : "drain",   gear : 0,  col : rgb(120, 140, 200), lands : ["tundra", "crypt"] },
		{ name : "troll",     shape : { hp : 10, mp : 2, atk : 8, mag : 1, def : 7, mdef : 2, spd : 2, hit : 4 }, crit : 5, cmulti : 2,   cnt : 4,  erode : .5,  magic : false, skill : "reform",  gear : .3, col : rgb(100, 110, 90),  lands : ["hills", "mountains", "marsh"] },
		// ---- the coast ----
		{ name : "crab",      shape : { hp : 6, mp : 2, atk : 5, mag : 1, def : 8, mdef : 3, spd : 4, hit : 6 }, crit : 6,  cmulti : 1.6, cnt : 12, erode : 1,   magic : false, skill : "",        gear : 0,  col : rgb(200, 100, 80),  lands : ["coast", "isle"] },
		{ name : "gull",      shape : { hp : 4, mp : 2, atk : 5, mag : 1, def : 2, mdef : 3, spd : 10, hit : 9 }, crit : 7, cmulti : 1.5, cnt : 3,  erode : 1,   magic : false, skill : "",        gear : 0,  col : rgb(235, 235, 240), lands : ["coast", "isle"] },
		{ name : "merrow",    shape : { hp : 4, mp : 6, atk : 4, mag : 6, def : 3, mdef : 5, spd : 5, hit : 5 }, crit : 6,  cmulti : 1.7, cnt : 3,  erode : 1,   magic : true,  skill : "bolt",    gear : .2, col : rgb(80, 150, 160),  lands : ["coast", "isle"] },
		// ---- the deep ----
		{ name : "imp",       shape : { hp : 4, mp : 5, atk : 3, mag : 7, def : 3, mdef : 5, spd : 6, hit : 5 }, crit : 7,  cmulti : 1.7, cnt : 4,  erode : 1,   magic : true,  skill : "bolt",    gear : .1, col : rgb(190, 80, 90),   lands : ["dungeon", "ruin"] },
		{ name : "bat",       shape : { hp : 4, mp : 2, atk : 5, mag : 2, def : 3, mdef : 3, spd : 9, hit : 8 }, crit : 8,  cmulti : 1.5, cnt : 3,  erode : 1,   magic : false, skill : "",        gear : 0,  col : rgb(90, 80, 110),   lands : ["crypt", "dungeon", "mine"] },
		{ name : "ghoul",     shape : { hp : 7, mp : 3, atk : 7, mag : 2, def : 6, mdef : 4, spd : 4, hit : 5 }, crit : 7,  cmulti : 1.7, cnt : 5,  erode : 1,   magic : false, skill : "drain",   gear : .2, col : rgb(140, 150, 130), lands : ["crypt", "ruin"] },
	];
	return _ros;
}
