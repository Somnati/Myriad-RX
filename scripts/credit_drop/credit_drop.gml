/// @description credit_drop(x, y, [amount], [motes]) - THE ONE SITE credits are
/// earned (Myriad DE's drop_credits). amount = -1 (default) PULLS from
/// the dropper's pool: refused while the cooldown runs or the pool is
/// at its floor; otherwise a random 1..pool, capped by credit_maxpull,
/// leaves the pool and arms a fresh cooldown (credit_cool_min..max
/// seconds, halved one time in ten - DE's roll). Any other amount is
/// an explicit grant (a sale refund, a gift) and touches no pool.
/// Returns how many credits landed (0 = nothing).
/// THE CEREMONY (DE's): the diamond sound, and lavender motes from the
/// drop point to the credit panel's icon - which slides in from the
/// left edge to receive them (obj_display_credits). Credits land the
/// same frame; the motes are cosmetic, as in DE (drop_credits pays
/// before emit_bezier_profit).
function credit_drop(_x, _y, _amount = -1, _motes = 8) {
	credits_init();
	var _n = _amount;

	if (_n == -1) {
		if (g.credit_cool > 0) return 0;
		if (!(g.credit_pool > 1)) return 0;
		_n = clamp(round(random_range(1, g.credit_pool)), 1, g.credit_maxpull);
		g.credit_pool -= _n;
		g.credit_cool = random_range(g.credit_cool_min, g.credit_cool_max);
		if (roll_perc(10 * luck_mod())) g.credit_cool *= .5;   // the lucky short cooldown leans with luck
	}
	if (_n < 1) return 0;
	_n = floor(_n);

	var _a = arb(_n);
	g.credits       = (g.credits       >= arb(1)) ? do_add(g.credits,       _a) : _a;
	g.total_credits = (g.total_credits >= arb(1)) ? do_add(g.total_credits, _a) : _a;
	save_mark_dirty();

	// the ceremony
	// the player's choice now (settings > audio). snd_diamond was hard
	// coded here the same way snd_orb was hard coded on the crit, so it
	// is row 0 of the credit roster and nothing changes by default.
	sfx_play("credit");
	var _tx = 8, _ty = 50;
	if (instance_exists(obj_display_credits)) {
		obj_display_credits.__pop(_n);
		_tx = obj_display_credits.seat_x;
		_ty = obj_display_credits.seat_y;
	}
	// motes 0 = pay in silence. The tap uses that outside the money
	// room, where a burst of lavender pixels across a settings page is
	// noise rather than feedback. The panel still pops and glows, so
	// the drop is still announced - just where the balance lives.
	if (_motes > 0)
		bezier_bits(_x, _y, clamp(_n, 1, _motes), c_lavender, _tx, _ty, 1, 0,
			-1, 1, "credit");

	show("[credits +" + string(_n) + "]");
	return _n;
}
