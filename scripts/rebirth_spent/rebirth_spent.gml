/// @description rebirth_spent(before, after) - the pile went from
/// before to after on a spend: the fed profit follows IN PROPORTION
/// (spend half the pile, half the fed goes), which keeps fed = pile x
/// the run's growth so far. The common case - the two were equal - is
/// copied exactly rather than scaled, so a run at 100% never drifts by
/// log-space dust. Under the networth ability nothing here happens:
/// what was earned stays counted.
function rebirth_spent(_before, _after) {
	rebirth_init();
	if (variable_global_exists("ad_networth") && g.ad_networth == 1) return;
	if (!(g.rebirth.fed >= arb(1))) return;
	if (!(_after >= arb(1))) { g.rebirth.fed = 0; return; }
	if (g.rebirth.fed == _before) { g.rebirth.fed = _after; return; }
	var _ratio = power(10, arb_log10(_after) - arb_log10(_before));
	g.rebirth.fed = do_scale(g.rebirth.fed, _ratio);
}
