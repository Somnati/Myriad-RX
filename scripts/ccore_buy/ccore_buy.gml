/// @description ccore_buy() -> true if a level was bought
/// Pays ccore_cost() in credits for one level. The first level unlocks
/// the core (it starts producing on the next tick).
function ccore_buy() {
	ccore_init();
	var _cost = ccore_cost();
	if (!(g.credits >= arb(_cost))) return false;
	g.credits = do_subtract(g.credits, arb(_cost));
	if (!(g.credits >= arb(1))) g.credits = 0;
	g.ccore.lv += 1;
	if (g.ccore.st == 0) { g.ccore.st = 1; g.ccore.xp = 0; }
	save_mark_dirty();
	return true;
}
