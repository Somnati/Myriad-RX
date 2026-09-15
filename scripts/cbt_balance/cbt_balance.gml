/// @description cbt_balance() -> g.cbal, the tech demo's combat constants
/// (combat_balance, ported 2026-09-14 for the expedition fights - his
/// call: "make the turn based combat and stats of the sprites match the
/// tech demo's combat engine"). One struct, set once. The two deliberate
/// changes the demo made from DnD GPT stay: turn rate on sqrt(spd), and
/// dodge as its own evasion (spd x .5) so spd does not double-serve.
function cbt_balance() {
	if (variable_global_exists("cbal")) return g.cbal;
	g.cbal = {
		// hit curve (hit_chance = a r^2 + b r, r = hit / (hit + eva))
		hitcurve_a : -160,
		hitcurve_b : 250,
		// stat derivation
		hp_per_point : 3.75,
		hp_flat_add  : 4,
		spd_to_eva   : .5,    // evasion = spd x this (the dodge split)
		tic_spd_base : 1,     // tic_spd = base + sqrt(spd) / tic_spd_div
		tic_spd_div  : 2,
		// damage shaping (the hit-quality spectrum)
		def_div      : 3,
		def_lerp_low : .8,    // clean hits pierce def harder
		dmg_lerp_low : .4,    // nick damage floor
		dmg_lerp_high: 1.1,   // clean ceiling
		perf_lerp_high : 1.2, // perfect ceiling
		crit_lerp_low  : .4,
		crit_lerp_high : 1,
		ttk_multi    : 1.4,   // global time-to-kill dial
		dmg_to_maxhp : .1,    // attrition: damage erodes max hp (x pawn erode)
		// mp economy: builder / spender. basic attacks GENERATE mp, quality
		// hits generate more, skills spend - basics stay meaningful forever
		mp_gain       : 1,
		mp_gain_qual  : 2,
		mp_start_frac : .5,   // a fight opens at this fraction of max mp
		// counters: chance = cnt stat, halving per chain link
		cnt_mult    : .7,
		cnt_falloff : .5,
		cnt_chain   : 3,
	};
	return g.cbal;
}
