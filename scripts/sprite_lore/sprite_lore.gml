/// @description sprite_lore(s) - one line about THIS sprite (his ask,
/// 2026-09-11: "a little line of lore... something they like, what
/// they are thinking... funny or off the wall"). Procedural and
/// STABLE: picked by a hash of the sprite's id, never the RNG (the
/// house rule - get/set-seed rewinds the ambient stream), so a sprite
/// says the same thing every time you ask. Six shapes, a list each;
/// add lines to the lists and every future sprite may say them.
/// @param s
function sprite_lore(_s) {
	static shapes = [
		{ pre : "likes ",     l : ["shiny tiles", "the puck's ring", "long naps", "the number 4",
		                           "being poked", "the glow", "warm dials", "tier-up sparks",
		                           "the sound of merging", "you, mostly", "the hum of the fabricator",
		                           "small change", "the dark corners of the room"] },
		{ pre : "thinks ",    l : ["the puck is a pancake", "the dice are watching", "profit is a colour",
		                           "the header is the sky", "taps are free", "the fabricator is its mum",
		                           "it invented merging", "the crank is a snack", "you are the sprite",
		                           "rebirth is a rumour", "the grid is a ladder"] },
		{ pre : "afraid of ", l : ["the number 7", "the auto sell", "the quiet after a rebirth",
		                           "the edge of the room", "big dice", "running out of ram",
		                           "the battery going flat", "being sorted", "the sort button",
		                           "its own reflection in the puck"] },
		{ pre : "dreams of ", l : ["being a dial one day", "a tier-99 tile", "a nap on the puck",
		                           "the top of the visualiser", "a 1e308 tap", "its own drawer",
		                           "a second eye", "getting cranked", "a preset named after it",
		                           "the hopper, full"] },
		{ pre : "collects ",  l : ["tier-3 tiles it never merges", "spare sparks", "credits it can't spend",
		                           "seconds off the time bank", "lint from the tile table",
		                           "other sprites' names", "taps that missed", "unused ram sticks"] },
		{ pre : "once ",      l : ["tapped 1e6 by accident", "merged a tile in its sleep", "fell in the hopper",
		                           "beat the puck at a race", "saw the debug menu", "slept through a rebirth",
		                           "was a die for a day", "got stuck in the drawer", "ate a credit"] },
	];
	var _h  = (_s.id * 2654435761) mod 1000003;
	var _sh = shapes[_h mod array_length(shapes)];
	var _h2 = ((_s.id + 7) * 40503) mod 1000003;
	return _sh.pre + _sh.l[_h2 mod array_length(_sh.l)];
}
