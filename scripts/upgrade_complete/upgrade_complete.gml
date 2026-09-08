/// @description upgrade_complete(slot);
/// @param slot
/// The slot's last tier has just been bought. DE clears the slot at
/// this moment (obj_upgrade_slot's Step_1: `if u_tier = u_tier_
/// create_new_upgrade(u)`) and RX does too - a finished upgrade should
/// not go on occupying the scarcest thing on the screen.
///
/// WHERE THE BONUS GOES, and why this script exists at all. DE can free
/// the slot without losing anything because buy_upgrade already did
/// `g.u_tapprofit += val` at every purchase: the effect lives in a
/// global and the slot was only ever a receipt. RX derives its bonuses
/// from the slots, so clearing one would delete the upgrade you just
/// finished paying for - the exact bug DE's accumulators avoid, and the
/// exact reason they cost DE everything else (see upgrade_init).
///
/// So the finished upgrade moves to a LEDGER instead. g.upg.done keeps
/// what it IS - id, rarity, rolled value, final tier - and
/// upgrade_bonus walks it alongside the slots. Nothing is accumulated,
/// so a rebalance still reaches saves that already exist and selling is
/// still a plain deletion; the slot frees up exactly as DE's does.
function upgrade_complete(_slot) {
	upgrade_init();
	var _s = g.upg.slot[_slot];
	if (!is_struct(_s)) return;

	// fold it into this id's running total (see upgrade_init for why
	// this is a total rather than a list)
	var _d = g.upg.done[$ _s.id];
	if (!is_struct(_d)) {
		_d = { stat : _s.stat, sum : 0, n : 0 };
		g.upg.done[$ _s.id] = _d;
	}
	// the FULL curve, completion bonus and all - the slot is being
	// filed at its last tier, which is the tier worth the most
	_d.sum += upgrade_tier_value(_s.val, _s.tier, upgrade_cap(_slot));
	_d.n   += 1;

	g.upg.slot[_slot] = -1;

	assign_banner("upgrade complete - slot freed", c_gold, c_black);
	play_sound_ext(snd_diamond, .9, 1.1, .5, 2);
}
