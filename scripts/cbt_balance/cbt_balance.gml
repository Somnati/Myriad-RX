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
		// ELEMENTS AND AILMENTS (his design, 2026-09-17 - see cbt_elem_info,
		// cbt_res_gen, cbt_status): the triangle water > fire > nature > water
		// only GENERATES a pawn's table; the signed resistance is the one
		// multiplier (damage x (1 - res / 100)). Light and dark are schools -
		// flat damage, buffs against nerfs - never a row here.
		res_step     : 20,    // a generated pawn: +this in one element, -this in another
		res_min      : -50,   // the table's floor and ceiling (signed %)
		res_max      : 50,
		res_quirk    : 10,    // a gear quirk's points; a ward note's too
		fire_bonus   : 1.1,   // fire carries no ailment: it hits harder instead
		ail_skill    : 60,    // % a skill's ailment lands on a landed hit
		ail_basic    : 20,    // % a kind's own ailment lands on its basic bite
		ail_turns    : 3,     // poison / slow / leech: this many of the victim's actions
		boss_ail     : .5,    // a boss takes ailments at this fraction of the turns
		poison_pct   : .04,   // of max hp, each of the victim's actions
		slow_rate    : .6,    // a slowed pawn's atb fills at this rate
		haste_rate   : 1.25,  // a hasted one's
		leech_pct    : .4,    // a marked target: the marker heals this share of every hit on it
		buff_pct     : .25,   // atk / def / hit up (light) or down (dark)
		buff_turns   : 3,
		regen_pct    : .05,   // of max hp an action, light's regen
		barrier_pct  : .40,   // THE BARRIER / THE WARD (q312, the ff7 pair): blows through a barrier, spells through a ward, land this much lower; a breached guard / an unwarded mind takes as much more
		// counters: chance = cnt stat, halving per chain link
		cnt_mult    : .7,
		cnt_falloff : .5,
		cnt_chain   : 3,
	};
	return g.cbal;
}
