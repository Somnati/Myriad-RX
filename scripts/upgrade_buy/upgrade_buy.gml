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
	// DE'S +1% (his ask, 2026-09-17: "DE gave each upgrade a +1% to its
	// bonus based off its total bonus from all upgrades of that type"):
	// update_upgrade's `u_val += u_profit[dial] / 100` - the tier bought
	// now is worth one percent of what the type already pays, on top.
	// That is history (the total at the moment of purchase), so it is
	// banked on the slot, not derived
	if (_s.stat != "") {
		var _e0 = upgrade_entry(_s.id);
		var _ub0 = upgrade_bonus();
		var _tot0 = (_s.stat == "dial_one" && _e0 != -1) ? _ub0.dial_one[_e0.dial] : (_ub0[$ _s.stat] ?? 0);
		_s.xtra = (_s[$ "xtra"] ?? 0) + _tot0 / 100;
	}
	_s.tier += 1;
	g.upg.total += 1;
	// THE UPGRADE LEVEL's xp (DE's buy_upgrade: (1 + rarity) x the tier)
	if (_s.stat != "") upgrade_xp_add((1 + _s.rar) * _s.tier);
	// the offer meter takes a share of every purchase (DE's buy_upgrade:
	// get_sub_sec_inf(cost, 1/4, .01))
	upgrade_meter_feed(_cost * .25 * (1 + .01 * (_cost - 1)));

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
