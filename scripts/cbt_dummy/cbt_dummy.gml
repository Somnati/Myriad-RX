/// @description cbt_dummy(lv, hpmul, armour, mode) -> a TRAINING DUMMY pawn (q246, the arena): a foe-shaped pawn with no skills - hp the level's budget x hpmul (1..5), def / mdef by armour (0 none .. 3 plate), mode "still" (it stands there: cbt_ai passes) or "hits" (it swings, plainly)
/// The shape is foe_gen's: every field the engine reads (cbt_hit / cbt_status / cbt_heal / the arena's rows) with the
/// neutral values - an empty ability set (ability_effects([])), no element, no resistances, no tags
function cbt_dummy(_lv, _hpmul = 1, _armour = 1, _mode = "still") {
	var _b = cbt_balance();
	var _pts = sprite_par_pts(max(1, _lv)) * SPRITE_FOE_BUDGET;
	var _hp = max(10, round(_pts * 2.2 * _hpmul));
	var _def = round(_pts * .12 * (.4 + .6 * _armour)), _atk = (_mode == "hits") ? round(_pts * .14) : 0;
	var _ab = ability_effects([]);
	return {
		name : "training dummy", col : rgb(190, 175, 150), kind : "dummy", lv : _lv, boss : false, worn : [], variant : "",
		team : 1, k : 0,
		maxhp_real : _hp, maxhp : _hp, hpmax : _hp, hp : _hp,
		maxmp : 0, mp : 0,
		atk : _atk, def : _def, mag : 0, mdef : _def, spd : (_mode == "hits") ? round(_pts * .06) : 1, hit : (_mode == "hits") ? round(_pts * .10) : 0,
		eva : 0,
		crit_rate : 0, crit_multi : 1.5, cnt : 0, erode : 0, luck : 0,
		magic : false, skills : [],
		tic : random(.3), tic_spd : _b.tic_spd_base + ((_mode == "hits") ? sqrt(max(0, _pts * .06)) / _b.tic_spd_div : 0),
		pts_total : 0,
		dd : 0, dt : 0, cc : 0,
		res : { fire : 0, water : 0, nature : 0 }, elem : "", school : "",
		ail_k : "", ail_c : 0, tags : [], ab : _ab, abil : [], undying_used : false,
		ail : { poison : 0, slow : 0, leech : 0 }, bf : { atk : 0, def : 0, hit : 0, spd : 0 }, nf : { atk : 0, def : 0, hit : 0 }, regen : 0, leecher : undefined,
		still : (_mode != "hits"),
	};
}
