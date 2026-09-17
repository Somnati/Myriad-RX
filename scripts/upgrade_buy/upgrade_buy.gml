/// @description upgrade_buy(slot);
/// @param slot
/// Level the offer in this slot by one tier, paying credits. Returns
/// true if it landed.
///
/// ⚖️ IT ADDS NOTHING TO ANY ACCUMULATOR - it raises a tier and stops.
/// Every effective number is derived from the slots afterwards
/// (upgrade_bonus), which is what makes selling a plain deletion and a
/// rebalance reach old saves. Myriad DE's version does the arithmetic
/// here instead, and pays for it everywhere else.
function upgrade_buy(_slot) {
	upgrade_init();
	if (_slot < 0 || _slot >= upgrade_slots()) return false;
	var _s = g.upg.slot[_slot];
	if (!is_struct(_s)) return false;

	var _cost = upgrade_cost(_slot);
	if (_cost < 0) return false;                       // at its ceiling
	if (!(g.credits >= arb(_cost))) return false;      // cannot afford it

	g.credits = do_subtract(g.credits, arb(_cost));
	_s.tier += 1;
	g.upg.total += 1;

	// ---- GRANTS ----
	// A grant is not a modifier: it changes state once and consumes
	// itself, freeing the slot it was sitting in. Keeping these apart
	// from the derived stats is what lets everything else be derived.
	if (_s.stat == "") {
		var _e = upgrade_entry(_s.id);
		g.upg.slot[_slot] = -1;
		if (_e != -1 && (_e[$ "burst"] ?? false)) {
			// A BURST (2026-09-16): the slot frees and the clock starts NOW,
			// on the wall clock - see upgrade_burst_start for the stacking
			var _dur = max(5, _s[$ "dur"] ?? 120);
			var _ss  = _dur mod 60;
			upgrade_burst_start(_e.kind, _s.val, _dur);
			assign_banner(_e.name + "  x" + string_format(_s.val, 1, 2) + " for "
				+ string(floor(_dur / 60)) + ":" + ((_ss < 10) ? "0" : "") + string(_ss), _e.col, c_black);
			play_sound_ext(snd_diamond, 1.1, 1.2, 0.4, 2);
		} else {
			if (_s.id == "new_slot") g.upg.bought += 1;
			assign_banner("upgrade slot gained", c_white, c_black);
			play_sound_ext(snd_diamond, 1, 1.05, 0.424, 2);
		}
	} else if (_s.tier >= upgrade_cap(_slot)) {
		// THE LAST TIER FREES THE SLOT (DE's behaviour). The upgrade
		// moves to the completed ledger, where it keeps paying out -
		// see upgrade_complete for why that indirection is needed here
		// and is not needed in DE.
		upgrade_complete(_slot);
	} else {
		play_sound_ext(snd_pop, .95, 1.15, .5, 1);
	}

	// the tap and the dials both read the bonus at derive time, so one
	// resync is all it takes for a purchase to be live everywhere
	update_dials();
	save_mark_dirty();
	return true;
}
