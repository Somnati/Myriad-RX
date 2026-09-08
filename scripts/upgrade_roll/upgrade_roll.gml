/// @description upgrade_roll(slot);
/// @param slot
/// Rolls a fresh offer into an empty slot: pay the stake, pick a kind
/// that is currently available, pick a rarity, roll a value inside that
/// kind's band scaled by the rarity, and roll how DEEP it goes.
/// Returns the offer, -1 if nothing can be offered yet, or -2 if the
/// stake cannot be paid.
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

	// THE STAKE, taken before anything is rolled. See upgrade_roll_cost:
	// without it, free rolling makes rarity pointless and a sellable
	// offer makes credits infinite.
	var _price = upgrade_roll_cost();
	if (!(g.credits >= arb(_price))) return -2;
	g.credits = do_subtract(g.credits, arb(_price));

	// THE RARITY, drawn by walking upgrade_rarity_odds() - the same
	// array the statistics screen draws as a bar. It used to be an
	// inline floor(random(1)^3 * N) here and a picture of that curve
	// somewhere else, which is two descriptions of one law and an
	// invitation for them to drift; now the chart and the generator are
	// the same numbers read twice.
	var _odds = upgrade_rarity_odds();
	var _u    = random(1);
	var _acc  = 0;
	var _rar  = UPG_RARITY_N - 1;   // the top rung catches rounding
	for (var _q = 0; _q < UPG_RARITY_N; _q++) {
		_acc += _odds[_q];
		if (_u < _acc) { _rar = _q; break; }
	}
	// A GRANT ROLLS AT COMMON, always. Rarity scales an upgrade's VALUE
	// and its price together; a grant has no value to scale - "one more
	// slot" is one more slot at every rung - so a rare one would be the
	// identical thing at sixteen times the price. Nothing about that is
	// a reward.
	if (_pick.stat == "") _rar = 0;
	var _mult = upgrade_rarity_mult(_rar);

	// HOW DEEP THIS ONE GOES, rolled once and kept: DE's per-rarity
	// table, then clamped by the roster's own ceiling so a grant stays
	// one tier however lucky the roll was. This is what the dots under
	// the row are counting.
	var _cap = min(upgrade_roll_tiers(_rar), _pick.cap);

	var _val = random_range(_pick.band[0], _pick.band[1]) * _mult;
	// two decimals: the exact number is noise, and a readout that
	// changes in the third decimal reads as instability rather than detail
	_val = round(_val * 100) / 100;

	g.upg.slot[_slot] = {
		id   : _pick.id,
		stat : _pick.stat,
		rar  : _rar,
		val  : _val,
		cap  : _cap,         // how many tiers it can ever take
		tier : 0,            // an offer, not yet owned
	};
	g.upg.rolls += 1;
	g.upg.seen[_rar] += 1;   // the histogram - see upgrade_init
	save_mark_dirty();
	return g.upg.slot[_slot];
}
