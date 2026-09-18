/// @description unfold_all() - EVERY mechanic unlocked at once (his ask, 2026-09-18: "a cheat toggle that lets me unlock all mechanics so I can access expeditions"): unfold_reveal_all (every time-gated row, the whole objective chain granted and done, the tap's veil) and then the keys other events hand out - the sprites, the expeditions, the tickets, the cheat shop, the toys - quietly; one save mark
function unfold_all() {
	static _keys = ["upgrades", "tiles", "abilities", "automation", "timebank", "battery", "ccore", "sprites", "expeditions", "gift", "statistics", "offlog", "rebirth", "cheat",
	                "tickets", "dials", "coin", "dice", "puck", "scale", "sprite", "dimensions"];
	unfold_reveal_all();
	for (var _i = 0; _i < array_length(_keys); _i++) unfold_grant(_keys[_i], "", true);
	save_mark_dirty();
}
