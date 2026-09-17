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

	// DE's one-in-five that ignores the per-dial average (see
	// upgrade_dial_hot) - rolled ONCE here so every dial's gate agrees
	g.upg_dial_ignore = roll_perc(20);
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
	// (free while UPG_ROLL_COST is 0 - the whole block sits out)
	var _price = upgrade_roll_cost();
	if (_price > 0) {
		if (!(g.credits >= arb(_price))) return -2;
		g.credits = do_subtract(g.credits, arb(_price));
	}

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
	// ...EXCEPT A BURST (2026-09-16), which has a value to scale: rarity
	// widens its multiplier and its clock
	if (_pick.stat == "" && !(_pick[$ "burst"] ?? false)) _rar = 0;
	var _mult = upgrade_rarity_mult(_rar);

	// HOW DEEP THIS ONE GOES, rolled once and kept: DE's per-rarity
	// table, then clamped by the roster's own ceiling so a grant stays
	// one tier however lucky the roll was. This is what the dots under
	// the row are counting.
	// (upgrade tier+, DE's: up to two tiers more, and the roster's ceiling
	// gives the same two - upgrade_cap raises its clamp by two while it is on)
	var _xt = abi_on("ad_upgradetier") ? irandom(2) : 0;
	var _cap = min(upgrade_roll_tiers(_rar) + _xt, _pick.cap + (abi_on("ad_upgradetier") ? 2 : 0));
	// a grant is one tier however lucky the roll (the tier+ ability's
	// two extra would draw three dots under a one-off)
	if (_pick.stat == "") _cap = 1;

	var _val = 0, _dur = 0;
	if (_pick[$ "burst"] ?? false) {
		// A BURST ROLLS A MULTIPLIER AND A CLOCK (his ask, 2026-09-16:
		// "make the x2 variable and the time be random so sometimes i
		// might get x1.58 for 2:30min"). Rarity widens both by its SQUARE
		// ROOT, so the burst's worth (multiplier x time) climbs with the
		// full rarity multiplier - the law the price follows - without
		// either number alone running silly. Clocks land on 5 s.
		var _rs = sqrt(_mult);
		_val = 1 + random_range(_pick.band[0], _pick.band[1]) * _rs;
		_dur = round(random_range(_pick.dur[0], _pick.dur[1]) * _rs / 5) * 5;
	} else _val = random_range(_pick.band[0], _pick.band[1]);   // the rung enters through the tier law (upgrade_tier_add) - DE's shape
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
		dur  : _dur,         // a burst's clock in seconds (0 for the rest)
		lv   : g.upg.level,  // rolled at this upgrade level, and keeps it (DE's u_lv)
		xtra : 0,            // DE's +1%: what each tier bought added off the type's total then
	};
	g.upg.rolls += 1;
	g.upg.seen[_rar] += 1;   // the histogram - see upgrade_init
	save_mark_dirty();
	return g.upg.slot[_slot];
}
