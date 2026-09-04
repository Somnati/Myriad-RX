/// @description credit_tick([seconds]) - THE DROPPER's clock (Myriad
/// DE's syst_creditdropper Step, rebuilt on a SECONDS BUDGET like
/// prod_dials so the offline replay drives the same code). Called
/// bare by syst_production every step (this frame's delta) and by
/// offline_replay with the whole absence.
/// DE'S LAWS: the pool refills at credit_refill per HOUR up to
/// credit_cap and never sits below 1 once live; the cooldown after a
/// drop counts down in real time; and nothing accrues until the game
/// has actually started - DE zeroed the pool until dial a's autonomy
/// upgrade existed; RX's equivalent gate is owning dial a at all.
function credit_tick(_secs = -1) {
	credits_init();
	if (_secs < 0) _secs = delta / 60;
	if (_secs <= 0) return;

	// the gate: no dial, no pool (DE: u_autonamy[0] = false -> cd_val 0)
	if (!variable_global_exists("dial") || g.dial[0].level <= 0) {
		g.credit_pool = 0;
		return;
	}

	g.credit_pool = clamp(g.credit_pool + (g.credit_refill / 3600) * _secs, 1, g.credit_cap);
	g.credit_cool = max(0, g.credit_cool - _secs);
}
