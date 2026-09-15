/// @description exped_biomes() -> the biome roster: what a world is known for
/// Four kinds. Each has the colours its portrait wears, the kinds of
/// room its delve rolls (weights), and the loot table (weights over
/// the six kinds: mats / sprite / offer / credits / charm / chart) -
/// so WHERE you send the crew is a real choice: stone for materials,
/// living worlds for sprites, ruins for offers and charms, ice for
/// charts. Names are the hint the board shows.
function exped_biomes() {
	static _b = [
		{ name : "stone",  hint : "materials likely",
		  col1 : rgb(70, 62, 58),   col2 : rgb(150, 128, 104), col3 : rgb(210, 200, 190), sea : .35,
		  rooms : { find : 40, rest : 15, trap : 25, fight : 20 },
		  loot  : { mats : 45, sprite : 5, offer : 8, credits : 17, charm : 5, chart : 8, gear : 12 } },
		{ name : "living", hint : "sprites likely",
		  col1 : rgb(32, 70, 120),  col2 : rgb(70, 150, 80),   col3 : rgb(230, 240, 245), sea : .5,
		  rooms : { find : 35, rest : 25, trap : 10, fight : 30 },
		  loot  : { mats : 22, sprite : 32, offer : 8, credits : 18, charm : 5, chart : 5, gear : 10 } },
		{ name : "ruined", hint : "offers and charms",
		  col1 : rgb(60, 40, 70),   col2 : rgb(140, 100, 150), col3 : rgb(90, 70, 100), sea : .3,
		  rooms : { find : 30, rest : 10, trap : 30, fight : 30 },
		  loot  : { mats : 8, sprite : 5, offer : 32, credits : 12, charm : 18, chart : 8, gear : 17 } },
		{ name : "ice",    hint : "charts likely",
		  col1 : rgb(120, 160, 200), col2 : rgb(220, 235, 250), col3 : rgb(250, 250, 255), sea : .55,
		  rooms : { find : 40, rest : 20, trap : 30, fight : 10 },
		  loot  : { mats : 32, sprite : 5, offer : 5, credits : 18, charm : 9, chart : 23, gear : 8 } },
	];
	return _b;
}
