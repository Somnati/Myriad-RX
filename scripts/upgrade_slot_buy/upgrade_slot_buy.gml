/// @description upgrade_slot_buy() - buy the next upgrade slot (the
/// "new slot" row). Returns true if it landed.
/// A purchase, never a sale: a slot bought is a slot, there is nothing
/// left to sell (his rule, 2026-09-17).
function upgrade_slot_buy() {
	upgrade_init();
	var _cost = upgrade_slot_cost();
	if (_cost < 0) return false;
	if (!(g.credits >= arb(_cost))) return false;
	g.credits = do_subtract(g.credits, arb(_cost));
	g.upg.bought = min(g.upg.bought + 1, UPG_SLOT_MAX - UPG_SLOT_BASE);
	g.upg.total += 1;
	assign_banner("upgrade slot gained", c_white, c_black);
	play_sound_ext(snd_diamond, 1, 1.05, 0.424, 2);
	save_mark_dirty();
	return true;
}
