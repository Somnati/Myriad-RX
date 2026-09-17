/// @description exped_tally(trip, key, [n]) - THE TRIP'S TALLY (his ask, 2026-09-16: the completion screen's "mistakes made / enemies slain / items / credits earned / xp"): trip.tl, one counter a key, added to where it happens
///   slain   a foe falls (exped_tick_one)          mist    a dumb moment (sprite_take), a wrong road, a lost hour, a slip (exped_agent)
///   items   gear or a find taken (the loot sites, the shop)     xp    exped_xp_grant     earned   credits made on the trip (bounties, chests, the pay, the reward)
/// The haul copies it home with the pocket returned; the save keeps it (exped_pack, field 9).
function exped_tally(_tr, _key, _n = 1, _who = undefined) {
	if (!is_struct(_tr)) return;
	if (!is_struct(_tr[$ "tl"])) _tr.tl = { slain : 0, mist : 0, items : 0, xp : 0, earned : 0 };
	_tr.tl[$ _key] = (_tr.tl[$ _key] ?? 0) + _n;
	// A MISTAKE is the expedition ledger's too (his ask, 2026-09-17), and
	// the sprite's own: the one named (a dumb moment is one sprite's), else
	// everyone on the trip (a wrong road is the party's)
	if (_key == "mist") {
		exped_stat("mistakes", _n);
		if (is_struct(_who)) sprite_led(_who, "mist", _n);
		else if (is_array(_tr[$ "sids"])) for (var _k = 0; _k < array_length(_tr.sids); _k++) sprite_led(exped_sprite(_tr.sids[_k]), "mist", _n);
	}
}
