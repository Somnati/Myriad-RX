/// @description upgrade_roll(slot);
/// @param slot
/// Rolls a fresh offer into an empty slot: pick a kind that is
/// currently available, pick a rarity, roll a value inside that kind's
/// band scaled by the rarity. Returns the offer, or -1 if nothing can
/// be offered yet.
///
/// ⚖️ AVAILABILITY IS A GATE, NOT A FILTER ON THE RESULT. Each roster
/// entry carries its own `avail` closure and a kind that fails it is
/// never in the draw at all - so an upgrade for a system that does not
/// exist yet cannot appear, and the roster can be written now for
/// systems that land later. That is also where the feature-unlock
/// spine will hook when it arrives: one more condition per entry, in
/// the file that already describes the entry.
///
/// THE RARITY ROLL is weighted toward the common end and widens the
/// value band as it climbs, so a legendary roll of a modest stat is a
/// real dilemma rather than a strictly better version of the same
/// thing - which is what makes a scarce slot a decision.
function upgrade_roll(_slot) {
	upgrade_init();

	// the candidates that can be offered at all right now
	var _cfg = upgrade_config();
	var _ok  = [];
	for (var _i = 0; _i < array_length(_cfg); _i++) {
		var _c = _cfg[_i];
		if (!_c.avail()) continue;
		// a GRANT that is already in another slot would be a dead
		// duplicate - one "another slot" offer at a time is plenty
		if (_c.stat == "" && upgrade_holds(_c.id, _slot)) continue;
		array_push(_ok, _c);
	}
	if (array_length(_ok) == 0) return -1;

	var _pick = _ok[irandom(array_length(_ok) - 1)];

	// rarity 0..6, weighted toward common. The cube pushes the mass
	// down without ever making the top rung unreachable.
	var _rar = floor(power(random(1), 3) * (UPG_RARITY_N - 0.0001));
	var _mult = upgrade_rarity_mult(_rar);

	var _val = random_range(_pick.band[0], _pick.band[1]) * _mult;
	// two decimals: the exact number is noise, and a readout that
	// changes in the third decimal reads as instability rather than detail
	_val = round(_val * 100) / 100;

	g.upg.slot[_slot] = {
		id   : _pick.id,
		stat : _pick.stat,
		rar  : _rar,
		val  : _val,
		tier : 0,            // an offer, not yet owned
	};
	g.upg.rolls += 1;
	save_mark_dirty();
	return g.upg.slot[_slot];
}
